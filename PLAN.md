# MoanSwipe 開発計画書 v2.4

## 1. SSOT参照宣言

本計画書は、以下を単一真実源として参照する。

- [`AI_PLANNING_GUIDELINES.md`](/Users/hori/Desktop/MoanSwipe/AI_PLANNING_GUIDELINES.md)
- [`MoanSwipe/MoanSwipeApp.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/MoanSwipeApp.swift)
- [`MoanSwipe/ContentView.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/ContentView.swift)
- [`MoanSwipe.xcodeproj/project.pbxproj`](/Users/hori/Desktop/MoanSwipe/MoanSwipe.xcodeproj/project.pbxproj)

本計画書における判断は、上記と矛盾しないことを前提とする。

---

## 2. プロダクト要約

MoanSwipe は、MacBook のトラックパッド操作に応じて、複数候補から短い音声リアクションを低遅延で再生する軽量な macOS menubar アプリである。

優先順位は以下のとおり。

- 一発で分かる面白さ
- 動画映え
- 軽量
- 即時 ON / OFF

---

## 3. 既存実装の類似参照

現状の主要ファイルを「現行の基準点」として扱う。

### 3.1 アプリエントリ

- [`MoanSwipe/MoanSwipeApp.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/MoanSwipeApp.swift)
  - 現在は `MenuBarExtra` ベース
  - menubar シェルとしての現行構成

### 3.2 初期 UI

- [`MoanSwipe/ContentView.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/ContentView.swift)
  - テンプレート UI
  - 現時点では本体機能なし

### 3.3 プロジェクト設定

- [`MoanSwipe.xcodeproj/project.pbxproj`](/Users/hori/Desktop/MoanSwipe/MoanSwipe.xcodeproj/project.pbxproj)
  - macOS ターゲット
  - sandbox 有効
  - 追加設定はここを正とする

### 3.4 今回の正解パターン

現時点での正解パターンは以下の責務分離にある。

- [`MoanSwipe/MoanSwipeApp.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/MoanSwipeApp.swift)
  - menubar シェル
- [`MoanSwipe/AppState.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AppState.swift)
  - 入力と再生の接続
- [`MoanSwipe/InputMonitor.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/InputMonitor.swift)
  - click / scroll の最小監視
- [`MoanSwipe/AudioPlayer.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AudioPlayer.swift)
  - 音声プールと現行再生基盤

---

## 4. 現状認識

現状のプロジェクトは以下の状態である。

- menubar アプリとして起動し、メニュー表示と Quit は成立している
- click 系入力で音が鳴る
- scroll 系入力で音が鳴る
- 音声プールと直前音回避の最小実装はある
- 低遅延・多重再生 audio 基盤が入り、クリック連打時の音切れは改善している
- `ContentView` は本体機能ではなく補助的な位置づけである

ただし、UX 上の重要課題が残っている。

- scroll が gesture ではなく event 単位で鳴りやすい
- `1 アクション = 1 サウンド` の知覚が弱い

したがって、次の優先事項は機能追加よりも audio UX の是正と gesture 単位の設計改善である。

---

## 5. MVPスコープ

MVP 完了条件は以下とする。

- menubar アプリとして起動する
- メニューから ON / OFF、Volume、Quit を操作できる
- click / tap 系入力の少なくとも 1 種で音が鳴る
- scroll 系入力の少なくとも 1 種で音が鳴る
- 同一カテゴリで複数音声からランダム再生できる
- 直前音の連打を避ける
- 連続スクロールで過剰発火しない
- click 連打時に前の音が不自然に潰れにくい
- 入力から音までの違和感が小さい
- 短い scroll では 1 アクション 1 サウンドとして知覚しやすい
- OFF 時は完全に無反応
- 音源欠損や読み込み失敗でクラッシュしない

以下は MVP 外とする。

- Windows
- Magic Trackpad 最適化
- App Store 対応
- 課金
- ユーザー音源インポート
- 高度な設定 UI
- SNS 共有

---

## 6. 問題一覧（Issue List）

### C-01: テンプレート構成のままで menubar 前提になっていない

- `WindowGroup` ベースで起動している
- menubar 中心の導線が存在しない

### C-02: 現在の Xcode 設定に menubar 常駐用の明示方針がない

- `LSUIElement` 相当の扱いを計画に落としていない
- Dock / メインウィンドウの扱いが未確定

### A-01: 音声再生基盤が存在しない

- 単発再生も未実装
- 低遅延前提の選定と責務分離が未着手

