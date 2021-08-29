//
//  AccessoryCell.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/18/21.
//

import SwiftUI

struct AccessoryCell: View {
    var accessory: Accessory
    var showManufacturer = false

    var body: some View {
        HStack {
            if let image = accessory.image {
                BoxedImage(image: image, width: 100)
            } else {
                Rectangle()
                    .frame(width: 100)
                    .hidden()
            }

            VStack(alignment: .leading) {
                if showManufacturer {
                    OptionalText(accessory.catalogTitle)
                        .font(.headline)
                } else {
                    OptionalText(accessory.catalogNumber!)
                        .font(.headline)
                }
                OptionalText(accessory.catalogDescription!)
            }
        }
        .frame(minHeight: 60)
    }
}

struct AccessoryCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AccessoryCell(accessory: PreviewData.shared.accessories["R8206"]!)

            AccessoryCell(accessory: PreviewData.shared.accessories["R7229"]!, showManufacturer: true)
        }
    }
}
