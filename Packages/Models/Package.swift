// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [
        .iOS(.v17), .watchOS(.v10), .macOS(.v14),
    ],
    products: [
        .library(
            name: "Models",
            targets: ["Models"]
        ),
    ],
    dependencies: [
        .package(name: "Extensions", path: "../Extensions"),
    ],
    targets: [
        .target(
            name: "Models", dependencies: [.product(name: "Extensions", package: "Extensions"),
            ]
        ),
    ]
)
