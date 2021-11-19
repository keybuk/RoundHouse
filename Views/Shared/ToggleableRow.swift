//
//  TogglableRow.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 9/6/21.
//

import SwiftUI

struct ToggleableRow: View {
    var title: String
    @Binding var value: Bool

    init(_ title: String, value: Binding<Bool>) {
        self.title = title
        self._value = value
    }

    var body: some View {
        Button {
            value.toggle()
        } label: {
            HStack {
                Text(title)
                Spacer()
                if value {
                    Image(systemName: "checkmark")
                }
            }
            .foregroundColor(.primary)
        }
    }
}

struct ToggleableRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                ToggleableRow("Programmable", value: .constant(PreviewData.shared.decoderTypes["58412"]!.isProgrammable))
                
                TextField("Next Field", text: .constant("Next Field"))
            }
        }
    }
}
