//
//  AccessoryView.swift
//  AccessoryView
//
//  Created by Scott James Remnant on 9/3/21.
//

import SwiftUI

/// AccessoryView is the navigation target for showing details on a selected accessory.
struct AccessoryView: View {
    @ObservedObject var accessory: Accessory
    var showPurchase: Bool = true
    
    var body: some View {
        AccessoryDetail(accessory: accessory, showPurchase: showPurchase)
            .navigationTitle(accessory.catalogTitle)
    }
}

struct AccessoryView_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryView(accessory: PreviewData.shared.accessories["R8206"]!)
    }
}
