import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/onboarding.dart';
import 'package:bambuscanner/printers.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:bambuscanner/settings.dart';
import 'package:bambuscanner/theme/app_color.dart';
import 'package:bambuscanner/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

void main() {
  //debugPaintSizeEnabled = true;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AvailablePrinters()),
        ChangeNotifierProvider(create: (_) => StorageService()),
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

  final List<String> titles = ["Printers", "Settings"];

  List<Widget> _buildScreens() {
    final appColor = Theme.of(context).extension<AppColor>()!;
    return [
      Scaffold(backgroundColor: appColor.base1, body: const Printers()),
      Scaffold(backgroundColor: appColor.base1, body: const Settings()),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        title: ("Home"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: "/",
          routes: {
            "/first": (final context) => const Printers(),
            "/second": (final context) => const Settings(),
          },
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.settings),
        title: ("Settings"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: "/",
          routes: {
            "/first": (final context) => const Printers(),
            "/second": (final context) => const Settings(),
          },
        ),
      ),
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
    final appColor = Theme.of(context).extension<AppColor>()!;
    final storage = context.watch<StorageService>();
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
          items: _navBarsItems(),
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          hideNavigationBarWhenKeyboardAppears: true,
          popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
          padding: const EdgeInsets.only(top: 8),
          backgroundColor: appColor.base2,
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
