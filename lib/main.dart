import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/onboarding.dart';
import 'package:bamscan/provider/available_filaments.dart';
import 'package:bamscan/provider/available_printers.dart';
import 'package:bamscan/services/api.dart';
import 'package:bamscan/services/device_capabilities.dart';
import 'package:bamscan/services/storage.dart';
import 'package:bamscan/tabs/filaments.dart';
import 'package:bamscan/tabs/printers.dart';
import 'package:bamscan/tabs/settings.dart';
import 'package:bamscan/theme/app_theme.dart';
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
        ChangeNotifierProvider(create: (_) => AvailableFilaments()),
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => DeviceCapabilities()),
      ],
      child: Consumer<StorageService>(
        builder: (context, storage, _) {
          return MaterialApp(
            //showPerformanceOverlay: true,
            title: "BamScan",
            themeMode: storage.darkMode == "System"
                ? ThemeMode.system
                : storage.darkMode == "Dark"
                ? ThemeMode.dark
                : ThemeMode.light,
            theme: AppTheme().light,
            darkTheme: AppTheme().dark,
            home: const MyApp(),
          );
        },
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

  final PersistentTabController _controller = PersistentTabController(initialIndex: 1);

  List<Widget> _buildScreens() {
    return [
      Scaffold(backgroundColor: context.appColor.base1, body: const FilamentTab()),
      Scaffold(backgroundColor: context.appColor.base1, body: const Printers()),
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
    DeviceCapabilities().checkDevicesCapabilities();
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
          icon: Icon(Icons.inventory_2_outlined),
          title: ("Filaments"),
          activeColorPrimary: context.appColor.primary,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.printer),
          title: ("Home"),
          activeColorPrimary: context.appColor.primary,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.settings_outlined),
          title: ("Settings"),
          activeColorPrimary: context.appColor.primary,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
      ];
    }

    if (storageLoaded == false) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (storage.firstUse == true) {
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
          backgroundColor: context.appColor.base3,
          isVisible: true,
          animationSettings: const NavBarAnimationSettings(
            navBarItemAnimation: ItemAnimationSettings(duration: Duration(milliseconds: 200), curve: Curves.easeInOut),
            screenTransitionAnimation: ScreenTransitionAnimationSettings(
              animateTabTransition: true,
              duration: Duration(milliseconds: 150),
              screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
              curve: Curves.easeInOut,
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