### I-01: click / tap 系入力の取得方針が未定

- 生イベント取得方法が未定
- menubar アプリ状態でどこまで拾えるか未検証

### I-02: scroll 系入力の取得と発火制御方針が未定

- 二本指スクロールの実用監視が未検証
- 過剰発火抑制ルールが未定

### A-02: 音声プールとランダム選択の仕様が未実装

- 1 イベント 1 音から脱却する設計はあるが未実装
- 直前音回避ルールが未定義

### A-03: 低遅延・多重再生に対応した audio 基盤の実装と検証が必要

- 低遅延・多重再生基盤は実装済み
- Gate 通過確認結果を計画へ反映済み
- 今後は scroll session 設計との整合を維持する必要がある

### I-03: scroll 継続時間や変化量を表現するセッション管理が未実装

- 現状は scroll ごとの単発間引きのみ
- 継続時間、累積操作量、変化段階に応じた音の変化が未実装

### I-04: scroll が gesture 単位ではなく event 単位で鳴りやすい

- 一般的な 2 本指スクロールでも複数音が流れやすい
- `1 アクション = 1 サウンド` の知覚が弱い
- scroll 開始時、継続時、終了時の責務分離がない

### A-04: 長時間 scroll が段階遷移後に無音化しやすい

- 現状は `short / sustained / intense` の各段階で 1 回ずつしか音が出ない
- 長時間 scroll 中に無音区間が長くなりやすい

### I-05: 長い scroll に対する追加音タイミングの UX 調整が未実装

- `sustained` と `intense` の遷移時刻が近く感じられやすい
- 長時間 scroll 中の追加音を制御する pulse 仕様が未定

### S-01: ON/OFF と Volume の状態管理が存在しない

- メニュー表示状態と内部状態の同期先がない
- 永続化の責務が未定

### K-01: Force Click と Pinch の実現性が不確実

- OS / API 制約に左右される
- MVP 必須にすると計画破綻リスクが高い

### D-01: AI 実装向けのフェーズ運用基準がプロジェクト専用化されていなかった

- 汎用ガイドラインはあったが、このプロジェクトの現実に合っていなかった

---

## 7. フェーズ計画

各フェーズは 1 目的、最大 3 ファイル変更、最大 1 新規ファイルを原則とする。

### Phase 1: menubar シェル化

**対応 Issue**
- C-01
- C-02

**主目的**
- アプリを `WindowGroup` 中心のテンプレートから、menubar 主体のシェルへ移行する

**想定変更範囲**
- `MoanSwipe/MoanSwipeApp.swift`
- 必要なら menubar 用の新規ファイル 1 件
- `project.pbxproj` または Info 設定相当

**実装内容**
- menubar エントリを作る
- メニューに ON / OFF と Quit の最低限項目を置く
- 通常ウィンドウ依存を外す
- Dock / 表示方針を固定する

**Gate 条件**
- アプリ起動後にメニューバーから操作できる
- ON / OFF のダミー切替ができる
- Quit が機能する
- menubar 主体の導線に切り替わっている

### Phase 2: 単発音再生基盤

**対応 Issue**
- A-01

**主目的**
- 任意トリガーで短尺音声を 1 回再生できる状態を作る

**想定変更範囲**
- Audio 用の新規ファイル 1 件
- `MoanSwipe/MoanSwipeApp.swift` または menubar 関連ファイル
- 必要なら音源リソース設定

**実装内容**
- 音声読み込みと単発再生を分離した最小 Audio 層を作る
- ダミーイベントまたはメニュー操作で再生確認できるようにする
- 音源欠損時にクラッシュしないようにする

**Gate 条件**
- ダミー操作で音が鳴る
- 読み込み失敗時に落ちない
- 再生呼び出しが 1 つの Audio 層 API に集約されていることをコードレビューで確認できる

### Phase 3: click / tap 系入力接続

**対応 Issue**
- I-01

**主目的**
- click / tap 系の少なくとも 1 種を入力として受け取り、音声再生へ接続する

**想定変更範囲**
- Input 用の新規ファイル 1 件
- Audio 関連ファイル
- menubar / app シェル接続ファイル

**実装内容**
- 生イベント取得を最小限で接続する
- 入力をアプリ固有イベントへ正規化する
- 音声再生の呼び出し境界を定める

**Gate 条件**
- click または tap の少なくとも 1 種で音が鳴る
- 入力検出と再生処理が分離されている
- OFF 時には再生しない

### Phase 4: scroll 入力と頻度制御

**対応 Issue**
- I-02

