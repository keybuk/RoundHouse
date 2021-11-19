//
//  SocketPicker.swift
//  SocketPicker
//
//  Created by Scott James Remnant on 9/6/21.
//

import SwiftUI
import CoreData

struct SocketPicker: View {
    var title: String
    @Binding var socket: Socket?
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\Socket.numberOfPins), SortDescriptor(\Socket.title)],
        animation: .default)
    var sockets: FetchedResults<Socket>

    init(_ title: String, socket: Binding<Socket?>) {
        self.title = title
        self._socket = socket
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Socket")
                .font(.caption)

            Picker(selection: $socket) {
                ForEach(sockets) { socket in
                    Text(socket.title!)
                        .tag(socket.id)
                }
                
                Text("None")
            } label: {
                Text(socket?.title! ?? "None")
            }
        }
    }
}

struct SocketPicker_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                SocketPicker("Socket", socket: .constant(PreviewData.shared.sockets[22]!))

                SocketPicker("Socket", socket: .constant(nil))
            }
        }
        .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
