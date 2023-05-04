//
//  RoundHouseApp.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 5/3/23.
//

import SwiftUI

@main
struct RoundHouseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
