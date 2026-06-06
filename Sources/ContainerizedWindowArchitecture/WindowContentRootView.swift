//
//  WindowContentRootView.swift
//  ContainerizedWindowArchitecture
//
//  Created by treastrain on 2026/05/23.
//

public import SwiftUI

public protocol WindowContentRootView: View {
    associatedtype Content: WindowContent
    nonisolated init(windowContent: Content)
}
