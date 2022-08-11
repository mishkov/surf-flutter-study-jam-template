import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surf_practice_chat_flutter/features/auth/exceptions/auth_exception.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Screen for authorization process.
///
/// Contains [IAuthRepository] to do so.
class AuthScreen extends StatefulWidget {
  /// Repository for auth implementation.
  final IAuthRepository authRepository;

  /// Constructor for [AuthScreen].
  const AuthScreen({
    required this.authRepository,
    Key? key,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignInInProcess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _loginController,
              decoration: InputDecoration(
                label: const Text('Login'),
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                label: const Text('Password'),
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            _isSignInInProcess
                ? const CircularProgressIndicator.adaptive()
                : ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 70,
                          vertical: 10,
                        ),
                      ),
                    ),
                    onPressed: _signIn,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    final login = _loginController.text;
    final password = _passwordController.text;
    try {
      _isSignInInProcess = true;
      final token =
          await widget.authRepository.signIn(login: login, password: password);
      _pushToChat(context, token);
    } on AuthException catch (e) {
      final snackBar = SnackBar(
        content: Text(e.message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      log(e.toString(), error: e);
      const snackBar = SnackBar(
        content: Text('Error occured'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      _isSignInInProcess = false;
    }
  }

  void _pushToChat(BuildContext context, TokenDto token) {
    Navigator.push<ChatScreen>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChatScreen(
            chatRepository: ChatRepository(
              StudyJamClient().getAuthorizedClient(token.token),
            ),
          );
        },
      ),
    );
  }
}
