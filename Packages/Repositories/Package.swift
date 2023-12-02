// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Repositories",
    platforms: [
        .iOS(.v17), .watchOS(.v10), .macOS(.v14),
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
            from: "1.0.0"
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
            ]
        ),
    ]
)
