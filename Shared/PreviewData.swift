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
    var decoders: [String: Decoder] = [:]

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
            decoderType.isRailComPlusSupported = true
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
            decoderType.isRailComPlusSupported = true
            decoderType.setPreviewImage(named: "58429")
            decoderType.minimumStock = 5

            decoderTypes["58429"] = decoderType
            
            for index in 1...decoderType.minimumStock {
                let decoder = Decoder(context: viewContext)
                decoder.type = decoderType
                decoder.serialNumber = "FFFF429\(index)"
                
                decoder.firmwareVersion = "5.0.0"
                decoder.firmwareDateComponents = DateComponents(year: 2021, month: 1, day: 1)

                decoders[decoder.serialNumber!] = decoder
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
            decoderType.isRailComPlusSupported = true
            decoderType.setPreviewImage(named: "58412")
            decoderType.minimumStock = 5

            decoderTypes["58412"] = decoderType
            
            for index in 1...(decoderType.minimumStock - 2) {
                let decoder = Decoder(context: viewContext)
                decoder.type = decoderType
                decoder.serialNumber = "FFFF412\(index)"

                decoder.firmwareVersion = "5.1.0"
                decoder.firmwareDateComponents = DateComponents(year: 2021, month: 2, day: 1)

                decoders[decoder.serialNumber!] = decoder
            }
        }

        do {
            let decoderType = DecoderType(context: viewContext)
            decoderType.socket = sockets[22]!
            decoderType.manufacturer = "Zimo"
            decoderType.catalogNumber = "MX645P22"
            decoderType.catalogFamily = "MX640"
            decoderType.isProgrammable = true
            decoderType.isSoundSupported = true
            decoderType.isRailComSupported = true
            decoderType.isRailComPlusSupported = true
            decoderType.setPreviewImage(named: "58412")
            decoderType.minimumStock = 0

            decoderTypes["MX645P22"] = decoderType
            
            let decoder = Decoder(context: viewContext)
            decoder.type = decoderType
            decoder.serialNumber = "200:200:10:1"

            decoder.firmwareVersion = "40.0"
            decoder.firmwareDateComponents = DateComponents(year: 2021, month: 2, day: 1)

            decoders[decoder.serialNumber!] = decoder
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

            // Named train that comes as a set in a single purchase.
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

            accessories["R7229"] = powerController

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
            let purchase = Purchase(context: viewContext)
            purchase.manufacturer = "Bachmann"
            purchase.catalogNumber = "32-908"
            purchase.catalogDescription = "Class 108 2-Car DMU BR Blue & Grey"
            purchase.catalogYear = 2020
            purchase.dateComponents = DateComponents(year: 2021, month: 1, day: 15)
            purchase.store = "Rails of Sheffield"
            purchase.price = 239.95
            purchase.condition = .new

            purchases["32-908"] = purchase

            let dmbs = purchase.addModel()
            dmbs.classification = .multipleUnit
            dmbs.setPreviewImage(named: "32-908a")
            dmbs.modelClass = "108"
            dmbs.vehicleType = "DMBS"
            dmbs.number = "53620"
            dmbs.livery = "BR Blue & Grey"
            dmbs.details = "Destination: Bristol Temple Meads"
            dmbs.era = .brCorporateBluePostTOPS
            dmbs.disposition = .normal
            dmbs.socket = sockets[8]

            models["32-908 DMBS"] = dmbs

            for title in ["Interior", "Directional", "Destination Blinds"] {
                let light = Light(context: viewContext)
                light.title = title
                dmbs.addToLights(light)
            }

            for title in ["NEM Socket", "Tension Lock (Small)", "Close-coupling"] {
                let coupling = Coupling(context: viewContext)
                coupling.title = title
                dmbs.addToCouplings(coupling)
            }

            let dtcl = purchase.addModel()
            dtcl.classification = .multipleUnit
            dtcl.setPreviewImage(named: "32-908b")
            dtcl.modelClass = "108"
            dtcl.vehicleType = "DTCL"
            dtcl.number = "54203"
            dtcl.livery = "BR Blue & Grey"
            dtcl.details = "Destination: Taunton"
            dtcl.era = .brCorporateBluePostTOPS
            dtcl.disposition = .normal
            dtcl.socket = sockets[8]

            for title in ["Interior", "Directional", "Destination Blinds"] {
                let light = Light(context: viewContext)
                light.title = title
                dtcl.addToLights(light)
            }

            for title in ["NEM Socket", "Tension Lock (Small)", "Close-coupling"] {
                let coupling = Coupling(context: viewContext)
                coupling.title = title
                dtcl.addToCouplings(coupling)
            }

            models["32-908 DTCL"] = dtcl

            // Numbered multiple unit train.
            let train = Train(context: viewContext)
            train.number = "108 B968"

            let dmbsMember = train.addMember()
            dmbsMember.modelClass = "DMBS"
            dmbsMember.model = dmbs

            let dtclMember = train.addMember()
            dtclMember.modelClass = "DTCL"
            dtclMember.model = dtcl

            trains["108 B968"] = train
        }

        do {
            let purchase = Purchase(context: viewContext)
            purchase.manufacturer = "Accurascale"
            purchase.catalogNumber = "ACC2093DRG"
            purchase.catalogDescription = "PFA - DRS LLNW - Dragon Pack 1"
            purchase.catalogYear = 2021
            purchase.dateComponents = DateComponents(year: 2021, month: 6, day: 1)
            purchase.store = "Accurascale"
            purchase.price = 62.46
            purchase.condition = .new

            purchases["ACC2093DRG"] = purchase

            let wagon1 = purchase.addModel()
            wagon1.classification = .wagon
            wagon1.setPreviewImage(named: "ACC2093DRGa")
            wagon1.modelClass = "PFA"
            wagon1.number = "DRSL 92736"
            wagon1.livery = "DRS Light Blue"
            wagon1.era = .currentEra
            wagon1.disposition = .normal

            models["DRSL 92736"] = wagon1

            let wagon2 = purchase.addModel()
            wagon2.classification = .wagon
            wagon2.setPreviewImage(named: "ACC2093DRGb")
            wagon2.modelClass = "PFA"
            wagon2.number = "DRSL 92779"
            wagon2.livery = "DRS Blue"
            wagon2.era = .currentEra
            wagon2.disposition = .normal

            models["DRSL 92779"] = wagon2

            let wagon3 = purchase.addModel()
            wagon3.classification = .wagon
            wagon3.setPreviewImage(named: "ACC2093DRGc")
            wagon3.modelClass = "PFA"
            wagon3.number = "DRSL 92798"
            wagon3.livery = "DRS Grey"
            wagon3.era = .currentEra
            wagon3.disposition = .normal

            models["DRSL 92798"] = wagon3
        }

        do {
            let purchase = Purchase(context: viewContext)
            purchase.manufacturer = "Bachmann"
            purchase.catalogNumber = "35-125SF"
            purchase.catalogDescription = "Class 20/3 20306 DRS Blue Diesel Locomotive (DCC Sound)"
            purchase.catalogYear = 2021
            purchase.dateComponents = DateComponents(year: 2021, month: 6, day: 7)
            purchase.store = "Rails of Sheffield"
            purchase.price = 237.95
            purchase.condition = .new

            purchases["35-125SF"] = purchase

            let locomotive = purchase.addModel()
            locomotive.classification = .dieselElectricLocomotive
            locomotive.setPreviewImage(named: "35-125SF")
            locomotive.modelClass = "20/3"
            locomotive.number = "20306"
            locomotive.livery = "DRS Blue"
            locomotive.era = .initialPrivatisation
            locomotive.disposition = .normal
            locomotive.socket = sockets[22]
            locomotive.motor = "5-pole with twin flywheels"

            models["35-125SF"] = locomotive

            for title in ["Cab", "Directional", "Day/Night"] {
                let light = Light(context: viewContext)
                light.title = title
                locomotive.addToLights(light)
            }

            for title in ["NEM Socket", "Tension Lock (Small)"] {
                let coupling = Coupling(context: viewContext)
                coupling.title = title
                locomotive.addToCouplings(coupling)
            }

            let decoder = decoderTypes["58412"]!.addDecoder()
            decoder.address = 3
            decoder.serialNumber = "FFFF0306"
            decoder.soundAuthor = "Bachmann"
            decoder.soundProject = "20/3"

            decoder.firmwareVersion = "5.2.0"
            decoder.firmwareDateComponents = DateComponents(year: 2021, month: 3, day: 1)

            locomotive.decoder = decoder
        }

        do {
            let purchase = Purchase(context: viewContext)
            purchase.manufacturer = "Bachmann"
            purchase.catalogNumber = "35-127SF"
            purchase.catalogDescription = "Class 20/3 20312 DRS Compass (Original)"
            purchase.catalogYear = 2021
            purchase.dateComponents = DateComponents(year: 2021, month: 6, day: 10)
            purchase.store = "Rails of Sheffield"
            purchase.price = 279.95
            purchase.condition = .new

            purchases["35-127SF"] = purchase

            let locomotive = purchase.addModel()
            locomotive.classification = .dieselElectricLocomotive
            locomotive.setPreviewImage(named: "35-127SF")
            locomotive.modelClass = "20/3"
            locomotive.number = "20312"
            locomotive.livery = "DRS Compass"
            locomotive.era = .initialPrivatisation
            locomotive.disposition = .normal
            locomotive.socket = sockets[22]
            locomotive.motor = "5-pole with twin flywheels"

            models["35-127SF"] = locomotive

            for title in ["Cab", "Directional", "Day/Night"] {
                let light = Light(context: viewContext)
                light.title = title
                locomotive.addToLights(light)
            }

            for title in ["NEM Socket", "Tension Lock (Small)"] {
                let coupling = Coupling(context: viewContext)
                coupling.title = title
                locomotive.addToCouplings(coupling)
            }

            let decoder = decoderTypes["58412"]!.addDecoder()
            decoder.address = 3
            decoder.serialNumber = "FFFF0312"
            decoder.soundAuthor = "Bachmann"
            decoder.soundProject = "20/3"

            decoder.firmwareVersion = "5.2.0"
            decoder.firmwareDateComponents = DateComponents(year: 2021, month: 3, day: 1)

            locomotive.decoder = decoder
        }

        // Train made up from multiple purchases with a description rather than a name or number.
        do {
            let train = Train(context: viewContext)
            train.trainDescription = "DRS Nuclear Flask Train"

            let frontLocomotiveMember = train.addMember()
            frontLocomotiveMember.modelClass = "20/3"
            frontLocomotiveMember.model = models["35-125SF"]

            let wagon1Member = train.addMember()
            wagon1Member.modelClass = "FNA DRSL"
            wagon1Member.model = models["DRSL 92736"]

            let wagon2Member = train.addMember()
            wagon2Member.modelClass = "FNA DRSL"
            wagon2Member.model = models["DRSL 92779"]

            let wagon3Member = train.addMember()
            wagon3Member.modelClass = "FNA DRSL"
            wagon3Member.model = models["DRSL 92798"]

            let rearLocomotiveMember = train.addMember()
            rearLocomotiveMember.modelClass = "20/3"
            rearLocomotiveMember.model = models["35-127SF"]

            trains["DRS"] = train
        }

        // Missing Departmental
        // Missing No Protoype
        // Missing Vehicle

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
