# Phase 6 Plan: Low-Latency Polyphonic Audio

## 1. SSOT参照宣言

本計画書は、以下を単一真実源として参照する。

- [`PLAN.md`](/Users/hori/Desktop/MoanSwipe/PLAN.md)
- [`AI_PLANNING_GUIDELINES.md`](/Users/hori/Desktop/MoanSwipe/AI_PLANNING_GUIDELINES.md)
- [`MoanSwipe/MoanSwipeApp.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/MoanSwipeApp.swift)
- [`MoanSwipe/ContentView.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/ContentView.swift)
- [`MoanSwipe.xcodeproj/project.pbxproj`](/Users/hori/Desktop/MoanSwipe/MoanSwipe.xcodeproj/project.pbxproj)
- [`MoanSwipe/AudioPlayer.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AudioPlayer.swift)
- [`MoanSwipe/AppState.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AppState.swift)
- [`MoanSwipe/InputMonitor.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/InputMonitor.swift)

本計画書は `PLAN.md` の `A-03 / Phase 6` を実装対象とし、それ以外の課題には踏み込まない。
本計画は `PLAN.md` における `Phase 5` の完了を前提とする。

---

## 2. 既存実装の類似参照

### 2.1 現行の audio 実装

- [`MoanSwipe/AudioPlayer.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AudioPlayer.swift)
  - 音声プール
  - ランダム再生
  - 直前音回避
  - ただし再生は単一 `AVAudioPlayer` 差し替え

### 2.2 現行の接続点

- [`MoanSwipe/AppState.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AppState.swift)
  - click / scroll の各イベントから `AudioPlayer` を呼び出している
  - scroll クールダウンを暫定的に保持している

### 2.3 今回の正解パターン

今回の正解パターンは、以下を満たすこととする。

- 再生前に音声を事前ロードする
- 再生時に既存の再生中音声を潰さない
- クリック連打時でも入力に対して one-shot 的に追従する
- `AppState` はカテゴリ指定の呼び出しだけを持ち、audio 制御の詳細を持たない

---

## 3. 問題一覧（Issue List）

本計画書内の `A-03-1` 〜 `A-03-4` は、[`PLAN.md`](/Users/hori/Desktop/MoanSwipe/PLAN.md) の `A-03` を実装可能な粒度へ詳細化したサブ Issue である。

### A-03-1: 単一プレイヤー差し替えで音が途中中断される

- 現状は `AudioPlayer` が単一 `AVAudioPlayer` を保持している
- 新しい再生要求で前の音が実質的に潰れる

### A-03-2: 再生ごとのロードで入力追従性が落ちる

- `AVAudioPlayer(contentsOf:)` を毎回生成している
- `prepareToPlay()` を都度実行している
- 短い click 音ではラグが目立ちやすい

### A-03-3: 同時再生上限の設計がない

- 多重再生へ移行する際の上限が未定
- 無制限再生は音の破綻や負荷増大につながる

### A-03-4: 現行のランダム化・直前音回避を壊す回帰リスクがある

- 低遅延化だけを優先すると、既存のカテゴリ選択ロジックを崩す可能性がある

---

## 4. 修正フェーズ

本計画書は `A-03` 専用であり、以下の 1 フェーズのみを対象とする。

### Phase 6

**対応 Issue**
- A-03-1
- A-03-2
- A-03-3
- A-03-4

**主目的**
- 低遅延かつ多重再生可能な one-shot audio 基盤へ移行する

**想定変更範囲**
- [`MoanSwipe/AudioPlayer.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AudioPlayer.swift)
- [`MoanSwipe/AppState.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AppState.swift)
- 必要なら audio 補助用の新規ファイル 1 件

**実装内容**
- 音声ファイルを起動時または初回利用前に事前ロードする
- カテゴリごとにクリップ選択したあと、再生は voice pool から空きスロットへ流す
- 再生中インスタンスを複数保持できるようにする
- 同時再生上限を定め、上限超過時の挙動を固定する
- 既存のランダム選択と直前音回避は維持する
- scroll クールダウンは本 Phase では [`MoanSwipe/AppState.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/AppState.swift) に暫定据え置きとし、`I-03 / I-04` を扱う Phase 7 で責務移設を再判断する
- 検証用ログを追加した場合は、Phase 完了までに撤去するか課題化する

---

## 5. Gate条件（Exit Criteria）

