import 'package:flutter/material.dart';
import '../model_classes/add_newuser_model.dart';
import '../model_classes/delete_user_model.dart';
import '../model_classes/onUpdate_Password.dart';
import '../services/user_all_api.dart';

class UserProvider extends ChangeNotifier {
  final UserServices _userServices = UserServices();

  bool _isLoading = false;
  String? _errorMessage;
  AddNewuserModel? _addUserResponse;

  DeleteUserModel? _deleteUserResponse;

  DeleteUserModel? get deleteUserResponse =>
      _deleteUserResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AddNewuserModel? get addUserResponse => _addUserResponse;
  OnUpdatePassword? _updatePasswordResponse;

  OnUpdatePassword? get updatePasswordResponse =>
      _updatePasswordResponse;


  List<Map<String, dynamic>>? _searchUsers;

  List<Map<String, dynamic>>? get searchUsers => _searchUsers;
  Future<void> addNewUser(Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _addUserResponse = await _userServices.addNewUser(body);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> deleteUser(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _deleteUserResponse =
      await _userServices.deleteUser(id);

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> searchUsersByKeyword(
      String keyword) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final data = await _userServices.getSearchUser(keyword);

      _searchUsers = List<Map<String, dynamic>>.from(data);

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    }
  void clearSearch() {
    _searchUsers = null;
    notifyListeners();
  }
  Future<void> updatePassword({
    required Map<String, dynamic> body,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _updatePasswordResponse =
      await _userServices.updateStaff(
        body: body,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}