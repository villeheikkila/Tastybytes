// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EnvironmentModels",
    platforms: [
        .iOS(.v18), .watchOS(.v11), .tvOS(.v17), .visionOS(.v2),
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
                .enableExperimentalFeature("DisableOutwardActorInference"),
            ]
        ),
    ],
    swiftLanguageVersions: [.version("6")]
)
