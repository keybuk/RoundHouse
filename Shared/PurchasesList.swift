//
//  PurchasesList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import SwiftUI

extension Purchase {
    // This will end up being sectionIdentifierForGrouping
    static func sectionIdentifier() -> KeyPath<Purchase, String?> {
        \.manufacturer
    }

    // This will end up being sortDescriptorsForGrouping
    static func sortDescriptors() -> [SortDescriptor<Purchase>] {
        [
            SortDescriptor(\.manufacturer),
            SortDescriptor(\.catalogNumber),
            SortDescriptor(\.dateForSort),
        ]
    }
}

struct PurchasesList: View {
    @Environment(\.managedObjectContext) var viewContext

    @SectionedFetchRequest(
        sectionIdentifier: Purchase.sectionIdentifier(),
        sortDescriptors: Purchase.sortDescriptors(),
        animation: .default)
    var purchases: SectionedFetchResults<String?, Purchase>

    var body: some View {
        List {
            ForEach(purchases) { section in
                Section(header: Text(section.id!)) {
                    ForEach(section) { purchase in
                        PurchaseCell(purchase: purchase)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Purchases")
        #if os(macOS)
        .navigationSubtitle("\(purchases.reduce(0, { $0 + $1.count })) Purchases")
        #endif
        // BUG(FB9191598) Simulator will fail to build if the view ends at #endif
        .frame(minWidth: 250)
    }
}

struct PurchasesList_Previews: PreviewProvider {
    static var previews: some View {
        PurchasesList()
            .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
