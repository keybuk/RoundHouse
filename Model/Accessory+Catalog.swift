//
//  Accessory+Catalog.swift
//  Accessory+Catalog
//
//  Created by Scott James Remnant on 8/28/21.
//

import Foundation

extension Accessory {
    /// Combined accessory `manufacturer` and `catalogNumber`.
    @objc
    var catalogTitle: String {
        return [ manufacturer!, catalogNumber! ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Standard sort descriptors for sorting accessories by catalog entry.
    ///
    /// Also may be used if grouping by `catalogTitle`.
    static let catalogSortDescriptors: [SortDescriptor<Accessory>] = [
        SortDescriptor(\.manufacturer),
        SortDescriptor(\.catalogNumber),
    ]
}
