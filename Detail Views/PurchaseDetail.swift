//
//  PurchaseDetail.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/30/21.
//

import SwiftUI

struct PurchaseDetail: View {
    @ObservedObject var purchase: Purchase

    var body: some View {
        Text(purchase.catalogTitle)
    }
}

struct PurchaseDetail_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseDetail(purchase: PreviewData.shared.purchases["R1234M"]!)
    }
}
