import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nudge/core/theme/app_theme.dart';
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
              // App Icon with modern styling
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withOpacity(0.1),
                      AppTheme.primaryPurple.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryPurple.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("assets/app_assets/nudge_bro.png"),
                ),
              ),

              const SizedBox(height: 20),

              // Logo with better positioning
              SizedBox(
                height: 35,
                child: Center(
                  child: SvgPicture.asset(
                    "assets/app_assets/NUDGE.svg",
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 20,
                width:20,
                child: const CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
