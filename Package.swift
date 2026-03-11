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
            url: "https://github.com/alanchen/WebRTC/releases/download/146.0.0/WebRTC-M146.xcframework.zip",
            checksum: "01734ef4556afcce00a1314c9fd7894ba820de05debfd31a01279cde805e427e"
        ),
    ]
)
