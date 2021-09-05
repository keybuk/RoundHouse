//
//  DecoderTypeView.swift
//  DecoderTypeView
//
//  Created by Scott James Remnant on 9/3/21.
//

import SwiftUI

/// DecoderTypeView is the navigation target for showing details on a selected decoder type.
struct DecoderTypeView: View {
    @ObservedObject var decoderType: DecoderType

    var body: some View {
        DecoderTypeDetail(decoderType: decoderType)
            .navigationTitle(decoderType.catalogTitle)
    }
}

struct DecoderTypeView_Previews: PreviewProvider {
    static var previews: some View {
        DecoderTypeView(decoderType: PreviewData.shared.decoderTypes["58412"]!)
    }
}
