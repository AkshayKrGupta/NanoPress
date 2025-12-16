import SwiftUI

@main
struct NanoPressApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            SidebarCommands()
            
            CommandGroup(after: .newItem) {
                Button("Browse Files...") {
                    NotificationCenter.default.post(name: NSNotification.Name("BrowseFiles"), object: nil)
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Start Compression") {
                    NotificationCenter.default.post(name: NSNotification.Name("StartCompression"), object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Divider()
                
                Button("Remove Selected") {
                    NotificationCenter.default.post(name: NSNotification.Name("RemoveSelected"), object: nil)
                }
                .keyboardShortcut(.delete, modifiers: .command)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.isOpaque = false
            window.backgroundColor = .clear
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
        }
    }
}
