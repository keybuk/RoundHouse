//
//  Model+Image.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import Foundation
import CoreGraphics

extension Model {
    var cgImage: CGImage? {
        get { imageData.flatMap { CGImageCreateFromPNGData($0) } }
        set { imageData = newValue?.pngData() }
    }
}
