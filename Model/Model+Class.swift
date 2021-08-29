//
//  Model+Class.swift
//  Model+Class
//
//  Created by Scott James Remnant on 8/27/21.
//

import Foundation

extension Model {
    /// Full title of the model's class.
    ///
    /// Combines `modelClass` and `wheelArrangement` or `vehicleType`.
    @objc
    var classTitle: String {
        [ modelClass!, wheelArrangement!, vehicleType! ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Standard sort descriptors for sorting models by class.
    ///
    /// Also may be used if grouping by `classTitle`.
    static let classSortDescriptors: [SortDescriptor<Model>] = [
        SortDescriptor(\.modelClass),
        SortDescriptor(\.wheelArrangement),
        SortDescriptor(\.vehicleType)
    ]
}
