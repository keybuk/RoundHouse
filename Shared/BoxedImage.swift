//
//  BoxedImage.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/28/19.
//

import SwiftUI

/// A view that makes an Image flexible in height, limited by sibling views.
///
/// `BoxedImage` works by placing its associated `Image` in a secondary ``overlay`` view, with the primary view
/// constrained by `width` and filled with `fillColor`. Since no height is specified to the primary view, it will expand to fill all
/// available space, which when constrained by ``layoutPriority`` or placed in a construst such as ``List`` will
/// limit it to the size of its siblings.
///
/// Within the secondary view, `image` will fit within the available space.
///
/// For example if the following is placed in a `List`, the maximum height of the image will be the height of the three lines of text:
///
///     HStack {
///       BoxedImage(image: anImage, width: 100)
///       VStack {
///         Text("Some")
///         Text("Lines of")
///         Text("Text")
///       }
///     }
struct BoxedImage: View {
    var image: Image
    var width: CGFloat
    var fillColor: Color = .white

    var body: some View {
        Rectangle()
            .fill(fillColor)
            .frame(width: width)
            .overlay(image
                .resizable()
                .aspectRatio(contentMode: .fit))
            .cornerRadius(4)
    }
}

struct BoxedImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
                .layoutPriority(1)

            HStack {
                BoxedImage(image: Image("R3804"),
                           width: 100)

                Rectangle()
                    .fill(.quaternary)
                    .frame(width: 100, height: 100)
            }
            .padding()
            .background(.green)
            .layoutPriority(-1)

            HStack {
                BoxedImage(image: Image("R3804"),
                           width: 100)

                Rectangle()
                    .fill(.quaternary)
                    .frame(width: 100, height: 50)
            }
            .padding()
            .background(.green)
            .layoutPriority(-2)

            Spacer()
                .layoutPriority(1)
        }
    }
}
