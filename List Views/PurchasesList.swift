//
//  PurchasesList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import SwiftUI

struct PurchasesList: View {
    @SceneStorage("Purchase.grouping") var grouping: Purchase.Grouping = .date

    var body: some View {
        List {
            switch grouping {
            case .date:
                PurchasesByDate()
            case .catalog:
                PurchasesByCatalog()
            }
        }
        .listStyle(.plain)
        .navigationTitle("Purchases")
        .toolbar {
            ToolbarItem(placement: .principal) {
                PurchaseGroupingPicker(grouping: $grouping)
#if os(iOS)
                    .padding([.leading, .trailing])
#endif
            }
        }
        .frame(minWidth: 250)
    }
}

struct PurchasesByDate: View {
    @SectionedFetchRequest(
        sectionIdentifier: \Purchase.purchaseMonth,
        sortDescriptors: Purchase.purchaseMonthSortDescriptors + [
            SortDescriptor(\Purchase.manufacturer),
            SortDescriptor(\Purchase.catalogNumber),
        ],
        animation: .default)
    var purchases: SectionedFetchResults<Date, Purchase>

    let purchaseMonthFormat = Date.FormatStyle(timeZone: TimeZone(identifier: "UTC")!)
        .year().month(.wide)

    var body: some View {
        ForEach(purchases) { section in
            Section(header: Text(section.id, format: purchaseMonthFormat)) {
                ForEach(section) { purchase in
                    PurchaseCell(purchase: purchase, showDate: true, showManufacturer: true)
                }
            }
        }
#if os(macOS)
        .navigationSubtitle("\(purchases.recordCount) Purchases")
#endif
    }
}

struct PurchasesByCatalog: View {
    @SectionedFetchRequest(
        sectionIdentifier: \Purchase.manufacturer,
        sortDescriptors: Purchase.catalogSortDescriptors + [
            SortDescriptor(\Purchase.dateForSort),
        ],
        animation: .default)
    var purchases: SectionedFetchResults<String?, Purchase>

    var body: some View {
        ForEach(purchases) { section in
            Section(header: Text(section.id!)) {
                ForEach(section) { purchase in
                    PurchaseCell(purchase: purchase)
                }
            }
        }
#if os(macOS)
        .navigationSubtitle("\(purchases.recordCount) Purchases")
#endif
    }
}

struct PurchasesList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PurchasesList()
                .environment(\.managedObjectContext, PreviewData.shared.viewContext)
        }
    }
}
