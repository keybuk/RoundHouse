//
//  Decoder+Date.swift
//  Decoder+Date
//
//  Created by Scott James Remnant on 9/3/21.
//

import Foundation

extension Decoder {
    /// `firmwareDateComponents` as `Date` in current time zone.
    @objc
    var firmwareDate: Date? {
        get { firmwareDateComponents.flatMap { Calendar.current.date(from: $0) } }
        set {
            firmwareDateComponents = newValue.map {
                Calendar.current.dateComponents([ .year, .month, .day ], from: $0)
            }
        }
    }
}
