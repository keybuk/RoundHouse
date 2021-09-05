//
//  DecoderCell.swift
//  DecoderCell
//
//  Created by Scott James Remnant on 9/3/21.
//

import SwiftUI

struct DecoderCell: View {
    @ObservedObject var decoder: Decoder

    var body: some View {
        Text(decoder.serialNumber!)
    }
}

struct DecoderCell_Previews: PreviewProvider {
    static var previews: some View {
        DecoderCell(decoder: PreviewData.shared.decoders["FFFF4291"]!)
    }
}
