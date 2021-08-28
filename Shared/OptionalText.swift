//
//  OptionalText.swift
//  OptionalText
//
//  Created by Scott James Remnant on 8/28/21.
//

import SwiftUI

/// A text view that is only present in the hierarchy when the content is non-empty.
///
/// Unlike `Text`, the content of this view is never localized, since it can be assumed that the empty string is never a localized string key. Likewise initializes aren't provided for formatted values since it's assumed those aways result in a string.
struct OptionalText: View {
    var body: Text?

    init<S>(_ content: S) where S: StringProtocol {
        if !content.isEmpty {
            self.body = Text(content)
        }
    }

    init(verbatim content: String) {
        if !content.isEmpty {
            self.body = Text(verbatim: content)
        }
    }

    init(_ attributedContent: AttributedString) {
        if attributedContent.endIndex != attributedContent.startIndex {
            self.body = Text(attributedContent)
        }
    }
}

struct OptionalText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 25) {
            OptionalText("")
                .background(.white)
            OptionalText("Not Empty")
                .background(.white)
            OptionalText(AttributedString(""))
                .background(.white)
            OptionalText(AttributedString("Not Empty"))
                .background(.white)
            OptionalText(verbatim: "")
                .background(.white)
            OptionalText(verbatim: "Not Empty")
                .background(.white)
        }
        .padding(25)
        .background(.green)
    }
}
