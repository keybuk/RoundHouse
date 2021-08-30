//
//  PurchaseGroupingPicker.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 7/6/21.
//

import SwiftUI

extension Purchase {
    enum Grouping: String {
        case catalog
        case date
    }
}

struct PurchaseGroupingPicker: View {
    @Binding var grouping: Purchase.Grouping

    var body: some View {
        Picker("Group By", selection: $grouping) {
            Text("Date")
                .tag(Purchase.Grouping.date)
            Text("Catalog")
                .tag(Purchase.Grouping.catalog)
        }
        .pickerStyle(.segmented)
    }
}

struct PurchaseGroupingPicker_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseGroupingPicker(grouping: .constant(.date))
    }
}
