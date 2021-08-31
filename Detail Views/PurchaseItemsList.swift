//
//  PurchaseItemsList.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/30/21.
//

import SwiftUI

struct PurchaseItemsList: View {
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
            predicate: NSPredicate(format: "purchase == %@", purchase),
            animation: .default)
        _accessories = FetchRequest(
            sortDescriptors: [
                SortDescriptor(\Accessory.index)
            ],
            predicate: NSPredicate(format: "purchase == %@", purchase),
            animation: .default)
    }

    var body: some View {
        List {
            if models.count > 0 {
                Section(header: accessories.count > 0 ? Text("Models") : nil) {
                    ForEach(models) { model in
                        NavigationLink {
                            ModelView(model: model)
                        } label: {
                            ModelCell(model: model, showClass: true)
                        }
                    }
                }
            }
            if accessories.count > 0 {
                Section(header: models.count > 0 ? Text("Accessories") : nil) {
                    ForEach(accessories) { accessory in
                        AccessoryCell(accessory: accessory)
                    }
                }
            }
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
