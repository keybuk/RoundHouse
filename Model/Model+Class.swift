//
//  Model+Class.swift
//  Model+Class
//
//  Created by Scott James Remnant on 8/27/21.
//

import Foundation

extension Model {
    @objc
    var classTitle: String {
        [ modelClass!, wheelArrangement!, vehicleType! ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    static let classSortDescriptors: [SortDescriptor<Model>] = [
        SortDescriptor(\.modelClass),
        SortDescriptor(\.wheelArrangement),
        SortDescriptor(\.vehicleType)
    ]
}
