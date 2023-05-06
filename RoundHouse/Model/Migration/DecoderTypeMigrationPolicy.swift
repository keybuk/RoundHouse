//
//  DecoderTypeMigrationPolicy.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 9/5/21.
//

import Foundation
import CoreData

final class DecoderTypeMigrationPolicy: DefaultMigrationPolicy {
    override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createRelationships(forDestination: dInstance, in: mapping, manager: manager)

        // Populated "willSave" fields" that are based on relationships.
        let fetchRequest = DecoderType.fetchRequestForRemainingStock(decoderType: dInstance)
        let results = try manager.destinationContext.fetch(fetchRequest)
        let remainingStock = results.first?.intValue ?? 0
        dInstance.setValue(remainingStock, forKey: "remainingStock")
    }
}
