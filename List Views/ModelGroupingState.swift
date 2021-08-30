//
//  ModelGroupingState.swift
//  ModelGroupingState
//
//  Created by Scott James Remnant on 8/29/21.
//

import Foundation

/// Provides scene storage for the grouping state of all `ModelsList` views by `Model.Classification`.
///
/// As a state value this provides a mapping from `Model.Classification` to `Model.Grouping` and a subscript operator
/// to change the values. This can be used through a binding:
///
///     grouping[.coach] = .livery
///     $grouping[.coach] // Binding<Model.Grouping>
///
/// `@SceneStorage` allows us to only store very simple types: `Bool`, `Int`, `Double`, `String`, and `URL`. But it also
/// allows `RawRepresentable` types with a `RawValue` or `Int` or `String`. This value conforms to the latter producing
/// a string value that can be persisted in the scene storage.
struct ModelGroupingState: RawRepresentable {
    let defaultValue: Model.Grouping = .modelClass
    var groupings: [Model.Classification: Model.Grouping]

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
