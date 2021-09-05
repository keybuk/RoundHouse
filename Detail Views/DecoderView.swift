//
//  DecoderView.swift
//  DecoderView
//
//  Created by Scott James Remnant on 9/5/21.
//

import SwiftUI

/// DecoderView is the navigation target for showing details on a selected decoder.
struct DecoderView: View {
    @ObservedObject var decoder: Decoder
    var showType: Bool = true

    var body: some View {
        DecoderDetail(decoder: decoder, showType: showType)
            .navigationTitle(decoder.serialNumber!)
    }
}

struct DecoderView_Previews: PreviewProvider {
    static var previews: some View {
        DecoderView(decoder: PreviewData.shared.decoders["FFFF4291"]!)
    }
}
