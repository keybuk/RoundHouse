//
//  Model+Image (iOS).swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

#if os(iOS)
import UIKit
import SwiftUI

extension Model {
    var uiImage: UIImage? {
        get { imageData.flatMap { UIImage(data: $0) } }
        set { imageData = newValue?.pngData() }
    }

    var image: Image? {
        get { uiImage.map { Image(uiImage: $0) } }
    }

    /// Set the model image from an asset catalog.
    /// - Parameter name: name of asset.
    func setPreviewImage(named name: String) {
        uiImage = UIImage(named: name)
    }
}
#endif

