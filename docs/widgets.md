# 画面・Widget 一覧

---

## スクリーン一覧

### LoginScreen

- **ファイル**: `lib/screens/login/login_screen.dart`
- **ルート**: `/login`
- **概要**: Cognito 認証ログイン画面。ログイン結果に応じて遷移先を振り分ける。
- **遷移先**
  - `LoginSuccess` → `/simulator`
  - `LoginNewAccount` → `/user/registration`
  - `LoginPendingApproval` → `/pending-approval`
  - `LoginBlocked` → `/error/blocked`
- **入力**
  - ユーザー名: `keyboardType: TextInputType.emailAddress`（IME 無効）
  - パスワード: `keyboardType: TextInputType.visiblePassword`（ASCII キーボード固定）、表示切替あり
- **状態管理**: `AuthProvider`（`context.read`）

---

### UserScreen

- **ファイル**: `lib/screens/user/user_screen.dart`
- **ルート**
  - `/user/registration` → `UserScreen(isRegistration: true)`
  - `/user/profile` → `UserScreen(isRegistration: false)`
- **コンストラクタ引数**: `isRegistration: bool`
- **概要**: プロフィール登録（初回）・変更（以降）画面。NickName の入力のみ。Email は読み取り専用表示。
- **API**
  - 登録: `POST /v1/user` `{ nickName }`
  - 更新: `PUT /v1/user/{userIdBase64}` `{ nickName }`（userId は Base64 エンコード）
  - プロフィール取得（`isRegistration: false` かつ `auth.user == null` の場合）: `GET /v1/user`
- **状態管理**: `AuthProvider`（`context.read` / `context.watch`）

---

### SimulatorScreen

- **ファイル**: `lib/screens/fx/simulator/simulator_screen.dart`
- **ルート**: `/simulator`
- **概要**: FX トレードシミュレーター。グローバル入力フォーム + シミュレーターパネル 1 枚（固定）。
- **サブウィジェット**: `InputFormGlobal`、`SimulatorPanel`
- **状態管理**: `SimulatorProvider`（`context.watch`）、`initialize()` を `initState` の `addPostFrameCallback` で呼ぶ
- **Pull to Refresh**: `sim.calculate` を実行

---

### BarDataScreen

- **ファイル**: `lib/screens/fx/bar_data/bar_data_screen.dart`
- **ルート**
  - `/fx/bar-data/trade` → `BarDataScreen(symbolType: 'Trade')`
  - `/fx/bar-data/analyze` → `BarDataScreen(symbolType: 'Analyze')`
- **コンストラクタ引数**: `symbolType: String`（`'Trade'` or `'Analyze'`）
- **概要**: FX バーデータ一覧。barType タブ・通貨ペア選択・日付期間・ASC/DESC 切替・ページネーション付き。
- **API**
  - シンボルリスト取得（初期化時）
    - Trade: `GET /v1/fx/symbol/currency-pair-list` → `SymbolDto[]`
    - Analyze: `GET /v1/fx/symbol/currency-index-list` → `SymbolDto[]`
  - データ検索: `POST /v1/fx/bar-data` `BarDataSearchRequest`
- **barType**

  | 表示 | API 値 | Trade | Analyze |
  |------|--------|:-----:|:-------:|
  | M15  | 15M    | ○     |         |
  | H1   | 1H     | ○     | ○       |
  | H4   | 4H     | ○     | ○       |
  | D1   | 1D     | ○     | ○       |

  - デフォルト: `1H`
- **テーブルカラム**: BarTime / Range / Close / High / Low / RSI / Open / High / Low / Close（pip値は正負・閾値超えで色変換）

---

### EIDataScreen

- **ファイル**: `lib/screens/fx/economic_indicator_data/ei_data_screen.dart`
- **ルート**: `/fx/economic-indicator-data`
- **概要**: 経済指標データ一覧。重要度・国・指標フィルタ。高重要度行（`importance == 'H'`）をハイライト。
- **API**
  - 国リスト: `GET /v1/fx/master-list/country`
  - 指標リスト: `GET /v1/fx/master-list/economic-indicator/{countryCode}` / `ALL`
  - データ検索: `POST /v1/fx/economic-indicator-data/search` `EIDSearchRequest`
- **Admin のみ**
  - AppBar の ADD ボタン → `EIDataModal`（新規登録）
  - 行ロングプレス → `EIDataModal`（編集）
- **トースト**: 操作結果を `Positioned` で画面下部に 4 秒表示

---

### ZigZagScreen

- **ファイル**: `lib/screens/fx/zigzag/zigzag_screen.dart`
- **ルート**: `/fx/zigzag`
- **概要**: ZigZag データ一覧。方向フィルタ行（UP/DW 件数集計）、波カラーリング、SMA セル色分け。
- **API**
  - シンボルリスト: `GET /v1/fx/symbol/currency-pair-list`
  - データ検索: `POST /v1/fx/zigzag` `ZigZagSearchRequest`
- **行ダブルタップ**: `ChartModal` を Stack でオーバーレイ表示
- **AppBar**: `Generate` ボタン → `/fx/zigzag/generate` へプッシュ
- **デフォルト条件**: barType `4H`、depth `12`、barDateTimeMax = 翌日 00:00:00（タイムゾーンオフセット付き）
- **テーブルカラム**: begin~end / R（resistance）/ S（support）/ p / W / n / n2 / Range / 4H200 / DXY4h / DXY1h / NextRs / NextMax / 4H / 4H200

---

### ZigZagGenerateScreen

