//
//  DecoderTypeCell.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import SwiftUI

extension DecoderType {
    var title: String {
        [manufacturer!, catalogNumber!]
            .joined(separator: " ")
    }
}

struct DecoderTypeCell: View {
    var decoderType: DecoderType

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
                if !decoderType.title.isEmpty {
                    Text(decoderType.title)
                        .font(.headline)
                }
                if !decoderType.catalogName!.isEmpty {
                    Text(decoderType.catalogName!)
                } else if !decoderType.catalogFamily!.isEmpty {
                    Text(decoderType.catalogFamily!)
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
            
            DecoderTypeCell(decoderType: PreviewData.shared.decoderTypes["58412"]!)
        }
    }
}
