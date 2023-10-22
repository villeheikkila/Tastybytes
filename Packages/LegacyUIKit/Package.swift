// swift-tools-version: 5.9

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
            name: "LegacyUIKit"
        ),
    ]
)
