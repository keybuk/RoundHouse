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
            if let image = decoderType.image {
                BoxedImage(image: image, width: 100)
            } else {
                Rectangle()
                    .frame(width: 100)
                    .hidden()
            }

            VStack(alignment: .leading) {
                if showManufacturer && !decoderType.manufacturer!.isEmpty && !decoderType.catalogNumber!.isEmpty {
                    Text("\(decoderType.manufacturer!) \(decoderType.catalogNumber!)")
                        .font(.headline)
                } else if showManufacturer && !decoderType.manufacturer!.isEmpty {
                    Text(decoderType.manufacturer!)
                        .font(.headline)
                } else if !decoderType.catalogNumber!.isEmpty {
                    Text(decoderType.catalogNumber!)
                        .font(.headline)
                }
                if !decoderType.catalogName!.isEmpty {
                    Text(decoderType.catalogName!)
                } else if !decoderType.catalogFamily!.isEmpty {
                    Text(decoderType.catalogFamily!)
                }
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
