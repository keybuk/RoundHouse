//
//  PurchaseView.swift
//  PurchaseView
//
//  Created by Scott James Remnant on 9/3/21.
//

import SwiftUI

/// PurchaseView is the navigation target for showing details on a selected purchase.
struct PurchaseView: View {
    @ObservedObject var purchase: Purchase

    var body: some View {
        PurchaseDetail(purchase: purchase)
            .navigationTitle(purchase.catalogTitle)
    }
}

struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView(purchase: PreviewData.shared.purchases["R1234M"]!)
    }
}
