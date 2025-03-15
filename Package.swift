// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mac-virtual-pet",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "mac-virtual-pet", targets: ["mac-virtual-pet"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "mac-virtual-pet",
            dependencies: [],
            path: "Sources/mac-virtual-pet",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
