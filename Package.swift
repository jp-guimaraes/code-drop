// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "code-drop",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "code-drop", path: "Sources/code-drop")
    ]
)
