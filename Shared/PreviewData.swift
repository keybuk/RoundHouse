//
//  PreviewData.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/12/21.
//

import CoreData

struct PreviewData {
    let persistenceController: PersistenceController
    var container: NSPersistentCloudKitContainer { persistenceController.container }

    var sockets: [Int16: Socket] = [:]
    var purchases: [String: Purchase] = [:]
    var models: [String: Model] = [:]
    var trains: [String: Train] = [:]

    init() {
        persistenceController = PersistenceController(inMemory: true)
        let viewContext = persistenceController.container.viewContext

        do {
            let socket = Socket(context: viewContext)
            socket.title = "8-pin NEM652"
            socket.numberOfPins = 8

            sockets[8] = socket
        }

        do {
            let socket = Socket(context: viewContext)
            socket.title = "21MTC"
            socket.numberOfPins = 21

            sockets[21] = socket
        }

        do {
            let socket = Socket(context: viewContext)
            socket.title = "PluX22"
            socket.numberOfPins = 22

            sockets[22] = socket
        }

        do {
            let purchase = Purchase(context: viewContext)
            purchase.manufacturer = "Hornby"
            purchase.catalogNumber = "R1234M"
            purchase.catalogDescription = "Hogwarts Express' Train Set"
            purchase.catalogYear = 2020
            purchase.dateComponents = DateComponents(year: 2020, month: 8, day: 10)
            purchase.store = "Hattons"
            purchase.price = 199.99
            purchase.condition = .new

            purchases["R1234M"] = purchase

            let locomotive = purchase.addModel()
            locomotive.classification = .steamLocomotive
            locomotive.setPreviewImage(named: "R3804")
            locomotive.modelClass = "GWR 'Hall'"
            locomotive.wheelArrangement = "4-6-0"
            locomotive.number = "5972"
            locomotive.name = "Hogwarts Castle"
            locomotive.livery = "Hogwarts Maroon"
            locomotive.era = .rebuildingOfTheRailways
            locomotive.disposition = .normal
            locomotive.socket = sockets[22]

            models["R3804"] = locomotive

            let skCoach = purchase.addModel()
            skCoach.classification = .coach
            skCoach.setPreviewImage(named: "R4934A")
            skCoach.modelClass = "Mk1 SK"
            skCoach.number = "99721"
            skCoach.livery = "Hogwarts Maroon"
            skCoach.era = .rebuildingOfTheRailways
            skCoach.disposition = .normal

            models["R4934A"] = skCoach

            let bskCoach = purchase.addModel()
            bskCoach.classification = .coach
            bskCoach.setPreviewImage(named: "R4935A")
            bskCoach.modelClass = "Mk1 BSK"
            bskCoach.number = "99312"
            bskCoach.livery = "Hogwarts Maroon"
            bskCoach.era = .rebuildingOfTheRailways
            bskCoach.disposition = .normal

            let train = Train(context: viewContext)
            train.name = "Hogwarts Express"

            let locomotiveMember = train.addMember()
            locomotiveMember.modelClass = "GWR 'Hall'"
            locomotiveMember.numberOrName = "Hogwarts Express"
            locomotiveMember.model = locomotive

            let skMember = train.addMember()
            skMember.modelClass = "SK"
            skMember.model = skCoach

            let bskMember = train.addMember()
            bskMember.modelClass = "BSK"
            bskMember.model = bskCoach

            trains["Hogwarts Express"] = train
        }

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

let previewData = PreviewData()
