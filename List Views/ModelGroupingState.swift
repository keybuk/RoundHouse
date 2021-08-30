//
//  ModelGroupingState.swift
//  ModelGroupingState
//
//  Created by Scott James Remnant on 8/29/21.
//

import Foundation

/// Provides scene storage for the grouping state of all `ModelsList` views by `Model.Classification`.
struct ModelGroupingState: RawRepresentable, Equatable, Hashable {
    var groupings: [Model.Classification: Model.Grouping]
    let defaultValue: Model.Grouping = .modelClass

    init?(rawValue: String) {
        groupings = Dictionary(uniqueKeysWithValues: rawValue
                                .split(separator: ",")
                                .compactMap {
            let components = $0.split(separator: "=", maxSplits: 1)
            if components.count == 2,
               let classificationRawValue = Int16(components[0]),
               let classification = Model.Classification(rawValue: classificationRawValue),
               let grouping = Model.Grouping(rawValue: String(components[1])) {
                return (classification, grouping)
            } else {
                return nil
            }
        })
    }

    init() {
        groupings = [:]
    }

    var rawValue: String {
        groupings
            .map {"\($0.rawValue)=\($1.rawValue)"}
            .joined(separator: ",")
    }

    subscript(_ classification: Model.Classification?) -> Model.Grouping {
        get {
            guard let classification = classification else { return defaultValue }
            return groupings[classification, default: defaultValue]
        }
        set {
            guard let classification = classification else { return }
            groupings[classification] = newValue
        }
    }
}
