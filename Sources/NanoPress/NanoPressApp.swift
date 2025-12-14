import SwiftUI

@main
struct NanoPressApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            SidebarCommands() // Standard sidebar commands if we need them, mostly just to be a "good citizen"
        }
    }
}