**主目的**
- scroll 系入力に反応しつつ、過剰発火を抑える

**想定変更範囲**
- Input ファイル
- Audio ファイル
- 必要なら設定またはしきい値管理ファイル

**実装内容**
- scroll 系イベントを追加する
- クールダウンまたは間引き制御を入れる
- 方向 / 速度の扱いは最小限でよい

**Gate 条件**
- scroll 系 1 種以上で音が鳴る
- 同一方向への連続スクロール入力で、発火頻度が 1 秒あたり最大 2 回以下に制御されている
- click / tap 系挙動を壊していない

### Phase 5: 音声プールとランダム化

**対応 Issue**
- A-02

**主目的**
- 1 イベント 1 音から、カテゴリ経由の複数候補ランダム再生へ移行する

**想定変更範囲**
- Audio ファイル
- 必要なら音声カテゴリ定義ファイル 1 件
- 入力正規化ファイル

**実装内容**
- モーションカテゴリと音声プールの対応を定義する
- ランダム選択と直前音回避を実装する
- Audio 層にクールダウン責務を寄せる

**Gate 条件**
- 同一カテゴリで複数音声から再生される
- 直前に再生した音声クリップを次回抽選から除外または低優先化し、直前音回避ロジックが動作している
- 既存入力経路を壊していない

### Phase 6: 低遅延・多重再生 audio 基盤

**対応 Issue**
- A-03

**主目的**
- クリック連打や短い連続操作でも音が潰れにくく、入力追従性の高い one-shot 再生基盤へ移行する

**想定変更範囲**
- Audio ファイル
- AppState 接続ファイル
- 必要なら音声プール定義ファイル 1 件

**実装内容**
- 音声ファイルの事前ロードを導入する
- 複数同時再生可能な voice pool または polyphonic 再生へ変更する
- 同時再生上限を定める
- 再生ごとのロードや prepare による遅延を減らす

**Gate 条件**
- 連続クリック時に前の音が不自然に途切れにくい
- クリック連打でも無音区間が目立ちにくい
- 事前ロード済みの音声から再生される
- 既存のランダム化と直前音回避を壊していない

**現在の状態**
- 実装済み
- ローカル確認では Gate 通過

### Phase 7: scroll セッション化と段階変化

**対応 Issue**
- I-03
- I-04

**主目的**
- scroll を単発イベント列ではなく gesture / session として扱い、1 アクション 1 サウンドを基本にしつつ、継続時間や変化量に応じて音の段階を変える

**想定変更範囲**
- Input ファイル
- Motion 分類または scroll session 用ファイル 1 件
- Audio ファイル

**実装内容**
- scroll 開始時のみ 1 音とする基本挙動を定義する
- scroll 開始、継続中、終了のセッション概念を導入する
- 継続時間、累積イベント数、速度変化などを保持する
- `short / sustained / intense` のような段階カテゴリへ分類する
- 段階に応じて異なる音声プールを選べる構造へつなぐ

**Gate 条件**
- 一般的な短い scroll で 1 アクションに対して 1 音として知覚しやすい
- 短い scroll と長い scroll で異なるカテゴリ選択が可能になっている
- scroll 継続中に段階変化を表現できる内部状態がある
- 既存の click / tap および短い scroll の挙動を壊していない

### Phase 7.1: 長時間 scroll pulse UX

**対応 Issue**
- A-04
- I-05

**主目的**
- 短い scroll の 1 アクション 1 音感を維持したまま、長い scroll では制御された追加音を継続できるようにする

**想定変更範囲**
- scroll session 用ファイル
- Audio ファイル
- コマンド / 音声対応表

**実装内容**
- `short` は開始時 1 音のみを維持する
- `sustained` と `intense` では、段階遷移音に加えて一定間隔の pulse 発火を許可する
- pulse は event ごとの連打ではなく、session 状態が保持する次回再生可能時刻に基づいて発火する
- `sustained` と `intense` で異なる pulse 間隔を持たせる
- コマンドと音声の対応表へ pulse 運用を反映する

**Gate 条件**
- 一般的な短い scroll を 5 回試行し、1 アクションで複数音が鳴ったと知覚される事象が 5 回中 1 回以下である
- 長い scroll を 5 回試行し、`sustained` 到達後に無音のまま終わる事象が 5 回中 1 回以下である
- `sustained` の pulse 間隔は `1.1 秒以上` を維持し、「次が早すぎる」印象を減らしている
- `intense` の pulse 間隔は `sustained` より短いが、連打感で破綻していない
- 既存の click / tap と短い scroll の挙動を壊していない
- OFF 時は引き続き無音である
- 音源欠損時でもクラッシュしない
- 権限制約の確認は本 Phase の変更対象外であるため N/A とし、入力監視まわりの権限挙動を変更していない

