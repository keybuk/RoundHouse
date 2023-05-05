//
//  PurchaseMigrationPolicy.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 9/5/21.
//

import Foundation
import CoreData

final class PurchaseMigrationPolicy: DefaultMigrationPolicy {
    override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createRelationships(forDestination: dInstance, in: mapping, manager: manager)

        // Reindex models and accessories since they're split into seperate tables.
        let modelObjectIDs = dInstance.objectIDs(forRelationshipNamed: "models")
        var modelObjects = modelObjectIDs.map { manager.destinationContext.object(with: $0) }
        modelObjects.sort {
            ($0.value(forKey: "index") as! Int16) < ($1.value(forKey: "index") as! Int16)
        }
        
        for (enumeratedIndex, modelObject) in modelObjects.enumerated() {
            modelObject.setValue(Int16(enumeratedIndex), forKey: "index")
        }
        
        dInstance.setValue(modelObjects.count - 1, forKey: "maxModelIndex")
        
        // Accessories
        let accessoryObjectIDs = dInstance.objectIDs(forRelationshipNamed: "accessories")
        var accessoryObjects = accessoryObjectIDs.map { manager.destinationContext.object(with: $0) }
        accessoryObjects.sort {
            ($0.value(forKey: "index") as! Int16) < ($1.value(forKey: "index") as! Int16)
        }
        
        for (enumeratedIndex, accessoryObject) in accessoryObjects.enumerated() {
            accessoryObject.setValue(Int16(enumeratedIndex), forKey: "index")
        }
        
        dInstance.setValue(accessoryObjects.count - 1, forKey: "maxAccessoryIndex")
    }
}
