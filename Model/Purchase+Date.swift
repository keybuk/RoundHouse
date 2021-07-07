//
//  Purchase+Date.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import Foundation
import CoreData

extension Purchase {
    /// `dateComponents` as `Date` in current time zone.
    public var date: Date? {
        get { dateComponents.flatMap { Calendar.current.date(from: $0) } }
        set {
            dateComponents = newValue.map {
                Calendar.current.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }

    /// Returns a date value suitable for grouping purchaes into months.
    ///
    /// - Parameter dateComponents: components of date.
    /// - Returns: a `Date` equivalent to UTC midnight on the first day of the month in`dateComponents` or
    /// `.distantPast` when `dateComponents` is `nil`.
    static func makeDateForGrouping(from dateComponents: DateComponents?) -> Date {
        guard var dateComponents = dateComponents else { return .distantPast }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        dateComponents.day = 1
        return calendar.date(from: dateComponents)!
    }

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
