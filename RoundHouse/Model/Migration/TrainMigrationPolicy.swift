//
//  TrainMigrationPolicy.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 5/5/23.
//

import Foundation
import CoreData

final class TrainMigrationPolicy: DefaultMigrationPolicy {
    override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createRelationships(forDestination: dInstance, in: mapping, manager: manager)

        // Reindex train members.
        let memberObjectIDs = dInstance.objectIDs(forRelationshipNamed: "members")
        var memberObjects = memberObjectIDs.map { manager.destinationContext.object(with: $0) }
        memberObjects.sort {
            ($0.value(forKey: "index") as! Int16) < ($1.value(forKey: "index") as! Int16)
        }

        for (enumeratedIndex, memberObject) in memberObjects.enumerated() {
            memberObject.setValue(Int16(enumeratedIndex), forKey: "index")
        }

        dInstance.setValue(memberObjects.count - 1, forKey: "maxMemberIndex")
    }
}
