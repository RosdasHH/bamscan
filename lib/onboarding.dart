import 'package:bambuscanner/helper/showSnackbar.dart';
import 'package:bambuscanner/services/api.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:bambuscanner/theme/app_color.dart';
import 'package:bambuscanner/theme/app_theme.dart';
import 'package:bambuscanner/utils/url.dart';
import 'package:bambuscanner/widgets/textinput.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final TextEditingController _bambuddyUrlController = TextEditingController();
  final TextEditingController _bambuddyAPIKeyController =
      TextEditingController();
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
          "Manage your filaments more easily.",
          style: TextStyle(color: context.appColor.primaryText, fontSize: 18),
        ),
        image: SvgPicture.asset(
          "assets/lens.svg",
          height: 250.0,
          colorFilter: ColorFilter.mode(
            context.appColor.primaryText,
            BlendMode.srcIn,
          ),
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
                      labeltext: "Bambuddy URL:PORT",
                      hinttext: "e.g. http://127.0.0.1:8000",
                      autofocus: true,
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
                      hinttext: "Bambuddy WebUI -> Settings -> API Keys",
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
            if (!context.mounted) return;
            if (!await checkapikey(context.appColor)) {
              return;
            }
            StorageService storageService = StorageService();
            storageService.setBambuddyUrl(
              stripUrl(_bambuddyUrlController.text),
            );
            storageService.saveToken(_bambuddyAPIKeyController.text);
            storageService.setFirstUse(false);
            StorageService().loadFromStorage();
            storageService = StorageService();
          },
          nextStyle: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(
              context.appColor.primaryText,
            ),
          ),
          doneStyle: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(
              context.appColor.primaryText,
            ),
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
    ApiService apiService = context.read<ApiService>();
    bool? apikeystate = await apiService.checkApiKey(
      stripUrl(_bambuddyUrlController.text),
      _bambuddyAPIKeyController.text,
    );
    if (apikeystate == true) {
      return true;
    } else {
      if (!mounted) return false;
      showSnackbar(
        context,
        apikeystate == false
            ? "API Key is invalid!"
            : "Error while checking API Key!",
        apikeystate == true ? appColor.success : appColor.error,
      );
      return false;
    }
  }

  Future<bool> checkurl(AppColor appColor) async {
    ApiService apiService = context.read<ApiService>();
    String url = _bambuddyUrlController.text;
    bool? health = await apiService.checkHealth(stripUrl(url));
    if (health == true) {
      return true;
    } else {
      if (!mounted) return false;
      showSnackbar(
        context,
        "No Bambuddy Server found!",
        health == true ? appColor.success : appColor.error,
      );
      return false;
    }
  }
}
