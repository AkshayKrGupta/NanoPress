import SwiftUI

@main
struct NanoPressApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle()) // Still useful for the full content look
        .commands {
            SidebarCommands()
        }
    }
}
