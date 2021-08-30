//
//  ModelDetailView.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/30/21.
//

import SwiftUI

/// ModelView is the navigation target for showing details on a selected model.
///
/// On non-compact views this will show the details of the purchase, purchase items, and selected model.
struct ModelView: View {
    @ObservedObject var model: Model

    var body: some View {
        VStack {
            PurchaseDetail(purchase: model.purchase!)
            HStack {
                PurchaseItemsList(purchase: model.purchase!)
                ModelDetail(model: model)
            }
        }
    }
}

struct ModelView_Previews: PreviewProvider {
    static var previews: some View {
        ModelView(model: PreviewData.shared.models["R3804"]!)
            .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
