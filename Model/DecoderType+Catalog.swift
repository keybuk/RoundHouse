//
//  DecoderType+Catalog.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/27/21.
//

import Foundation

extension DecoderType {
    /// Combined decoder type `manufacturer` and `catalogNumber`.
    @objc
    var catalogTitle: String {
        return [ manufacturer!, catalogNumber! ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Standard sort descriptors for sorting decoder types by catalog entry.
    ///
    /// Also may be used if grouping by `catalogTitle`.
    static let catalogSortDescriptors: [SortDescriptor<DecoderType>] = [
        SortDescriptor(\.manufacturer),
        SortDescriptor(\.catalogNumber)
    ]

    /// Combined decoder type `manufacturer` and `catalogFamily`.
    @objc
    var catalogFamilyTitle: String {
        return [ manufacturer!, catalogFamily! ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Standard sort descriptors for sorting decoder types by catalog family.
    ///
    /// Also may be used if grouping by `catalogFamilyTitle`.
    static let catalogFamilySortDescriptors: [SortDescriptor<DecoderType>] = [
        SortDescriptor(\.manufacturer),
        SortDescriptor(\.catalogFamily)
    ]
}
