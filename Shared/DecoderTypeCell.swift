//
//  DecoderTypeCell.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import SwiftUI

struct DecoderTypeCell: View {
    var decoderType: DecoderType
    var showManufacturer = true
    var showSocket = false

    var body: some View {
        HStack {
            BoxedImage(image: decoderType.image, width: 100)
            
            VStack(alignment: .leading) {
                if showManufacturer {
                    OptionalText(decoderType.catalogTitle)
                        .font(.headline)
                } else {
                    OptionalText(decoderType.catalogNumber!)
                        .font(.headline)
                }
                OptionalText(decoderType.catalogName!)
                if showSocket {
                    Text(decoderType.socket!.title!)
                        .font(.caption)
                }
            }
            
            if decoderType.isStocked {
                Spacer()
                DecoderTypeStock(decoderType: decoderType)
            }
        }
        .frame(minHeight: 60)
    }
}

struct DecoderTypeStock : View {
    var decoderType: DecoderType

    var body: some View {
        Text("\(decoderType.remainingStock)")
            .font(.callout)
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 4)
            .foregroundStyle(decoderType.isStocked ? .white : .secondary)
            .background(decoderType.isStockLow ? .red : .secondary)
            .mask(Capsule())
            .padding([.leading])
    }
}

struct DecoderTypeCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            DecoderTypeCell(decoderType: PreviewData.shared.decoderTypes["58420"]!)
            
            DecoderTypeCell(decoderType: PreviewData.shared.decoderTypes["58429"]!)
            
            DecoderTypeCell(decoderType: PreviewData.shared.decoderTypes["58412"]!, showManufacturer: false, showSocket: true)
        }
    }
}
