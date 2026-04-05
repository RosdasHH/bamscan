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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Filaments")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: FilamentList(),
      ),
    );
  }
}

class FilamentList extends StatefulWidget {
  const FilamentList({super.key, this.selection = false});
  final bool selection;

  @override
  State<FilamentList> createState() => FilamentListState();
}

class FilamentListState extends State<FilamentList> {
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

    return ListView(
      children: [
        SizedBox(height: 30),
        if (filaments.isEmpty) Center(child: Text("No filaments available.")),
        for (Spool filament in filaments)
          if (widget.selection && filament.assignment == null ||
              !widget.selection)
            FilamentCard(filament: filament, selection: widget.selection),
        SizedBox(height: 30),
      ],
    );
  }
}

class FilamentCard extends StatefulWidget {
  const FilamentCard({
    super.key,
    required this.filament,
    required this.selection,
  });
  final Spool filament;
  final bool? selection;

  @override
  State<FilamentCard> createState() => FilamentCardState();
}

class FilamentCardState extends State<FilamentCard> {
  void getFilaments() async {
    if (!mounted) return;
    final availableFilaments = context.read<AvailableFilaments>();
    if (!availableFilaments.filamentsSet) {}
    try {
      await availableFilaments.getAllSpools();
      if (!mounted) return;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: widget.selection != null
            ? () async {
                if (widget.selection!) {
                  Navigator.pop(context, widget.filament.id.toString());
                } else {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: "filamentdata"),
                      builder: (context) => FilamentViewScreen(
                        spool: widget.filament,
                        editable: true,
                        useScaffold: true,
                      ),
                    ),
                  );
                  getFilaments();
                }
              }
            : null,
        child: ListTile(
          title: Text(
            "${widget.filament.slicerFilamentName.startsWith(widget.filament.brand) ? "" : "${widget.filament.brand} "}${widget.filament.slicerFilamentName}",
          ),
          minLeadingWidth: 20,
          leading: SizedBox(
            width: 20,
            child: Center(
              child: SizedBox.square(
                dimension: 20,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: toFlutterColor(widget.filament.rgba),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          subtitle: Row(
            children: [
              Text(widget.filament.colorName),
              widget.filament.assignment != null && widget.selection != null
                  ? Text(
                      " ⋅ ${widget.filament.assignment!.printerName} | ${amsIdToLetter(widget.filament.assignment!.amsId)}${widget.filament.assignment!.trayId + 1}",
                      style: TextStyle(color: Colors.purple),
                    )
                  : SizedBox.shrink(),
            ],
          ),
          trailing: Stack(
            alignment: AlignmentGeometry.center,
            children: [
              if (widget.selection != null)
                CircularProgressIndicator(
                  value:
                      ((widget.filament.labelWeight -
                                  widget.filament.weightUsed) /
                              widget.filament.labelWeight)
                          .toDouble(),
                ),
              if (widget.filament.qrcode != null && widget.selection == false)
                Icon(Icons.qr_code_2_rounded)
              else
                SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
