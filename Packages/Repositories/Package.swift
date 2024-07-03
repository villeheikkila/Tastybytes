// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Repositories",
    platforms: [
        .iOS(.v18), .watchOS(.v11), .tvOS(.v17), .visionOS(.v2),
    ],
    products: [
        .library(
            name: "Repositories",
            targets: ["Repositories"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/supabase-community/supabase-swift.git",
            from: "2.13.7"
        ),
        .package(name: "Models", path: "../Models"),
        .package(name: "Extensions", path: "../Extensions"),
    ],
    targets: [
        .target(
            name: "Repositories",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
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
