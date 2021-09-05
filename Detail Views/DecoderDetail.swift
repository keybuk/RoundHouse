//
//  DecoderDetail.swift
//  DecoderDetail
//
//  Created by Scott James Remnant on 9/5/21.
//

import SwiftUI

struct DecoderDetail: View {
    @ObservedObject var decoder: Decoder
    var showType: Bool = true

    let dateFormat = Date.FormatStyle.dateTime
        .year().month(.defaultDigits).day()

    var body: some View {
        List {
            Section {
                if showType, let decoderType = decoder.type {
                    NavigationLink {
                        DecoderTypeDetail(decoderType: decoderType, showDecoders: false)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(decoderType.catalogTitle)
                                .font(.headline)
                            if let socket = decoderType.socket {
                                Text(socket.title!)
                                .font(.caption)
                            }
                        }
                    }
                }
                
                if !decoder.serialNumber!.isEmpty {
                    DecoderDetailRow(title: "Serial Number") {
                        Text(decoder.serialNumber!)
                    }
                }

                DecoderDetailRow(title: "Address") {
                    Text(decoder.address, format: .number)
                }
            }

            Section("Firmware") {
                if !decoder.firmwareVersion!.isEmpty {
                    DecoderDetailRow(title: "Version") {
                        Text(decoder.firmwareVersion!)
                    }
                }
                
                if let firmwareDate = decoder.firmwareDate {
                    DecoderDetailRow(title: "Date") {
                        Text(firmwareDate, format: dateFormat)
                    }
                }
            }
            
            Section("Sound Project") {
                if !decoder.soundAuthor!.isEmpty {
                    DecoderDetailRow(title: "Author") {
                        Text(decoder.soundAuthor!)
                    }
                }

                if !decoder.soundProject!.isEmpty {
                    DecoderDetailRow(title: "Project") {
                        Text(decoder.soundProject!)
                    }
                }
                
                if !decoder.soundProjectVersion!.isEmpty {
                    DecoderDetailRow(title: "Version") {
                        Text(decoder.soundProjectVersion!)
                    }
                }
                
                if !decoder.soundSettings!.isEmpty {
                    DecoderDetailRow(title: "Settings") {
                        Text(decoder.soundSettings!)
                    }
                }
            }
        }
    }
}

struct DecoderDetailRow<Content: View>: View {
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

struct DecoderDetail_Previews: PreviewProvider {
    static var previews: some View {
        DecoderDetail(decoder: PreviewData.shared.decoders["FFFF4291"]!)
    }
}