### Phase 8: 設定管理の成立

**対応 Issue**
- S-01

**主目的**
- ON / OFF、Volume を単一ソースで管理し、メニュー状態と同期させる

**想定変更範囲**
- Settings 用の新規ファイル 1 件
- menubar ファイル
- Audio ファイル

**実装内容**
- ON / OFF と Volume の状態ソースを定義する
- メニュー表示と内部状態を同期する
- 必要最小限の永続化を導入する

**Gate 条件**
- ON / OFF が即時反映される
- Volume が即時反映される
- 表示状態と内部状態が一致している

### Phase 9: 技術スパイクの採否判断

**対応 Issue**
- K-01

**主目的**
- Force Click / Pinch を機能追加ではなく、採否判断として整理する

**想定変更範囲**
- 原則コード変更なし、または最小限
- 計画書更新

**実装内容**
- 実現性、必要権限、UX 価値、保守コストを整理する
- 採用、見送り、後回しを明文化する

**Gate 条件**
- Force Click / Pinch の扱いが曖昧なまま残っていない
- 今後の実装判断に使える記録が残る

### Phase 10: ドキュメントとレビュー運用整備

**対応 Issue**
- D-01

**主目的**
- フェーズ進行、レビュー、逸脱時対応をプロジェクト運用に定着させる

**想定変更範囲**
- `PLAN.md`
- `AI_PLANNING_GUIDELINES.md`
- 必要なら `plans/` 配下の個別計画 1 件

**実装内容**
- フェーズ完了ごとに変更履歴を更新する
- 必要に応じて次フェーズ計画を詳細化する
- 独立レビュー前提の運用を固定する

**Gate 条件**
- 計画書が実装進行と同期して更新される
- 逸脱時処遇が記録できる

---

## 8. Phase と Issue の対応表

| Phase | 対応 Issue |
|------|------------|
| Phase 1 | C-01, C-02 |
| Phase 2 | A-01 |
| Phase 3 | I-01 |
| Phase 4 | I-02 |
| Phase 5 | A-02 |
| Phase 6 | A-03 |
| Phase 7 | I-03, I-04 |
| Phase 8 | S-01 |
| Phase 9 | K-01 |
| Phase 10 | D-01 |

---

## 9. フェーズ依存順序

- Phase 1 完了前に Phase 2 以降へ進まない
- Phase 2 完了前に Phase 3 以降へ進まない
- Phase 3 を先に完了し、その後に Phase 4 を開始する
- Phase 5 は Phase 3 / 4 完了後に開始する
- Phase 6 は Phase 5 完了後に開始する
- Phase 7 は Phase 4 / 6 完了後に開始する
- Phase 8 は Phase 2 〜 7 の制御対象が揃ってから行う
- Phase 9 は MVP の妨げにならないよう後置する
- Phase 10 は全期間を通じて更新するが、実装目的としては最後に整理する

---

## 10. 参照実装との差分

### 10.1 `MoanSwipeApp.swift` との差分

- すでに menubar シェルへ移行済み
- 今後は UI の変更より状態・設定の同期が焦点になる

**理由**
- プロダクト目的が常駐 menubar アプリであるため

**回帰リスク**
- 起動導線や終了導線を壊す可能性
- Window 前提コードが残ると状態不整合を起こす可能性

### 10.2 `ContentView.swift` との差分

- 主役から外れており、必要なら補助 UI に限定する方針を維持する

**理由**
- MVP の主導線はメニューバーであり、メインビューではないため

**回帰リスク**
- テンプレート依存のコードが残ると menubar 方針がぶれる

### 10.3 `project.pbxproj` との差分

- menubar 常駐に必要な設定は追加済み
- 今後は表示形態より入力・音声 UX を優先する

**理由**
- アプリの表示形態を明示する必要があるため

**回帰リスク**
- Dock 表示や起動挙動が意図せず変わる可能性

---

## 11. DRY / KISS 評価

### DRY

- 入力検出ごとに再生処理を重複実装しない
- Audio 層にランダム選択、直前音回避、事前ロード、多重再生制御を集約する
- Settings 層に ON / OFF と Volume の単一ソースを持たせる

### KISS

- 最初から Voice Pack 管理や複雑な設定画面を作らない
- click / tap / scroll を同時に全部完成させようとしない
- Force Click / Pinch は後段の採否判断へ送る

