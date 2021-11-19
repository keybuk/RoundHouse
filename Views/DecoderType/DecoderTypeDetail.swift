//
//  DecoderTypeDetail.swift
//  DecoderTypeDetail
//
//  Created by Scott James Remnant on 9/3/21.
//

import SwiftUI

struct DecoderTypeDetail: View {
    @ObservedObject var decoderType: DecoderType
    var showDecoders: Bool = true

    var body: some View {
        List {
            Section {
                if let image = decoderType.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            
            DecoderTypeCatalog(decoderType: decoderType)
            
            DecoderTypeFeatures(decoderType: decoderType)

            Section("Stock") {
                FormattedTextFieldRow("Minimum Stock", value: $decoderType.minimumStock, format: .number)
            }
            
            if showDecoders {
                DecoderTypeDecoders(decoderType: decoderType)
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

struct DecoderTypeCatalog: View {
    @ObservedObject var decoderType: DecoderType
    
    var body: some View {
        Section("Catalog") {
            SuggestingTextFieldRow("Manufacturer",text: Binding($decoderType.manufacturer, default: ""), suggestions: decoderType.suggestionsForManufacturer(matching:))
            
            TextFieldRow("Number", text: Binding($decoderType.catalogNumber, default: ""))
            
            TextFieldRow("Name", text: Binding($decoderType.catalogName, default: ""))
            
            SuggestingTextFieldRow("Family", text: Binding($decoderType.catalogFamily, default: ""), suggestions: decoderType.suggestionsForCatalogFamily(matching:))
            
            // Description: multi-line text
                        
            TextEditorRow("Description", text: Binding($decoderType.catalogDescription, default: ""))
                .lineLimit(0)
        }
        .onSubmit {
            print("SECTION SUBMIT!")
        }
    }
}

struct DecoderTypeFeatures: View {
    @ObservedObject var decoderType: DecoderType

    var body: some View {
        Section("Features") {
            SocketPicker("Socket", socket: $decoderType.socket)
            
            ToggleableRow("Programmable", value: $decoderType.isProgrammable)

            ToggleableRow("Sound", value: $decoderType.isSoundSupported)

            ToggleableRow("RailCom", value: $decoderType.isRailComSupported)

            ToggleableRow("RailCom Plus", value: $decoderType.isRailComPlusSupported)
        }
    }
}

struct DecoderTypeDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DecoderTypeDetail(decoderType: PreviewData.shared.decoderTypes["58412"]!)
        }
    }
}

