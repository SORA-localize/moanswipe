# Phase 7 Plan: Scroll Session UX

## 1. SSOT参照宣言

本計画書は、以下を単一真実源として参照する。

- [`PLAN.md`](/Users/hori/Desktop/MoanSwipe/PLAN.md)
- [`AI_PLANNING_GUIDELINES.md`](/Users/hori/Desktop/MoanSwipe/AI_PLANNING_GUIDELINES.md)
- [`MoanSwipe/MoanSwipeApp.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/MoanSwipeApp.swift)
- [`MoanSwipe/ContentView.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/ContentView.swift)
- [`MoanSwipe.xcodeproj/project.pbxproj`](/Users/hori/Desktop/MoanSwipe/MoanSwipe.xcodeproj/project.pbxproj)
- [`MoanSwipe/InputMonitor.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/InputMonitor.swift)
- [`MoanSwipe/AppState.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AppState.swift)
- [`MoanSwipe/AudioPlayer.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AudioPlayer.swift)

本計画書は `PLAN.md` の `I-03 / I-04 / Phase 7` を実装対象とし、それ以外の課題には踏み込まない。  
本計画は `PLAN.md` における `Phase 6` の完了を前提とする。

---

## 2. 既存実装の類似参照

### 2.1 現行の scroll 入力実装

- [`MoanSwipe/InputMonitor.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/InputMonitor.swift)
  - `scrollWheel` を event 単位で監視している

### 2.2 現行の scroll 再生接続

- [`MoanSwipe/AppState.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AppState.swift)
  - `scrollCooldown` により event 間引きを行っている
  - ただし gesture / session 概念は持っていない

### 2.3 今回の正解パターン

今回の正解パターンは、以下を満たすこととする。

- 短い一般的な scroll は 1 アクション 1 サウンドとして知覚しやすい
- scroll 開始、継続、終了を session として扱える
- 長い scroll だけ段階変化可能な内部状態を持つ
- click 系 UX は壊さない

---

## 3. 問題一覧（Issue List）

本計画書内の `I-03-1` 〜 `I-04-2` は、[`PLAN.md`](/Users/hori/Desktop/MoanSwipe/PLAN.md) の `I-03` と `I-04` を実装可能な粒度へ詳細化したサブ Issue である。

### I-03-1: scroll の開始・継続・終了を識別できない

- 現状は event 列しか扱っていない
- 継続時間や累積量を保持できない

### I-03-2: 長い scroll に対する段階変化の内部状態がない

- `short / sustained / intense` のような分類に必要なセッション状態が未実装

### I-04-1: 短い scroll でも複数音が鳴りやすい

- event ベースの間引きでは `1 アクション = 1 サウンド` に寄せにくい

### I-04-2: scroll クールダウン責務が暫定的に `AppState` に残っている

- Phase 6 では据え置いたが、Phase 7 では session 設計と合わせて整理する必要がある

---

## 4. 修正フェーズ

本計画書は `I-03 / I-04` 専用であり、以下の 1 フェーズのみを対象とする。

### Phase 7

**対応 Issue**
- I-03-1
- I-03-2
- I-04-1
- I-04-2

**主目的**
- scroll を event 単位ではなく session / gesture 単位で扱い、短い scroll の音数を減らしつつ、長い scroll の段階変化へつなぐ

**想定変更範囲**
- [`MoanSwipe/InputMonitor.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/InputMonitor.swift)
- [`MoanSwipe/AppState.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AppState.swift)
- [`MoanSwipe/AudioPlayer.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AudioPlayer.swift)
- 必要なら scroll session 用の新規ファイル 1 件

**実装内容**
- scroll session の開始時刻、最終イベント時刻、累積イベント数を保持する
- 一定時間イベントが途切れたら session 終了とみなす
- 基本挙動は「scroll 開始時だけ 1 音」とする
- 長時間継続した場合のみ段階変化可能な状態を作る
- `short / sustained / intense` のような scroll カテゴリを実際の audio 選択へ接続する
- `AudioPlayer` 側で scroll 用カテゴリごとの音声プール選択を扱えるようにする
- `scrollCooldown` の責務を `AppState` から session 側へ移すか、最小化して残すかを明文化して実装する
- 検証用ログを追加した場合は、Phase 完了までに撤去するか課題化する

---

## 5. Gate条件（Exit Criteria）

