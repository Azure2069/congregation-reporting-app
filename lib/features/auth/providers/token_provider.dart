import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/token_storage.dart';
































final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final authTokenProvider = StateProvider<String?>((ref) => null);

final restoreTokenProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(tokenStorageProvider);
  final token = await storage.readToken();

  if (token != null && token.isNotEmpty) {
    ref.read(authTokenProvider.notifier).state = token;
  }
});

