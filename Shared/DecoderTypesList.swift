//
//  DecoderTypesList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import SwiftUI
import CoreData

struct DecoderTypesList: View {
    @State var grouping: DecoderType.Grouping = .socket

    var body: some View {
        List {
            switch grouping {
            case .socket:
                DecoderTypesBySocket()
            case .catalog:
                DecoderTypesByCatalog()
            }
        }
        .listStyle(.plain)
        .navigationTitle("Decoders")
        .toolbar {
            ToolbarItem(placement: .principal) {
                DecoderTypeGroupingPicker(grouping: $grouping)
            }
        }
        .frame(minWidth: 250)
    }
}

private extension SectionedFetchResults.Section where Element == DecoderType, SectionIdentifier == Socket? {
    var title: String {
        let socket = id!
        return socket.title ?? ""
    }
}

struct DecoderTypesBySocket: View {
    @SectionedFetchRequest(
        // BUG(FB9194735) We can't just use \.socket yet
        sectionIdentifier: \DecoderType.socket,
        sortDescriptors: [
            SortDescriptor(\DecoderType.socket?.title, order: .reverse),
            SortDescriptor(\DecoderType.socket?.numberOfPins, order: .reverse),
            SortDescriptor(\DecoderType.minimumStock, order: .reverse),
            SortDescriptor(\DecoderType.remainingStock, order: .reverse),
            SortDescriptor(\DecoderType.manufacturer),
            SortDescriptor(\DecoderType.catalogNumber),
        ],
        animation: .default)
    var decoderTypes: SectionedFetchResults<Socket?, DecoderType>

    var body: some View {
        ForEach(decoderTypes) { section in
            Section(header: Text(section.title)) {
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

struct DecoderTypesByCatalog: View {
    @SectionedFetchRequest(
        sectionIdentifier: \DecoderType.manufacturer,
        sortDescriptors: [
            SortDescriptor(\DecoderType.manufacturer),
            SortDescriptor(\DecoderType.catalogNumber),
        ],
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
        DecoderTypesList()
            .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
