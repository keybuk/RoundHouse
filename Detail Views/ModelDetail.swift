//
//  ModelDetail.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/30/21.
//

import SwiftUI

struct ModelDetail: View {
    @ObservedObject var model: Model

    var body: some View {
        VStack {
            Text(model.classTitle)
            OptionalText(model.number!)
            OptionalText(model.name!)
        }
    }
}

struct ModelDetail_Previews: PreviewProvider {
    static var previews: some View {
        ModelDetail(model: PreviewData.shared.models["R3804"]!)
    }
}
