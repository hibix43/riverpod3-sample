# Riverpod ライフサイクル管理の分析

## 概要

このドキュメントは、Riverpod の `autoDispose` プロバイダーと `Ref` のライフサイクル管理に関する分析結果をまとめたものです。
テストの成功・失敗パターンから、どのような実装が失敗するのか、また成功するのかを整理しています。

## テスト結果の整理

### ServiceWithoutRef のテスト結果

| テスト名 | read() | listen() | 結果 |
|---------|--------|----------|------|
| `withoutRef_read_失敗` | ✅ | - | ❌ 失敗 |
| `withoutRef_listen_成功` | - | ✅ | ✅ 成功 |
| `withoutRef2_read_失敗` | ✅ | - | ❌ 失敗 |
| `withoutRef2_listen_成功` | - | ✅ | ✅ 成功 |

**パターン**: `read()` で失敗、`listen()` で成功

### ServiceWithRef のテスト結果

| テスト名 | read() | listen() | 結果 |
|---------|--------|----------|------|
| `withRef_read_失敗` | ✅ | - | ❌ 失敗 |
| `withRef_listen_成功` | - | ✅ | ✅ 成功 |
| `withRef_read_失敗_例外期待_リトライ` | ✅ | - | ❌ 失敗 |
| `withRef_listen_成功_例外期待_リトライ` | - | ✅ | ✅ 成功 |

**パターン**: `read()` で失敗、`listen()` で成功

### SyncStateUseCaseNotifier のテスト結果

| テスト名 | read() | listen() | 結果 |
|---------|--------|----------|------|
| `executeWithServiceWithoutRef_read_失敗` | ✅ | - | ❌ 失敗 |
| `executeWithServiceWithoutRef_listen_失敗` | - | ✅ | ❌ 失敗 |
| `executeWithServiceWithoutRef2_read_失敗` | ✅ | - | ❌ 失敗 |
| `executeWithServiceWithoutRef2_listen_成功` | - | ✅ | ✅ 成功（`await` 追加後） |
| `executeWithServiceWithRef_read_失敗` | ✅ | - | ❌ 失敗 |
| `executeWithServiceWithRef_listen_失敗` | - | ✅ | ❌ 失敗 |

**パターン**: ほぼ全て失敗（`executeWithServiceWithoutRef2_listen` のみ `await` 追加で成功）

### AsyncStateUseCaseNotifier のテスト結果

| テスト名 | read() | listen() | 結果 |
|---------|--------|----------|------|
| `executeWithServiceWithoutRef_read_失敗` | ✅ | - | ❌ 失敗 |
| `executeWithServiceWithoutRef_listen_成功` | - | ✅ | ✅ 成功 |
| `executeWithServiceWithoutRef2_read_失敗` | ✅ | - | ❌ 失敗 |
| `executeWithServiceWithoutRef2_listen_成功` | - | ✅ | ✅ 成功 |
| `executeWithServiceWithRef_read_失敗` | ✅ | - | ❌ 失敗 |
| `executeWithServiceWithRef_listen_成功` | - | ✅ | ✅ 成功 |

**パターン**: `read()` で失敗、`listen()` で成功

## 失敗する実装パターン

### 1. FutureProvider + `container.read()` の組み合わせ

**失敗するケース:**
- `serviceWithoutRefProvider` / `serviceWithoutRef2Provider` を `container.read()` で取得
- `serviceWithRefProvider` を `container.read()` で取得
- `SyncStateUseCaseNotifier` / `AsyncStateUseCaseNotifier` を `container.read()` で取得

**原因:**
- `read()` は一時的な参照のため、`autoDispose` が有効なプロバイダーは即座に破棄される可能性がある
- 非同期処理中に `Ref` が破棄されると `UnmountedRefException` が発生

### 2. `ServiceWithoutRef` のクロージャ内での `ref.read()` 使用

