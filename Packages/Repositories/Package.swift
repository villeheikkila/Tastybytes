// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Repositories",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Repositories",
            targets: ["Repositories"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", branch: "master"),
        .package(name: "Models", path: "../Models"),
    ],
    targets: [
        .target(
            name: "Repositories",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "Models", package: "Models"),
            ]
        ),
    ]
)
