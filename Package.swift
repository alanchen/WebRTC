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
            url: "https://github.com/alanchen/WebRTC/releases/download/156.0.0/WebRTC-M156.xcframework.zip",
            checksum: "38c11e40bd6b204eb8ef6dd8cc71026e908f37c3ea3bd4b5da20c953065d5bcd"
        ),
    ]
)
