# sandbox-flutter

### 目的
- Flutter でスマホ・タブレット向けアプリを作る

### 参考情報
- React WEB の既存画面をベースにする
  - `./docs/src`
- API ドキュメント
  - `./docs/api-docs.yaml`

---

### 機能一覧・画面構成

#### ログイン機能
- `./docs/src/pages/login`
- AWS Cognito (amplify_flutter) で認証
- ユーザー名: `keyboardType: TextInputType.emailAddress`（IME 無効）
- パスワード: `keyboardType: TextInputType.visiblePassword`（ASCII キーボード固定）

#### ユーザ機能
- `./docs/src/pages/user`

#### FX Trade Simulator
- `./docs/src/pages/fx/trade/simulator`
- React WEB では simulatorPanel max5個だが、Flutter では **1個固定**

#### FX BarData
- `./docs/src/pages/fx/bar-data`
- Trade / Analyze の2種類（ルート引数 `symbolType` で切り替え）
- シンボルリスト取得 API:
  - Trade → `GET /v1/fx/symbol/currency-pair-list`（`SymbolDto[]`）
  - Analyze → `GET /v1/fx/symbol/currency-index-list`（`SymbolDto[]`）
  - ※ `/v1/fx/master-list/symbol/{symbolType}` は `KeyValue[]` を返すため **使用不可**
- barType: 表示ラベル ↔ API 値のマッピング

  | 表示 | API 値 |
  |------|--------|
  | M15  | 15M    |
  | H1   | 1H     |
  | H4   | 4H     |
  | D1   | 1D     |

  - Trade: M15 / H1 / H4 / D1、Analyze: H1 / H4 / D1
  - デフォルト: `1H`

#### FX Economic Indicator Data
- `./docs/src/pages/fx/economic-indicator-data`
- 重要度・国・指標フィルタ、高重要度行ハイライト
- Admin のみ: 行ロングプレスで編集モーダル、AppBar の ADD ボタン
- 発表日時の URL エンコード: `Uri.encodeComponent(publication)` 必須

#### FX ZigZag
- `./docs/src/pages/fx/zigzag`
- 方向フィルタ行（UP/DW 集計）、波カラーリング
- 行ダブルタップ → ChartModal（ローソク足 + SMA + R/S ライン、CustomPainter 実装）
- ZigZag Generate: シンボルごとに逐次 generate

---

### プロジェクト構成

```
lib/
├── main.dart                        # エントリーポイント (Amplify 初期化)
├── app.dart                         # MaterialApp + Provider + ルート定義
├── amplifyconfiguration.dart        # Cognito 設定 (PoolId, AppClientId, Region)
├── config/app_config.dart           # API ベース URL 設定
├── theme/app_theme.dart             # ダークテーマ・色定義
├── models/
│   ├── sandbox_user.dart            # ユーザーモデル・LoginResult
│   ├── symbol_dto.dart              # FX 通貨ペアモデル
│   ├── trade_info.dart              # TradeEntry/Position/Request/Response
│   ├── bar_data.dart                # BarData 関連モデル
│   ├── economic_indicator_data.dart # 経済指標データモデル
│   └── zigzag.dart                  # ZigZag 関連モデル
├── services/api_service.dart        # HTTP API クライアント (JWT 自動付与)
│                                    # get / getList / post / put / postMultipart
├── providers/
│   ├── auth_provider.dart           # 認証状態管理
│   └── simulator_provider.dart      # Simulator 状態管理 (1パネル固定)
├── screens/
│   ├── login/login_screen.dart      # ログイン画面
│   ├── user/user_screen.dart        # プロフィール・ユーザ登録
│   └── fx/
│       ├── simulator/
│       │   ├── simulator_screen.dart
│       │   └── widgets/
│       │       ├── input_form_global.dart
│       │       └── simulator_panel.dart
│       ├── bar_data/
│       │   └── bar_data_screen.dart
│       ├── economic_indicator_data/
│       │   ├── ei_data_screen.dart
│       │   └── widgets/ei_data_modal.dart
│       └── zigzag/
│           ├── zigzag_screen.dart
│           ├── zigzag_generate_screen.dart
│           └── widgets/chart_modal.dart
└── widgets/
    ├── app_drawer.dart              # 全画面共通ハンバーガーメニュー
    ├── search_pager.dart            # 共通ページネーション
    └── input_price_field.dart       # 数値入力ウィジェット
```

### ルート定義 (`app.dart`)

| ルート | 画面 |
|--------|------|
| `/login` | LoginScreen |
| `/user/registration` | UserScreen(isRegistration: true) |
| `/user/profile` | UserScreen(isRegistration: false) |
| `/simulator` | SimulatorScreen |
| `/fx/bar-data/trade` | BarDataScreen(symbolType: 'Trade') |
| `/fx/bar-data/analyze` | BarDataScreen(symbolType: 'Analyze') |
| `/fx/economic-indicator-data` | EIDataScreen |
| `/fx/zigzag` | ZigZagScreen |
| `/fx/zigzag/generate` | ZigZagGenerateScreen |

---

### 開発・動作確認コマンド

```bash
# Android 実機で起動
flutter run -d HQ627E144D

# 静的解析
flutter analyze

# デバイス一覧
flutter devices
```

---

### UI 設計方針

- ダークテーマ固定 (`app_theme.dart`)
- 全画面 `AppDrawer` でハンバーガーメニューによる画面間ナビゲーション
- ログイン・プロフィール以外: 検索エリア・データエリアは **左寄せ**
  - body `Column` に `crossAxisAlignment: CrossAxisAlignment.start`
  - DataTable ラッパーに `Align(alignment: Alignment.topLeft)`
- スマホ・タブレット向け（ファイルアップロード機能は非搭載）
- 新規画面は `StatefulWidget` + ローカル state（Provider 不使用）

---

### API 連携の注意事項

#### リクエスト共通
- `riskAmount`, `firstLotRatio` は **integer** で送る (`double` 不可)
- `positionRatio`, `settlementAmount`, `lossPips` (EntryParam) は **integer**
- `settlementPips`, `profitAmount`, `lossAmount` (PositionParam) は **integer**

#### 認証
- Cognito JWT の claims から email を取得する際、`JsonWebClaims` は `[]` 演算子非対応
  - raw トークンを Base64 デコードして claims を手動パース (`auth_provider.dart` の `_emailFromRawToken`)

#### Android 設定 (`android/app/src/main/AndroidManifest.xml`)
- `<uses-permission android:name="android.permission.INTERNET" />` が必要
- ローカル API への HTTP 通信は `android:usesCleartextTraffic="true"` が必要 (Android 9+)
