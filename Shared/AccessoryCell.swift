//
//  AccessoryCell.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/18/21.
//

import SwiftUI

struct AccessoryCell: View {
    var accessory: Accessory

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
                HStack {
                    if !accessory.manufacturer!.isEmpty {
                        Text(accessory.manufacturer!)
                    }
                    if !accessory.catalogNumber!.isEmpty {
                        Text(accessory.catalogNumber!)
                    }
                }
                .font(.headline)
                
                if !accessory.catalogDescription!.isEmpty {
                    Text(accessory.catalogDescription!)
                }
            }
        }
        .frame(minHeight: 60)
    }
}

struct AccessoryCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AccessoryCell(accessory: PreviewData.shared.accessories["R8206"]!)
        }
    }
}
