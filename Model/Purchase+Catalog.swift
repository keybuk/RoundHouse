//
//  Purchase+Catalog.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 2/1/20.
//

import Foundation
import Algorithms

extension Purchase {
    /// Returns the common catalog number prefix for a catalog number.
    ///
    /// Most model railway manufacturers use a system where common models differing only in running
    /// numbers, or sometimes liveries, share a common catalog number prefix. For Hornby and
    /// Bachmann for example, *R1000*, *R1000A*, and *R1000B* are all variations of the same
    /// original model.
    ///
    /// - Parameter catalogNumber: full catalog number.
    /// - Returns: `catalogNumber` or the common prefix equivalent, which is always shorter.
    static func makeCatalogNumberPrefix(from catalogNumber: String) -> String {
        let parts = catalogNumber.chunked(by: {
            ($0.isWhitespace && $1.isWhitespace)
                || ($0.isLetter && $1.isLetter)
                || ($0.isNumber && $1.isNumber)
                || ($0.isPunctuation && $1.isPunctuation)
        })

        if let lastDash = parts.lastIndex(of: "-") {
            if lastDash != parts.firstIndex(of: "-") {
                // Dapol, Hattons, etc. with more than one dash, remove everything past the last dash.
                return parts[...lastDash].joined()
            } else if parts.count > 0 && parts[0].count > 2 && parts[0].first!.isNumber {
                // Special case for Realtrack, the first part is a number sequence longer than two.
                return parts[...lastDash].joined()
            }
        }

        // Hornby, Bachmann, final-letter style.
        if parts.count > 1 && parts.last!.first!.isLetter {
            return parts.dropLast().joined()
        }

        // Oxford Diecast style; number, letter, long number. Shrink long number to three digits.
        if parts.count == 3 && parts[0].first!.isNumber && parts[1].first!.isLetter && parts[2].first!.isNumber && parts[2].count > 3 {
            return (parts[..<2] + parts[2...].map { $0.prefix(3) }).joined()
        }

        return parts.joined()
    }
    
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
    static let catalogSortDescriptors: [SortDescriptor<Purchase>] = [
        SortDescriptor(\.manufacturer),
        SortDescriptor(\.catalogNumber),
    ]
}
