//
//  Model+Image.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import SwiftUI
import CoreGraphics
import ImageIO

private extension CGImage {
    func pngData() -> Data? {
        guard let mutableData = CFDataCreateMutable(nil, 0),
              let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil) else { return nil }

        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}

private func CGImageCreateFromPNGData(_ imageData: Data) -> CGImage? {
    guard let dataProvider = CGDataProvider(data: imageData as CFData) else { return nil }
    return CGImage(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
}

extension Model {
    var cgImage: CGImage? {
        get { imageData.flatMap { CGImageCreateFromPNGData($0) } }
        set { imageData = newValue?.pngData() }
    }
}
