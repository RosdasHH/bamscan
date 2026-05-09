import 'dart:async';

import 'package:bamscan/animation/ble_animation.dart';
import 'package:bamscan/classes/scale.dart';
import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/provider/available_filaments.dart';
import 'package:bamscan/services/ble.dart';
import 'package:bamscan/services/scale_service.dart';
import 'package:bamscan/theme/app_theme.dart';
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
  @override
  void initState() {
    super.initState();
    if (Ble().connectedDevice == null) Ble().connect();
    sub = ScaleService().stream.listen((value) {
      setState(() {
        scale = value;
      });
    });
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
    if (!ble.isConnecting && ble.connectedDevice == null) {
      ble.connect();
    }
    if (scale != null) {
      filamentWeight = double.parse((scale!.weight - widget.spool.coreWeight).toStringAsFixed(1));
      weightDifference = double.parse((filamentWeight - (widget.spool.labelWeight - widget.spool.weightUsed)).toStringAsFixed(1));
    }
    return Scaffold(
      appBar: AppBar(title: Text("Scale")),
      body: ble.isConnecting
          ? ScaleLoading()
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Current Weight", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Column(
                    children: [
                      Text("${scale?.weight.toString() ?? ""}g", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      Text("Filament: ${filamentWeight.toString()}g"),
                      Text("${weightDifference.toString()}g", style: TextStyle(color: weightDifference >= 0 ? context.appColor.success : context.appColor.error)),
                    ],
                  ),
                  InfoCard(
                    title: "Update Weight",
                    icon: Icons.scale_outlined,
                    disabled: !(scale?.isStable ?? false),
                    onTap: () async {
                      if (scale?.weight == null) return;
                      AvailableFilaments availableFilaments = context.read<AvailableFilaments>();
                      await availableFilaments.patchSpool(widget.spool.id.toString(), {
                        "weight_used": (widget.spool.labelWeight - filamentWeight).toString(),
                        "last_weighed_at": DateTime.now().toString(),
                      });
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class ScaleLoading extends StatelessWidget {
  const ScaleLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text("Connecting Scale"), BleAnimation(), Text("Please turn on your scale and let it connect.")],
    );
  }
}
