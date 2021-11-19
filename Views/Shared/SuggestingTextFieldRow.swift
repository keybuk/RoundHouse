//
//  SuggestingTextFieldRow.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 9/6/21.
//

import SwiftUI
import CoreData

struct SuggestingTextFieldRow: View {
    var title: String
    @Binding var text: String
    var suggestions: (String) -> [String]
    
    @FocusState var isFocused: Bool
    @State var cachedSuggestions: [String] = []
    
    init(_ title: String, text: Binding<String>, suggestions: @escaping (String) -> [String]) {
        self.title = title
        self._text = text
        self.suggestions = suggestions
    }
    
    var body: some View {
        Group {
            TextFieldRow(title, text: $text)
                .focused($isFocused)
            
            if isFocused {
                ForEach(cachedSuggestions, id: \.self) { suggestion in
                    Button {
                        text = suggestion
                        isFocused = false
                    } label: {
                        Text(suggestion)
                            .foregroundColor(.primary)
                    }
                    .listRowInsets(.init(top: 0, leading: 35, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden, edges: [.top])
                }
            }
        }
        .onChange(of: isFocused) { newValue in
            if newValue {
                cachedSuggestions = suggestions(text)
            } else {
                cachedSuggestions.removeAll()
            }
        }
        .onChange(of: text) { newValue in
            cachedSuggestions = suggestions(text)
        }
    }
}

struct SuggestingTextFieldRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                SuggestingTextFieldRow("Manufacturer", text: .constant(PreviewData.shared.decoderTypes["58412"]!.manufacturer!), suggestions: PreviewData.shared.decoderTypes["58412"]!.suggestionsForManufacturer(matching:))

                TextField("Next Field", text: .constant("Next Field"))
            }
        }
    }
}