複雑化が必要になるのは、menubar 常駐、入力監視、音声再生がそれぞれ OS 制約を持つためであり、これは最小責務分離で吸収する。

---

## 12. 回帰 / 副作用チェック

各フェーズで最低限確認する観点は以下とする。

- アプリ起動後に menubar 導線が壊れていないか
- OFF にした直後に音が鳴らないか
- Volume 変更が即時反映されるか
- click / tap 実装後に menubar 操作が重くなっていないか
- scroll 実装後に過剰発火していないか
- ランダム化後に同一音の偏りが強すぎないか
- クリック連打時に前の音が途中で不自然に切れないか
- クリック連打時に入力から音までの遅延で無音感が出ていないか
- 一般的な短い scroll で複数音が流れすぎていないか
- 音源欠損時にクラッシュしないか
- 権限不足や未対応入力があってもアプリ全体が破綻しないか

---

## 13. 逸脱時の処遇方針

違反または逸脱が発生した場合は以下に従う。

1. 該当フェーズの実装を停止する
2. どの Issue / Phase / ガイドラインに違反したか記録する
3. 軽微なら `PLAN.md` に追記、重大ならフェーズ計画を再作成する
4. 緊急例外が必要なら `AI_PLANNING_GUIDELINES.md` の 4.5 に従う

---

## 14. 実装順序の最小単位

AI 実装時は、以下の最小単位で進める。

1. Phase 1 を単独で完了させる
2. Phase 2 を単独で完了させる
3. Phase 3 を単独で完了させる
4. Phase 4 を単独で完了させる
5. Phase 5 を単独で完了させる
6. Phase 6 を単独で完了させる
7. Phase 7 を単独で完了させる
8. Phase 8 を単独で完了させる
9. Phase 9 を判断フェーズとして実施する
10. Phase 10 は全期間を通じて更新し、節目ごとに計画とレビュー運用を整理する

1 回の実装指示で複数 Phase をまとめて進めない。

---

## 15. SSOT整合チェック結果

- `AI_PLANNING_GUIDELINES.md` と整合: 適合
- 現行実装との差分列挙: 記載済み
- menubar 優先方針: 計画に反映済み
- 入力 / Audio / Settings 分離方針: 計画に反映済み
- 不確実要素のスパイク化: `K-01` として分離済み

---

## 16. 変更履歴

- 2026-04-09 v1.0: 初回の要件整理版を作成
- 2026-04-09 v2.0: `AI_PLANNING_GUIDELINES.md` に合わせて再構成。Issue ID、Phase、Gate 条件、MECE、逸脱時処遇、セルフチェック前提を追加
- 2026-04-09 v2.1: 独立レビューの ADVISORY を反映。Phase 依存順序、Phase 2/4/5 の Gate 条件、Phase 8 の実装順序注記を明確化
- 2026-04-09 v2.2: Phase 3/4 の実装進行を反映し、scroll 継続時間や段階変化を扱う `I-03 / Phase 6` を追加。後続フェーズ番号と依存順序を更新
- 2026-04-09 v2.3: UX レビューを反映。`A-03` と `I-04` を追加し、低遅延・多重再生 audio 基盤と gesture 単位 scroll UX を独立フェーズへ分離。現状認識、MVP 条件、回帰チェック、実装順序も更新
- 2026-04-09 v2.4: Phase 6 の実装・Gate 通過を反映。現状認識と A-03 の状態を更新

---

## 17. セルフチェック結果

### §8 必須構成
[x] 1. SSOT参照宣言
[x] 2. 既存実装の類似参照
[x] 3. ID付き問題一覧
[x] 4. Issue と Phase の対応
[x] 5. Gate 条件
[x] 6. 回帰 / 副作用チェック
[x] 7. 変更履歴

### §10 MECE検査
[x] 検査A: Issue と Phase が相互対応している
[x] 検査B: 既存実装との差分を列挙した
[x] 検査C: DRY / KISS の評価を記載した

### §11 フェーズ閾値
[x] 1フェーズのファイル数 <= 3
[x] 新規ファイル <= 1
[x] 1フェーズの主目的は 1 つ

### §12 計画違反の処遇方針
[x] 逸脱時の処遇を記載した

### §13 AI向け指示
[x] SSOT整合チェック結果を記載した
[x] Issue→Phase対応表を記載した
[x] 実装順序の最小単位を記載した

### 判定
セルフチェック完了。独立レビューへ提出可。
