![Flutter Test](https://github.com/lesson-t/tagged_notes/actions/workflows/flutter_test.yml/badge.svg)

# Tagged Notes

タグで整理できるシンプルなメモアプリです。検索・ピン留め・永続化に対応し、UseCase/Repository 分離とユニットテスト、CI により品質を担保しています。

## Features
- メモ作成 / 編集 / 削除
- タグで絞り込み（仕事 / プライベート / その他）
- キーワード検索（タイトル / 本文）
- ピン留め（pinned を先頭表示）
- 永続化（KeyValueStore 抽象化 + SharedPreferences 実装）

## Architecture / Design
- Provider（ChangeNotifier）を Presentation 層の状態管理として使用
- UseCase（Application 層）に業務ロジックを集約
- Repository を通じて永続化へアクセス（KeyValueStore で差し替え可能）
- 一覧の並び順ルール（pinned 先頭）を共通ルールとして集約し、テストで固定

## Tech Stack
- Flutter / Dart
- state management: Provider
- persistence: SharedPreferences（KeyValueStore 抽象化）
- testing: Unit Test（UseCase中心）+ Widget Test（一部）
- CI: GitHub Actions（format / analyze / test / coverage artifact）

## Directory Structure (overview)
- `lib/models/`：ドメインモデル（Noteなど）
- `lib/usecase/`：UseCase（Add/Delete/TogglePin/Update/Load）+ ルール（NoteListRules）
- `lib/repositories/`：Repository（NoteRepository）
- `lib/storage/`：KeyValueStore 抽象化 + SharedPreferences 実装
- `lib/providers/`：Provider（NoteProvider）
- `lib/screens/`：UI（List/Detail/Edit）
- `test/`：UseCase のユニットテスト / Widget テスト

## CI
PR / main push で以下を自動実行します。
- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test --coverage`
- coverage HTML を artifact としてアップロード
