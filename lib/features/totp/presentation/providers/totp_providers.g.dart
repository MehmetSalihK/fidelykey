// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totp_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$secureStorageServiceHash() =>
    r'28ef5a96de61720fa06a7ba59ceb572a1791b078';

/// See also [secureStorageService].
@ProviderFor(secureStorageService)
final secureStorageServiceProvider =
    AutoDisposeProvider<SecureStorageService>.internal(
  secureStorageService,
  name: r'secureStorageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureStorageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureStorageServiceRef = AutoDisposeProviderRef<SecureStorageService>;
String _$totpServiceHash() => r'e04e3f3d0865784ea192f71bb4c22b53ab278a2a';

/// See also [totpService].
@ProviderFor(totpService)
final totpServiceProvider = AutoDisposeProvider<TotpService>.internal(
  totpService,
  name: r'totpServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totpServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotpServiceRef = AutoDisposeProviderRef<TotpService>;
String _$totpRepositoryHash() => r'b8bd738f01e7ee3c0a600afde07bf1e471c771a8';

/// See also [totpRepository].
@ProviderFor(totpRepository)
final totpRepositoryProvider = AutoDisposeProvider<TotpRepository>.internal(
  totpRepository,
  name: r'totpRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totpRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotpRepositoryRef = AutoDisposeProviderRef<TotpRepository>;
String _$filteredAccountsHash() => r'6e977e91d9cf197e058a5c0fb50e94c95344f15b';

/// See also [filteredAccounts].
@ProviderFor(filteredAccounts)
final filteredAccountsProvider =
    AutoDisposeProvider<List<TotpAccount>>.internal(
  filteredAccounts,
  name: r'filteredAccountsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredAccountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredAccountsRef = AutoDisposeProviderRef<List<TotpAccount>>;
String _$totpTimerHash() => r'82c4b712aded9302d1eb8fd1772f3fe32898fe95';

/// See also [totpTimer].
@ProviderFor(totpTimer)
final totpTimerProvider = AutoDisposeStreamProvider<int>.internal(
  totpTimer,
  name: r'totpTimerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totpTimerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotpTimerRef = AutoDisposeStreamProviderRef<int>;
String _$totpProgressHash() => r'4d543d0ed3b8a5a8b63796c3a0b52ceeef8ab4a5';

/// See also [totpProgress].
@ProviderFor(totpProgress)
final totpProgressProvider = AutoDisposeStreamProvider<double>.internal(
  totpProgress,
  name: r'totpProgressProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totpProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotpProgressRef = AutoDisposeStreamProviderRef<double>;
String _$totpCodeHash() => r'5b76e7400b8c94025d2d6f29999b0430f6b91730';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [totpCode].
@ProviderFor(totpCode)
const totpCodeProvider = TotpCodeFamily();

/// See also [totpCode].
class TotpCodeFamily extends Family<String> {
  /// See also [totpCode].
  const TotpCodeFamily();

  /// See also [totpCode].
  TotpCodeProvider call(
    TotpAccount account,
  ) {
    return TotpCodeProvider(
      account,
    );
  }

  @override
  TotpCodeProvider getProviderOverride(
    covariant TotpCodeProvider provider,
  ) {
    return call(
      provider.account,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'totpCodeProvider';
}

/// See also [totpCode].
class TotpCodeProvider extends AutoDisposeProvider<String> {
  /// See also [totpCode].
  TotpCodeProvider(
    TotpAccount account,
  ) : this._internal(
          (ref) => totpCode(
            ref as TotpCodeRef,
            account,
          ),
          from: totpCodeProvider,
          name: r'totpCodeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$totpCodeHash,
          dependencies: TotpCodeFamily._dependencies,
          allTransitiveDependencies: TotpCodeFamily._allTransitiveDependencies,
          account: account,
        );

  TotpCodeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.account,
  }) : super.internal();

  final TotpAccount account;

  @override
  Override overrideWith(
    String Function(TotpCodeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TotpCodeProvider._internal(
        (ref) => create(ref as TotpCodeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        account: account,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _TotpCodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TotpCodeProvider && other.account == account;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, account.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TotpCodeRef on AutoDisposeProviderRef<String> {
  /// The parameter `account` of this provider.
  TotpAccount get account;
}

class _TotpCodeProviderElement extends AutoDisposeProviderElement<String>
    with TotpCodeRef {
  _TotpCodeProviderElement(super.provider);

  @override
  TotpAccount get account => (origin as TotpCodeProvider).account;
}

String _$duressModeHash() => r'd66425d72c94b4647e5bd54f93d33515f7d188d1';

/// See also [DuressMode].
@ProviderFor(DuressMode)
final duressModeProvider =
    AutoDisposeNotifierProvider<DuressMode, bool>.internal(
  DuressMode.new,
  name: r'duressModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$duressModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DuressMode = AutoDisposeNotifier<bool>;
String _$accountsHash() => r'086b2f4728e445ee2dcd030354b84d60cf06e8d5';

/// See also [Accounts].
@ProviderFor(Accounts)
final accountsProvider =
    AutoDisposeAsyncNotifierProvider<Accounts, List<TotpAccount>>.internal(
  Accounts.new,
  name: r'accountsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$accountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Accounts = AutoDisposeAsyncNotifier<List<TotpAccount>>;
String _$searchQueryHash() => r'2ab221c441fd042c8cbf58b17e7e766363f36b6f';

/// See also [SearchQuery].
@ProviderFor(SearchQuery)
final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQuery, String>.internal(
  SearchQuery.new,
  name: r'searchQueryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
