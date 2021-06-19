//
//  Accessory+Image.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/18/21.
//

import Foundation
import CoreGraphics

extension Accessory {
    var cgImage: CGImage? {
        get { imageData.flatMap { CGImageCreateFromPNGData($0) } }
        set { imageData = newValue?.pngData() }
    }
}
