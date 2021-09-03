//
//  Model+Date.swift
//  Model+Date
//
//  Created by Scott James Remnant on 9/3/21.
//

import Foundation

extension Model {
    /// `lastRunDateComponents` as `Date` in current time zone.
    @objc
    var lastRunDate: Date? {
        get { lastRunDateComponents.flatMap { Calendar.current.date(from: $0) } }
        set {
            lastRunDateComponents = newValue.map {
                Calendar.current.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }

    /// `lastOilDateComponents` as `Date` in current time zone.
    @objc
    var lastOilDate: Date? {
        get { lastOilDateComponents.flatMap { Calendar.current.date(from: $0) } }
        set {
            lastOilDateComponents = newValue.map {
                Calendar.current.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }
}
