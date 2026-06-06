//
//  WindowGroup+.swift
//  ContainerizedWindowArchitecture
//
//  Created by treastrain on 2026/05/23.
//

public import SwiftUI

extension WindowGroup {
    #if os(iOS) || os(macOS) || os(visionOS) || targetEnvironment(macCatalyst)
        public nonisolated init<W: WindowContent>(
            for windowContent: W
        ) where Content == PresentedWindowContent<W, ContainerizedWindowContent> {
            WindowContentRegistry.register(W.self)
            self.init(
                windowContent.titleResource,
                id: windowContent.id,
                for: W.self,
                content: { ContainerizedWindowContent(initialContent: $0.wrappedValue) },
                defaultValue: { windowContent }
            )
        }
    #elseif os(tvOS) || os(watchOS)
        public nonisolated init<W: WindowContent>(
            for windowContent: W
        ) where Content == ContainerizedWindowContent {
            WindowContentRegistry.register(W.self)
            self.init(
                windowContent.titleResource,
                id: windowContent.id,
                makeContent: { ContainerizedWindowContent(initialContent: windowContent) }
            )
        }
    #endif
}
