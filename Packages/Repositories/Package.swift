// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Repositories",
    platforms: [
        .iOS(.v18),
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
            from: "2.17.1"
        ),
        .package(url: "https://github.com/hyperoslo/Cache", from: "7.2.0"),
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
                .product(name: "Cache", package: "Cache"),
            ]
        ),
    ],
    swiftLanguageModes: [.version("6")]
)
