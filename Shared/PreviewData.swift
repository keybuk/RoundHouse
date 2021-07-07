//
//  PreviewData.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 6/12/21.
//

import CoreData

struct PreviewData {
    static let shared = PreviewData()

    let persistenceController: PersistenceController
    var viewContext: NSManagedObjectContext { persistenceController.container.viewContext }

    var sockets: [Int16: Socket] = [:]
    var purchases: [String: Purchase] = [:]
    var models: [String: Model] = [:]
    var accessories: [String: Accessory] = [:]
    var trains: [String: Train] = [:]
    var decoderTypes: [String: DecoderType] = [:]

    init() {
        persistenceController = PersistenceController(inMemory: true)

        do {
            let socket = Socket(context: viewContext)
            socket.title = "8-pin NEM652"
            socket.numberOfPins = 8

            sockets[8] = socket

            let decoderType = DecoderType(context: viewContext)
            decoderType.socket = socket
            decoderType.manufacturer = "ESU"
            decoderType.catalogNumber = "58420"
            decoderType.catalogName = "LokSound 5 DCC"
            decoderType.catalogFamily = "LokSound 5"
            decoderType.catalogDescription = "LokSound 5 DCC \"blank decoder\", 8-pin NEM652, gauge: 0, H0"
            decoderType.isProgrammable = true
            decoderType.isSoundSupported = true
            decoderType.isRailComSupported = true
            decoderType.setPreviewImage(named: "58420")

            decoderTypes["58420"] = decoderType
        }

        do {
            let socket = Socket(context: viewContext)
            socket.title = "21MTC"
            socket.numberOfPins = 21

            sockets[21] = socket

            let decoderType = DecoderType(context: viewContext)
            decoderType.socket = socket
            decoderType.manufacturer = "ESU"
            decoderType.catalogNumber = "58429"
            decoderType.catalogName = "LokSound 5 DCC"
            decoderType.catalogFamily = "LokSound 5"
            decoderType.catalogDescription = "LokSound 5 DCC \"blank decoder\", 21MTC NEM6660, gauge: 0, H0"
            decoderType.isProgrammable = true
            decoderType.isSoundSupported = true
            decoderType.isRailComSupported = true
            decoderType.setPreviewImage(named: "58429")
            decoderType.minimumStock = 5

            decoderTypes["58429"] = decoderType
            
            for serial in 1...decoderType.minimumStock {
                let decoder = Decoder(context: viewContext)
                decoder.type = decoderType
                decoder.serialNumber = "\(serial)"
            }
        }

        do {
            let socket = Socket(context: viewContext)
            socket.title = "PluX22"
            socket.numberOfPins = 22

            sockets[22] = socket

            let decoderType = DecoderType(context: viewContext)
            decoderType.socket = socket
            decoderType.manufacturer = "ESU"
            decoderType.catalogNumber = "58412"
            decoderType.catalogName = "LokSound 5"
            decoderType.catalogFamily = "LokSound 5"
            decoderType.catalogDescription = "LokSound 5 DCC/MM/SX/M4 \"blank decoder\", PluX22, with speaker 11x15mm, gauge: 0, H0"
            decoderType.isProgrammable = true
            decoderType.isSoundSupported = true
            decoderType.isRailComSupported = true
            decoderType.setPreviewImage(named: "58412")
            decoderType.minimumStock = 5

            decoderTypes["58412"] = decoderType
            
            for serial in 1...(decoderType.minimumStock - 2) {
                let decoder = Decoder(context: viewContext)
                decoder.type = decoderType
                decoder.serialNumber = "\(serial)"
            }
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

            let straightTrack = purchase.addAccessory()
            straightTrack.manufacturer = "Hornby"
            straightTrack.catalogNumber = "R600"
            straightTrack.catalogDescription = "Straight Track"
            straightTrack.setPreviewImage(named: "R600")

            for _ in 0..<8 {
                let accessory = purchase.addAccessory()
                accessory.manufacturer = "Hornby"
                accessory.catalogNumber = "R609"
                accessory.catalogDescription = "Double Curve - 3rd Radius"
                accessory.setPreviewImage(named: "R609")
            }

            let powerTrack = purchase.addAccessory()
            powerTrack.manufacturer = "Hornby"
            powerTrack.catalogNumber = "R8206"
            powerTrack.catalogDescription = "Power Track"
            powerTrack.setPreviewImage(named: "R8206")

            accessories["R8206"] = powerTrack

            let powerController = purchase.addAccessory()
            powerController.manufacturer = "Hornby"
            powerController.catalogNumber = "R7229"
            powerController.catalogDescription = "Analogue Train and Accessory Controller"
            powerController.setPreviewImage(named: "R7229")

            let powerTransformer = purchase.addAccessory()
            powerTransformer.manufacturer = "Hornby"
            powerTransformer.catalogNumber = "P9000"
            powerTransformer.catalogDescription = "Standard Wall Plug Mains Transformer"
            powerTransformer.setPreviewImage(named: "P9000")

            let rerailer = purchase.addAccessory()
            rerailer.manufacturer = "Hornby"
            rerailer.catalogNumber = "HUB68"
            rerailer.catalogDescription = "Rerailer"
            rerailer.setPreviewImage(named: "HUB68")
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
