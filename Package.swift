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
            url: "https://github.com/alanchen/WebRTC/releases/download/148.0.0/WebRTC-M148.xcframework.zip",
            checksum: "612c0ea2eac03e39bd530424330c62789c254c1b9a77d30dadd60208422cd290"
        ),
    ]
)
