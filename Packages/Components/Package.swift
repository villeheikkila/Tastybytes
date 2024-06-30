// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Components",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18), .watchOS(.v11), .tvOS(.v17), .visionOS(.v2),
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
        .package(url: "https://github.com/kean/Nuke.git", from: "12.7.3"),
        .package(url: "https://github.com/muukii/Brightroom.git", exact: "3.0.0-beta.5"),
        .package(url: "https://github.com/daprice/BlurHashViews.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Components",
            dependencies: [
                .product(name: "Models", package: "Models"),
                .product(name: "Extensions", package: "Extensions"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
                .product(name: "BrightroomEngine", package: "Brightroom"),
                .product(name: "BrightroomUI", package: "Brightroom"),
                .product(name: "BrightroomUIPhotosCrop", package: "Brightroom"),
                .product(name: "BlurHashViews", package: "blurhashviews")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableExperimentalFeature("DisableOutwardActorInference"),
            ]
        ),
    ],
    swiftLanguageVersions: [.version("6")]
)
