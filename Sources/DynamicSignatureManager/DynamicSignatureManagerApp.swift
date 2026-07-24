import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu bar app: no Dock icon, no app switcher entry.
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct DynamicSignatureManagerApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        MenuBarExtra("Dynamic Signature Manager", systemImage: "quote.bubble") {
            MenuBarView()
                .environmentObject(model)
        }
        .menuBarExtraStyle(.window)

        Window("Quote Library", id: WindowID.quoteLibrary) {
            QuoteLibraryView()
                .environmentObject(model)
        }
        .defaultSize(width: 680, height: 480)

        Settings {
            SettingsView()
                .environmentObject(model)
        }
    }
}

enum WindowID {
    static let quoteLibrary = "quoteLibrary"
}
