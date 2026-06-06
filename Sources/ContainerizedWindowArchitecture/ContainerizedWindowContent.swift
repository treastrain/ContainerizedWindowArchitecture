//
//  ContainerizedWindowContent.swift
//  ContainerizedWindowArchitecture
//
//  Created by treastrain on 2026/05/23.
//

public import SwiftUI

public struct ContainerizedWindowContent: View {
    @State private var currentContent: AnyWindowContent

    nonisolated init(initialContent: some WindowContent) {
        _currentContent = State(initialValue: AnyWindowContent(erasing: initialContent))
    }

    public var body: some View {
        let switchAction = SwitchWindowContentAction { @MainActor content in
            withAnimation { currentContent = AnyWindowContent(erasing: content) }
        }

        currentContent.content.rootView
            .id(currentContent.id)
            .environment(\.windowContentID, currentContent.id)
            .environment(\.switchWindow, switchAction)
    }
}
