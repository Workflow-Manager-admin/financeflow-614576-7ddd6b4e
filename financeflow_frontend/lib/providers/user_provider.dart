import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final SharedPreferences _prefs;

  UserProvider(this._prefs) {
    _loadUser();
  }

  UserModel? get user => _user;
  bool get isPremium => _user?.isPremium ?? false;

  Future<void> _loadUser() async {
    final userJson = _prefs.getString('user');
    if (userJson != null) {
      _user = UserModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(userJson)),
      );
      notifyListeners();
    }
  }

  Future<void> updateUser(UserModel user) async {
    _user = user;
    await _prefs.setString('user', jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> togglePremium() async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(isPremium: !_user!.isPremium);
      await updateUser(updatedUser);
    }
  }
}
