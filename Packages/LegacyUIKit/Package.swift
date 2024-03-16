// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "LegacyUIKit",
    platforms: [
        .iOS(.v17),
    ],

    products: [
        .library(
            name: "LegacyUIKit",
            targets: ["LegacyUIKit"]
        ),
    ],
    targets: [
        .target(
            name: "LegacyUIKit",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
    ]
)
