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
            url: "https://github.com/alanchen/WebRTC/releases/download/154.0.0/WebRTC-M154.xcframework.zip",
            checksum: "d0c501d74fd4b714d81f4055715631db92f9ec7de07fc4b761342259e79b84a6"
        ),
    ]
)
