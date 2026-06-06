//
//  OpenWindowAction+.swift
//  ContainerizedWindowArchitecture
//
//  Created by treastrain on 2026/05/23.
//

#if os(iOS) || os(macOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public import SwiftUI

    extension OpenWindowAction {
        public func callAsFunction(_ windowContent: some WindowContent) {
            callAsFunction(id: windowContent.id, value: windowContent)
        }
    }
#endif
