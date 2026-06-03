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
            url: "https://github.com/alanchen/WebRTC/releases/download/149.0.0/WebRTC-M149.xcframework.zip",
            checksum: "6977d0a9932f103ce6320280931e86ac938ff0c39efdc1504b6936f4582404cf"
        ),
    ]
)
