# ContainerizedWindowArchitecture

`ContainerizedWindowArchitecture` は、1つのホストアプリケーション内で複数の独立した「アプリ内アプリ（コンテナ化された機能・モジュール）」を安全かつ柔軟に管理・切り替えるためのアーキテクチャおよび SwiftUI 向けのライブラリです。

## 設計思想と目的

アプリケーション開発において、任意の単位ごと（例: 機能、ドメイン、画面フローなど）にモジュールを分割し、それぞれの結合度を下げて独立して開発・テストできるアプローチが取られることがあります。

本アーキテクチャは、その思想をさらに発展させ、「各機能モジュールがそれ自体で1つの自立したアプリ（`Scene`）として振る舞い、ホスト側での複雑なルーティング処理（巨大な `switch` 文など）を完全に排除する」ことを目的として設計しています。

## 特徴

- 完全なモジュール分離
  - ホストアプリは各機能モジュールが提供する `Scene` を並べて登録するだけでよく、各画面の具体的なビュー実装（`RootView`）の内部仕様を知る必要はありません。
- 型安全な動的パラメータの伝播
  - SwiftUI の `WindowGroup(for:)` の仕組みをネイティブに拡張し、ディープリンクやアプリ内遷移時に必要なパラメータ（`WindowContent`）を直接 `RootView` まで型安全に届けます。
- シームレスなアニメーションと状態リセット
  - コンテナ切り替え時に SwiftUI の `id` を明示的に更新することで、以前の画面状態（`@State` など）をリセットしつつ、スムーズなアニメーション遷移を実現します。

## 主要コンポーネント

1. `WindowContent`
   
   画面遷移先を識別する ID、ウインドウのタイトル、および画面に必要な任意のパラメータを保持するデータ構造。SwiftUI の `WindowGroup` 宣言と紐付けるため、`id` プロパティは動的なパラメータを含まない、コンテナ/画面タイプごとに一意かつ固定の文字列である必要がある。

   ```swift
    import ContainerizedWindowArchitecture
    import Foundation

    public struct ItemDetailWindowContent: WindowContent {
        public typealias RootView = ItemDetailRootView
        
        // 画面タイプごとに一意かつ固定の ID（SwiftUI の WindowGroup の ID と一致する）
        public var id: String { "item-detail" }
        
        // ウインドウのタイトル
        public var titleResource: LocalizedStringResource { "アイテム詳細" }
        
        // 必要に応じて任意のパラメータを追加可能
        public let itemID: String
        
        public init(itemID: String) {
            self.itemID = itemID
        }
    }
    ```

2. `WindowContentRootView`
   
   特定の `WindowContent` に紐づく最上位の画面（SwiftUI の `View`）。初期化時に自身の `Content` を受け取り、それをもとに描画を行う。

   ```swift
    import ContainerizedWindowArchitecture
    import SwiftUI

    public struct ItemDetailRootView: WindowContentRootView {
        public let windowContent: ItemDetailWindowContent
        
        public init(windowContent: ItemDetailWindowContent) {
            self.windowContent = windowContent
        }
        
        public var body: some View {
            Text("アイテム ID: \(windowContent.itemID)")
        }
    }
    ```

3. `WindowContentScene`
   
   ホストアプリやプレビューアプリに対して機能を提供する、`Scene` 単位のプロトコル。これに対して `@PreviewApp` マクロを使用すると、このモジュール単独で動作するテスト用・開発用の `App` を自動生成できる。

   ```swift
    import ContainerizedWindowArchitecture
    import PreviewAppMacro
    import SwiftUI

    @PreviewApp
    public struct ItemDetailScene: WindowContentScene {
        public init() {}
        
        public var body: some Scene {
            WindowGroup(for: ItemDetailWindowContent(itemID: "default-item-id"))
        }
    }
    ```

## ホストアプリでの登録と遷移の呼び出し

ホストアプリでは、各モジュールが提供する `Scene` を並べるだけでセットアップが完了します。また、アプリ全体で切り替え可能な機能のリストを `.environment(\.availableWindowContents, [...])` を通じて流し込むことで、子となるモジュールに遷移先の選択肢を提供できます。

```swift
import ContainerizedWindowArchitecture
import SwiftUI
// そのほか、作成したモジュールを import する

@main
struct HostApp: App {
    var body: some Scene {
       scenes
            .environment(
                \.availableWindowContents,
                [
                    ItemDetailWindowContent(itemID: "default-item-id"),
                    // そのほかの遷移先...
                ]
            )
    }
    
    @SceneBuilder
    private var scenes: some Scene {
        ItemDetailScene()
        // そのほかの Scene...
    }    
}
```

遷移を実行する際は、プラットフォームの仕様（マルチウインドウに対応しているか）に応じて `openWindow` または `switchWindow` を呼び出します。

```swift
import ContainerizedWindowArchitecture
import SwiftUI

struct HomeView: View {
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    
    // iPadOS / Mac Catalyst / macOS / visionOS におけるマルチウインドウ環境用
    @Environment(\.openWindow) private var openWindow
    
    // iOS / tvOS / watchOS における単一ウインドウでの切り替え用
    @Environment(\.switchWindow) private var switchWindow
    
    var body: some View {
        Button("アイテム 123 の詳細を開く") {
            let targetContent = ItemDetailWindowContent(itemID: "123")
            
            if supportsMultipleWindows {
                // 新しいウインドウを開く
                openWindow(targetContent)
            } else {
                // 現在のウインドウ内のコンテンツを切り替える
                switchWindow(targetContent)
            }
        }
    }
}
```

## 動作環境

- iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / visionOS 1.0+ / watchOS 9.0+
- Swift 6.3+
