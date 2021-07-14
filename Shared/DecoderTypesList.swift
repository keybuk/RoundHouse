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
            DecoderTypeGroupingPicker(grouping: $grouping)
                .padding([ .leading, .trailing ])
                #if !os(macOS)
                .listRowSeparator(.hidden)
                #endif

            switch grouping {
            case .socket:
                DecoderTypesBySocket()
            case .catalog:
                DecoderTypesByCatalog()
            }
        }
        .listStyle(.plain)
        .navigationTitle("Decoders")
        .frame(minWidth: 250)
    }
}

struct DecoderTypesBySocket: View {
    @SectionedFetchRequest(
        // BUG(FB9194735) We can't just use \.socket yet
        sectionIdentifier: \DecoderType.socket?.title,
        sortDescriptors: [
            SortDescriptor(\DecoderType.socket?.title, order: .reverse),
            SortDescriptor(\DecoderType.socket?.numberOfPins, order: .reverse),
            SortDescriptor(\DecoderType.minimumStock, order: .reverse),
            SortDescriptor(\DecoderType.remainingStock, order: .reverse),
            SortDescriptor(\DecoderType.manufacturer),
            SortDescriptor(\DecoderType.catalogNumber),
        ],
        animation: .default)
    var decoderTypes: SectionedFetchResults<String?, DecoderType>

    var body: some View {
        ForEach(decoderTypes) { section in
            Section(header: Text(section.id!)) {
                ForEach(section) { decoderType in
                    DecoderTypeCell(decoderType: decoderType)
                }
            }
        }
        #if os(macOS)
        .navigationSubtitle("\(decoderTypes.recordCount) Types")
        #endif
        // BUG(FB9191598) Simulator will fail to build if the view ends at #endif
        .listStyle(.plain)
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
        // BUG(FB9191598) Simulator will fail to build if the view ends at #endif
        .listStyle(.plain)
    }
}

struct DecoderTypesList_Previews: PreviewProvider {
    static var previews: some View {
        DecoderTypesList()
            .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
