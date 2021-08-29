//
//  PurchaseCell.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import SwiftUI

struct PurchaseCell: View {
    var purchase: Purchase
    var showDate = false
    var showManufacturer = false

    let dateFormat = Date.FormatStyle.dateTime
        .year().month(.defaultDigits).day()

    var body: some View {
        HStack {
            BoxedImage(image: purchase.keyModel?.image ?? purchase.keyAccessory?.image, width: 100)

            VStack(alignment: .leading) {
                if showDate, let date = purchase.date {
                    Text(date, format: dateFormat)
                        .font(.caption)
                }
                if showManufacturer {
                    OptionalText(purchase.catalogTitle)
                        .font(.headline)
                } else {
                    OptionalText(purchase.catalogNumber!)
                        .font(.headline)
                }
                OptionalText(purchase.catalogDescription!)
            }
        }
        .frame(minHeight: 60)
    }
}

struct PurchaseCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PurchaseCell(purchase: PreviewData.shared.purchases["R1234M"]!)
            
            PurchaseCell(purchase: PreviewData.shared.purchases["R1234M"]!, showDate: true, showManufacturer: true)
        }
    }
}
