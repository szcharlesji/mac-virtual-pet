import Cocoa
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var petWindow: NSWindow?
    var petViewController: PetViewController?
    
    // Define a smaller window width
    private let windowWidth: CGFloat = 300
    
    // Character name from command line argument
    var characterName: String = "pet"
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create a window for the pet with the constrained width
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: 100),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.backgroundColor = .clear
        window.isOpaque = false
        window.level = .popUpMenu // Stay above all windows
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        window.ignoresMouseEvents = true // Ignore mouse events completely
        
        // Create and set the pet view controller with the character name
        let petVC = PetViewController()
        petVC.characterName = characterName
        window.contentViewController = petVC
        self.petViewController = petVC
        
        // Position the window at the bottom left of the screen
        if let screen = NSScreen.main {
            let screenRect = screen.frame
            window.setFrameOrigin(NSPoint(
                x: screenRect.minX,
                y: screenRect.minY
            ))
        }
        
        window.makeKeyAndOrderFront(nil)
        self.petWindow = window
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // No timers to invalidate anymore
    }
}
