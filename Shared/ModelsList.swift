//
//  ModelsList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/12/21.
//

import SwiftUI

extension Model {
    static func predicateForClassification(_ classification: Classification) -> NSPredicate {
        NSPredicate(format: "classificationRawValue == \(classification.rawValue)")
    }

    // This will end up being sectionIdentifierForGrouping
    static func sectionIdentifier() -> KeyPath<Model, String?> {
        \.modelClass
    }

    // This will end up being sortDescriptorsForGrouping
    static func sortDescriptors() -> [SortDescriptor<Model>] {
        [
            SortDescriptor(\.modelClass),
            SortDescriptor(\.number),
            SortDescriptor(\.name),
            SortDescriptor(\.dispositionRawValue)
        ]
    }
}

struct ModelsList: View {
    @Environment(\.managedObjectContext) var viewContext

    var classification: Model.Classification?

    @SectionedFetchRequest
    var models: SectionedFetchResults<String?, Model>

    init(classification: Model.Classification? = nil) {
        self.classification = classification

        _models = SectionedFetchRequest(
            sectionIdentifier: Model.sectionIdentifier(),
            sortDescriptors: Model.sortDescriptors(),
            predicate: classification.map { Model.predicateForClassification($0) },
            animation: .default)
    }

    var body: some View {
        List {
            ForEach(models) { section in
                Section(header: Text(section.id!)) {
                    ForEach(section) { model in
                        ModelCell(model: model)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(classification?.pluralDescription ?? "Models")
        #if os(macOS)
        .navigationSubtitle("\(models.reduce(0, { $0 + $1.count })) Models")
        #endif
        // BUG(FB9191598) Simulator will fail to build if the view ends at #endif
        .frame(minWidth: 250)
    }
}

struct ModelsList_Previews: PreviewProvider {
    static var previews: some View {
        ModelsList()
            .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
