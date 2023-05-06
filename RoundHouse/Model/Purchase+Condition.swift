//
//  Purchase+Condition.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 12/12/17.
//

import Foundation

extension Purchase {
    enum Condition: Int16, CaseIterable {
        case new = 1
        case likeNew
        case used
        case usedInWrongBox
        case handmade
    }

    var condition: Condition? {
        get { Condition(rawValue: conditionRawValue) }
        set { conditionRawValue = newValue?.rawValue ?? 0 }
    }
}

extension Purchase.Condition: CustomStringConvertible {
    var description: String {
        switch self {
        case .new: return "New"
        case .likeNew: return "Like New"
        case .used: return "Used"
        case .usedInWrongBox: return "Used in Wrong Box"
        case .handmade: return "Handmade"
        }
    }
}
