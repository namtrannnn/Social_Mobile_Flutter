import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';

import 'core/services/socket_service.dart';

import 'features/auth/data/controllers/auth_controller.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';

import 'features/post/data/datasources/post_remote_datasource.dart';
import 'features/post/presentation/controllers/post_controller.dart';

import 'features/user/data/datasources/user_remote_datasource.dart';
import 'features/user/presentation/controllers/user_search_controller.dart';

import 'features/post/data/datasources/comment_remote_datasource.dart';
import 'features/post/data/repositories/comment_repository.dart';
import 'features/post/presentation/controllers/comment_controller.dart';

import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';

import 'features/notification/data/datasources/notification_remote_datasource.dart';
import 'features/notification/data/repositories/notification_repository.dart';
import 'features/notification/presentation/controllers/notification_controller.dart';

import 'features/friend/data/datasources/friend_remote_datasource.dart';
import 'features/friend/data/repositories/friend_repository.dart';
import 'features/friend/presentation/controllers/friend_controller.dart';

import 'features/chats/data/datasources/chat_remote_datasource.dart';
import 'features/chats/data/repositories/chat_repository.dart';
import 'features/chats/presentation/controllers/chat_controller.dart';

import 'features/search/presentation/controllers/global_search_controller.dart';

void main() {
  final socketService = SocketService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
            AuthRepository(AuthRemoteDataSource()),
            socketService,
          ),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              PostController(postRemoteDataSource: PostRemoteDataSource()),
        ),

        ChangeNotifierProvider(
          create: (_) => UserSearchController(
            userRemoteDataSource: UserRemoteDataSource(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => GlobalSearchController()),
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

        ChangeNotifierProvider(
          create: (_) => FriendController(
            repository: FriendRepository(
              remoteDataSource: FriendRemoteDataSource(),
            ),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => ChatController(
            repository: ChatRepository(remote: ChatRemoteDatasource()),
            socketService: socketService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
