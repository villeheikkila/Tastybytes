// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Components",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "Components",
            targets: ["Components"]
        ),
    ],
    dependencies: [
        .package(name: "Extensions", path: "../Extensions"),
        .package(url: "https://github.com/muukii/Brightroom.git", exact: "3.0.0-beta.5"),
        .package(url: "https://github.com/daprice/BlurHashViews.git", from: "1.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.1.0"),
    ],
    targets: [
        .target(
            name: "Components",
            dependencies: [
                .product(name: "Extensions", package: "Extensions"),
                .product(name: "BrightroomEngine", package: "Brightroom"),
                .product(name: "BrightroomUI", package: "Brightroom"),
                .product(name: "BrightroomUIPhotosCrop", package: "Brightroom"),
                .product(name: "BlurHashViews", package: "blurhashviews"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS"),
            ]
        ),
    ],
    swiftLanguageModes: [.version("6")]
)
