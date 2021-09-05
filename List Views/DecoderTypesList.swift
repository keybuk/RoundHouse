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
        // BUG(FB9194735) We can't just use \.socket yet
        sectionIdentifier: \DecoderType.socket?.objectID,
        sortDescriptors: [
            SortDescriptor(\DecoderType.socket?.numberOfPins, order: .reverse),
            SortDescriptor(\DecoderType.socket?.title, order: .reverse),
            SortDescriptor(\DecoderType.minimumStock, order: .reverse),
            SortDescriptor(\DecoderType.remainingStock, order: .reverse),
            SortDescriptor(\DecoderType.manufacturer),
            SortDescriptor(\DecoderType.catalogNumber),
        ],
        animation: .default)
    var decoderTypes: SectionedFetchResults<NSManagedObjectID?, DecoderType>

    @Environment(\.managedObjectContext) var viewContext
    func socket(with objectID: NSManagedObjectID) -> Socket {
        viewContext.object(with: objectID) as! Socket
    }

    var body: some View {
        ForEach(decoderTypes) { section in
            Section(header: Text(socket(with: section.id!).title!)) {
                ForEach(section) { decoderType in
                    NavigationLink {
                        DecoderTypeView(decoderType: decoderType)
                    } label: {
                        DecoderTypeCell(decoderType: decoderType)
                    }
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
                    NavigationLink {
                        DecoderTypeView(decoderType: decoderType)
                    } label: {
                        DecoderTypeCell(decoderType: decoderType, showManufacturer: false, showSocket: true)
                    }
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
                    NavigationLink {
                        DecoderTypeView(decoderType: decoderType)
                    } label: {
                        DecoderTypeCell(decoderType: decoderType, showManufacturer: false, showSocket: true)
                    }
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
