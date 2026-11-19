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
            url: "https://github.com/alanchen/WebRTC/releases/download/158.0.0/WebRTC-M158.xcframework.zip",
            checksum: "ec6878348dc0f98f9714a5b9a85d4216a1e50768225d469ae116a663486b2696"
        ),
    ]
)
