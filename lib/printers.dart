import 'package:bambuscanner/classes/printer.dart';
import 'package:bambuscanner/services/globals.dart';
import 'package:bambuscanner/modals/ams_modal.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Printers extends StatefulWidget {
  const Printers({super.key});

  @override
  State<Printers> createState() => _PrintersState();
}

class _PrintersState extends State<Printers> {
  final storageservice = StorageService();
  @override
  void initState() {
    storageservice.loadFromStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    if (storage.bambuddyUrl == "") {
      return Text("Please enter the Bambuddy Url in the Settings tab.");
    } else if (storage.xapitoken == "") {
      return Text("Please enter your Bambuddy API Token in the Settings tab.");
    } else {
      final repo = Provider.of<AvailablePrinters>(context, listen: false);
      repo.fetchPrinters();
      return FutureBuilder<void>(
        future: repo.fetchPrinters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Fehler: ${snapshot.error}');
          }

          final printers = context.watch<AvailablePrinters>().printers;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: Column(
                children: [
                  for (Printer printer in printers)
                    if (printer.isActive)
                      Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Image.network(
                                "${storage.bambuddyUrl}${Globals.imagesnamespace}${printer.model.replaceAll(" ", "").toLowerCase()}.png",
                              ),
                              title: Text(printer.name),
                              subtitle: Text(printer.serialNumber),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    settings: const RouteSettings(name: "ams"),
                                    builder: (context) => AmsModal(
                                      printerid: printer.id.toString(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
