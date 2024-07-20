// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Models",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18), .watchOS(.v11), .tvOS(.v17), .visionOS(.v2),
    ],
    products: [
        .library(
            name: "Models",
            targets: ["Models"]
        ),
    ],
    dependencies: [
        .package(name: "Extensions", path: "../Extensions"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.6.0"),
    ],
    targets: [
        .target(
            name: "Models", dependencies: [
                .product(name: "Extensions", package: "Extensions"),
                .product(name: "Tagged", package: "swift-tagged"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableExperimentalFeature("DisableOutwardActorInference"),
            ]
        ),
    ],
    swiftLanguageVersions: [.version("6")]
)
