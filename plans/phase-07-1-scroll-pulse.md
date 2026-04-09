# Phase 7.1 Plan: Long Scroll Pulse UX

## 1. SSOT参照宣言

本計画書は、以下を単一真実源として参照する。

- [`PLAN.md`](/Users/hori/Desktop/MoanSwipe/PLAN.md)
- [`AI_PLANNING_GUIDELINES.md`](/Users/hori/Desktop/MoanSwipe/AI_PLANNING_GUIDELINES.md)
- [`MoanSwipe/MoanSwipeApp.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/MoanSwipeApp.swift)
- [`MoanSwipe/ContentView.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/ContentView.swift)
- [`MoanSwipe.xcodeproj/project.pbxproj`](/Users/hori/Desktop/MoanSwipe/MoanSwipe.xcodeproj/project.pbxproj)
- [`MoanSwipe/AppState.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AppState.swift)
- [`MoanSwipe/AudioPlayer.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AudioPlayer.swift)
- [`MoanSwipe/ScrollSessionTracker.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/ScrollSessionTracker.swift)

本計画書は `PLAN.md` の `A-04 / I-05 / Phase 7.1` を実装対象とし、それ以外の課題には踏み込まない。  
本計画は `Phase 7` の session 導入が成立していることを前提とする。

---

## 2. 既存実装の類似参照

### 2.1 現在の scroll session 実装

- [`MoanSwipe/ScrollSessionTracker.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/ScrollSessionTracker.swift)
  - `short / sustained / intense` へ段階遷移する
  - ただし各段階で 1 回ずつしか音を返さない

### 2.2 現在の scroll 音声カテゴリ

