//
//  Model+Title.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/27/21.
//

import Foundation

extension Model {
    /// Full title of the model.
    ///
    /// Combines `modelClass` and `wheelArrangement` or `vehicleType`.
    @objc
    var title: String {
        [ modelClass!, wheelArrangement!, vehicleType! ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Sort descriptors for sorting or grouping models by `title`.
    static let titleSortDescriptors: [SortDescriptor<Model>] = [
        SortDescriptor(\.modelClass),
        SortDescriptor(\.wheelArrangement),
        SortDescriptor(\.vehicleType)
    ]
}
