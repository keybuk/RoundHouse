//
//  Purchase+Accessories.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/13/21.
//

import Foundation
import CoreData

extension Purchase {
    /// Add a new `Accessory` to the purchase.
    ///
    /// The new `Accessory` is inserted into the same `managedObjectContext` as this purchase, added to the
    /// `accessories` set, and the `index` set to the next value in sequence.
    ///
    /// This method must be called within a `perform` block of `managedObjectContext`.
    ///
    /// - Returns: `Accessory` now present in `accessories`.
    func addAccessory() -> Accessory {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot add an accessory to a purchase without a managed object context")
        }

        let accessory = Accessory(context: managedObjectContext)
        accessory.index = maxAccessoryIndex + 1
        maxAccessoryIndex = accessory.index
        addToAccessories(accessory)

        return accessory
    }

    /// Remove an `Accessory` from the purchase.
    ///
    /// `accessory` is removed from the `accessories` set, deleted from its `managedObjectContext` and all `index`
    /// of each following accessory in `accessories` adjusted.
    ///
    /// This method must be called within a `perform` block of `managedObjectContext`.
    ///
    /// - Parameter accessory: `Accessory` to be removed.
    func removeAccessory(_ accessory: Accessory) {
        guard let managedObjectContext = managedObjectContext else {
            preconditionFailure("Cannot remove an accessory from a purchase without a managed object context")
        }
        guard let accessories = accessories as? Set<Accessory> else { return }

        removeFromAccessories(accessory)

        for other in accessories {
            if other.index > accessory.index {
                other.index -= 1
            }
        }

        maxAccessoryIndex -= 1
        managedObjectContext.delete(accessory)
    }

    /// Move an `Accessory` within the purchase from one position to another.
    ///
    /// After calling this method, the accessory at the zero-indexed `origin` position with the set of `accessories`
    /// will have the new index `destination` with intermediate indexes adjusted.
    ///
    /// Note that when moving an accessory to a lower position, after calling this method, the accessory will be placed **before**
    /// the accessory currently at the `destination` index; while when moving an accessory to a higher position, the accessory
    /// will be placed **after** the accessory currently at the `destination`.
    ///
    /// This method must be called within a `perform` block of `managedObjectContext`.
    ///
    /// - Parameters:
    ///   - origin: The position of the accessory that you want to move.
    ///   - destination: The accessory's new position.
    func moveAccessoryAt(_ origin: Int, to destination: Int) {
        guard let _ = managedObjectContext else {
            preconditionFailure("Cannot move an accessory within a purchase without a managed object context")
        }

        guard origin != destination else { return }
        guard let accessories = accessories as? Set<Accessory> else { return }

        for accessory in accessories {
            if (accessory.index == origin) {
                accessory.index = Int16(clamping: destination)
            } else if (destination > origin && accessory.index > origin && accessory.index <= destination) {
                accessory.index -= 1
            } else if (destination < origin && accessory.index >= destination && accessory.index < origin) {
                accessory.index += 1
            }
        }
    }
}