- [`MoanSwipe/AudioPlayer.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AudioPlayer.swift)
  - `scrollShort`
  - `scrollSustained`
  - `scrollIntense`

### 2.3 今回の正解パターン

今回の正解パターンは、以下を満たすこととする。

- 短い scroll は引き続き 1 アクション 1 音に感じやすい
- 長い scroll では、一定間隔で追加音が流れ続ける
- 追加音は早すぎず、間延びしすぎない
- click 系 UX は壊さない

---

## 3. 問題一覧（Issue List）

### A-04: 長時間 scroll が段階遷移後に無音化する

- 現状は `short / sustained / intense` の各段階で 1 回ずつしか音が出ない
- 長時間 scroll 中に無音区間が長くなりやすい

### I-05: 長い scroll に対する追加音タイミングが UX 基準に合っていない

- `sustained` と `intense` の遷移時刻が近く感じられやすい
- 「次の音が早すぎる」違和感が出る

---

## 4. 修正フェーズ

本計画書は `A-04 / I-05` 専用であり、以下の 1 フェーズのみを対象とする。

### Phase 7.1

**対応 Issue**
- A-04
- I-05

**主目的**
- 長い scroll 中に制御された追加音を流せるようにし、無音化しやすい UX を改善する

**想定変更範囲**
- [`MoanSwipe/ScrollSessionTracker.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/ScrollSessionTracker.swift)
- [`MoanSwipe/AudioPlayer.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AudioPlayer.swift)
- [`COMMAND_AUDIO_MAP.md`](/Users/hori/Desktop/MoanSwipe/COMMAND_AUDIO_MAP.md)

**実装内容**
- `short` は開始時 1 音のみを維持する
- `sustained` と `intense` では、段階遷移音とは別に一定間隔の pulse 発火を許可する
- pulse 間隔は段階ごとに分ける
  - `sustained`: 長め
  - `intense`: やや短め
- pulse は event ごとの連打ではなく、session 状態が保持する `nextEligiblePlaybackAt` に基づいて発火する
- 実装着手前に [`COMMAND_AUDIO_MAP.md`](/Users/hori/Desktop/MoanSwipe/COMMAND_AUDIO_MAP.md) を、pulse 対応を反映した最新版へ更新する

---

## 5. Gate条件（Exit Criteria）

- 一般的な短い 2 本指 scroll を 5 回試行し、1 アクションで複数音が鳴ったと知覚される事象が 5 回中 1 回以下である
- 長い scroll を 5 回試行し、`sustained` 到達後に無音のまま終わる事象が 5 回中 1 回以下である
- `sustained` の pulse 間隔はおおむね 1.1 秒以上を維持し、「次が早すぎる」印象を減らしている
- `intense` の pulse 間隔は `sustained` より短いが、連打感で破綻していない
- click 系 UX を壊していない
- OFF 時は引き続き無音である
- 音源欠損時でもクラッシュしない
- 権限制約の確認は本 Phase の変更対象外であるため N/A とし、入力監視まわりの権限挙動を変更していない
- 検証用ログや暫定コードを追加した場合は、Phase 完了時に撤去または課題化されている

---

## 6. 回帰 / 副作用チェック

- 短い scroll の 1 音感が壊れていないか
- 長い scroll で追加音が早すぎないか
- 長い scroll で途中から無音になりすぎないか
- click 連打 UX が壊れていないか
- OFF 時に click / scroll とも鳴らないか

---

## 7. 参照実装との差分

### 7.1 `ScrollSessionTracker.swift` との差分

- 現状は段階ごとに 1 回ずつしか音を返さない
- 変更後は段階遷移音に加え、長い scroll 中の pulse 発火時刻を管理する

**理由**
- 長時間 scroll 中の無音化を防ぎつつ、event 連打再生へ戻さないため

**回帰リスク**
- 短い scroll でも余計な音が出る可能性

### 7.2 `AudioPlayer.swift` との差分

- 現状は scroll カテゴリ選択のみを受けている
- 変更後は pulse による繰り返し再生でも既存カテゴリ選択をそのまま使う

**理由**
- 長い scroll の追加音でも既存の音声カテゴリと抽選ロジックを再利用するため

**回帰リスク**
- 既存 click / scroll 抽選のシンプルさを壊す可能性

### 7.3 `COMMAND_AUDIO_MAP.md` との差分

- 現状は `scrollShort / scrollSustained / scrollIntense` の単発対応のみ
- 変更後は `pulse` の運用ルールを明記する

**理由**
- 音声追加時に「どこへ足すか」が曖昧なまま増殖するのを防ぐため

**回帰リスク**
- 実装と台帳がズレる可能性

---

## 8. DRY / KISS評価

### DRY

- pulse 判定は `ScrollSessionTracker` に集約する
- コマンドと音声の対応は `COMMAND_AUDIO_MAP.md` を唯一の台帳にする

### KISS

- pulse は段階別の固定間隔から始める
- `sustained` / `intense` の 2 段階だけに限定し、複雑な速度補正は入れない

---

## 9. Issue→Phase対応表

| Issue | Phase |
|---|---|
| A-04 | Phase 7.1 |
| I-05 | Phase 7.1 |

---

## 10. フェーズごとのGate条件

### Phase 7.1

- §5 の Gate 条件を満たしていること

---

## 11. 逸脱時の処遇方針

- 短い scroll の 1 音感を壊す変更はこの Phase では採用しない
- click 系の再生ロジックまでまとめて変更しない
- 3 ファイル超の変更が必要になった場合は、実装前に計画を分割する

---

## 12. 実装順序の最小単位

1. `COMMAND_AUDIO_MAP.md` を pulse 前提の運用へ更新する
2. `ScrollSessionTracker` に pulse 時刻管理を追加する
3. `AudioPlayer` の既存カテゴリ再生を pulse 運用にそのまま接続する
4. 短い scroll と click の回帰を確認する
5. 長い scroll の pulse 間隔を体感確認する

---

## 13. SSOT整合チェック結果

- `PLAN.md` の `A-04 / I-05 / Phase 7.1` と整合: 適合
- `AI_PLANNING_GUIDELINES.md` の scroll UX 指針と整合: 適合
- 既存実装との差分列挙: 記載済み
- 短い scroll の 1 音感を維持しつつ長い scroll だけを強化する方針: 適合

---

## 14. 変更履歴

- 2026-04-09 v1.0: 長時間 scroll 向け pulse UX の専用計画書を新規作成
- 2026-04-09 v1.1: 親計画へ `Phase 7.1` を反映し、rare 音声先回り項目を外して pulse UX 改善へ焦点を絞った

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
[x] 新規ファイル <= 0
[x] 1フェーズの主目的は 1 つ

### §12 計画違反の処遇方針
[x] 逸脱時の処遇を記載した

### §13 AI向け指示
[x] SSOT整合チェック結果を記載した
[x] Issue→Phase対応表を記載した
