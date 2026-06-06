//
//  SwitchWindowContentAction.swift
//  ContainerizedWindowArchitecture
//
//  Created by treastrain on 2026/05/23.
//

public import SwiftUI

public struct SwitchWindowContentAction: Sendable {
    var handler: @Sendable @MainActor (any WindowContent) -> Void

    @MainActor
    public func callAsFunction(_ windowContent: some WindowContent) {
        handler(windowContent)
    }
}

extension EnvironmentValues {
    @Entry public var switchWindow = SwitchWindowContentAction(handler: { _ in })
}
