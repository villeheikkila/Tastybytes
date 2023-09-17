// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [
        .iOS(.v17), .watchOS(.v10),
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
            name: "Models"
        ),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["Models"]
        ),
    ]
)
