//
//  DecoderType+Image (iOS).swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

#if os(iOS)
import UIKit
import SwiftUI

extension DecoderType {
    var uiImage: UIImage? {
        get { imageData.flatMap { UIImage(data: $0) } }
        set { imageData = newValue?.pngData() }
    }

    var image: Image? {
        get { uiImage.map { Image(uiImage: $0) } }
    }

    /// Set the image from an asset catalog.
    /// - Parameter name: name of asset.
    func setPreviewImage(named name: String) {
        uiImage = UIImage(named: name)
    }
}
#endif
