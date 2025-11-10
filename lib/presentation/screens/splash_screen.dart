import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nudge/presentation/screens/main_navigation_screen.dart';
import 'package:nudge/presentation/screens/onboarding_screen.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AuthState? _latestState;
  bool _minTimePassed = false;

  @override
  void initState() {
    super.initState();

    // 1. Start a 2-second timer.
    Timer(const Duration(seconds: 2), () {
      _minTimePassed = true;
      _tryNavigate();
    });
  }

  Future<void> _tryNavigate() async {
    // Only navigate when: (a) we have an auth state AND (b) 2 seconds are done
    if (_minTimePassed && _latestState != null && mounted) {
      if (_latestState is AuthAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else if (_latestState is AuthUnauthenticated) {
        FlutterSecureStorage flutterSecureStorage = FlutterSecureStorage();
        final isOnboardedString = await flutterSecureStorage.read(
          key: "isOnboarded",
        );
        final isOnboarded = isOnboardedString == "true";

        if (isOnboarded) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {}
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // 2. Save the latest auth state, but don't navigate yet
        _latestState = state;
        _tryNavigate();
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_rounded,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Chat App',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
