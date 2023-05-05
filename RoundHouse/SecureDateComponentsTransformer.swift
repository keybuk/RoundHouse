//
//  SecureDateComponentsTransformer.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 1/27/20.
//

import Foundation

@objc(SecureDateComponentsTransformer)
final class SecureDateComponentsTransformer: NSSecureUnarchiveFromDataTransformer {
    public static let transformerName = NSValueTransformerName(rawValue: "SecureDateComponentsTransformer")

    override class var allowedTopLevelClasses: [AnyClass] { [NSDateComponents.self] }
}
