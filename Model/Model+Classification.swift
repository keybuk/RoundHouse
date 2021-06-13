//
//  Model+Classification.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 12/12/17.
//

import Foundation

extension Model {
    enum Classification: Int16, CaseIterable {
        case dieselElectricLocomotive = 1
        case steamLocomotive
        case coach
        case wagon
        case multipleUnit
        case departmental
        case noPrototype
        case vehicle
    }

    var classification: Classification? {
        get { Classification(rawValue: classificationRawValue) }
        set { classificationRawValue = newValue?.rawValue ?? 0 }
    }
}

extension Model.Classification: CustomStringConvertible {
    var description: String {
        switch self {
        case .dieselElectricLocomotive: return "Diesel or Electric Locomotive"
        case .steamLocomotive: return "Steam Locomotive"
        case .coach: return "Coach"
        case .wagon: return "Wagon"
        case .multipleUnit: return "Multiple Unit"
        case .departmental: return "Departmental"
        case .noPrototype: return "No Prototype"
        case .vehicle: return "Vehicle"
        }
    }
}