```dart
@riverpod
Future<ServiceWithoutRef> serviceWithoutRef(Ref ref) async {
  final repository = await ref.watch(repositoryProvider.future);
  return ServiceWithoutRef(
    repository: repository,
    runSideEffect: (data) {
      // ❌ 失敗: UnmountedRefException
      ref.read(runSideEffectProvider)(data);
    },
  );
}
```

**失敗する理由:**
- `ServiceWithoutRef` の `runSideEffect` クロージャが `ref` をキャプチャしている
- プロバイダーが破棄された後にクロージャが実行されると `ref` が無効になる

### 3. `ServiceWithRef` の `calcWithRetry()` で `read()` 使用時

```dart
Future<void> calcWithRetry({int retryCount = 0}) async {
  try {
    final repository = await ref.read(repositoryProvider.future);
    final data = await repository.fetchHelloWorld();
    ref.read(runSideEffectProvider)(data);
  } catch (e) {
    if (retryCount < 3) {
      await Future.delayed(const Duration(milliseconds: 500));
      await calcWithRetry(retryCount: retryCount + 1);
    }
  }
}
```

**失敗する理由:**
- リトライの `Future.delayed(500ms)` 中に `Ref` が破棄される可能性がある
- 非同期処理の時間が `autoDispose` による `Ref` の破棄より長い場合に失敗する

### 4. `SyncStateUseCaseNotifier` の全パターン（一部を除く）

**失敗する理由:**
- `SyncStateUseCaseNotifier` 自体が `read()` で取得されている
- 内部でさらに `ref.read()` を使うと、二重に破棄のリスクがある
- `readFirst()` 拡張メソッドの実装に問題がある（後述）

## 成功する実装パターン

### 1. `container.listen()` の使用

**成功するケース:**
- すべてのプロバイダーで `container.listen()` を使用すると成功

**理由:**
- `listen()` はプロバイダーを購読状態に保つため、`autoDispose` による破棄が抑制される
- `Ref` が有効な状態が維持される

### 2. `serviceWithoutRef2Provider` の `ref.watch()` 使用

```dart
@riverpod
Future<ServiceWithoutRef> serviceWithoutRef2(Ref ref) async {
  final repository = await ref.watch(repositoryProvider.future);
  // ✅ 成功: ref.watch() で事前に取得
  final runSideEffectFunction = ref.watch(runSideEffectProvider);
  return ServiceWithoutRef(
    repository: repository,
    runSideEffect: runSideEffectFunction,
  );
}
```

**成功する理由:**
- `ref.watch()` で `runSideEffectProvider` を取得しているため、クロージャ内で `ref` を使わない
- 依存関係が明確になり、ライフサイクル管理が適切になる

### 3. `AsyncStateUseCaseNotifier` の `listen()` 使用

**成功する理由:**
- `AsyncValue.guard()` 内で実行されるため、非同期処理のライフサイクルが適切に管理される
- `AsyncStateUseCaseNotifier` 自体が購読状態で保持される

## `SyncStateUseCaseNotifier` が全て失敗する原因

### 根本原因

`readFirst()` 拡張メソッドの実装に問題があります：

```dart
extension on Ref {
  Future<T> readFirst<T>(Refreshable<Future<T>> listenable) async {
    final subscription = listen(listenable, (p, n) {});
    try {
      return subscription.read();  // ❌ await がない
    } finally {
      subscription.close();
    }
  }
}
```

### 失敗の流れ

1. **`readFirst()` の実行**
   - `listen()` で `serviceWithoutRefProvider` を購読
   - `subscription.read()` で `ServiceWithoutRef` インスタンスを取得（非同期で完了を待つ）
   - `finally` ブロックで `subscription.close()` を実行

2. **`close()` による破棄**
   - `serviceWithoutRefProvider` が破棄される
   - 依存する `repositoryProvider` や `runSideEffectProvider` も破棄される可能性がある
   - `serviceWithoutRefProvider` の `Ref` が無効化される

