//
//  DecoderType+Catalog.swift
//  DecoderType+Catalog
//
//  Created by Scott James Remnant on 8/27/21.
//

import Foundation

extension DecoderType {
    private var catalogGroup: String {
        if !catalogFamily!.isEmpty {
            return catalogFamily!
        } else {
            return catalogName!
        }
    }

    @objc
    var catalogTitle: String {
        return [ manufacturer!, catalogGroup ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    static let catalogSortDescriptors: [SortDescriptor<DecoderType>] = [
        SortDescriptor(\.manufacturer),
        SortDescriptor(\.catalogFamily),
        SortDescriptor(\.catalogName)
    ]
}
