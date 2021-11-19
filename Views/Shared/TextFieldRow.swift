//
//  TextFieldRow.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 9/6/21.
//

import SwiftUI

struct TextFieldRow: View {
    var title: String
    @Binding var text: String
    var formatter: Formatter?

    init(_ title: String, text: Binding<String>, formatter: Formatter? = nil) {
        self.title = title
        self._text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)

            TextField(title, text: $text, prompt: Text(title))
        }
    }
}

struct TextFieldRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                TextFieldRow("Catalog Number", text: .constant(PreviewData.shared.decoderTypes["58412"]!.catalogNumber!))
                
                TextField("Next Field", text: .constant("Next Field"))
            }
        }
    }
}
