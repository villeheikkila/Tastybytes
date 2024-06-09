// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Repositories",
    platforms: [
        .iOS(.v17), .watchOS(.v10), .tvOS(.v14), .visionOS(.v1),
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
            from: "2.13.2"
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
    ]
)