- **ファイル**: `lib/screens/fx/zigzag/zigzag_generate_screen.dart`
- **ルート**: `/fx/zigzag/generate`
- **概要**: ZigZag SMA 生成バッチ画面。ステータス一覧表示 → 確認ダイアログ → シンボルごとに**逐次** generate。
- **API**
  - ステータス取得: `POST /v1/fx/zigzag/status` `{ symbolType, barType, depth }`
  - 生成: `POST /v1/fx/zigzag/generate` `ZigZagGenerateRequest`（シンボル 1 件ずつ）
- **選択肢**
  - barType: `15M` / `1H` / `4H` / `1D`
  - depth: `10` / `12`
  - symbolType: `Trade` / `Analyze`
  - loadSize: `1000` / `5000` / `10000`
- **barDateTime**: ステータス一覧の `barDateTimeMaxZigZag` 最小値を自動セット（編集可）
- **処理中**: 各行に `processing...` を表示しながら逐次更新

---

### _MessageScreen（システム画面）

- **ファイル**: `lib/app.dart`（内部クラス）
- **ルート**
  - `/pending-approval`: 承認待ちメッセージ
  - `/error/blocked`: ブロック済みメッセージ
- **概要**: メッセージ表示のみ。「ログイン画面に戻る」ボタン付き。

---

## Screen-local Widgets

### InputFormGlobal

- **ファイル**: `lib/screens/fx/simulator/widgets/input_form_global.dart`
- **概要**: Simulator 画面のグローバル入力エリア。RiskAmount / Lot1% / USDJPY 価格を入力し、計算結果（決済1〜3・Total）を表示。
- **状態管理**: `SimulatorProvider`（`context.watch`）
- **使用ウィジェット**: `InputPriceField`

---

### SimulatorPanel

- **ファイル**: `lib/screens/fx/simulator/widgets/simulator_panel.dart`
- **概要**: エントリー条件入力（シンボル、売買方向、Entry価格・Loss価格など）とポジション計算結果の表示パネル。1 枚固定。
- **状態管理**: `SimulatorProvider`（`context.watch`）
- **使用ウィジェット**: `InputPriceField`

---

### EIDataModal

- **ファイル**: `lib/screens/fx/economic_indicator_data/widgets/ei_data_modal.dart`
- **概要**: 経済指標データの新規登録・編集 `Dialog`。Admin のみ使用。
- **コンストラクタ引数**
  - `dataId: int?` — null で新規登録、値があれば編集
  - `publication: String?` — 編集時の発表日時（URLエンコード必須）
  - `defaultCountryCode: String` — 新規時のデフォルト国コード
  - `countryList: List<KeyValue>` — 国ドロップダウン用リスト
  - `onClose: void Function(bool refresh)` — 保存後 `refresh: true` で呼ばれる
  - `onToast: void Function(String msg, bool isError)` — 親に通知
- **API**
  - 取得（編集時）: `GET /v1/fx/economic-indicator-data/{id}/{publication}` ※ `Uri.encodeComponent(publication)` 必須
  - 指標リスト: `GET /v1/fx/master-list/economic-indicator/{countryCode}`
  - 登録: `POST /v1/fx/economic-indicator-data` `{ data }`
  - 更新: `PUT /v1/fx/economic-indicator-data/{id}/{publication}` `{ data }` ※ `Uri.encodeComponent` 必須

---

### ChartModal

- **ファイル**: `lib/screens/fx/zigzag/widgets/chart_modal.dart`
- **概要**: ZigZag 行ダブルタップで表示するチャートモーダル。ローソク足 + SMA + R/S ラインを `CustomPainter` で描画。15M / 1H / 4H タブ切替。前後レコードへの← →ナビゲーション付き。
- **コンストラクタ引数**
  - `dataList: List<ZigZagResult>` — 全レコードリスト
  - `initialIndex: int` — 初期表示インデックス
  - `scale: int` — 価格小数点桁数
  - `onClose: VoidCallback`
- **API**: `POST /v1/fx/zigzag/bar-data` `{ barType, symbol, barDateTimeMin, barDateTimeMax }`

---

## 共通 Widgets

### AppDrawer

- **ファイル**: `lib/widgets/app_drawer.dart`
- **概要**: 全画面共通ハンバーガーメニュー。現在のルートをハイライト表示。プロフィール編集・ログアウト機能付き。
- **メニュー構成**
  - FX Trade: Simulator
  - FX BarData: BarData (Trade) / BarData (Analyze)
  - FX Indicator: Economic Indicator Data / ZigZag
  - フッター: プロフィール / ログアウト

---

### SearchPager

- **ファイル**: `lib/widgets/search_pager.dart`
- **概要**: 全件数・ページ移動（先頭/前/次/末尾）・ページサイズ切替を備えた共通ページネーション行。
- **Props**
  - `page`, `totalPage`, `totalCount`, `size: int`
  - `pageSizes: List<int>`
  - `onPageChange: void Function(int page)`
  - `onSizeChange: void Function(int size)`
- **使用画面**: BarDataScreen / EIDataScreen / ZigZagScreen

---

### InputPriceField

- **ファイル**: `lib/widgets/input_price_field.dart`
- **概要**: 数値（価格・ロット・レート）入力フィールド。フォーカスアウト時に値を確定・通知。`scale: 0` で整数表示。
- **Props**
  - `price: double` — 表示値
  - `scale: int` — 小数点桁数（0 で整数）
  - `onChanged: ValueChanged<double>`
  - `isZeroError: bool` — 0 のとき赤枠表示（デフォルト `false`）
  - `width: double?`
- **使用場所**: InputFormGlobal / SimulatorPanel
