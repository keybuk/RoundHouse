//
//  DefaultMigrationPolicy.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/12/21.
//

import Foundation
import CoreData

class DefaultMigrationPolicy: NSEntityMigrationPolicy {
    /// Converts nil strings to empty strings.
    /// - Parameter string: string in source instance.
    /// - Returns: `string` or "" when `string` is `nil`.
    @objc
    func nilToEmptyString(_ string: String?) -> String? {
        string ?? ""
    }
}
