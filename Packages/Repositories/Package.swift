// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Repositories",
    products: [
        .library(
            name: "Repositories",
            targets: ["Repositories"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Repositories",
            dependencies: ["Supabase"]
        ),
        .testTarget(
            name: "RepositoriesTests",
            dependencies: ["Repositories"]
        ),
    ]
)
