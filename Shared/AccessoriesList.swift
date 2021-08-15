//
//  AccessoriesList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import SwiftUI

struct AccessoriesList: View {
    var body: some View {
        List {
            AccessoriesByCatalog()
        }
        .listStyle(.plain)
        .navigationTitle("Accessories")
        .frame(minWidth: 250)
    }
}

private extension SectionedFetchResults.Section where Element == Accessory, SectionIdentifier == String? {
    var title: String {
        return id!
    }
}

struct AccessoriesByCatalog: View {
    @SectionedFetchRequest(
        sectionIdentifier: \Accessory.manufacturer,
        sortDescriptors: [
            SortDescriptor(\Accessory.manufacturer),
            SortDescriptor(\Accessory.catalogNumber),
        ],
        animation: .default)
    var accessories: SectionedFetchResults<String?, Accessory>

    var body: some View {
        ForEach(accessories) { section in
            Section(header: Text(section.title)) {
                ForEach(section) { accessory in
                    AccessoryCell(accessory: accessory)
                }
            }
        }
        #if os(macOS)
        .navigationSubtitle("\(accessories.reduce(0, { $0 + $1.count })) Accessories")
        #endif
    }
}

struct AccessoriesList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccessoriesList()
                .environment(\.managedObjectContext, PreviewData.shared.viewContext)
        }
    }
}