3. **`service.calc()` 実行時のエラー**
   - `ServiceWithoutRef` の `runSideEffect` クロージャ内で `ref.read(runSideEffectProvider)` を呼び出そうとする
   - 既に `ref` が破棄されているため `UnmountedRefException` が発生

### 修正: `await` の追加

```dart
extension on Ref {
  Future<T> readFirst<T>(Refreshable<Future<T>> listenable) async {
    final subscription = listen(listenable, (p, n) {});
    try {
      return await subscription.read();  // ✅ await を追加
    } finally {
      subscription.close();
    }
  }
}
```

**なぜ `await` が必要なのか:**

1. **`subscription.read()` は `Future<T>` を返す**
   - `Future` が完了するまで待つ必要がある

2. **`await` がない場合の動作**
   - `subscription.read()` は `Future` を返すだけで、完了を待たない
   - `finally` ブロックが即座に実行され、`subscription.close()` が呼ばれる
   - `Future` が完了する前に `close()` が呼ばれ、プロバイダーが破棄される可能性がある
   - タイミングによっては、`Future` が完了する前に破棄される

3. **`await` がある場合の動作**
   - `subscription.read()` の `Future` が完了するまで待つ
   - `Future` が完了してから `finally` ブロックが実行される
   - `close()` が呼ばれる前に `Future` が完了することが保証される
   - プロバイダーが破棄される前に値が取得できる

### なぜ `executeWithServiceWithoutRef2_listen` だけ成功するのか

**`serviceWithoutRef2` と `serviceWithoutRef` の実装の違い:**

- **`serviceWithoutRef`**: クロージャ内で `ref.read(runSideEffectProvider)` を使用
  - `close()` 後に `service.calc()` を実行すると、破棄された `ref` を使用しようとして失敗

- **`serviceWithoutRef2`**: `ref.watch(runSideEffectProvider)` で事前に取得
  - クロージャ内で `ref` を使用しない
  - `await` により、`close()` 前に `Future` が完了し、`runSideEffectFunction` が取得済み
  - `close()` 後でも、既に取得した関数を使うだけなので成功

## まとめ

### 失敗する実装の特徴

1. `container.read()` で `autoDispose` プロバイダーを取得
2. 非同期処理中に `Ref` が破棄される可能性がある
3. クロージャ内で `ref.read()` を使用し、プロバイダー破棄後に実行される
4. リトライなど長時間の非同期処理中に `Ref` が無効になる
5. `readFirst()` で `await` がない場合、`Future` が完了する前に `close()` が呼ばれる

### 成功する実装の特徴

1. `container.listen()` でプロバイダーを購読状態に保つ
2. `ref.watch()` で依存関係を明示的に管理
3. `Ref` を直接保持するのではなく、必要な値を事前に取得
4. `readFirst()` で `await` を使用し、`Future` が完了してから `close()` を呼ぶ
5. `AsyncValue.guard()` を使用して非同期処理のライフサイクルを適切に管理

### 根本原因

Riverpod の `autoDispose` と `Ref` のライフサイクル管理が原因です。
`read()` は一時的な参照のため、非同期処理中に破棄されるリスクがあります。
`listen()` はプロバイダーを購読状態に保つため、破棄が抑制されます。

### 推奨される実装パターン

1. **プロバイダーの取得**: `container.listen()` を使用
2. **依存関係の管理**: `ref.watch()` を使用
3. **非同期処理**: `AsyncValue.guard()` を使用
4. **一時的な取得**: `readFirst()` を使用する場合は必ず `await` を付ける

## 参考

- [Riverpod Documentation](https://riverpod.dev/)
- [autoDispose の動作](https://riverpod.dev/docs/concepts/modifiers/auto_dispose)
- [Ref のライフサイクル](https://riverpod.dev/docs/concepts/reading)

