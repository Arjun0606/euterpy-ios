// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Euterpy",
    // iOS 17 is the real target — that's where the @Observable
    // macro and the modern Environment(.self) API live.
    // macOS 14 is included so we can run `swift build` sanity
    // checks from the CLI on a Mac during development without
    // having to spin up xcodebuild + a simulator.
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "Euterpy",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ],
            path: "Euterpy/Sources",
            // ARCHITECTURE.md is documentation that lives next to
            // the source files for visibility, not a resource SPM
            // should try to bundle.
            exclude: ["ARCHITECTURE.md"]
        ),
    ]
)
