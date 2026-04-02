import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
import 'package:bambuscanner/services/api.dart';
import 'package:bambuscanner/tabs/offline.dart';
import 'package:bambuscanner/utils/ams_number_letter.dart';
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
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    getFilaments();
  }

  void getFilaments() async {
    if (!mounted) return;
    final availableFilaments = context.read<AvailableFilaments>();
    if (!availableFilaments.filamentsSet) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await availableFilaments.getAllSpools();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final filaments = context.watch<AvailableFilaments>().spools;
    final bool reachable = context.watch<ApiService>().reachable;
    if (!reachable) return Offline();
    if (_isLoading) return Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: Text("Filaments")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          children: [
            SizedBox(height: 30),
            if (filaments.isEmpty)
              Center(child: Text("No filaments available.")),
            for (Spool filament in filaments)
              Card(
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: "filamentdata"),
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
                    subtitle: Row(
                      children: [
                        Text("${filament.colorName}   "),
                        filament.assignment != null
                            ? Text(
                                " ⋅ ${filament.assignment!.printerName} | ${amsIdToLetter(filament.assignment!.amsId)}${filament.assignment!.trayId + 1}",
                                style: TextStyle(color: Colors.purple),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
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
                              ((filament.labelWeight - filament.weightUsed) /
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
