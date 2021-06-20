//
//  RoundHousePurchaseMigrationPolicy.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/12/21.
//

import Foundation
import CoreData
import SwiftUI

final class RoundHouseMigrationPolicy: NSEntityMigrationPolicy {
    /// Converts locale identifiers in the old scheme to currency codes in the new.
    /// - Parameter identifier: locale identifier.
    /// - Returns: currency code identifier.
    @objc
    func currencyCodeForLocaleIdentifier(_ identifier: String?) -> String? {
        identifier.flatMap { Locale(identifier: $0).currencyCode }
    }

    /// Converts nil strings to empty strings.
    /// - Parameter string: string in source instance.
    /// - Returns: `string` or "" when `string` is `nil`.
    @objc
    func nilToEmptyString(_ string: String?) -> String? {
        string ?? ""
    }

    /// Renumbers classification raw values to match enum.
    /// - Parameter classificationRawValue: raw value in source instance.
    /// - Returns: raw value for destination instance.
    @objc
    func renumberedClassification(_ oldClassification: NSNumber) -> NSNumber {
        switch oldClassification.int16Value {
        case 1: return oldClassification
        // Make room for .steamLocomotive at 2
        case 2...6: return NSNumber(value: oldClassification.int16Value + 1)
        // .accessory is removed from 7, so .vehicle is unchanged
        case 8: return oldClassification
        // .steamLocomotive is moved to 2.
        case 9: return NSNumber(integerLiteral: 2)
        default: return NSNumber(integerLiteral: 2)
        }
    }

    private func accessoryCatalogSplit(_ modelClass: String) -> (String, String) {
        let components = modelClass.components(separatedBy: .whitespaces)
        guard components.count > 2 else { return ("", modelClass) }
        guard let _ = components[0].rangeOfCharacter(from: .decimalDigits) else { return ("", modelClass) }
        guard !components[0].hasSuffix("ft") else { return ("", modelClass) }

        let catalogDescription = modelClass
            .dropFirst(components[0].count)
            .drop(while: \.isWhitespace)

        return (components[0], String(catalogDescription))

    }

    /// Extracts the accessory catalog number from a model class.
    /// - Parameter modelClass: model class in source instance.
    /// - Returns: `modelClass` or the first component if it contains a catalog number.
    @objc
    func accessoryCatalogNumber(_ modelClass: String?) -> String {
        guard let modelClass = modelClass else { return "" }
        let (catalogNumber, _) = accessoryCatalogSplit(modelClass)
        return catalogNumber
    }

    /// Extracts the accessory catalog decription from a model class.
    /// - Parameter modelClass: model class in source instance.
    /// - Returns: `modelClass` or the following components if the first contains a catalog number.
    @objc
    func accessoryCatalogDescription(_ modelClass: String?) -> String {
        guard let modelClass = modelClass else { return "" }
        let (_, catalogDescription) = accessoryCatalogSplit(modelClass)
        return catalogDescription
    }

    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)

        // Migrate "socket" string field of Model and DecoderType to a new Socket table.
        if mapping.name == "ModelToModel" || mapping.name == "DecoderTypeToDecoderType" {
            guard let dInstance = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]).first else { preconditionFailure("Missing destination instance") }
            guard let title = sInstance.value(forKey: "socket") as! String?, !title.isEmpty else { return }

            let pinCount = title.components(separatedBy: .decimalDigits.inverted)
                .first { $0 != "" }
                .flatMap { Int16($0) }
            let numberOfPins = pinCount ?? 0

            var userInfo = manager.userInfo ?? ["sockets": [String: NSManagedObject]()]
            var sockets = userInfo["sockets"] as! [String: NSManagedObject]

            var socketInstance = sockets[title]
            if socketInstance == nil {
                socketInstance = NSEntityDescription.insertNewObject(forEntityName: Socket.entity().name!, into: manager.destinationContext)
                socketInstance!.setValue(title, forKey: "title")
                socketInstance!.setValue(numberOfPins, forKey: "numberOfPins")

                sockets[title] = socketInstance!
                userInfo["sockets"] = sockets
                manager.userInfo = userInfo
            }

            dInstance.setValue(socketInstance, forKey: "socket")
        }
    }

    override func createRelationships(forDestination dInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createRelationships(forDestination: dInstance, in: mapping, manager: manager)

        // Reindex models and accessories since they're split into seperate tables.
        if mapping.name == "PurchaseToPurchase" {
            // Models
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

}
