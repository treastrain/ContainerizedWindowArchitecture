//
//  PreviewAppMacroTests.swift
//  ContainerizedWindowArchitecture
//
//  Created by treastrain on 2026/05/25.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import SwiftSyntaxMacrosTestSupport
import Testing

@testable import PreviewAppMacroPlugin

struct PreviewAppMacroTests {
    let macros: [String: any Macro.Type] = [
        "PreviewApp": PreviewAppMacro.self
    ]

    // MARK: - 正常系

    @Test
    func `public struct + WindowContentScene に @PreviewApp を付与`() {
        assertMacroExpansion(
            """
            @PreviewApp
            public struct SampleScene: WindowContentScene {
                public init() {}
                public var body: some Scene {
                    WindowGroup {
                        Text("Hello")
                    }
                }
            }
            """,
            expandedSource: """
                public struct SampleScene: WindowContentScene {
                    public init() {}
                    public var body: some Scene {
                        WindowGroup {
                            Text("Hello")
                        }
                    }
                }

                public struct SampleScenePreviewApp: App {
                    public init() {}

                    public var body: some Scene {
                        SampleScene()
                    }
                }
                """,
            macros: macros
        )
    }

    @Test
    func `internal（修飾子なし）struct + WindowContentScene に @PreviewApp を付与`() {
        assertMacroExpansion(
            """
            @PreviewApp
            struct MyScene: WindowContentScene {
                init() {}
                var body: some Scene {
                    WindowGroup {
                        Text("Hello")
                    }
                }
            }
            """,
            expandedSource: """
                struct MyScene: WindowContentScene {
                    init() {}
                    var body: some Scene {
                        WindowGroup {
                            Text("Hello")
                        }
                    }
                }

                struct MyScenePreviewApp: App {
                    init() {}

                    var body: some Scene {
                        MyScene()
                    }
                }
                """,
            macros: macros
        )
    }

    @Test
    func `完全修飾名の WindowContentScene に @PreviewApp を付与`() {
        assertMacroExpansion(
            """
            @PreviewApp
            struct QualifiedScene: ContainerizedWindowArchitecture.WindowContentScene {
                init() {}
                var body: some Scene {
                    WindowGroup {
                        Text("Hello")
                    }
                }
            }
            """,
            expandedSource: """
                struct QualifiedScene: ContainerizedWindowArchitecture.WindowContentScene {
                    init() {}
                    var body: some Scene {
                        WindowGroup {
                            Text("Hello")
                        }
                    }
                }

                struct QualifiedScenePreviewApp: App {
                    init() {}

                    var body: some Scene {
                        QualifiedScene()
                    }
                }
                """,
            macros: macros
        )
    }

    @Test
    func `Module Name Selector の WindowContentScene に @PreviewApp を付与`() {
        assertMacroExpansion(
            """
            @PreviewApp
            struct ModuleSelectorScene: ContainerizedWindowArchitecture::WindowContentScene {
                init() {}
                var body: some Scene {
                    WindowGroup {
                        Text("Hello")
                    }
                }
            }
            """,
            expandedSource: """
                struct ModuleSelectorScene: ContainerizedWindowArchitecture::WindowContentScene {
                    init() {}
                    var body: some Scene {
                        WindowGroup {
                            Text("Hello")
                        }
                    }
                }

                struct ModuleSelectorScenePreviewApp: App {
                    init() {}

                    var body: some Scene {
                        ModuleSelectorScene()
                    }
                }
                """,
            macros: macros
        )
    }

    @Test
    func `型名が Scene で終わらない場合は末尾に PreviewApp を追加`() {
        assertMacroExpansion(
            """
            @PreviewApp
            struct MyWindowContentSceneImpl: WindowContentScene {
                init() {}
                var body: some Scene {
                    WindowGroup {
                        Text("Hello")
                    }
                }
            }
            """,
            expandedSource: """
                struct MyWindowContentSceneImpl: WindowContentScene {
                    init() {}
                    var body: some Scene {
                        WindowGroup {
                            Text("Hello")
                        }
                    }
                }

                struct MyWindowContentSceneImplPreviewApp: App {
                    init() {}

                    var body: some Scene {
                        MyWindowContentSceneImpl()
                    }
                }
                """,
            macros: macros
        )
    }

    // MARK: - 異常系

    @Test
    func `struct 以外に適用するとエラー`() {
        assertMacroExpansion(
            """
            @PreviewApp
            class SampleScene: WindowContentScene {
            }
            """,
            expandedSource: """
                class SampleScene: WindowContentScene {
                }
                """,
            diagnostics: [
                DiagnosticSpec(
                    message: "'@PreviewApp' can only be applied to a struct declaration",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }

    @Test
    func `WindowContentScene に適合していない場合はエラー`() {
        assertMacroExpansion(
            """
            @PreviewApp
            struct SampleScene: View {
                init() {}
                var body: some View {
                    Text("Hello")
                }
            }
            """,
            expandedSource: """
                struct SampleScene: View {
                    init() {}
                    var body: some View {
                        Text("Hello")
                    }
                }
                """,
            diagnostics: [
                DiagnosticSpec(
                    message: "'@PreviewApp' requires conformance to 'WindowContentScene'",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }
}
