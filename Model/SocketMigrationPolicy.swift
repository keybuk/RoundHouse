//
//  SocketMigrationPolicy.swift
//  SocketMigrationPolicy
//
//  Created by Scott James Remnant on 9/5/21.
//

import Foundation
import CoreData

final class SocketMigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        guard let title = sInstance.value(forKey: "socket") as! String?, !title.isEmpty else { preconditionFailure("empty or nil socket in source instance") }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: mapping.destinationEntityName!)
        fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        
        let results = try manager.destinationContext.fetch(fetchRequest)
        if let dInstance = results.first {
            manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
        } else {
            try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
        }
    }
    
    override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        // Nothing to do, the source mapping will take care of fixing the relationships since
        // that the correct destination instances.
    }
    
    /// Extracts the number of pins from a socket name.
    /// - Parameter title: socket title.
    /// - Returns: the value of the first integer component of the string.
    @objc
    func numberOfPins(_ title: String?) -> NSNumber {
        let pinCount = title?.split(whereSeparator: { !$0.isNumber })
            .first
            .flatMap { Int($0) }
        return NSNumber(integerLiteral: pinCount ?? 0)
    }
}
