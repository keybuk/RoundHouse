//
//  ModelCell.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/25/19.
//

import SwiftUI

struct ModelCell: View {
    var model: Model
    var showClass = false

    var body: some View {
        HStack {
            if let image = model.image {
                BoxedImage(image: image, width: 100)
            } else {
                Rectangle()
                    .frame(width: 100)
                    .hidden()
            }

            VStack(alignment: .leading) {
                if showClass {
                    OptionalText(model.classTitle)
                        .font(.caption)
                }
                OptionalText(model.number!)
                    .font(.headline)
                OptionalText(model.name!)
            }
        }
        .frame(minHeight: 60)
    }
}

struct ModelCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ModelCell(model: PreviewData.shared.models["R3804"]!)

            ModelCell(model: PreviewData.shared.models["R4934A"]!)

            ModelCell(model: PreviewData.shared.models["R3804"]!, showClass: true)

        }
    }
}
