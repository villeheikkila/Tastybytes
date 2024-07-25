// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Extensions",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18), .watchOS(.v11), .tvOS(.v17), .visionOS(.v2),
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
    swiftLanguageVersions: [.version("6")]
)
