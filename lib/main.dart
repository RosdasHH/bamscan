import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/onboarding.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:bambuscanner/tabs/filaments.dart';
import 'package:bambuscanner/tabs/printers.dart';
import 'package:bambuscanner/tabs/settings.dart';
import 'package:bambuscanner/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

void main() {
  //debugPaintSizeEnabled = true;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AvailablePrinters()),
        ChangeNotifierProvider(create: (_) => StorageService()),
        ChangeNotifierProvider(create: (_) => AvailableFilaments()),
      ],
      child: MaterialApp(
        title: "BamScan",
        themeMode: ThemeMode.system,
        theme: AppTheme().light,
        darkTheme: AppTheme().dark,
        home: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool scannerEnabled = false;
  String? scannedCode;
  Spool? scannedSpool;
  int currentPageIndex = 0;

  bool storageLoaded = false;

  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );

  List<Widget> _buildScreens() {
    return [
      Scaffold(backgroundColor: context.appColor.base1, body: const Printers()),
      Scaffold(
        backgroundColor: context.appColor.base1,
        body: const FilamentTab(),
      ),
      Scaffold(backgroundColor: context.appColor.base1, body: const Settings()),
    ];
  }

  @override
  void initState() {
    super.initState();
    getStorage();
  }

  void getStorage() async {
    final StorageService storageService = StorageService();
    await storageService.loadFromStorage();
    setState(() {
      storageLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    List<PersistentBottomNavBarItem> navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.home),
          title: ("Home"),
          activeColorPrimary: context.appColor.primary,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(MdiIcons.disc),
          title: ("Filaments"),
          activeColorPrimary: context.appColor.primary,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.settings),
          title: ("Settings"),
          activeColorPrimary: context.appColor.primary,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
      ];
    }

    if (storageLoaded == false) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (storage.bambuddyUrl == "" || storage.xapitoken == "") {
      return Onboarding();
    } else {
      return Scaffold(
        body: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: navBarsItems(),
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: false,
          hideNavigationBarWhenKeyboardAppears: true,
          popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
          padding: const EdgeInsets.only(top: 8),
          backgroundColor: context.appColor.base2,
          isVisible: true,
          animationSettings: const NavBarAnimationSettings(
            navBarItemAnimation: ItemAnimationSettings(
              duration: Duration(milliseconds: 400),
              curve: Curves.ease,
            ),
            screenTransitionAnimation: ScreenTransitionAnimationSettings(
              animateTabTransition: true,
              duration: Duration(milliseconds: 200),
              screenTransitionAnimationType:
                  ScreenTransitionAnimationType.fadeIn,
            ),
          ),
          confineToSafeArea: true,
          navBarHeight: kBottomNavigationBarHeight,
          navBarStyle: NavBarStyle.style19,
        ),
      );
    }
  }
}
