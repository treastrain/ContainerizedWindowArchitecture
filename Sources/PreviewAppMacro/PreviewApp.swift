//
//  PreviewApp.swift
//  ContainerizedWindowArchitecture
//
//  Created by treastrain on 2026/05/25.
//

@attached(peer, names: suffixed(PreviewApp))
public macro PreviewApp() = #externalMacro(module: "PreviewAppMacroPlugin", type: "PreviewAppMacro")
