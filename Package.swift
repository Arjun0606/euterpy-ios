// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Euterpy",
    platforms: [.iOS(.v17)],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "Euterpy",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ],
            path: "Euterpy/Sources"
        ),
    ]
)
