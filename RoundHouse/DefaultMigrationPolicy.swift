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

    /// Converts DateComponents-stored values to Date.
    /// - Parameter dateComponents: date components in source instance.
    /// - Returns: Date equivalent or `nil` when `dateComponents` is `nil`.
    @objc
    func dateComponentsToDate(_ dateComponents: DateComponents?) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        return dateComponents.flatMap { calendar.date(from: $0) }
    }
}
