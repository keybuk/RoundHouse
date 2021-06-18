//
//  ContentView.swift
//  Shared
//
//  Created by Scott James Remnant on 6/12/21.
//

import SwiftUI

struct ContentView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    var body: some View {
        #if os(iOS)
        // BUG(FB9182105) This is a workaround; by not using the three-pane view on iPhone we
        // get a functional app.
        if horizontalSizeClass == .compact {
            CompactAppSidebarNavigation()
        } else {
            AppSidebarNavigation()
        }
        #elseif os(macOS)
        AppSidebarNavigation()
        #endif
    }
}

struct AppSidebarNavigation: View {
    var body: some View {
        NavigationView {
            AppSidebar()

            // BUG(FB9182070) On iPad these will show placeholders until the sidebar is revealed.
            Text("List Placeholder")
            Text("Detail Placeholder")
        }
    }
}

struct CompactAppSidebarNavigation: View {
    var body: some View {
        NavigationView {
            AppSidebar()

            Text("Placeholder")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PreviewData.shared.viewContext)
    }
}
