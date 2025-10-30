# GitHub Issue #4371 コメント

I apologize for the confusion. After further investigation, I realized this was actually my mistake in the issue description.

The issue was that I incorrectly showed extending `$Notifier<bool>` in the issue description, but the correct approach is to extend `_$SampleNotifier`. Here's the corrected implementation:

**Issue description (incorrect):**

```dart
class SampleNotifierMock extends $Notifier<bool>
    with Mock
    implements SampleNotifier {}
```

**Correct implementation:**

```dart
class SampleNotifierMock extends _$SampleNotifier
    with Mock
    implements SampleNotifier {
  @override
  bool build() {
    return false;
  }
}
```

This resolves the "Null check operator used on a null value" error when accessing `.notifier`.

Thank you for your time, and sorry for the confusion in the original issue description!

---
