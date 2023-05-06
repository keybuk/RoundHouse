//
//  DecoderType+Catalog.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/27/21.
//

import Foundation

extension DecoderType {
    /// Full title of the decoder type.
    ///
    /// Combines `manufacturer` and `catalogNumber`.
    @objc
    var title: String {
        return [ manufacturer!, catalogNumber! ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Sort descriptors for sorting or grouping decoder types by `title`.
    static let titleSortDescriptors: [SortDescriptor<DecoderType>] = [
        SortDescriptor(\.manufacturer),
        SortDescriptor(\.catalogNumber)
    ]

    /// Full title of the decoder type's family.
    ///
    /// Combines `manufacturer` and `catalogFamily`.
    @objc
    var family: String {
        return [ manufacturer!, catalogFamily! ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Sort descriptors for sorting or grouping decoder types by `family`.
    static let familySortDescriptors: [SortDescriptor<DecoderType>] = [
        SortDescriptor(\.manufacturer),
        SortDescriptor(\.catalogFamily)
    ]

}
