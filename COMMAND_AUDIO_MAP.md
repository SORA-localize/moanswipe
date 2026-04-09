# MoanSwipe Command / Audio Map

## 目的

MoanSwipe で扱う入力コマンド、内部音声カテゴリ、実ファイル対応を 1 つの台帳にまとめる。  
今後の音声追加、リネーム、レア音源導入時はこのファイルを更新する。

---

## 1. 現在利用可能なコマンド一覧

### 1.1 実装済み

| コマンドID | 種別 | 発火元 | 内部カテゴリ | 現在の音声ファイル |
|---|---|---|---|---|
| `menu.play_test_sound` | 手動テスト | menubar `Play Test Sound` | `click` | `click_light_01.wav`, `click_soft_01.wav`, `click_sharp_01.wav` |
| `input.primary_click` | 実入力 | `leftMouseDown` | `click` | `click_light_01.wav`, `click_soft_01.wav`, `click_sharp_01.wav` |
| `input.scroll.short` | 実入力 | scroll session 開始時 | `scrollShort` | `scroll_soft_01.wav` |
| `input.scroll.sustained` | 実入力 | scroll session 継続 1.3 秒到達時 | `scrollSustained` | `scroll_flow_01.wav` |
| `input.scroll.sustained.pulse` | 実入力 | `sustained` 中に約 1.2 秒ごと | `scrollSustained` | `scroll_flow_01.wav` |
| `input.scroll.intense` | 実入力 | scroll session 継続 2.7 秒到達時 | `scrollIntense` | `scroll_intense_01.wav`, `67.wav` |
| `input.scroll.intense.pulse` | 実入力 | `intense` 中に約 0.9 秒ごと | `scrollIntense` | `scroll_intense_01.wav`, `67.wav` |

### 1.2 実装済みだが音声非対応

| コマンドID | 種別 | 状態 | 備考 |
|---|---|---|---|
| `menu.enabled_toggle` | UI 制御 | 音声なし | ON/OFF のみ |
| `menu.quit` | UI 制御 | 音声なし | アプリ終了 |

### 1.3 未実装だが計画上の候補

| コマンドID | 種別 | 計画上の位置づけ | 想定カテゴリ |
|---|---|---|---|
| `input.tap` | 実入力 | MVP 候補 | `tapLight`, `tapStrong` など |
| `input.force_click` | 実入力 | 検証項目 | `forceClick` |
| `input.pinch` | 実入力 | Phase 2 以降候補 | `pinchIn`, `pinchOut` など |

---

## 2. 現在の内部カテゴリ対応表

| 内部カテゴリ | 用途 | 発火条件 | 現在のファイル数 | 推奨数 | 実ファイル |
|---|---|---|---|---|---|
| `click` | 単発リアクション | menubar テスト再生、通常 click | 3 | 7 | `click_light_01.wav`, `click_soft_01.wav`, `click_sharp_01.wav` |
| `scrollShort` | 短い scroll 開始音 | 新規 scroll session 開始時 | 1 | 5 | `scroll_soft_01.wav` |
| `scrollSustained` | 中継続 scroll 音 | session 継続 1.3 秒到達時、および `sustained` pulse | 1 | 5 | `scroll_flow_01.wav` |
| `scrollIntense` | 長継続 scroll 音 | session 継続 2.7 秒到達時、および `intense` pulse | 2 | 6 | `scroll_intense_01.wav`, `67.wav` |

---

## 3. 現在の実ファイル一覧

### 3.1 本採用ファイル

配置先: [`MoanSwipe/Resources`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/Resources)

| ファイル名 | 現在の所属カテゴリ | 備考 |
|---|---|---|
| `click_light_01.wav` | `click` | click プール |
| `click_soft_01.wav` | `click` | click プール |
| `click_sharp_01.wav` | `click` | click プール |
| `scroll_soft_01.wav` | `scrollShort` | 短い scroll 用 |
| `scroll_flow_01.wav` | `scrollSustained` | 中継続 scroll 用 |
| `scroll_intense_01.wav` | `scrollIntense` | 長継続 scroll 用 |
| `67.wav` | `scrollIntense` | 試験的に intense プールへ追加したレア音声 |
| `anime-moan-3.wav` | 未使用 | 旧検証ファイル |

### 3.2 レア枠候補

配置先: [`wav_samples`](/Users/hori/Desktop/MoanSwipe/wav_samples)

| ファイル名 | 状態 | 備考 |
|---|---|---|
| `67.wav` | 試験採用中 | 現在は `scrollIntense` へ直接混在。将来的には低確率レア枠へ戻す想定 |
| `Girl-moans-EAR-RAPE.wav` | 未採用 | 低確率レア枠候補 |

---

## 4. 現在の入力ロジック対応

| 入力 | 実装箇所 | 現在の処理 |
|---|---|---|
| `leftMouseDown` | [`InputMonitor.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/InputMonitor.swift) | `AppState` を経由して `click` を再生 |
| `scrollWheel` | [`InputMonitor.swift`](/Users/hori/Desktop/MoanSwipe/MoanSwipe/InputMonitor.swift) | `ScrollSessionTracker` へ渡し、開始時は `scrollShort`、長時間継続中は `scrollSustained / scrollIntense` を pulse 間隔つきで再生 |

---

## 5. 命名ルール

### 5.1 コマンドID

- `menu.*`: menubar からの手動操作
- `input.*`: 実入力イベント
- `input.scroll.*`: scroll session の段階別イベント
- `input.scroll.*.pulse`: 長時間 scroll 中の追加発火

### 5.2 音声ファイル

- click 系: `click_<character>_<index>.wav`
- scroll 系: `scroll_<character>_<index>.wav`
- レア枠: 通常枠へ入れるまで `wav_samples/` で保留

---

## 6. 更新ルール

- 新しい入力イベントを実装したら、先にこのファイルへ `コマンドID` を追加する
- 新しい音声を採用したら、`内部カテゴリ対応表` と `実ファイル一覧` を同時に更新する
- pulse 間隔や段階到達時刻を変えた場合は、このファイルの発火条件も更新する
- レア音源を本採用に上げる場合は、出現条件もこのファイルへ追記する
- 旧検証音源を使わなくなったら、未使用として残すか削除するかを明記する
