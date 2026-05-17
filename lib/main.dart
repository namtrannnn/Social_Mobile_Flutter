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

import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';

import 'features/notification/data/datasources/notification_remote_datasource.dart';
import 'features/notification/data/repositories/notification_repository.dart';
import 'features/notification/presentation/controllers/notification_controller.dart';

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
        ChangeNotifierProvider(
          create: (_) => ProfileController(
            repository: ProfileRepository(
              remoteDataSource: ProfileRemoteDataSource(),
            ),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => NotificationController(
            repository: NotificationRepository(
              remoteDataSource: NotificationRemoteDataSource(),
            ),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
