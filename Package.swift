// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "WebRTC",
    platforms: [.iOS(.v10), .macOS(.v10_11)],
    products: [
        .library(
            name: "WebRTC",
            targets: ["WebRTC"]),
    ],
    dependencies: [ ],
    targets: [
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/alanchen/WebRTC/releases/download/151.0.0/WebRTC-M151.xcframework.zip",
            checksum: "595f2ee8b1ed9403e4958da110f6cf9ea53819e0cb00a00dd51d17053d95f39a"
        ),
    ]
)
