//
//  Model+Disposition.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 12/19/17.
//

import Foundation

extension Model {
    enum Disposition: Int16, CaseIterable {
        case normal = 1
        case collectorItem
        case spareParts
    }

    var disposition: Disposition? {
        get { Disposition(rawValue: dispositionRawValue) }
        set { dispositionRawValue = newValue?.rawValue ?? 0 }
    }
}

extension Model.Disposition: CustomStringConvertible {
    var description: String {
        switch self {
        case .normal: return "Normal"
        case .collectorItem: return "Collector Item"
        case .spareParts: return "Spare Parts"
        }
    }
}
