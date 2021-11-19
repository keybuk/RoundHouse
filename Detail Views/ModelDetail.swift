//
//  ModelDetail.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 8/30/21.
//

import SwiftUI

extension Model {
    var lightsList: [String] {
        (lights as! Set<Light>?)?
            .map(\.title!)
            .sorted()
        ?? []
    }

    var couplingsList: [String] {
        (couplings as! Set<Coupling>?)?
            .map(\.title!)
            .sorted()
        ?? []
    }
    
    var featuresList: [String] {
        (features as! Set<Feature>?)?
            .map(\.title!)
            .sorted()
        ?? []
    }

    var detailPartsList: [String] {
        (detailParts as! Set<DetailPart>?)?
            .compactMap({ "\($0.title!)" + ($0.isFitted ? " ✔️" : "") })
            .sorted()
        ?? []
    }

    var modificationsList: [String] {
        (modifications as! Set<Modification>?)?
            .map(\.title!)
            .sorted()
        ?? []
    }

    var tasksList: [String] {
        (tasks as! Set<Task>?)?
            .map(\.title!)
            .sorted()
        ?? []
    }
    
    var speakersList: [Speaker] {
        (speakers as! Set<Speaker>?)?
            .sorted(by: { $0.title! < $1.title! })
        ?? []
    }
}

extension Speaker {
    var fittingsList: [String] {
        (fittings as! Set<SpeakerFitting>?)?
            .map(\.title!)
            .sorted()
        ?? []
    }
}

struct ModelDetail: View {
    @ObservedObject var model: Model
    var showPurchase: Bool = true

    let dateFormat = Date.FormatStyle.dateTime
        .year().month(.defaultDigits).day()

    var body: some View {
        List {
            Section {
                if let image = model.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                if showPurchase {
                    NavigationLink {
                        PurchaseView(purchase: model.purchase!)
                    } label: {
                        ModelPurchaseCell(purchase: model.purchase!)
                    }
                }
            }
            
            Section("Model") {
                Group {
                    if let classification = model.classification {
                        ModelDetailRow(title: "Classification") {
                            Text(classification.description)
                        }
                    }
                    
                    if !model.modelClass!.isEmpty {
                        ModelDetailRow(title: "Class") {
                            Text(model.modelClass!)
                        }
                    }

                    if (model.classification == .dieselElectricLocomotive || model.classification == .steamLocomotive) && !model.wheelArrangement!.isEmpty {
                        ModelDetailRow(title: "Wheel Arrangement") {
                            Text(model.wheelArrangement!)
                        }
                    }
                    
                    if model.classification == .multipleUnit && !model.vehicleType!.isEmpty {
                        ModelDetailRow(title: "Vehicle Type") {
                            Text(model.vehicleType!)
                        }
                    }
                }
                
                Group {
                    if !model.number!.isEmpty {
                        ModelDetailRow(title: "Number") {
                            Text(model.number!)
                        }
                    }

                    if !model.name!.isEmpty {
                        ModelDetailRow(title: "Name") {
                            Text(model.name!)
                        }
                    }
                }
                
                Group {
                    if !model.livery!.isEmpty {
                        ModelDetailRow(title: "Livery") {
                            Text(model.livery!)
                        }
                    }
                    
                    if !model.details!.isEmpty {
                        ModelDetailRow(title: "Details") {
                            Text(model.details!)
                        }
                    }

                    if let era = model.era {
                        ModelDetailRow(title: "Era") {
                            Text(era.description)
                        }
                    }
                    
                    ModelDetailRow(title: "Gauge") {
                        Text(model.gauge!)
                    }
                    
                    if let disposition = model.disposition {
                        ModelDetailRow(title: "Disposition") {
                            Text(disposition.description)
                        }
                    }
                }
            }
            
            // TODO: Train
            
            Section("Electrical") {
                if !model.motor!.isEmpty {
                    ModelDetailRow(title: "Motor") {
                        Text(model.motor!)
                    }
                }
                
                if let socket = model.socket {
                    ModelDetailRow(title: "Socket") {
                        Text(socket.title!)
                    }
                }

                if let decoder = model.decoder {
                    NavigationLink {
                        DecoderView(decoder: decoder)
                    } label: {
                        VStack(alignment: .leading) {
                            Text("Decoder")
                                .font(.caption)
                            if let decoderType = decoder.type {
                                Text(decoderType.catalogTitle)
                            }
                            if !decoder.serialNumber!.isEmpty {
                                Text(decoder.serialNumber!)
                                    .font(.caption)
                            }
                        }
                    }
                }

                if model.lights!.count > 0 {
                    ModelDetailRow(title: "Lights") {
                        Text(model.lightsList, format: .list(type: .and))
                    }
                }
                
                ForEach(model.speakersList) { speaker in
                    VStack(alignment: .leading) {
                        Text("Speaker")
                            .font(.caption)
                        Text(speaker.title!)
                    }
                    
                    if speaker.fittings!.count > 0 {
                        ModelDetailRow(title: "Fitting") {
                            Text(speaker.fittingsList, format: .list(type: .and))
                        }
                    }
                }
            }

            Section("Details") {
                if model.couplings!.count > 0 {
                    ModelDetailRow(title: "Couplings") {
                        Text(model.couplingsList, format: .list(type: .and))
                    }
                }
                
                if model.features!.count > 0 {
                    ModelDetailRow(title: "Features") {
                        Text(model.featuresList, format: .list(type: .and))
                    }
                }

                if model.detailParts!.count > 0 {
                    ModelDetailRow(title: "Detail Parts") {
                        Text(model.detailPartsList, format: .list(type: .and))
                    }
                }

                if model.modifications!.count > 0 {
                    ModelDetailRow(title: "Modifications") {
                        Text(model.modificationsList, format: .list(type: .and))
                    }
                }
            }
            
            Section("Maintenance") {
                if let lastRunDate = model.lastRunDate {
                    PurchaseDetailRow(title: "Last Run") {
                        Text(lastRunDate, format: dateFormat)
                    }
                }

                if let lastOilDate = model.lastOilDate {
                    PurchaseDetailRow(title: "Last Oil") {
                        Text(lastOilDate, format: dateFormat)
                    }
                }

                if model.tasks!.count > 0 {
                    ModelDetailRow(title: "Tasks") {
                        Text(model.tasksList, format: .list(type: .and))
                    }
                }
            }
            
            if !model.notes!.isEmpty {
                Section(header: Text("Notes")) {
                    Text(model.notes!)
                }
            }
        }
    }
}

struct ModelDetailRow<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
            content
        }
    }
}

struct ModelPurchaseCell: View {
    @ObservedObject var purchase: Purchase

    let dateFormat = Date.FormatStyle.dateTime
        .year().month(.defaultDigits).day()

    var body: some View {
        VStack(alignment: .leading) {
            Text(purchase.catalogTitle)
                .font(.headline)
            Text(purchase.date!, format: dateFormat) +
            Text(" from ") +
            Text(purchase.store!)
        }
    }
}

struct ModelDetail_Previews: PreviewProvider {
    static var previews: some View {
        ModelDetail(model: PreviewData.shared.models["R3804"]!)
    }
}

