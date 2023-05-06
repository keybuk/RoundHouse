//
//  Purchase+Date.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import Foundation
import CoreData

extension Purchase {
    /// `Date` equivalent to UTC midnight on the first day of the month in`date` or
    /// `.distantPast` when `date` is `nil`.
    @objc
    var month: Date {
        guard let date = date else { return .distantPast }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!

        var dateComponents = calendar.dateComponents([ .year, .month ], from: date)
        dateComponents.day = 1

        return calendar.date(from: dateComponents)!
    }
}
