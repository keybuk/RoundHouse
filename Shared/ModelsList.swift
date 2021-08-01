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

extension SectionedFetchResults {
    var recordCount: Int { reduce(0, { $0 + $1.count }) }
}

struct ModelsList: View {
    var classification: Model.Classification?
    @State var grouping: Model.Grouping = .modelClass

    var body: some View {
        List {
            ModelGroupingPicker(grouping: $grouping)
                .padding([ .leading, .trailing ])
                #if !os(macOS)
                .listRowSeparator(.hidden)
                #endif

            switch grouping {
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
        .frame(minWidth: 250)
    }
}

private extension SectionedFetchResults.Section where Element == Model, SectionIdentifier == String? {
    var title: String {
        let modelClass = id!
        let wheelArrangements = Set(map({ $0.wheelArrangement! }))

        if wheelArrangements.count != 1 {
            return modelClass
        } else {
            return [ modelClass, wheelArrangements.first! ]
                .filter({ !$0.isEmpty })
                .joined(separator: " ")
        }
    }
}

struct ModelsByClass: View {
    @SectionedFetchRequest
    var models: SectionedFetchResults<String?, Model>

    init(classification: Model.Classification? = nil) {
        _models = SectionedFetchRequest(
            sectionIdentifier: \Model.modelClass,
            sortDescriptors: [
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
            Section(header: Text(section.title)) {
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
