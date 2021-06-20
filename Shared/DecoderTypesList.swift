//
//  DecoderTypesList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import SwiftUI
import CoreData

extension DecoderType {
    // This will end up being sectionIdentifierForGrouping
    static func sectionIdentifier() -> KeyPath<DecoderType, String?> {
        // BUG(FB9194735) We can't just use \.socket yet
        \.socket?.title
    }

    // This will end up being sortDescriptorsForGrouping
    static func sortDescriptors() -> [SortDescriptor<DecoderType>] {
        [
            SortDescriptor(\.socket?.title),
            SortDescriptor(\.socket?.numberOfPins),
            SortDescriptor(\.manufacturer),
            SortDescriptor(\.catalogNumber),
        ]
    }
}

struct DecoderTypesList: View {
    @Environment(\.managedObjectContext) var viewContext

    @SectionedFetchRequest(
        sectionIdentifier: DecoderType.sectionIdentifier(),
        sortDescriptors: DecoderType.sortDescriptors(),
        animation: .default)
    var decoderTypes: SectionedFetchResults<String?, DecoderType>

    var body: some View {
        List {
            ForEach(decoderTypes) { section in
                Section(header: Text(section.id!)) {
                    ForEach(section) { decoderType in
                        DecoderTypeCell(decoderType: decoderType)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Decoders")
        #if os(macOS)
        .navigationSubtitle("\(decoderTypes.reduce(0, { $0 + $1.count })) Types")
        #endif
        // BUG(FB9191598) Simulator will fail to build if the view ends at #endif
        .frame(minWidth: 250)
    }
}

struct DecoderTypesList_Previews: PreviewProvider {
    static var previews: some View {
        DecoderTypesList()
            .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
