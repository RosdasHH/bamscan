import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
import 'package:bambuscanner/utils/color.dart';
import 'package:bambuscanner/widgets/filament_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilamentTab extends StatefulWidget {
  const FilamentTab({super.key});

  @override
  State<FilamentTab> createState() => _FilamentTabState();
}

class _FilamentTabState extends State<FilamentTab> {
  @override
  void initState() {
    super.initState();
    getFilaments();
  }

  void getFilaments() async {
    if (!mounted) return;
    final availableFilaments = context.read<AvailableFilaments>();
    await availableFilaments.getAllSpools();
  }

  @override
  Widget build(BuildContext context) {
    final filaments = context.watch<AvailableFilaments>().spools;

    return Scaffold(
      appBar: AppBar(title: Text("Filaments")),
      body: filaments.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  SizedBox(height: 30),
                  for (Spool filament in filaments)
                    Card(
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: const RouteSettings(
                                name: "filamentdata",
                              ),
                              builder: (context) => FilamentViewScreen(
                                spool: filament,
                                editable: true,
                                useScaffold: true,
                              ),
                            ),
                          );
                          getFilaments();
                        },
                        child: ListTile(
                          title: Text(filament.slicerFilamentName),
                          minLeadingWidth: 20,
                          leading: SizedBox(
                            width: 20,
                            child: Center(
                              child: SizedBox.square(
                                dimension: 20,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: toFlutterColor(filament.rgba),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          subtitle: Text(filament.colorName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (filament.qrcode != null)
                                Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(Icons.qr_code_2_rounded),
                                )
                              else
                                SizedBox.shrink(),
                              CircularProgressIndicator(
                                value:
                                    ((filament.labelWeight -
                                                filament.weightUsed) /
                                            filament.labelWeight)
                                        .toDouble(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
