//
//  DecoderTypeDetail.swift
//  DecoderTypeDetail
//
//  Created by Scott James Remnant on 9/3/21.
//

import SwiftUI

struct DecoderTypeDetail: View {
    @ObservedObject var decoderType: DecoderType

    var body: some View {
        List {
            Section {
                if let image = decoderType.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            
            Section("Catalog") {
                if !decoderType.manufacturer!.isEmpty {
                    DecoderTypeDetailRow(title: "Manufacturer") {
                        Text(decoderType.manufacturer!)
                    }
                }

                if !decoderType.catalogNumber!.isEmpty {
                    DecoderTypeDetailRow(title: "Number") {
                        Text(decoderType.catalogNumber!)
                    }
                }

                if !decoderType.catalogName!.isEmpty {
                    DecoderTypeDetailRow(title: "Name") {
                        Text(decoderType.catalogName!)
                    }
                }

                if !decoderType.catalogFamily!.isEmpty {
                    DecoderTypeDetailRow(title: "Family") {
                        Text(decoderType.catalogFamily!)
                    }
                }

                if !decoderType.catalogDescription!.isEmpty {
                    DecoderTypeDetailRow(title: "Description") {
                        Text(decoderType.catalogDescription!)
                    }
                }
            }
            
            Section("Capabilities") {
                if decoderType.isProgrammable {
                    Text("Programmable")
                }
                if decoderType.isSoundSupported {
                    Text("Sound")
                }
                if decoderType.isRailComSupported {
                    Text("RailCom")
                }
            }

            Section("Stock") {
                DecoderTypeDetailRow(title: "Minimum Stock") {
                    Text(decoderType.minimumStock, format: .number)
                }
            }
        }
    }
}

struct DecoderTypeDetailRow<Content: View>: View {
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

struct DecoderTypeDetail_Previews: PreviewProvider {
    static var previews: some View {
        DecoderTypeDetail(decoderType: PreviewData.shared.decoderTypes["58412"]!)
    }
}
