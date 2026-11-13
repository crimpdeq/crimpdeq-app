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
        isAutoDispose: true,
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
    r'793dd860ca044d3a2fd1a892c44761f5b3636de3';

abstract class _$ProgressorNotifier extends $Notifier<ProgressorState> {
  ProgressorState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProgressorState, ProgressorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProgressorState, ProgressorState>,
              ProgressorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
