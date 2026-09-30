import Foundation

let args = Array(CommandLine.arguments.dropFirst())
if args.isEmpty {
    runMenuBarApp()
} else {
    exit(CLI.run(args))
}
