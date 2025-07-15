import 'package:flutter/material.dart';
import 'package:ptt/ui/screens/sign_in_screen.dart';
import 'package:ptt/ui/utils/asset_paths.dart';
import 'package:ptt/ui/widgets/screen_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _moveToNextScreen();
  }

  Future<void> _moveToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(child: Scaffold(
      body: Image.asset(AssetPaths.logoSvg),
    ));
  }
}
