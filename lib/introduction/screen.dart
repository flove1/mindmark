import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mindmark/auth/screen.dart';
import 'package:mindmark/helpers/fonts.dart';
import 'package:mindmark/settings/settings.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({ Key? key }) : super(key: key);

  @override
  IntroScreenState createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  void _onIntroEnd(context) {
    SettingsRepository.setSkipIntroduction(true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  Widget _buildImage(String assetName, {double width = 175}) {
    return SvgPicture.asset('assets/$assetName', width: width, height: width);
  }

  @override
  Widget build(BuildContext context) {
    double fontScaling = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.0025;

    return IntroductionScreen(
      pages: [
          PageViewModel(
            titleWidget: Container(),
            bodyWidget: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: const Text(
                "Organize your thoughts with MindMark!", 
                textAlign: TextAlign.center,
                style: TextStyles.title
              ),
            ),
            image: Center(
              child: _buildImage("messy.svg", width: MediaQuery.of(context).size.width)
            ),
            decoration: PageDecoration(
              imagePadding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
              imageFlex: 6,
              bodyFlex: 4
              // bodyAlignment: Alignment.bottomCenter
            )
          ),
          PageViewModel(
            titleWidget: Container(),
            bodyWidget: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: const Text(
              "Access your notes from everywhere!", 
                textAlign: TextAlign.center,
                style: TextStyles.title
              ),
            ),
            image: Center(
              child: _buildImage("reading.svg", width: MediaQuery.of(context).size.width)
            ),
            decoration: PageDecoration(
              imagePadding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
              imageFlex: 6,
              bodyFlex: 4
              // bodyAlignment: Alignment.bottomCenter
            )
          ),
      ],
      onDone: () async {
        _onIntroEnd(context);
      },
      // onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      showBackButton: false,
      skip: Text('Skip', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16 * fontScaling)),
      next: Icon(Icons.arrow_forward, size: 32 * fontScaling),
      done: Text('Done', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16 * fontScaling)),
      curve: Curves.fastLinearToSlowEaseIn,
      dotsDecorator: DotsDecorator(
        size: Size(MediaQuery.of(context).size.width * 0.025, MediaQuery.of(context).size.width * 0.025),
        color: const Color(0xFFBDBDBD),
        activeSize: Size(MediaQuery.of(context).size.width * 0.05, MediaQuery.of(context).size.width * 0.025),
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
