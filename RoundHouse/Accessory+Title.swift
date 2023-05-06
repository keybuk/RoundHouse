//
//  Accessory+Title.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/28/21.
//

import Foundation

extension Accessory {
    /// Full title of the accessory.
    ///
    /// Combines `manufacturer` and `catalogNumber`.
    @objc
    var title: String {
        return [ manufacturer!, catalogNumber! ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Sort descriptors for sorting or grouping accessories by `title`.
    static let titleSortDescriptors: [SortDescriptor<Accessory>] = [
        SortDescriptor(\.manufacturer),
        SortDescriptor(\.catalogNumber),
    ]
}
