//
//  Purchase+Title.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 5/5/23.
//

import Foundation

extension Purchase {
    /// Full title of the purchase.
    ///
    /// Combines `manufacturer` and `catalogNumber`.
    @objc
    var title: String {
        return [ manufacturer!, catalogNumber! ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Sort descriptors for sorting or grouping purchases by `title`.
    static let titleSortDescriptors: [SortDescriptor<Purchase>] = [
        SortDescriptor(\.manufacturer),
        SortDescriptor(\.catalogNumber),
    ]
}

