// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../services/local_db_service.dart';

class AuthProvider extends ChangeNotifier {
  final LocalDbService _dbService;
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userName;

  AuthProvider(this._dbService);

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  /// Giriş denemesi: eşleşme varsa true döner
  Future<bool> login(String email, String password) async {
    final result = await _dbService.db.rawQuery(
      'SELECT name, email FROM users WHERE email = ? AND password = ?',
      [email, password],
    );
    if (result.isNotEmpty) {
      _isAuthenticated = true;
      _userEmail = result.first['email'] as String;
      _userName = result.first['name'] as String;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Yeni kullanıcı kaydı
  Future<bool> register(String name, String email, String password) async {
    try {
      await _dbService.db.insert('users', {
        'name': name,
        'email': email,
        'password': password,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Çıkış yap
  void logout() {
    _isAuthenticated = false;
    _userEmail = null;
    _userName = null;
    notifyListeners();
  }
}
