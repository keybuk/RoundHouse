//
//  PurchaseCell.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import SwiftUI

extension Purchase {
    var image: Image? {
        if let image = (models as! Set<Model>?)?
            .filter({ $0.imageData != nil })
            .sorted(by: { $0.index < $1.index })
            .first
            .flatMap({ $0.image }) {
            return image
        }

        if let image = (accessories as! Set<Accessory>?)?
            .filter({ $0.imageData != nil })
            .sorted(by: { $0.index < $1.index })
            .first
            .flatMap({ $0.image }) {
            return image
        }

        return nil
    }
}

struct PurchaseCell: View {
    var purchase: Purchase
    var showDate = false
    var showManufacturer = false

    let dateFormat = Date.FormatStyle.dateTime
        .year().month(.defaultDigits).day()

    var body: some View {
        HStack {
            BoxedImage(image: purchase.image, width: 100)

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
