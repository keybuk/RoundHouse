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
        // .accessory is moved from 7 to 9, so .vehicle is unchanged
        case 7: return NSNumber(integerLiteral: 9)
        case 8: return oldClassification
        // .steamLocomotive is moved to 2.
        case 9: return NSNumber(integerLiteral: 2)
        default: return NSNumber(integerLiteral: 0)
        }
    }
}
