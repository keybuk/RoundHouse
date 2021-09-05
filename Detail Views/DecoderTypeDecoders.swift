//
//  DecoderTypeDecoders.swift
//  DecoderTypeDecoders
//
//  Created by Scott James Remnant on 9/3/21.
//

import SwiftUI

extension Decoder {
    static func predicateForUnallocatedDecoders(type decoderType: DecoderType) -> NSPredicate {
        NSPredicate(format: "type = %@ AND model = nil", decoderType)
    }
}

struct DecoderTypeDecoders: View {
    @ObservedObject var decoderType: DecoderType

    @FetchRequest
    var decoders: FetchedResults<Decoder>

    init(decoderType: DecoderType) {
        self.decoderType = decoderType
        _decoders = FetchRequest(
            sortDescriptors: [
                SortDescriptor(\Decoder.serialNumber)
            ],
            predicate: Decoder.predicateForUnallocatedDecoders(type: decoderType),
            animation: .default)
    }

    var body: some View {
        ForEach(decoders) { decoder in
            DecoderCell(decoder: decoder)
        }
    }
}

struct DecoderTypeDecoders_Previews: PreviewProvider {
    static var previews: some View {
        List {
            DecoderTypeDecoders(decoderType: PreviewData.shared.decoderTypes["58412"]!)
        }
        .environment(\.managedObjectContext, PreviewData.shared.viewContext)

    }
}
