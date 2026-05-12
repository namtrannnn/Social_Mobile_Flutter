import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'features/post/data/datasources/post_remote_datasource.dart';
import 'features/post/presentation/controllers/post_controller.dart';

import '../features/user/data/datasources/user_remote_datasource.dart';
import '../features/user/presentation/controllers/user_search_controller.dart';
import '../features/post/data/datasources/comment_remote_datasource.dart';
import '../features/post/data/repositories/comment_repository.dart';
import '../features/post/presentation/controllers/comment_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              PostController(postRemoteDataSource: PostRemoteDataSource()),
        ),

        ChangeNotifierProvider(
          create: (_) => UserSearchController(
            userRemoteDataSource: UserRemoteDataSource(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CommentController(
            repository: CommentRepository(
              remoteDataSource: CommentRemoteDataSource(),
            ),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
