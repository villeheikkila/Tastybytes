// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Models",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17), .watchOS(.v10), .tvOS(.v14), .visionOS(.v1),
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
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableExperimentalFeature("DisableOutwardActorInference"),
            ]
        ),
    ]
)
