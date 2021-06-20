//
//  DecoderType+Image.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import Foundation
import CoreGraphics

extension DecoderType {
    var cgImage: CGImage? {
        get { imageData.flatMap { CGImageCreateFromPNGData($0) } }
        set { imageData = newValue?.pngData() }
    }
}
