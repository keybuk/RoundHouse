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
    @objc
    var date: Date? {
        get { dateComponents.flatMap { Calendar.current.date(from: $0) } }
        set {
            dateComponents = newValue.map {
                Calendar.current.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }

    /// `Date` equivalent to UTC midnight on the first day of the month in`dateComponents` or
    /// `.distantPast` when `dateComponents` is `nil`.
    @objc
    var purchaseMonth: Date {
        guard var dateComponents = dateComponents else { return .distantPast }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        dateComponents.day = 1
        return calendar.date(from: dateComponents)!
    }

    static let purchaseMonthSortDescriptors: [SortDescriptor<Purchase>] = [
        SortDescriptor(\Purchase.dateForSort, order: .reverse)
    ]

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
