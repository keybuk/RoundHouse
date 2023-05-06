//
//  Decoder+Stock.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 3/5/19.
//

import Foundation

extension Decoder {
    /// Returns `true` if the decoder is fitted to a model.
    public var isFitted: Bool { model != nil }
    
    /// Returns `true` if the decoder has a sound project allocated or written to it.
    public var isAllocated: Bool {
        soundAuthor! != "" ||
        soundProject! != "" ||
        soundProjectVersion! != "" ||
        soundSettings! != ""
    }
    
    /// Returns `true` if the decoder is not allocated to any model or sound file.
    public var isSpare: Bool { !isFitted && !isAllocated }
}
