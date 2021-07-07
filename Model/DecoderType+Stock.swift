//
//  DecoderType+Stock.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 3/5/19.
//

import Foundation
import CoreData

extension DecoderType {
    /// Returns `true` if this type of decoder is currently or typically stocked.
    public var isStocked: Bool { minimumStock > 0 || remainingStock > 0 }

    /// Returns `true` if `remainingStock` falls below `minimumStock`.
    public var isStockLow: Bool { minimumStock > 0 && remainingStock < minimumStock }

    /// Returns the number of spare decoders in stock.
    func makeRemainingStock() -> Int16 {
        guard let managedObjectContext = managedObjectContext else { return 0 }
        
        let fetchRequest = Self.fetchRequestForRemainingStock(decoderType: self)

        var count = 0
        try? managedObjectContext.performAndWait {
            let results = try managedObjectContext.fetch(fetchRequest)
            count = results.first?.intValue ?? 0
        }

        return Int16(clamping: count)
    }
    
    /// Returns an `NSFetchRequest` to count the number of spare decoders in stock.
    /// - Parameter decoderType: `DecoderType` to count spare decoders for.
    /// - Returns: `NSFetchRequest` with a `.resultType` or `.countResultType`.
    static func fetchRequestForRemainingStock(decoderType: NSManagedObject) -> NSFetchRequest<NSNumber> {
        let fetchRequest: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: Decoder.entity().name!)
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "type = %@", decoderType),
            NSPredicate(format: "model = nil"),
            NSPredicate(format: "soundAuthor = ''"),
            NSPredicate(format: "soundProject = ''"),
            NSPredicate(format: "soundProjectVersion = ''"),
            NSPredicate(format: "soundSettings = ''"),
        ])
        
        return fetchRequest
    }
}
