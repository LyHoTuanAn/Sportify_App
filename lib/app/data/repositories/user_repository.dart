part of 'repositories.dart';

abstract class UserBase {
  Future<bool> toggleNotify(bool val);
  Future<UserModel> getDetail({String? userId});
  Future<UserModel> uploadAvatar(Uint8List bytes);
  Future<bool> updateUser(Map<String, dynamic> data);
  Future<Dashboard> getDashboard();
  Future<UserModel> getUserMe();
  Future<UserModel> updateUserMe(Map<String, dynamic> data);
}

class UserRepository implements UserBase {
  @override
  Future<UserModel> getDetail({String? userId}) {
    return ApiProvider.getDetail(userId: userId);
  }

  @override
  Future<bool> updateUser(Map<String, dynamic> data) {
    return ApiProvider.updateUser(data);
  }

  @override
  Future<UserModel> uploadAvatar(Uint8List bytes) {
    return ApiProvider.uploadAvatar(bytes);
  }

  @override
  Future<bool> toggleNotify(bool val) {
    return ApiProvider.toggleNotify(val);
  }

  @override
  Future<Dashboard> getDashboard() {
    return ApiProvider.getDashboard();
  }

  @override
  Future<UserModel> getUserMe() {
    return ApiProvider.getUserMe();
  }

  @override
  Future<UserModel> updateUserMe(Map<String, dynamic> data) {
    return ApiProvider.updateUserMe(data);
  }
}
