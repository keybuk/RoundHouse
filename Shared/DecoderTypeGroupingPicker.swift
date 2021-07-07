//
//  DecoderTypeGroupingPicker.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 7/6/21.
//

import SwiftUI

extension DecoderType {
    enum Grouping {
        case socket
        case catalog
    }
}

struct DecoderTypeGroupingPicker: View {
    @Binding var grouping: DecoderType.Grouping

    var body: some View {
        Picker("Group By", selection: $grouping) {
            Text("Socket")
                .tag(DecoderType.Grouping.socket)
            Text("Catalog")
                .tag(DecoderType.Grouping.catalog)
        }
        .pickerStyle(.segmented)
    }
}

struct DecoderTypeGroupingPicker_Previews: PreviewProvider {
    static var previews: some View {
        DecoderTypeGroupingPicker(grouping: .constant(.socket))
    }
}
