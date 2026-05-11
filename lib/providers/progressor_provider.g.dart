// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progressor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProgressorNotifier)
final progressorProvider = ProgressorNotifierProvider._();

final class ProgressorNotifierProvider
    extends $NotifierProvider<ProgressorNotifier, ProgressorState> {
  ProgressorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressorNotifierHash();

  @$internal
  @override
  ProgressorNotifier create() => ProgressorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgressorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgressorState>(value),
    );
  }
}

String _$progressorNotifierHash() =>
    r'c144e57461e3274695a4d700d973ae1e839885ac';

abstract class _$ProgressorNotifier extends $Notifier<ProgressorState> {
  ProgressorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProgressorState, ProgressorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProgressorState, ProgressorState>,
              ProgressorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
