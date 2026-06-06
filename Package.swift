// swift-tools-version: 6.3

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "ContainerizedWindowArchitecture",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .visionOS(.v1), .watchOS(.v9)],
    products: [
        .library(
            name: "ContainerizedWindowArchitecture",
            targets: ["ContainerizedWindowArchitecture"]
        ),
        .library(
            name: "PreviewAppMacro",
            targets: ["PreviewAppMacro"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "603.0.1")
    ],
    targets: [
        .target(
            name: "ContainerizedWindowArchitecture"
        ),
        .macro(
            name: "PreviewAppMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "PreviewAppMacro",
            dependencies: [
                "PreviewAppMacroPlugin"
            ]
        ),
        .testTarget(
            name: "PreviewAppMacroPluginTests",
            dependencies: [
                "PreviewAppMacroPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

// Ref: - https://github.com/treastrain/swift-upcomingfeatureflags-cheatsheet

extension SwiftSetting {
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")  // SE-0335, Swift 5.6,  SwiftPM 5.8+
    static let internalImportsByDefault: Self = .enableUpcomingFeature("InternalImportsByDefault")  // SE-0409, Swift 6.0,  SwiftPM 6.0+
    static let memberImportVisibility: Self = .enableUpcomingFeature("MemberImportVisibility")  // SE-0444, Swift 6.1,  SwiftPM 6.1+
    static let inferIsolatedConformances: Self = .enableUpcomingFeature("InferIsolatedConformances")  // SE-0470, Swift 6.2,  SwiftPM 6.2+
    static let nonisolatedNonsendingByDefault: Self = .enableUpcomingFeature("NonisolatedNonsendingByDefault")  // SE-0461, Swift 6.2,  SwiftPM 6.2+
    static let immutableWeakCaptures: Self = .enableUpcomingFeature("ImmutableWeakCaptures")  // SE-0481, Swift 6.2,  SwiftPM 6.2+
}

extension SwiftSetting: @retroactive CaseIterable {
    public static var allCases: [Self] {
        [
            .existentialAny,
            .internalImportsByDefault,
            .memberImportVisibility,
            .inferIsolatedConformances,
            .nonisolatedNonsendingByDefault,
            .immutableWeakCaptures,
        ]
    }
}

package.targets
    .filter { ![.system, .binary, .plugin].contains($0.type) }
    .forEach { $0.swiftSettings = SwiftSetting.allCases }
