import 'package:bambuscanner/classes/printer.dart';
import 'package:bambuscanner/modals/amsselection.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:bambuscanner/services/api.dart';
import 'package:bambuscanner/services/globals.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:bambuscanner/tabs/offline.dart';
import 'package:bambuscanner/theme/app_theme.dart';
import 'package:bambuscanner/widgets/badgeCard.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class Printers extends StatefulWidget {
  const Printers({super.key});

  @override
  State<Printers> createState() => _PrintersState();
}

class _PrintersState extends State<Printers> {
  final storageservice = StorageService();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    storageservice.loadFromStorage();
    if (!mounted) return;
    fetch();
  }

  void fetch() async {
    final AvailablePrinters availablePrinters = context
        .read<AvailablePrinters>();
    if (!availablePrinters.printersSet) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await availablePrinters.fetchPrinters();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final printers = context.watch<AvailablePrinters>().printers;
    final storage = context.read<StorageService>();
    final bool reachable = context.watch<ApiService>().reachable;
    String? configerror;
    if (!reachable) return Offline();

    if (storage.bambuddyUrl == "") {
      configerror = "Please enter the Bambuddy Url in the Settings tab.";
    } else if (storage.xapitoken == "") {
      configerror = "Please enter your Bambuddy API Token in the Settings tab.";
    }
    if (configerror != null) return Text(configerror);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text("Printers")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(10),
          child: Column(
            children: [
              if (printers.isEmpty)
                Center(child: Text("No printers available.")),
              for (Printer printer in printers)
                Builder(
                  builder: (BuildContext context) {
                    final status = printer.status;
                    if (status == null) return SizedBox.shrink();
                    final String connected = status.connected
                        ? "Connected"
                        : "Not connected";
                    final Color connectedColor = status.connected
                        ? context.appColor.success
                        : context.appColor.error;
                    final String nozzleTemp =
                        "${status.temperatures.nozzle.round()}/${status.temperatures.nozzleTarget.round()}"
                            .toString();
                    final String bedTemp =
                        "${status.temperatures.bed.round().toString()}/${status.temperatures.bedTarget.round().toString()}";
                    final double progress = status.progress / 100;
                    final int amsCount = status.ams.length;
                    final String nozzleDia1 = status.nozzles[0].nozzleDiameter
                        .toString();
                    final String nozzleDia2 =
                        status.nozzles[1].nozzleDiameter.toString() != "0.0"
                        ? status.nozzles[1].nozzleDiameter.toString()
                        : "";
                    final String firmware = status.firmwareVersion;
                    final String layer =
                        "${status.layerNum}/${status.totalLayers}";
                    final String timeRemaining =
                        "${status.remainingTime.toString()}min";
                    final bool nozzleHeating =
                        status.temperatures.nozzleHeating;
                    final String state = status.state;
                    return Card(
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: const RouteSettings(name: "ams"),
                              builder: (context) => AmsSelection(
                                printerid: printer.id.toString(),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      spacing: 5,
                                      children: [
                                        Text(
                                          printer.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        BadgeCard(
                                          text: connected,
                                          color: connectedColor,
                                        ),
                                        BadgeCard(
                                          text: state,
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ),
                                    Stack(
                                      alignment: AlignmentGeometry.center,
                                      children: [
                                        SizedBox.square(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 5,
                                            value: progress,
                                          ),
                                        ),
                                        Text(
                                          "${(progress * 100).toInt()}%",
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(5),
                                      child: SizedBox.square(
                                        dimension: 100,
                                        child: Image.network(
                                          "${storage.bambuddyUrl}${Globals.imagesnamespace}${printer.model.replaceAll(" ", "").toLowerCase()}.png",
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  SizedBox.expand(),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 5,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  IconWithCicle(
                                                    icon: Icons.thermostat,
                                                    color: nozzleHeating
                                                        ? Colors.orange
                                                        : Colors.blue,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text("Nozzle"),
                                                ],
                                              ),
                                              Text("$nozzleTemp°C"),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  IconWithCicle(
                                                    icon: Icons.thermostat,
                                                    color: Colors.blue,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text("Bed"),
                                                ],
                                              ),
                                              Text("$bedTemp °C"),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  IconWithCicle(
                                                    icon: Icons.layers,
                                                    color: Colors.purple,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text("Layer"),
                                                ],
                                              ),
                                              Text(layer),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  IconWithCicle(
                                                    icon: Icons.timelapse,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text("Remaining"),
                                                ],
                                              ),
                                              Text(timeRemaining),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    //Stack(
                                    //  alignment: AlignmentGeometry.center,
                                    //  children: [
                                    //    SizedBox.square(
                                    //      dimension: 100,
                                    //      child: Padding(
                                    //        padding: EdgeInsets.all(20),
                                    //        child: CircularProgressIndicator(
                                    //          strokeWidth: 10,
                                    //          value: progress,
                                    //        ),
                                    //      ),
                                    //    ),
                                    //    Text("${(progress * 100).toInt()}%"),
                                    //  ],
                                    //),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  alignment: WrapAlignment.start,
                                  runAlignment: WrapAlignment.start,
                                  children: [
                                    CardWithoutMat(
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconWithCicle(
                                              color: Colors.blue,
                                              icon: MdiIcons.cube,
                                            ),
                                            Column(
                                              children: [
                                                Text("AMS"),
                                                Text(amsCount.toString()),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    CardWithoutMat(
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconWithCicle(
                                              color: Colors.purple,
                                              icon: MdiIcons.printer3DNozzle,
                                            ),
                                            Column(
                                              children: [
                                                Text("Nozzle"),
                                                Text(nozzleDia1.toString()),
                                                if (nozzleDia2 != "")
                                                  Text(nozzleDia2.toString()),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    CardWithoutMat(
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconWithCicle(
                                              color: Colors.orange,
                                              icon: Icons.memory,
                                            ),
                                            Column(
                                              children: [
                                                Text("Firmware"),
                                                Text(firmware),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class IconWithCicle extends StatelessWidget {
  const IconWithCicle({super.key, required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Icon(icon, color: color.withValues(alpha: 0.7)),
      ),
    );
  }
}

class CardWithoutMat extends StatelessWidget {
  final Widget child;

  const CardWithoutMat({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColor.base3,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
