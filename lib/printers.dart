import 'package:bambuscanner/classes/printer.dart';
import 'package:bambuscanner/globals.dart';
import 'package:bambuscanner/modals/ams_modal.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Printers extends StatelessWidget {
  const Printers({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<AvailablePrinters>(context, listen: false);
    repo.fetchPrinters();
    print("Fetching");

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
          child: Column(
            children: [
              for (Printer printer in printers)
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Image.network(
                          "${Globals.bambuddyurl}${Globals.imagesnamespace}${printer.model.replaceAll(" ", "").toLowerCase()}.png",
                        ),
                        title: Text(printer.name),
                        subtitle: Text(printer.serialNumber),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: const RouteSettings(name: "ams"),
                              builder: (context) =>
                                  AmsModal(printerid: printer.id.toString()),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
