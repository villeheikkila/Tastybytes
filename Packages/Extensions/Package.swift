// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Extensions",
    platforms: [
        .iOS(.v17), .watchOS(.v10),
    ],
    products: [
        .library(
            name: "Extensions",
            targets: ["Extensions"]
        ),
    ],
    targets: [
        .target(
            name: "Extensions"
        ),
        .testTarget(
            name: "ExtensionsTests",
            dependencies: ["Extensions"]
        ),
    ]
)
