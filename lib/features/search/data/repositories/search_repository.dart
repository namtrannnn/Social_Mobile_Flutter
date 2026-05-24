import '../datasources/search_remote_datasource.dart';
import '../models/search_user_model.dart';

class SearchRepository {
  final SearchRemoteDataSource _remoteDataSource = SearchRemoteDataSource();

  Future<List<SearchUserModel>> searchUsers({
    required String token,
    required String keyword,
  }) async {
    return await _remoteDataSource.searchUsers(token: token, keyword: keyword);
  }
}
