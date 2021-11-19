//
//  DecoderType+Suggestions.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 9/6/21.
//

import Foundation

extension DecoderType {
    func suggestionsForManufacturer(matching text: String) -> [String] {
        suggestionsFor(key: "manufacturer", matching: text)
    }

    func suggestionsForCatalogFamily(matching text: String) -> [String] {
        suggestionsFor(key: "catalogFamily", matching: text,
                       and: NSPredicate(format: "manufacturer = %@", manufacturer!))
    }
}
