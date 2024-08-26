// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Extensions",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "Extensions",
            targets: ["Extensions"]
        ),
    ],
    targets: [
        .target(name: "Extensions"),
    ],
    swiftLanguageModes: [.version("6")]
)
