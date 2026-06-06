//
//  PreviewAppMacro.swift
//  ContainerizedWindowArchitecture
//
//  Created by treastrain on 2026/05/25.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
public import SwiftSyntax
import SwiftSyntaxBuilder
public import SwiftSyntaxMacros

public struct PreviewAppMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: declaration,
                    message: PreviewAppMacroDiagnostic.requiresStruct
                )
            ])
        }

        // 継承句から WindowContentScene に適合していることを検証
        let inheritedTypes =
            structDecl.inheritanceClause?.inheritedTypes.map {
                $0.type.trimmedDescription
            } ?? []
        let hasWindowContentScene = inheritedTypes.contains("WindowContentScene")
        guard hasWindowContentScene else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: declaration,
                    message: PreviewAppMacroDiagnostic.requiresWindowContentScene
                )
            ])
        }

        let accessModifier = structDecl.modifiers.first(where: {
            switch $0.name.tokenKind {
            case .keyword(.public), .keyword(.internal), .keyword(.fileprivate), .keyword(.private), .keyword(.package):
                return true
            default:
                return false
            }
        })
        let accessPrefix = accessModifier.map { "\($0.trimmedDescription) " } ?? ""

        let originalName = structDecl.name.trimmedDescription
        let previewAppName = originalName + "PreviewApp"

        let newStruct: DeclSyntax = """
            \(raw: accessPrefix)struct \(raw: previewAppName): App {
                \(raw: accessPrefix)init() {}

                \(raw: accessPrefix)var body: some Scene {
                    \(raw: originalName)()
                }
            }
            """
        return [newStruct]
    }
}

enum PreviewAppMacroDiagnostic: String, DiagnosticMessage {
    case requiresStruct
    case requiresWindowContentScene

    var message: String {
        switch self {
        case .requiresStruct:
            "'@PreviewApp' can only be applied to a struct declaration"
        case .requiresWindowContentScene:
            "'@PreviewApp' requires conformance to 'WindowContentScene'"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "PreviewAppMacroPlugin", id: rawValue)
    }

    var severity: DiagnosticSeverity { .error }
}

@main
struct PreviewAppMacroPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        PreviewAppMacro.self
    ]
}
