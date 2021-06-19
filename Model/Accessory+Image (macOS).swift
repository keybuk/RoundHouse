//
//  Accessory+Image (macOS).swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/18/21.
//

#if os(macOS)
import Cocoa
import SwiftUI

extension Accessory {
    var nsImage: NSImage? {
        get { imageData.flatMap { NSImage(data: $0) } }
        set { imageData = try? newValue?.pngData() }
    }

    var image: Image? {
        get { nsImage.map { Image(nsImage: $0) } }
    }

    /// Set the model image from an asset catalog.
    /// - Parameter name: name of asset.
    func setPreviewImage(named name: NSImage.Name) {
        nsImage = NSImage(named: name)
    }
}
#endif
