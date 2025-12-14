// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NanoPress",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "NanoPress", targets: ["NanoPress"])
    ],
    targets: [
        .executableTarget(
            name: "NanoPress",
            path: "Sources/NanoPress",
            resources: []
        )
    ]
)
