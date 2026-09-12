# sandbox-flutter

Flutter でスマホ・タブレット向けアプリを作る。

---

## このファイルの管理方針

**CLAUDE.md は「Claudeの行動を変える指示書」** であり、ドキュメントではない。
毎回コンテキストに全文読み込まれるため、肥大化させない。

| 種類 | 置き場所 |
|---|---|
| コーディング規約・禁止事項 | **CLAUDE.md** |
| 実装時の落とし穴・制約 | **CLAUDE.md** |
| ビルド・実行コマンド | **CLAUDE.md** |
| 画面・Widget 仕様 | `docs/widgets.md` |
| API仕様 | `docs/api-docs.yaml` |
| プロジェクト構成・ルート定義 | **コードから読む**（`lib/app.dart`） |

---

## ドキュメント参照先

| 内容 | ファイル |
|---|---|
| 画面・Widget 仕様（ルート・API・Props） | [docs/widgets.md](docs/widgets.md) |
| API仕様 | [docs/api-docs.yaml](docs/api-docs.yaml) |

---

## 共通仕様（横断・FE/BE共通の大枠仕様）

@../claude-code/architecture/auth.md
@../claude-code/architecture/api-design.md

---

## Build & Run

```bash
# Android 実機で起動
flutter run -d HQ627E144D --dart-define-from-file=.env.json

# 静的解析
flutter analyze

# デバイス一覧
flutter devices

# Chrome で CORS を無効化して起動する
flutter run -d chrome \
            --web-browser-flag "--disable-web-security" \
            --dart-define-from-file=.env.json
```

---

## アーキテクチャ

```
lib/
├── models/         # ドメインモデル
├── services/       # API クライアント（JWT 自動付与）
├── providers/      # 状態管理（Providerパターン）
├── screens/        # 画面（StatefulWidget）
└── widgets/        # 共通ウィジェット
```

**依存方向**: screens → providers / services → models

---

## 実装規約

### 画面
- 新規画面は `StatefulWidget` + ローカル state（Provider 不使用）
- 全画面 `AppDrawer` でハンバーガーメニューによる画面間ナビゲーション
- 検索エリア・データエリアは左寄せ
  - body `Column`: `crossAxisAlignment: CrossAxisAlignment.start`
  - DataTable ラッパー: `Align(alignment: Alignment.topLeft)`

### Flutter 固有の制約
- FX Trade Simulator: React では simulatorPanel max5個だが、**Flutter では1個固定**
- BarData barType デフォルト: `1H`
- BarData barType マッピング（表示ラベル ↔ API 値）

  | 表示 | API 値 |
  |------|--------|
  | M15  | 15M    |
  | H1   | 1H     |
  | H4   | 4H     |
  | D1   | 1D     |

  - Trade: M15 / H1 / H4 / D1、Analyze: H1 / H4 / D1

---

## API 連携の落とし穴

### リクエスト型（integer 必須）
- `riskAmount`, `firstLotRatio` は **integer**（`double` 不可）
- `positionRatio`, `settlementAmount`, `lossPips`（EntryParam）は **integer**
- `settlementPips`, `profitAmount`, `lossAmount`（PositionParam）は **integer**

### シンボルリスト API
- Trade → `GET /v1/fx/symbol/currency-pair-list`（`SymbolDto[]`）
- Analyze → `GET /v1/fx/symbol/currency-index-list`（`SymbolDto[]`）
- `/v1/fx/master-list/symbol/{symbolType}` は `KeyValue[]` を返すため **使用不可**

### 認証
- Cognito JWT claims から email を取得する際、`JsonWebClaims` は `[]` 演算子非対応
  - raw トークンを Base64 デコードして手動パース（`auth_provider.dart` の `_emailFromRawToken`）

### 経済指標
- 発表日時の URL エンコード: `Uri.encodeComponent(publication)` 必須

---

## Android 設定

`android/app/src/main/AndroidManifest.xml`

- `<uses-permission android:name="android.permission.INTERNET" />` 必須
- ローカル API への HTTP 通信: `android:usesCleartextTraffic="true"` 必須（Android 9+）
