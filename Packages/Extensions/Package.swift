// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Extensions",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17), .watchOS(.v10), .tvOS(.v14), .visionOS(.v1),
    ],
    products: [
        .library(
            name: "Extensions",
            targets: ["Extensions"]
        ),
    ],

    targets: [
        .target(
            name: "Extensions",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableExperimentalFeature("DisableOutwardActorInference"),
            ]
        ),
    ]
)
