あなたは MoanSwipe の計画書品質レビュアーです。
作成者AIとは独立した立場で、以下の計画書をレビューしてください。

【レビュー対象】
`plans/phase-07-1-scroll-pulse.md`

参照必須:
- `PLAN.md`
- `AI_PLANNING_GUIDELINES.md`
- `MoanSwipe/MoanSwipeApp.swift`
- `MoanSwipe/ContentView.swift`
- `MoanSwipe.xcodeproj/project.pbxproj`

---

## STEP 1: 構成チェック

以下の各項目について `存在する / 不足 / 欠落` を判定してください。

| 項目 | 判定 | 具体的な問題（あれば） |
|---|---|---|
| SSOT参照宣言 |  |  |
| 既存実装の類似参照 |  |  |
| ID付き問題一覧 |  |  |
| Issue↔Phase対応 |  |  |
| Gate条件 |  |  |
| 回帰/副作用チェック |  |  |
| 変更履歴 |  |  |
| MECE検査A（Issue↔Phase照合） |  |  |
| MECE検査B（差分列挙+理由） |  |  |
| MECE検査C（DRY/KISS評価） |  |  |
| フェーズ閾値（ファイル数≤3/目的=1） |  |  |
| 逸脱時の処遇方針 |  |  |

---

## STEP 2: 論理・整合性チェック

以下の観点で内部矛盾と親計画整合性を確認してください。

1. `PLAN.md` に定義された `A-04 / I-05 / Phase 7.1` と一致しているか
2. 短い scroll の 1 アクション 1 音感を壊さず、長い scroll の pulse UX だけを対象にしているか
3. Gate 条件が成功パスだけでなく、音源欠損・OFF・権限制約 N/A を含んでいるか
4. `AudioPlayer` 側の変更が rare 音声の先回り実装まで広がっていないか
5. `COMMAND_AUDIO_MAP.md` 更新が計画に含まれていて、実装との差分管理に使えるか

---

## STEP 3: 出力形式

以下の形式で結果を出力してください。

### 判定結果: [BLOCKER あり / ADVISORY のみ / 通過]

#### BLOCKER（実装進行不可）
- なし または項目ごとに列挙

#### ADVISORY（推奨修正、進行は可）
- なし または項目ごとに列挙

#### 通過確認
- BLOCKERゼロかつ必須構成が満たされている場合のみ「通過」と記録する

---

注意:
- `PLAN.md` に明示されていない内容を個別計画が勝手に追加していないか厳密に見ること
- rare 音声の将来構想は、今回の主目的である pulse UX 改善と切り分けて評価すること
- 計画書に明記されていない情報は補完せず、不足として扱うこと
