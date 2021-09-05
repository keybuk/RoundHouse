//
//  PurchaseItems.swift
//  PurchaseItems
//
//  Created by Scott James Remnant on 9/3/21.
//

import SwiftUI

struct PurchaseItems: View {
    @ObservedObject var purchase: Purchase

    @FetchRequest
    var models: FetchedResults<Model>

    @FetchRequest
    var accessories: FetchedResults<Accessory>

    init(purchase: Purchase) {
        self.purchase = purchase
        _models = FetchRequest(
            sortDescriptors: [
                SortDescriptor(\Model.index)
            ],
            predicate: NSPredicate(format: "purchase = %@", purchase),
            animation: .default)
        _accessories = FetchRequest(
            sortDescriptors: [
                SortDescriptor(\Accessory.index)
            ],
            predicate: NSPredicate(format: "purchase = %@", purchase),
            animation: .default)
    }

    var body: some View {
        if models.count > 0 {
            Section("Models") {
                ForEach(models) { model in
                    NavigationLink {
                        ModelView(model: model, showPurchase: false)
                    } label: {
                        ModelCell(model: model, showClass: true)
                    }
                }
            }
        }

        if accessories.count > 0 {
            Section("Accessories") {
                ForEach(accessories) { accessory in
                    NavigationLink {
                        AccessoryView(accessory: accessory, showPurchase: false)
                    } label: {
                        AccessoryCell(accessory: accessory)
                    }
                }
            }
        }
    }
}

struct PurchaseItems_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PurchaseItems(purchase: PreviewData.shared.purchases["R1234M"]!)
        }
        .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
