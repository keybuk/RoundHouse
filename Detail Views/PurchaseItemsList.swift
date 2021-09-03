//
//  PurchaseItemsList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/30/21.
//

import SwiftUI

struct PurchaseItemsList: View {
    @ObservedObject var purchase: Purchase

    var body: some View {
        List {
            PurchaseItems(purchase: purchase, alwaysShowHeaders: false)
        }
        .listStyle(.plain)
    }
}

struct PurchaseItemsList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PurchaseItemsList(purchase: PreviewData.shared.purchases["R1234M"]!)

            PurchaseItemsList(purchase: PreviewData.shared.purchases["32-908"]!)
        }
        .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
