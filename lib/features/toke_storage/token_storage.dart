import 'package:shared_preferences/shared_preferences.dart';

import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';

class TokenStorate {
  static const _key = 'tokenDTO';

  static TokenStorate instance = TokenStorate._();

  factory TokenStorate() => instance;

  TokenStorate._();

  Future<void> set(TokenDto token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key, token.token);
  }

  Future<TokenDto> get() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(_key);

    if (token != null) {
      return TokenDto(token: token);
    } else {
      throw StorageDoesNotContainTokenException();
    }
  }

  Future<bool> doesContainsToken() async {
    try {
      await get();
      return true;
    } on StorageDoesNotContainTokenException {
      return false;
    }
  }
}

class StorageDoesNotContainTokenException implements Exception {}
