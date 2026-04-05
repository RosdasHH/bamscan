import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
import 'package:bambuscanner/services/api.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:bambuscanner/tabs/offline.dart';
import 'package:bambuscanner/utils/ams_number_letter.dart';
import 'package:bambuscanner/utils/color.dart';
import 'package:bambuscanner/widgets/filament_view.dart';
import 'package:bambuscanner/widgets/textinput.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
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
  List<Spool>? sortedSpools;
  final TextEditingController _searchController = TextEditingController();
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
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filaments = context.watch<AvailableFilaments>().spools;
    final storage = context.read<StorageService>();
    final ApiService apiService = context.watch<ApiService>();
    final List<Spool> iterationList;

    String? configerror;
    if (!apiService.reachable) return Offline();
    final fuse = Fuzzy(
      filaments,
      options: FuzzyOptions(
        threshold: 0.5,
        keys: [
          WeightedKey(name: "brand", getter: (Spool u) => u.brand, weight: 1),
          WeightedKey(
            name: "slicerFilamentName",
            getter: (Spool u) => u.slicerFilamentName,
            weight: 1,
          ),
          WeightedKey(
            name: "colorName",
            getter: (Spool u) => u.colorName,
            weight: 1,
          ),
        ],
      ),
    );
    void fuzzySearch(List<Spool> filaments, String term) {
      final res = fuse.search(term);
      setState(() {
        if (term == "") {
          sortedSpools = null;
        } else {
          sortedSpools = res.map((r) => r.item).toList();
        }
      });
    }

    if (storage.bambuddyUrl == "") {
      configerror = "Please enter the Bambuddy Url in the Settings tab.";
    } else if (storage.xapitoken == "") {
      configerror = "Please enter your Bambuddy API Token in the Settings tab.";
    }
    if (configerror != null) return Center(child: Text(configerror));
    if (apiService.error != null) {
      return Center(child: Text(apiService.error.toString()));
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (sortedSpools != null) {
      iterationList = sortedSpools!;
    } else {
      iterationList = filaments;
    }

    return ListView(
      children: [
        if (filaments.isEmpty)
          Center(child: Text("No filaments available."))
        else ...[
          Row(
            children: [
              Flexible(
                child: TextInput(
                  controller: _searchController,
                  labeltext: "Test",
                  onchanged: (term) {
                    fuzzySearch(filaments, term);
                  },
                ),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.qr_code)),
            ],
          ),
          SizedBox(height: 10),
          if (sortedSpools != null)
            Text("Search results:", style: TextStyle(fontSize: 20)),
          for (Spool filament in iterationList)
            if (widget.selection && filament.assignment == null ||
                !widget.selection)
              FilamentCard(filament: filament, selection: widget.selection),
        ],
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
