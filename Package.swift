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
            url: "https://github.com/alanchen/WebRTC/releases/download/145.0.0/WebRTC-M145.xcframework.zip",
            checksum: "539247bce4e3197e631d21164e45d5ba3ed83cad726cd422e6497c649dd950cc"
        ),
    ]
)
