import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/filamentsettings.dart';
import 'package:bambuscanner/services/api.dart';
import 'package:bambuscanner/utils/color.dart';
import 'package:flutter/material.dart';

class FilamentTab extends StatefulWidget {
  const FilamentTab({super.key});

  @override
  State<FilamentTab> createState() => _FilamentTabState();
}

class _FilamentTabState extends State<FilamentTab> {
  List<Spool>? filaments;

  @override
  void initState() {
    super.initState();
    getFilaments();
  }

  void getFilaments() async {
    filaments = await getAllSpools();
    setState(() {
      filaments = filaments;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (filaments == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(title: Text("Filaments")),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              for (Spool filament in filaments!)
                Card(
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: "filamentdata"),
                          builder: (context) =>
                              FilamentSettings(spool: filament),
                        ),
                      );
                      setState(() {
                        filaments = null;
                      });
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
                                ((filament.labelWeight - filament.weightUsed) /
                                        filament.labelWeight)
                                    .toDouble(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }
}
