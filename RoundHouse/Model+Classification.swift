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
        case coach
        case wagon
        case multipleUnit
        case departmental
        case noPrototype
        case accessory
        case vehicle
        case steamLocomotive
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
        case .coach: return "Coach"
        case .wagon: return "Wagon"
        case .multipleUnit: return "Multiple Unit"
        case .departmental: return "Departmental"
        case .noPrototype: return "No Prototype"
        case .accessory: return "Accessory"
        case .vehicle: return "Vehicle"
        case .steamLocomotive: return "Steam Locomotive"
        }
    }

    var pluralDescription: String {
        switch self {
        case .dieselElectricLocomotive: return "Diesel and Electric Locomotives"
        case .coach: return "Coaches"
        case .wagon: return "Wagons"
        case .multipleUnit: return "Multiple Units"
        case .departmental: return "Departmentals"
        case .noPrototype: return "No Prototype"
        case .accessory: return "Accessory"
        case .vehicle: return "Vehicles"
        case .steamLocomotive: return "Steam Locomotives"
        }
    }
}
