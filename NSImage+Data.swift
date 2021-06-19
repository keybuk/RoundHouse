//
//  NSImage+Data.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/18/21.
//

#if os(macOS)
import Cocoa

private extension NSImage {
    func pngData() throws -> Data {
        guard let imageData = self.tiffRepresentation else { throw NSError() }
        guard let imageRep = NSBitmapImageRep(data: imageData) else { throw NSError() }
        guard let pngData = imageRep.representation(using: .png, properties: [:]) else { throw NSError() }
        return pngData
    }
}
#endif

