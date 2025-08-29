// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SyphonWeb",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.4")
    ],
    targets: [
        .binaryTarget(
            name: "Syphon",
            path: "./third_party/Syphon.xcframework"
        ),
        .executableTarget(
            name: "SyphonWeb",
            dependencies: ["Syphon", .product(name: "SQLite", package: "sqlite.swift")],
            swiftSettings: [
                // Again. More hacks to use Syphon framework outside of the usual XCode environment. Ugh.
                .unsafeFlags([
                    "-I",
                    "./third_party/Syphon.xcframework/macos-arm64_x86_64/Syphon.framework/Headers",
                ])
            ]
        ),
    ]
)
