// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Components",
    platforms: [
        .iOS(.v17), .watchOS(.v10), .macOS(.v14),
    ],
    products: [
        .library(
            name: "Components",
            targets: ["Components"]
        ),
    ],
    dependencies: [
        .package(name: "Models", path: "../Models"),
        .package(name: "Extensions", path: "../Extensions"),
        .package(url: "https://github.com/kean/Nuke.git", from: "12.1.6"),

    ],
    targets: [
        .target(
            name: "Components", dependencies: [
                .product(name: "Models", package: "Models"),
                .product(name: "Extensions", package: "Extensions"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
            ]
        ),
        .testTarget(
            name: "ComponentsTests",
            dependencies: ["Components"]
        ),
    ]
)
