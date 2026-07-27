import SwiftUI

@main
struct DynamicSignatureMobileApp: App {

    @StateObject private var model = MobileAppModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
        }
        .onChange(of: scenePhase) { _, phase in
            // No background execution on iOS: catch up on rotation whenever
            // the app comes to the foreground.
            if phase == .active {
                model.rotateIfDue()
            }
        }
    }
}
