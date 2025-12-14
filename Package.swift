// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NanoPress",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "NanoPress", targets: ["NanoPress"])
    ],
    targets: [
        .executableTarget(
            name: "NanoPress",
            dependencies: [],
            path: "Sources/NanoPress",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
