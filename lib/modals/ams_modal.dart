import 'package:bambuscanner/classes/ams.dart';
import 'package:bambuscanner/classes/trayslot.dart';
import 'package:bambuscanner/provider/available_printers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AmsModal extends StatefulWidget {
  const AmsModal({super.key, required this.printerid});

  final String printerid;

  @override
  State<AmsModal> createState() => _AmsModalState();
}

class _AmsModalState extends State<AmsModal> {
  late final Future<List<Ams>> _amsFuture;

  @override
  void initState() {
    super.initState();
    final availablePrinters = Provider.of<AvailablePrinters>(
      context,
      listen: false,
    );
    _amsFuture = availablePrinters.getAmsByPrinterId(widget.printerid);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ams selection"),
      content: FutureBuilder<List<Ams>>(
        future: _amsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final List<Ams> amslist = snapshot.data ?? [];

            return Column(
              children: [
                for (Ams ams in amslist)
                  Row(
                    children: [
                      for (TraySlot tray in ams.tray)
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              child: Text(tray.id.toString()),
                            ),
                          ],
                        ),
                    ],
                  ),
              ],
            );
          }
        },
      ),
      actions: [],
    );
  }
}