- 一般的な短い 2 本指 scroll を 5 回試行し、1 アクションで複数音が鳴ったと知覚される事象が 5 回中 1 回以下である
- scroll 開始時、継続中、終了時を区別できる内部状態がある
- 短い scroll と長い scroll で異なるカテゴリ選択が可能になっている
- 長い scroll に対して段階変化用の分類状態が実際の audio 選択へ接続されている
- click 系の音再生 UX を壊していない
- OFF 時は引き続き無音である
- 音源欠損時でもクラッシュしない
- 権限制約の確認は本 Phase の変更対象外であるため N/A とし、入力監視まわりの権限挙動を変更していない
- 検証のために追加した一時ログや暫定コードは、Phase 完了時に撤去または課題化されている

---

## 6. 回帰 / 副作用チェック

- 短い scroll で 1 音に感じやすくなったか
- 長い scroll で複数段階へ拡張可能な内部状態が取れているか
- click 連打 UX が壊れていないか
- OFF 時に click / scroll とも鳴らないか
- 音源欠損時にクラッシュしないか
- 一時ログを追加した場合、最終差分に残っていないか

---

## 7. 参照実装との差分

### 7.1 `InputMonitor.swift` との差分

- 現状は event 単位で scroll を通知している
- 変更後は session 化に必要な情報を渡せる形へ寄せる

**理由**
- gesture 単位 UX を作るには event の生列だけでは足りないため

**回帰リスク**
- scroll 取得そのものを壊す可能性

### 7.2 `AppState.swift` との差分

- 現状は `scrollCooldown` による間引きが中心
- 変更後は session 状態を使って再生判断する

**理由**
- `1 アクション = 1 サウンド` に寄せるため

**回帰リスク**
- click 系ロジックへ影響する可能性

### 7.3 `AudioPlayer.swift` との差分

- 現状の `scroll` は 1 カテゴリのみ
- 変更後は `short / sustained / intense` など複数の scroll カテゴリを受けられるようにする

**理由**
- 親計画が要求する「異なるカテゴリ選択」を実際の音声プールへ接続するため

**回帰リスク**
- Phase 6 で成立した click 系 UX を巻き込む可能性
- scroll 音源プールの切り替えミス

---

## 8. DRY / KISS評価

### DRY

- scroll session 管理は 1 か所に集約する
- click と scroll の再生自体は既存 `AudioPlayer` を再利用する
- scroll カテゴリ選択から音声プール選択への接続は `AudioPlayer` に集約する

### KISS

- 初手では「scroll 開始時 1 音」を基本形にする
- いきなり複雑な強度分類を入れず、まずは session 状態の導入を優先する
- ただし親計画に合わせ、分類状態を持つだけで終わらせず、少なくとも異なるカテゴリ選択が音声プールへ接続されるところまでを Phase 7 の完了条件とする

---

## 9. Issue→Phase対応表

| Issue | Phase |
|------|-------|
| I-03-1 | Phase 7 |
| I-03-2 | Phase 7 |
| I-04-1 | Phase 7 |
| I-04-2 | Phase 7 |

---

## 10. フェーズごとのGate条件

### Phase 7

- §5 の Gate 条件を満たしていること

---

## 11. 逸脱時の処遇方針

- `AudioPlayer` の polyphonic 基盤は本 Phase で壊さない
- click 系の再生ロジックまでまとめて変更しない
- 3 ファイル超の変更が必要になった場合は、実装前に計画を分割する
- 検証用ログを追加した場合は、Phase 完了前に撤去する。残す場合は理由付きで課題化する

---

## 12. 実装順序の最小単位

1. scroll session の最小モデルを導入する
2. scroll 開始時 1 音の判定へ切り替える
3. 長い scroll 用の段階状態を保持する
4. click 回帰を確認する
5. 短い scroll UX を優先確認する

---

## 13. SSOT整合チェック結果

- `PLAN.md` の `I-03 / I-04 / Phase 7` と整合: 適合
- `AI_PLANNING_GUIDELINES.md` の scroll UX 指針と整合: 適合
- 既存実装との差分列挙: 記載済み
- Phase 6 の audio 基盤を前提にし、混線させない方針: 適合

---

## 14. 変更履歴

- 2026-04-09 v1.0: Phase 7 専用計画書を新規作成
- 2026-04-09 v1.1: 親計画との整合性レビューを反映。変更範囲に `AudioPlayer` を追加し、scroll カテゴリ選択を実際の音声プール選択へ接続する要件と Gate 条件を明確化

---

## 15. セルフチェック結果

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
