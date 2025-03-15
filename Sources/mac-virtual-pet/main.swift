import Cocoa

// Get the character name from command line arguments or use "pet" as default
let characterName = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "pet"

let app = NSApplication.shared
let delegate = AppDelegate()
delegate.characterName = characterName
app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
