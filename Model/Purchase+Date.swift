//
//  Purchase+Date.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import Foundation
import CoreData

extension Purchase {
    /// Returns a date value suitable for sorting purchaes.
    ///
    /// - Parameter dateComponents: components of date.
    /// - Returns: a `Date` equivalent to UTC midnight on `dateComponents` or `.distantPast` when
    /// `dateComponents` is `nil`.
    static func makeDateForSort(from dateComponents: DateComponents?) -> Date {
        guard let dateComponents = dateComponents else { return .distantPast }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        return calendar.date(from: dateComponents)!
    }
}
