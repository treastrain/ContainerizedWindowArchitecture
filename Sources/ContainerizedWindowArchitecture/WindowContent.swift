//
//  WindowContent.swift
//  ContainerizedWindowArchitecture
//
//  Created by treastrain on 2026/05/23.
//

public import Foundation
public import SwiftUI
import os

@_typeEraser(AnyWindowContent)
public protocol WindowContent: Codable, Hashable, Identifiable, Sendable {
    associatedtype RootView: WindowContentRootView where RootView.Content == Self
    var id: String { get }
    var titleResource: LocalizedStringResource { get }
}

public struct AnyWindowContent: WindowContent {
    public struct RootView: WindowContentRootView {
        private let windowContent: AnyWindowContent

        public nonisolated init(windowContent: AnyWindowContent) {
            self.windowContent = windowContent
        }

        public var body: some View {
            windowContent.content.rootView
        }
    }

    public let content: any WindowContent

    public var id: String { content.id }
    public var titleResource: LocalizedStringResource { content.titleResource }

    public init(erasing windowContent: some WindowContent) {
        self.content = windowContent
    }

    enum CodingKeys: String, CodingKey {
        case typeName
        case payload
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .typeName)

        guard let type = WindowContentRegistry.type(for: typeName) else {
            throw DecodingError.dataCorruptedError(
                forKey: .typeName,
                in: container,
                debugDescription: "Unregistered WindowContent type: \(typeName). Please ensure it is registered via WindowGroup(for:)."
            )
        }

        self.content = try type.decodePayload(from: container)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let typeName = WindowContentRegistry.typeName(for: type(of: content))
        try container.encode(typeName, forKey: .typeName)

        try encodePayload(content, to: &container)
    }

    private func encodePayload(_ value: some WindowContent, to container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encode(value, forKey: .payload)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

extension AnyWindowContent: Equatable {
    public static func == (lhs: AnyWindowContent, rhs: AnyWindowContent) -> Bool {
        lhs.id == rhs.id
    }
}

extension WindowContent {
    static func decodePayload(from container: KeyedDecodingContainer<AnyWindowContent.CodingKeys>) throws -> any WindowContent {
        return try container.decode(Self.self, forKey: AnyWindowContent.CodingKeys.payload)
    }
}

enum WindowContentRegistry {
    private static let registry = OSAllocatedUnfairLock<[String: any WindowContent.Type]>(initialState: [:])

    static func register(_ type: (some WindowContent).Type) {
        registry.withLock { $0[typeName(for: type)] = type }
    }

    fileprivate static func type(for name: String) -> (any WindowContent.Type)? {
        registry.withLock { $0[name] }
    }

    fileprivate static func typeName(for type: Any.Type) -> String {
        String(reflecting: type)
    }
}

extension EnvironmentValues {
    @Entry public var windowContentID: String? = nil
}

extension WindowContent {
    public var rootView: AnyView {
        AnyView(RootView(windowContent: self))
    }
}
