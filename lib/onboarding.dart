import 'package:bambuscanner/services/api.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:bambuscanner/theme/app_color.dart';
import 'package:bambuscanner/theme/app_theme.dart';
import 'package:bambuscanner/utils/url.dart';
import 'package:bambuscanner/widgets/textinput.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final TextEditingController _bambuddyUrlController = TextEditingController();
  final TextEditingController _bambuddyAPIKeyController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    List<PageViewModel> listPagesViewModel = [
      PageViewModel(
        titleWidget: Text(
          "Welcome to BamScan",
          style: TextStyle(
            color: context.appColor.primaryText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bodyWidget: Text(
          "This is the onboarding of BamScan.",
          style: TextStyle(color: context.appColor.primaryText, fontSize: 18),
        ),
        image: SvgPicture.asset(
          "assets/lens.svg",
          height: 250.0,
          colorFilter: ColorFilter.mode(context.appColor.primaryText, BlendMode.srcIn),
        ),
      ),
      PageViewModel(
        titleWidget: Text(
          "Connect Bambuddy",
          style: TextStyle(
            color: context.appColor.primaryText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bodyWidget: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextInput(
                      controller: _bambuddyUrlController,
                      labeltext: "Bambuddy URL",
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextInput(
                      controller: _bambuddyAPIKeyController,
                      labeltext: "Bambuddy API Key",
                      obscure: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
    return Scaffold(
      backgroundColor: context.appColor.base1,
      body: SafeArea(
        child: IntroductionScreen(
          globalBackgroundColor: context.appColor.base1,
          pages: listPagesViewModel,
          next: const Text(
            "Next",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          done: const Text(
            "Done",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          back: const Text(
            "Back",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onDone: () async {
            if (!await checkurl(context.appColor)) {
              return;
            }
            if (!await checkapikey(context.appColor)) {
              return;
            }
            StorageService.setBambuddyUrl(
              stripUrl(_bambuddyUrlController.text),
            );
            StorageService.saveToken(_bambuddyAPIKeyController.text);
            StorageService().loadFromStorage();
          },
          nextStyle: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(context.appColor.primaryText),
          ),
          doneStyle: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(context.appColor.primaryText),
          ),
          dotsDecorator: DotsDecorator(
            activeColor: context.appColor.primaryText,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<bool> checkapikey(AppColor appColor) async {
    bool? apikeystate = await checkApiKey(
      _bambuddyUrlController.text,
      _bambuddyAPIKeyController.text,
    );
    if (apikeystate == true) {
      return true;
    } else {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apikeystate == false
                ? "API Key is invalid!"
                : "Error while checking API Key!",
          ),
          backgroundColor: apikeystate == true
              ? appColor.success
              : appColor.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  Future<bool> checkurl(AppColor appColor) async {
    String url = _bambuddyUrlController.text;
    bool? health = await checkHealth(stripUrl(url));
    if (health == true) {
      return true;
    } else {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No Bambuddy Server found!"),
          backgroundColor: health == true ? appColor.success : appColor.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }
}
