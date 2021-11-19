//
//  NSManagedObject+Suggestions.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 9/6/21.
//

import Foundation
import CoreData

extension NSManagedObject {
    func suggestionsFor(key: String, matching text: String, and predicate: NSPredicate? = nil) -> [String] {
        guard let context = managedObjectContext else { preconditionFailure("Missing managed object context")}
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Self.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = [ key ]
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: key, ascending: true) ]
        
        let predicates = text
            .split(whereSeparator: \.isWhitespace)
            .map { NSPredicate(format: "\(key) CONTAINS[cd] %@", String($0)) }
        if let predicate = predicate {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates + [predicate])
        } else {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        do {
            let results = try context.fetch(fetchRequest) as! [[String: String]]
            return results.map({ $0[key]! })
        } catch {
            print("Fetch error \(error.localizedDescription)")
            return []
        }
    }
}
