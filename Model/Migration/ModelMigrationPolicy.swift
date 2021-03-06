//
//  ModelMigrationPolicy.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 9/5/21.
//

import Foundation
import CoreData

final class ModelMigrationPolicy: DefaultMigrationPolicy {
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
        let components = modelClass.split(whereSeparator: \.isWhitespace)
        guard components.count > 2 else { return ("", modelClass) }
        guard let _ = components[0].rangeOfCharacter(from: .decimalDigits) else { return ("", modelClass) }
        guard !components[0].hasSuffix("ft") else { return ("", modelClass) }

        let catalogDescription = modelClass
            .dropFirst(components[0].count)
            .drop(while: \.isWhitespace)

        return (String(components[0]), String(catalogDescription))
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
}
