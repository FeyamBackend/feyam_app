import 'dart:io';

import 'package:feyam/core/network/authenticated_http_client.dart';
import 'package:feyam/core/network/session_expired_notifier.dart';
import 'package:feyam/features/auth/domain/entities/auth_user_entity.dart';
import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Map<String, String> store;

  setUp(() {
    store = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
      switch (call.method) {
        case 'read':
          return store[args['key'] as String];
        case 'write':
          store[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          store.remove(args['key'] as String);
          return null;
        case 'containsKey':
          return store.containsKey(args['key'] as String);
        case 'readAll':
          return Map<String, String>.from(store);
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  AuthenticatedHttpClient build({
    required http.Client inner,
    required _FakeAuthRepository auth,
    required SessionExpiredNotifier notifier,
  }) {
    return AuthenticatedHttpClient(
      inner: inner,
      secureStorage: const FlutterSecureStorage(),
      authRepository: auth,
      sessionExpiredNotifier: notifier,
    );
  }

  test('injects the Bearer token and returns non-401 responses as-is', () async {
    store['access_token'] = 'tok-1';
    String? sentAuth;
    final inner = MockClient((req) async {
      sentAuth = req.headers['Authorization'];
      return http.Response('ok', 200);
    });
    final client = build(
      inner: inner,
      auth: _FakeAuthRepository(),
      notifier: SessionExpiredNotifier(),
    );

    final res = await client.get(Uri.parse('https://x/api/cart'));

    expect(res.statusCode, 200);
    expect(sentAuth, 'Bearer tok-1');
  });

  test('refreshes once and retries with the new token on 401', () async {
    store['access_token'] = 'old';
    final auth = _FakeAuthRepository(onRefresh: () {
      store['access_token'] = 'new';
    });
    final tokens = <String?>[];
    var calls = 0;
    final inner = MockClient((req) async {
      tokens.add(req.headers['Authorization']);
      calls++;
      return http.Response('', calls == 1 ? 401 : 200);
    });
    final client = build(
      inner: inner,
      auth: auth,
      notifier: SessionExpiredNotifier(),
    );

    final res = await client.get(Uri.parse('https://x/api/cart'));

    expect(res.statusCode, 200);
    expect(auth.refreshCount, 1);
    expect(tokens, <String?>['Bearer old', 'Bearer new']);
  });

  test('notifies session-expired on a definitive refresh failure', () async {
    store['access_token'] = 'old';
    final auth = _FakeAuthRepository(
      onRefresh: () => throw const AuthTokenExpiredException(),
    );
    final notifier = SessionExpiredNotifier();
    final notified = notifier.stream.first; // Future que completa al notificar
    final inner = MockClient((req) async => http.Response('', 401));
    final client = build(inner: inner, auth: auth, notifier: notifier);

    final res = await client.get(Uri.parse('https://x/api/cart'));

    expect(res.statusCode, 401);
    await notified.timeout(const Duration(seconds: 1));
  });

  test('does NOT notify and surfaces a network error on a transient refresh '
      'failure', () async {
    store['access_token'] = 'old';
    final auth = _FakeAuthRepository(
      onRefresh: () => throw const AuthTokenRefreshTransientException(),
    );
    final notifier = SessionExpiredNotifier();
    var notified = false;
    notifier.stream.listen((_) => notified = true);
    final inner = MockClient((req) async => http.Response('', 401));
    final client = build(inner: inner, auth: auth, notifier: notifier);

    await expectLater(
      client.get(Uri.parse('https://x/api/cart')),
      throwsA(isA<SocketException>()),
    );
    await Future<void>.delayed(Duration.zero);
    expect(notified, isFalse);
  });

  test('single-flight: concurrent 401s trigger a single refresh', () async {
    store['access_token'] = 'old';
    final auth = _FakeAuthRepository(onRefresh: () {
      store['access_token'] = 'new';
    }, refreshDelay: const Duration(milliseconds: 50));
    final inner = MockClient((req) async {
      // 401 mientras el token siga siendo "old"; 200 una vez refrescado.
      final ok = req.headers['Authorization'] == 'Bearer new';
      return http.Response('', ok ? 200 : 401);
    });
    final client = build(
      inner: inner,
      auth: auth,
      notifier: SessionExpiredNotifier(),
    );

    final results = await Future.wait<http.Response>([
      client.get(Uri.parse('https://x/api/a')),
      client.get(Uri.parse('https://x/api/b')),
      client.get(Uri.parse('https://x/api/c')),
    ]);

    expect(results.every((r) => r.statusCode == 200), isTrue);
    expect(auth.refreshCount, 1);
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.onRefresh, this.refreshDelay});

  final void Function()? onRefresh;
  final Duration? refreshDelay;
  int refreshCount = 0;

  @override
  Future<void> refreshAccessToken() async {
    refreshCount++;
    if (refreshDelay != null) {
      await Future<void>.delayed(refreshDelay!);
    }
    onRefresh?.call();
  }

  @override
  Future<void> login() async {}

  @override
  Future<bool> logout() async => true;

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<AuthUserEntity?> getCurrentUser() async => null;
}
