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

    var body: some View {
        HStack {
            if let image = purchase.image {
                BoxedImage(image: image, width: 100)
            } else {
                Rectangle()
                    .frame(width: 100)
                    .hidden()
            }

            VStack(alignment: .leading) {
                if !purchase.catalogNumber!.isEmpty {
                    Text(purchase.catalogNumber!)
                        .font(.headline)
                }
                if !purchase.catalogDescription!.isEmpty {
                    Text(purchase.catalogDescription!)
                }
            }
        }
        .frame(minHeight: 60)
    }
}

struct PurchaseCell_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseCell(purchase: PreviewData.shared.purchases["R1234M"]!)
    }
}
