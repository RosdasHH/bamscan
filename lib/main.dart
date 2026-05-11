import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/onboarding.dart';
import 'package:bamscan/provider/available_filaments.dart';
import 'package:bamscan/provider/available_printers.dart';
import 'package:bamscan/services/api.dart';
import 'package:bamscan/services/app_state.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: storage),
        ChangeNotifierProvider(create: (_) => AvailablePrinters()),
        ChangeNotifierProvider(create: (_) => AvailableFilaments()),
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => DeviceCapabilities()),
        ChangeNotifierProvider(create: (_) => AppStateService()),
      ],
      child: Consumer<StorageService>(
        builder: (context, storageService, child) {
          String themeRaw = storage.getString(StorageService.kDarkMode);
          ThemeMode theme = themeRaw == "System"
              ? ThemeMode.system
              : themeRaw == "Dark"
              ? ThemeMode.dark
              : ThemeMode.light;
          return MaterialApp(debugShowCheckedModeBanner: false, themeMode: theme, theme: AppTheme().light, darkTheme: AppTheme().dark, home: const MyApp());
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

  bool storageLoaded = false;

  final PersistentTabController _controller = PersistentTabController(initialIndex: 1);

  @override
  void initState() {
    super.initState();
    getStorage();
  }

  void getStorage() async {
    context.read<DeviceCapabilities>().checkDevicesCapabilities();
    final appState = context.read<AppStateService>();
    setState(() {
      storageLoaded = true;
    });
    if (appState.firstLaunchAfterUpdate && appState.version == "1.1.5+17") {
      if (!mounted) return;
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Changes"),
            content: const Text(
              "This version changes the way NFC tags are stored and read. Please go to: Settings → Reset → Reset NFC Tags, and reset all mappings. After that, please reassign all your NFC tags to your spools. This step is required to use the NFC feature.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("I understand"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buildScreens() {
      return [Scaffold(body: const FilamentTab()), Scaffold(body: const Printers()), Scaffold(body: const Settings())];
    }

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
    if (storage.getBool(StorageService.kFirstUse) == true) {
      return Onboarding();
    } else {
      return Scaffold(
        body: PersistentTabView(
          context,
          controller: _controller,
          screens: buildScreens(),
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
