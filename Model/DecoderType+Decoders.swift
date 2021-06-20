//
//  DecoderType+Decoders.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/19/21.
//

import Foundation
import CoreData

extension DecoderType {
    /// Add a new `Decoder` to the type.
    ///
    /// The new `Decoder` is inserted into the same `managedObjectContext` as this type and added to the `decoders`
    /// set.
    ///
    /// This method must be called within a `perform` block of `managedObjectContext`.
    ///
    /// - Returns: `Decoder` now present in `decoders`.
    func addDecoder() -> Decoder {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot add a decoder to a type without a managed object context")
        }

        let decoder = Decoder(context: managedObjectContext)
        addToDecoders(decoder)

        return decoder
    }

    /// Remove a `Decoder` from the type.
    ///
    /// `decoder` is removed from the `decoders` set and deleted from its `managedObjectContext`.
    ///
    /// This method must be called within a `perform` block of `managedObjectContext`.
    ///
    /// - Parameter decoder: `Decoder` to be removed.
    func removeDecoder(_ decoder: Decoder) {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot remove a decoder from a type without a managed object context")
        }

        removeFromDecoders(decoder)
        managedObjectContext.delete(decoder)
    }
}
