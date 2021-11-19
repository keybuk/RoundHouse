//
//  TextEditorRow.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 9/6/21.
//

import SwiftUI

struct TextEditorRow: View {
    var title: String
    @Binding var text: String

    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
            
            TextEditor(text: $text)
        }
    }
}

struct TextEditorRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                TextEditorRow("Description", text: .constant(PreviewData.shared.decoderTypes["58412"]!.catalogDescription!))
                
                TextField("Next Field", text: .constant("Next Field"))
            }
        }
    }
}
