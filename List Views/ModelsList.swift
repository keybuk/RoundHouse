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
}

struct ModelsList: View {
    var classification: Model.Classification?
    @SceneStorage("ModelsList.grouping") var grouping = ModelGroupingState()

    var body: some View {
        List {
            switch grouping[classification] {
            case .modelClass:
                ModelsByClass(classification: classification)
            case .era:
                ModelsByEra(classification: classification)
            case .livery:
                ModelsByLivery(classification: classification)
            }
        }
        .listStyle(.plain)
        .navigationTitle(classification?.pluralDescription ?? "Models")
        .toolbar {
            ToolbarItem(placement: .principal) {
                ModelGroupingPicker(grouping: $grouping[classification])
#if os(iOS)
                    .padding([.leading, .trailing])
#endif
            }
        }
        .frame(minWidth: 250)
    }
}

struct ModelsByClass: View {
    @SectionedFetchRequest
    var models: SectionedFetchResults<String, Model>

    init(classification: Model.Classification? = nil) {
        _models = SectionedFetchRequest(
            sectionIdentifier: \Model.classTitle,
            sortDescriptors: Model.classSortDescriptors + [
                SortDescriptor(\Model.number),
                SortDescriptor(\Model.name),
                SortDescriptor(\Model.dispositionRawValue)
            ],
            predicate: classification.map { Model.predicateForClassification($0) },
            animation: .default)
    }

    var body: some View {
        ForEach(models) { section in
            Section(header: Text(section.id)) {
                ForEach(section) { model in
                    ModelCell(model: model)
                }
            }
        }
#if os(macOS)
        .navigationSubtitle("\(models.recordCount) Models")
#endif
    }
}

struct ModelsByEra: View {
    @SectionedFetchRequest
    var models: SectionedFetchResults<Int16, Model>

    init(classification: Model.Classification? = nil) {
        _models = SectionedFetchRequest(
            sectionIdentifier: \Model.eraRawValue,
            sortDescriptors: [
                SortDescriptor(\Model.eraRawValue),
                SortDescriptor(\Model.modelClass),
                SortDescriptor(\Model.number),
                SortDescriptor(\Model.name),
                SortDescriptor(\Model.dispositionRawValue)
            ],
            predicate: classification.map { Model.predicateForClassification($0) },
            animation: .default)
    }

    var body: some View {
        ForEach(models) { section in
            Section(header: Text(Model.Era(rawValue: section.id)?.description ?? "")) {
                ForEach(section) { model in
                    ModelCell(model: model, showClass: true)
                }
            }
        }
#if os(macOS)
        .navigationSubtitle("\(models.recordCount) Models")
#endif
    }
}

struct ModelsByLivery: View {
    @SectionedFetchRequest
    var models: SectionedFetchResults<String?, Model>

    init(classification: Model.Classification? = nil) {
        _models = SectionedFetchRequest(
            sectionIdentifier: \Model.livery,
            sortDescriptors: [
                SortDescriptor(\Model.livery),
                SortDescriptor(\Model.modelClass),
                SortDescriptor(\Model.number),
                SortDescriptor(\Model.name),
                SortDescriptor(\Model.dispositionRawValue)
            ],
            predicate: classification.map { Model.predicateForClassification($0) },
            animation: .default)
    }

    var body: some View {
        ForEach(models) { section in
            Section(header: Text(section.id!)) {
                ForEach(section) { model in
                    ModelCell(model: model, showClass: true)
                }
            }
        }
#if os(macOS)
        .navigationSubtitle("\(models.recordCount) Models")
#endif
    }
}

struct ModelsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ModelsList()
                .environment(\.managedObjectContext, PreviewData.shared.viewContext)
        }
    }
}
