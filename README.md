# Tagged Notes

Flutter で作成した **タグ付きメモアプリ** です。  
シンプルな UI でメモを作成・編集でき、タグフィルタ・検索・ピン留め・永続化に対応しています。

## 主な機能

- メモの新規作成・編集
- タグ（仕事 / プライベート / その他）による絞り込み
- タイトル・本文テキスト検索
- ピン留め（上部固定表示）
- SharedPreferences による永続化
- メモ詳細画面
- シンプルで読みやすい UI

## 画面イメージ

### メモ一覧


### メモ詳細


### メモ編集


## 技術スタック

- Flutter 3.x
- Provider（状態管理）
- SharedPreferences（ローカル永続化）
- intl（日時フォーマット）

## ディレクトリ構成
lib/
models/
note.dart
providers/
note_provider.dart
screens/
note_list_screen.dart
note_edit_screen.dart
note_detail_screen.dart
widgets/
note_list_item.dart
tag_filter_chips.dart


## 今後の改善予定

- アーカイブ機能
- ダークテーマ調整
- データストアの抽象化（Repository パターン）

