//
//  FormattedTextFieldRow.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 9/6/21.
//

import SwiftUI

struct FormattedTextFieldRow<F>: View
where F: ParseableFormatStyle, F.FormatOutput == String {
    var title: String
    @Binding var value: F.FormatInput
    var format: F

    init(_ title: String, value: Binding<F.FormatInput>, format: F) {
        self.title = title
        self._value = value
        self.format = format
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
            
            TextField(title, value: $value, format: format, prompt: Text(title))
        }
    }
}

struct FormattedTextFieldRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                FormattedTextFieldRow("Minimum Stock", value: .constant(PreviewData.shared.decoderTypes["58412"]!.minimumStock), format: .number)
                
                TextField("Next Field", text: .constant("Next Field"))
            }
        }
    }
}
