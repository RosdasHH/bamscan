import 'package:bambuscanner/classes/printer.dart';
import 'package:bambuscanner/modals/amsselection.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:bambuscanner/services/api.dart';
import 'package:bambuscanner/services/globals.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:bambuscanner/tabs/offline.dart';
import 'package:flutter/material.dart';
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
                if (printer.isActive)
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Image.network(
                            "${storage.bambuddyUrl}${Globals.imagesnamespace}${printer.model.replaceAll(" ", "").toLowerCase()}.png",
                            errorBuilder: (context, error, stackTrace) =>
                                SizedBox.square(dimension: 30),
                          ),
                          title: Text(printer.name),
                          subtitle: Text(printer.serialNumber),
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
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
