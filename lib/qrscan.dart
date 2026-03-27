import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScan extends StatefulWidget {
  const QrScan({super.key, required this.enabled});
  final bool enabled;

  @override
  State<QrScan> createState() => _QrScanState();
}

class _QrScanState extends State<QrScan> with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    autoStart: false,
  );
  StreamSubscription<BarcodeCapture>? _subscription;

  @override
  void didUpdateWidget(covariant QrScan oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled && !oldWidget.enabled) {
      controller.start();
    } else if (!widget.enabled && oldWidget.enabled) {
      controller.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen(_handleBarcode);
    controller.start();
  }

  void _handleBarcode(BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    print(barcode.rawValue);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.hasCameraPermission) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _subscription = controller.barcodes.listen(_handleBarcode);
        controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _subscription?.cancel();
        _subscription = null;
        controller.stop();
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: controller,
      onDetect: (capture) {
        print(capture.barcodes.first.rawValue);
      },
    );
  }
}
