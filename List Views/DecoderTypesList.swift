//
//  DecoderTypesList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import SwiftUI
import CoreData

struct DecoderTypesList: View {
    @SceneStorage("DecoderTypesList.grouping") var grouping: DecoderType.Grouping = .socket

    var body: some View {
        List {
            switch grouping {
            case .socket:
                DecoderTypesBySocket()
            case .family:
                DecoderTypesByFamily()
            case .catalog:
                DecoderTypesByCatalog()
            }
        }
        .listStyle(.plain)
        .navigationTitle("Decoders")
        .toolbar {
            ToolbarItem(placement: .principal) {
                DecoderTypeGroupingPicker(grouping: $grouping)
#if os(iOS)
                    .padding([.leading, .trailing])
#endif
            }
        }
        .frame(minWidth: 250)
    }
}

struct DecoderTypesBySocket: View {
    @SectionedFetchRequest(
        sectionIdentifier: \DecoderType.socket?,
        sortDescriptors: [
            SortDescriptor(\DecoderType.socket?.numberOfPins, order: .reverse),
            SortDescriptor(\DecoderType.socket?.title, order: .reverse),
            SortDescriptor(\DecoderType.minimumStock, order: .reverse),
            SortDescriptor(\DecoderType.remainingStock, order: .reverse),
            SortDescriptor(\DecoderType.manufacturer),
            SortDescriptor(\DecoderType.catalogNumber),
        ],
        animation: .default)
    var decoderTypes: SectionedFetchResults<Socket?, DecoderType>

    var body: some View {
        ForEach(decoderTypes) { section in
            Section(header: Text(section.id!.title!)) {
                ForEach(section) { decoderType in
                    DecoderTypeCell(decoderType: decoderType)
                }
            }
        }
#if os(macOS)
        .navigationSubtitle("\(decoderTypes.recordCount) Types")
#endif
    }
}

struct DecoderTypesByFamily: View {
    @SectionedFetchRequest(
        sectionIdentifier: \DecoderType.catalogFamilyTitle,
        sortDescriptors: DecoderType.catalogFamilySortDescriptors + [
            SortDescriptor(\DecoderType.socket?.numberOfPins, order: .reverse),
            SortDescriptor(\DecoderType.catalogNumber),
        ],
        animation: .default)
    var decoderTypes: SectionedFetchResults<String, DecoderType>

    var body: some View {
        ForEach(decoderTypes) { section in
            Section(header: Text(section.id)) {
                ForEach(section) { decoderType in
                    DecoderTypeCell(decoderType: decoderType, showManufacturer: false, showSocket: true)
                }
            }
        }
#if os(macOS)
        .navigationSubtitle("\(decoderTypes.recordCount) Types")
#endif
    }
}

struct DecoderTypesByCatalog: View {
    @SectionedFetchRequest(
        sectionIdentifier: \DecoderType.manufacturer,
        sortDescriptors: DecoderType.catalogSortDescriptors,
        animation: .default)
    var decoderTypes: SectionedFetchResults<String?, DecoderType>

    var body: some View {
        ForEach(decoderTypes) { section in
            Section(header: Text(section.id!)) {
                ForEach(section) { decoderType in
                    DecoderTypeCell(decoderType: decoderType, showManufacturer: false, showSocket: true)
                }
            }
        }
#if os(macOS)
        .navigationSubtitle("\(decoderTypes.recordCount) Types")
#endif
    }
}

struct DecoderTypesList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DecoderTypesList()
                .environment(\.managedObjectContext, PreviewData.shared.viewContext)
        }
    }
}
