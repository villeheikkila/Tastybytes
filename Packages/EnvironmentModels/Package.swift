// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "EnvironmentModels",
    platforms: [
        .iOS(.v17), .watchOS(.v10), .macOS(.v14),
    ],
    products: [
        .library(
            name: "EnvironmentModels",
            targets: ["EnvironmentModels"]
        ),
    ],
    dependencies: [
        .package(name: "Repositories", path: "../Repositories"),
        .package(name: "Models", path: "../Models"),
        .package(name: "Extensions", path: "../Extensions"),
    ],
    targets: [
        .target(
            name: "EnvironmentModels",
            dependencies: [
                .product(name: "Repositories", package: "Repositories"),
                .product(name: "Models", package: "Models"),
                .product(name: "Extensions", package: "Extensions"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
    ]
)
