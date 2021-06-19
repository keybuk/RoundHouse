//
//  AccessoriesList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import SwiftUI

extension Accessory {
    static func sectionIdentifier() -> KeyPath<Accessory, String?> {
        \.manufacturer
    }

    // This will end up being sortDescriptorsForGrouping
    static func sortDescriptors() -> [SortDescriptor<Accessory>] {
        [
            SortDescriptor(\.manufacturer),
            SortDescriptor(\.catalogNumber),
        ]
    }
}

struct AccessoriesList: View {
    @Environment(\.managedObjectContext) var viewContext

    @SectionedFetchRequest(
        sectionIdentifier: Accessory.sectionIdentifier(),
        sortDescriptors: Accessory.sortDescriptors(),
        animation: .default)
    var accessories: SectionedFetchResults<String?, Accessory>

    var body: some View {
        List {
            ForEach(accessories) { section in
                Section(header: Text(section.id!)) {
                    ForEach(section) { accessory in
                        AccessoryCell(accessory: accessory)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Accessories")
        #if os(macOS)
        .navigationSubtitle("\(accessories.reduce(0, { $0 + $1.count })) Accessories")
        #endif
        // BUG(FB9191598) Simulator will fail to build if the view ends at #endif
        .frame(minWidth: 250)
    }
}

struct AccessoriesList_Previews: PreviewProvider {
    static var previews: some View {
        AccessoriesList()
            .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