- 200ms 間隔の連続クリックを 5 回試行しても、先行音が即切断されたと知覚される事象が 0 回である
- 200ms 間隔の連続クリックを 5 回試行した際、入力後の無音感が目立つ試行が 0 回である
- 再生時に毎回ディスクロードしていない
- 同時再生上限がコード上で明示されている
- `click` / `scroll` のカテゴリ選択は従来どおり維持されている
- ランダム化と直前音回避が維持されている
- OFF 時は引き続き無音である
- 既存の scroll 側クールダウンを壊していない
- 音源欠損時でもクラッシュしない
- 権限制約の確認は本 Phase の変更対象外であるため N/A とし、入力監視まわりの権限挙動を変更していない
- 検証のために追加した一時ログや暫定コードは、Phase 完了時に撤去または課題化されている

---

## 6. 回帰 / 副作用チェック

- click 単発で鳴るか
- click 連打で前の音が即切断されにくいか
- click 連打で遅延による無音感が減っているか
- scroll 単発で鳴るか
- scroll の頻度制御が壊れていないか
- 直前音回避が効いたままか
- OFF 時に click / scroll とも鳴らないか
- 多重再生により CPU 使用量やノイズが極端に増えていないか
- 音源欠損時にクラッシュしないか
- 一時ログを追加した場合、最終差分に残っていないか

---

## 7. 参照実装との差分

### 7.1 `AudioPlayer.swift` との差分

- 現状は単一 `AVAudioPlayer`
- 変更後は事前ロード + 多重再生スロット管理へ移行する

**理由**
- UX のボトルネックが音の中断とラグにあるため

**回帰リスク**
- ランダム化や直前音回避の崩れ
- 再生管理の複雑化によるバグ混入

### 7.2 `AppState.swift` との差分

- 現状は `AudioPlayer` を単純呼び出し
- 変更後もカテゴリ指定だけに留め、audio 内部制御は持たせない
- ただし scroll クールダウンは本 Phase では例外として据え置き、Phase 7 で Audio / Session 側へ移すか再判断する

**理由**
- audio 責務を `AppState` に漏らさないため
- scroll 側の gesture 設計は Phase 7 の責務であり、本 Phase で同時に動かすと境界がぶれるため

**回帰リスク**
- 呼び出し境界を崩すと再利用性が落ちる
- scroll クールダウンの責務が一時的に `AppState` に残る

---

## 8. DRY / KISS評価

### DRY

- ランダム化、直前音回避、事前ロード、voice pool 管理は `AudioPlayer` 側に集約する
- `AppState` では click / scroll のカテゴリ分岐以上を持たない
- 例外として scroll クールダウンは本 Phase では現状維持とし、Phase 7 で session 設計と合わせて整理する

### KISS

- まずは `AVAudioPlayer` ベースの事前ロード + 複数インスタンス運用で改善を図る
- いきなり `AVAudioEngine` へ飛ばず、必要なら次段で判断する

複雑化の理由は、現状 UX の主因が audio 基盤にあり、単一プレイヤー構成では改善できないためである。

---

## 9. Issue→Phase対応表

| Issue | Phase |
|------|-------|
| A-03-1 | Phase 6 |
| A-03-2 | Phase 6 |
| A-03-3 | Phase 6 |
| A-03-4 | Phase 6 |

---

## 10. フェーズごとのGate条件

### Phase 6

- §5 の Gate 条件を満たしていること

---

## 11. 逸脱時の処遇方針

- `AppState` に audio 再生制御の詳細を持ち込まない
- `scroll session` の設計まで同時に入れない
- 3 ファイル超の変更が必要になった場合は、実装前に計画を分割する
- `AVAudioEngine` への移行が必要と判明した場合は、例外ではなく別計画として切り出す
- 検証用ログを追加した場合は、Phase 完了前に撤去する。残す場合は理由付きで課題化する

---

## 12. 実装順序の最小単位

1. `AudioPlayer` に事前ロード用の構造を追加する
2. 単一プレイヤーを voice pool 化する
3. 同時再生上限を導入する
4. `AppState` からの呼び出しが壊れていないことを確認する
5. click UX を優先確認し、scroll 回帰を確認する

---

## 13. SSOT整合チェック結果

- `PLAN.md` の `A-03 / Phase 6` と整合: 適合
- `AI_PLANNING_GUIDELINES.md` の音声 UX 指針と整合: 適合
- 既存実装との差分列挙: 記載済み
- `scroll session` を混在させない分離方針: 適合

---

## 14. 変更履歴

- 2026-04-09 v1.0: Phase 6 専用計画書を新規作成
- 2026-04-09 v1.1: 独立レビューの ADVISORY を反映。Gate 条件を §5 に一本化し、最低確認基準、サブ Issue 説明、Phase 5 完了前提を追記
- 2026-04-09 v1.2: BLOCKER 指摘を反映。SSOT 参照の補完、失敗パス Gate、scroll クールダウン責務の暫定方針、ログ撤去方針を追記

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
