//
//  StorableImage.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

import CoreGraphics
import ImageIO
import SwiftUI

protocol StorableImage: AnyObject {
    var imageData: Data? { get set }
}

private extension CGImage {
    func pngData() -> Data? {
        guard let mutableData = CFDataCreateMutable(nil, 0),
              let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil) else { return nil }

        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}

#if os(macOS)
private extension NSImage {
    func pngData() throws -> Data {
        guard let imageData = self.tiffRepresentation else { throw NSError() }
        guard let imageRep = NSBitmapImageRep(data: imageData) else { throw NSError() }
        guard let pngData = imageRep.representation(using: .png, properties: [:]) else { throw NSError() }
        return pngData
    }
}
#endif

private func CGImageCreateFromPNGData(_ imageData: Data) -> CGImage? {
    guard let dataProvider = CGDataProvider(data: imageData as CFData) else { return nil }
    return CGImage(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
}

extension StorableImage {
    var cgImage: CGImage? {
        get { imageData.flatMap { CGImageCreateFromPNGData($0) } }
        set { imageData = newValue?.pngData() }
    }

    #if os(iOS)
    var uiImage: UIImage? {
        get { imageData.flatMap { UIImage(data: $0) } }
        set { imageData = newValue?.pngData() }
    }
    #elseif os(macOS)
    var nsImage: NSImage? {
        get { imageData.flatMap { NSImage(data: $0) } }
        set { imageData = try? newValue?.pngData() }
    }
    #endif

    var image: Image? {
        get {
            #if os(iOS)
            uiImage.map { Image(uiImage: $0) }
            #elseif os(macOS)
            nsImage.map { Image(nsImage: $0) }
            #endif
        }
    }

    /// Set the image from an asset catalog.
    /// - Parameter name: name of asset.
    func setPreviewImage(named name: String) {
        #if os(iOS)
        uiImage = UIImage(named: name)
        #elseif os(macOS)
        nsImage = NSImage(named: name)
        #endif
    }
}
