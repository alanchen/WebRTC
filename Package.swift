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
            url: "https://github.com/alanchen/WebRTC/releases/download/153.0.0/WebRTC-M153.xcframework.zip",
            checksum: "dc3ab804a9f9855cf6b2f017d09201cbed4e072a45b350e2bb4f0a3aab1f5ea9"
        ),
    ]
)
