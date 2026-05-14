import 'dart:async';

import 'package:bamscan/animation/ble_animation.dart';
import 'package:bamscan/classes/scale.dart';
import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/provider/available_filaments.dart';
import 'package:bamscan/services/ble.dart';
import 'package:bamscan/services/device_capabilities.dart';
import 'package:bamscan/services/scale_service.dart';
import 'package:bamscan/services/storage.dart';
import 'package:bamscan/theme/app_theme.dart';
import 'package:bamscan/widgets/ble_not_enabled.dart';
import 'package:bamscan/widgets/infocard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WeightMeasure extends StatefulWidget {
  const WeightMeasure({super.key, required this.spool});
  final Spool spool;

  @override
  State<WeightMeasure> createState() => _WeightMeasureState();
}

class _WeightMeasureState extends State<WeightMeasure> {
  StreamSubscription? sub;
  Scale? scale;
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    sub = ScaleService().stream.listen((value) {
      setState(() {
        scale = value;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      connectLoop();
    });
  }

  void connectLoop() async {
    while (mounted) {
      if (!mounted) return;
      final ble = context.read<Ble>();
      if (StorageService().bleRemoteId != "" && !ble.isConnecting && ble.connectedDevice == null) {
        if (!mounted) return;
        setState(() {
          isConnecting = true;
        });
        await ble.connect();
      }
      if (ble.connectedDevice != null) {
        setState(() {
          isConnecting = false;
        });
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<Ble>();
    late double filamentWeight = 0.0;
    late double weightDifference = 0.0;
    late double baseCircle = 0.0;
    late double differenceCircle = 0.0;
    if (scale != null) {
      filamentWeight = double.parse((scale!.weight - widget.spool.coreWeight).toString());
      weightDifference = double.parse((filamentWeight - (widget.spool.labelWeight - widget.spool.weightUsed)).toString());
      baseCircle = filamentWeight / (widget.spool.labelWeight - widget.spool.weightUsed);
      differenceCircle = baseCircle - 1;
    }
    return Scaffold(
      appBar: AppBar(title: Text("Scale")),
      body: Consumer<DeviceCapabilities>(
        builder: (context, deviceCapabilities, child) {
          if (!deviceCapabilities.isBluetoothAvailable) {
            return BleNotEnabled();
          }
          if (isConnecting || ble.isConnecting) {
            return ScaleLoading();
          }
          if (StorageService().bleRemoteId == "") {
            return Center(child: Text("Please pair a scale. Settings -> Bluetooth -> Scale"));
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Current Weight", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.square(
                          dimension: MediaQuery.of(context).size.width * 0.5,
                          child: CircularProgressIndicator(
                            value: (scale?.weight ?? 0) / widget.spool.coreWeight,
                            color: context.appColor.base3,
                            backgroundColor: context.appColor.base2,
                            strokeWidth: 10,
                          ),
                        ),
                        SizedBox.square(
                          dimension: MediaQuery.of(context).size.width * 0.5,
                          child: CircularProgressIndicator(
                            value: baseCircle,
                            color: context.appColor.info,
                            backgroundColor: 0 < baseCircle && baseCircle <= 1 ? context.appColor.error : Colors.transparent,
                            strokeWidth: 10,
                          ),
                        ),
                        SizedBox.square(
                          dimension: MediaQuery.of(context).size.width * 0.5,
                          child: CircularProgressIndicator(value: differenceCircle, color: context.appColor.success, backgroundColor: Colors.transparent, strokeWidth: 10),
                        ),
                        Column(
                          children: [
                            Text("${scale?.weight.toStringAsFixed(2) ?? ""}g", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                            Text("${weightDifference.toStringAsFixed(2)}g", style: TextStyle(color: weightDifference >= 0 ? context.appColor.success : context.appColor.error)),
                          ],
                        ),
                      ],
                    ),
                    if (!(scale?.isGram ?? true)) ...[
                      SizedBox(height: 20),
                      Text(
                        "Your scale is not set to gram. Please press the UNIT button on your Scale until this message is gone.",
                        style: TextStyle(color: context.appColor.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if ((filamentWeight <= 0 || filamentWeight > widget.spool.labelWeight) && scale?.weight != 0.0 && scale?.isStable == true) ...[
                      SizedBox(height: 20),
                      Text(
                        "The measured weight has to be between ${widget.spool.coreWeight}g and ${widget.spool.coreWeight + widget.spool.labelWeight}g",
                        style: TextStyle(color: context.appColor.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
                InfoCard(
                  title: "Update Weight",
                  icon: Icons.scale_outlined,
                  disabled: !(scale?.isStable ?? false) || !(scale?.isGram ?? false) || filamentWeight <= 0 || filamentWeight > widget.spool.labelWeight,
                  value: "${filamentWeight.toStringAsFixed(2)}/${widget.spool.labelWeight}",
                  onTap: () async {
                    if (scale?.weight == null) return;
                    AvailableFilaments availableFilaments = context.read<AvailableFilaments>();
                    await availableFilaments.patchSpool(widget.spool.id.toString(), {"weight_used": double.parse((widget.spool.labelWeight - filamentWeight).toStringAsFixed(2))});
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ScaleLoading extends StatefulWidget {
  const ScaleLoading({super.key});

  @override
  State<ScaleLoading> createState() => _ScaleLoadingState();
}

class _ScaleLoadingState extends State<ScaleLoading> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text("Connecting Scale"), BleAnimation(), Text("Please turn on your scale and let it connect.")],
    );
  }
}
