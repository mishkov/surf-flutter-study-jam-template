import 'package:flutter/material.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/auth/screens/auth_screen.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_practice_chat_flutter/features/splash/splash_screen.dart';
import 'package:surf_practice_chat_flutter/features/toke_storage/token_storage.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

/// App,s main widget.
class MyApp extends StatelessWidget {
  final Future<bool> isThereTokenFuture = Future.delayed(
    const Duration(seconds: 3),
    TokenStorage().doesContainsToken,
  );

  /// Constructor for [MyApp].
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: isThereTokenFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final isThereToken = snapshot.data!;
            if (isThereToken) {
              final tokenFuture = TokenStorage().get();
              return FutureBuilder<TokenDto>(
                future: tokenFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ChatScreen(
                      chatRepository: ChatRepository(
                        StudyJamClient().getAuthorizedClient(
                          snapshot.data!.token,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Scaffold(
                      body: Center(
                        child: Text('Erro occured. Contact the developer'),
                      ),
                    );
                  } else {
                    return const SplashScreen();
                  }
                },
              );
            } else {
              return AuthScreen(
                authRepository: AuthRepository(StudyJamClient()),
              );
            }
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text('Erro occured. Contact the developer'),
              ),
            );
          } else {
            return const SplashScreen();
          }
        },
      ),
    );
  }
}
