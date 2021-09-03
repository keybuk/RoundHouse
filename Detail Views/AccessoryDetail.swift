//
//  AccessoryDetail.swift
//  AccessoryDetail
//
//  Created by Scott James Remnant on 9/3/21.
//

import SwiftUI

struct AccessoryDetail: View {
    @ObservedObject var accessory: Accessory
    var showPurchase: Bool = true

    var body: some View {
        List {
            Section {
                if let image = accessory.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                if showPurchase {
                    NavigationLink {
                        PurchaseView(purchase: accessory.purchase!)
                    } label: {
                        AccessoryPurchaseCell(purchase: accessory.purchase!)
                    }
                }
            }
            
            Section("Catalog") {
                if !accessory.manufacturer!.isEmpty {
                    AccessoryDetailRow(title: "Manufacturer") {
                        Text(accessory.manufacturer!)
                    }
                }

                if !accessory.catalogNumber!.isEmpty {
                    AccessoryDetailRow(title: "Number") {
                        Text(accessory.catalogNumber!)
                    }
                }

                if !accessory.catalogDescription!.isEmpty {
                    AccessoryDetailRow(title: "Description") {
                        Text(accessory.catalogDescription!)
                    }
                }
            }

            Section("Accessory") {
                AccessoryDetailRow(title: "Gauge") {
                    Text(accessory.gauge!)
                }
            }
            
            if !accessory.notes!.isEmpty {
                Section(header: Text("Notes")) {
                    Text(accessory.notes!)
                }
            }
        }
    }
}

struct AccessoryDetailRow<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
            content
        }
    }
}

struct AccessoryPurchaseCell: View {
    @ObservedObject var purchase: Purchase

    let dateFormat = Date.FormatStyle.dateTime
        .year().month(.defaultDigits).day()

    var body: some View {
        VStack(alignment: .leading) {
            Text(purchase.catalogTitle)
                .font(.headline)
            Text(purchase.date!, format: dateFormat) +
            Text(" from ") +
            Text(purchase.store!)
        }
    }
}

struct AccessoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryDetail(accessory: PreviewData.shared.accessories["R8206"]!)
    }
}
