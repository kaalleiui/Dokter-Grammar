import '../datasources/local/user_local_datasource.dart';
import '../../core/models/user_profile.dart';

class UserRepository {
  final UserLocalDataSource _dataSource = UserLocalDataSource();

  Future<int> createUser(UserProfile user) async {
    return await _dataSource.createUser(user);
  }

  Future<UserProfile?> getUserById(int id) async {
    return await _dataSource.getUserById(id);
  }

  Future<UserProfile?> getCurrentUser() async {
    return await _dataSource.getCurrentUser();
  }

  Future<void> updateUser(UserProfile user) async {
    await _dataSource.updateUser(user);
  }
}

