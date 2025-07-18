import 'package:bid/features/authentication/controllers/onboarding_controller.dart';
import 'package:bid/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:bid/utils/constants/image_strings.dart';
import 'package:bid/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    return Scaffold(
      body: Stack(
        children: [
          /// Horizontal Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnboardingPage(
                  image: BidImageStrings.onBoarding1,
                  title: BidText.onBoardingTitte1,
                  subTitle: BidText.onBoardingSubTitte1),
              OnboardingPage(
                  image: BidImageStrings.onBoarding2,
                  title: BidText.onBoardingTitte2,
                  subTitle: BidText.onBoardingSubTitte2),
              OnboardingPage(
                  image: BidImageStrings.onBoarding3,
                  title: BidText.onBoardingTitte3,
                  subTitle: BidText.onBoardingSubTitte3),
              // Add more pages similarly
            ],
          ),
          OnBoardingSkip(),
          OnboardingDotNavegation.onBoardingDotNavegation(),
          OnBoardingNextButton(),
        ],
      ),
    );
  }
}
