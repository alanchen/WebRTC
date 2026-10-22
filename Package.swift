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
            url: "https://github.com/alanchen/WebRTC/releases/download/150.0.0/WebRTC-M150.xcframework.zip",
            checksum: "399b0d744d66d1653cad87a5056d6c4c47fa2447decd769d2efc3e84ab60252c"
        ),
    ]
)
