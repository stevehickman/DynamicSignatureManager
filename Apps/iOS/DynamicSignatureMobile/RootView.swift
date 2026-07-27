import SwiftUI

struct RootView: View {

    var body: some View {
        TabView {
            SignatureView()
                .tabItem { Label("Signature", systemImage: "quote.bubble") }

            QuoteLibraryView()
                .tabItem { Label("Quotes", systemImage: "text.book.closed") }

            ProfilesView()
                .tabItem { Label("Profiles", systemImage: "person.2") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
