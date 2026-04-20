import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/helper/showsnackbar.dart';
import 'package:bamscan/provider/available_filaments.dart';
import 'package:bamscan/services/api.dart';
import 'package:bamscan/services/storage.dart';
import 'package:bamscan/tabs/offline.dart';
import 'package:bamscan/theme/app_theme.dart';
import 'package:bamscan/utils/ams_number_letter.dart';
import 'package:bamscan/utils/color.dart';
import 'package:bamscan/widgets/filament_view.dart';
import 'package:bamscan/widgets/qrscan.dart';
import 'package:bamscan/widgets/textinput.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class FilamentTab extends StatefulWidget {
  const FilamentTab({super.key});

  @override
  State<FilamentTab> createState() => _FilamentTabState();
}

class _FilamentTabState extends State<FilamentTab> {
  @override
  Widget build(BuildContext context) {
    //final ApiService apiService = context.watch<ApiService>();

    return Scaffold(
      appBar: AppBar(title: Text("Filaments")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: FilamentList(),
      ),
      //floatingActionButton: apiService.reachable
      //    ? FloatingActionButton(
      //        onPressed: () {
      //          Navigator.push(
      //            context,
      //            MaterialPageRoute(
      //              builder: (context) {
      //                return SizedBox.shrink();
      //              },
      //            ),
      //          );
      //        },
      //        child: Icon(Icons.add),
      //      )
      //    : null,
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
    //Read because FilamentTab rebuilds on change
    final ApiService apiService = context.read<ApiService>();
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
                  hinttext: "Search",
                  onchanged: (term) {
                    fuzzySearch(filaments, term);
                  },
                ),
              ),
              if (widget.selection == false)
                IconButton(
                  onPressed: () async {
                    final spool = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return Qrscan(spools: filaments);
                        },
                      ),
                    );
                    if (spool == null && context.mounted) {
                      showSnackbar(
                        context,
                        "No Spool found!",
                        context.appColor.error,
                      );
                      return;
                    }
                    if (!context.mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Scaffold(
                            appBar: AppBar(title: Text("Spool")),
                            body: FilamentView(spool: spool, editable: true),
                          );
                        },
                      ),
                    );
                  },
                  icon: Icon(Icons.qr_code),
                ),
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
    this.delete = false,
    this.deleteCallback,
  });
  final Spool filament;
  final bool? selection;
  final bool delete;
  final VoidCallback? deleteCallback;

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
            "${widget.filament.slicerFilamentName.startsWith(widget.filament.brand) ? "" : "${widget.filament.brand} "}${widget.filament.slicerFilamentName} ${widget.filament.slicerFilamentName.contains(widget.filament.subtype) ? "" : widget.filament.subtype}",
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
              Flexible(
                child: Text(
                  widget.filament.colorName,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              widget.filament.assignment != null && widget.selection != null
                  ? Text(
                      " ⋅ ${widget.filament.assignment!.printerName} | ${amsIdToLetter(widget.filament.assignment!.amsId)}${widget.filament.assignment!.trayId + 1}",
                      style: TextStyle(color: Colors.purple),
                    )
                  : SizedBox.shrink(),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.filament.qrcode != null && widget.selection == false)
                Icon(Icons.qr_code_2_rounded)
              else
                SizedBox.shrink(),
              if (widget.filament.nfcid != null && widget.selection == false)
                Icon(MdiIcons.contactlessPayment)
              else
                SizedBox.shrink(),
              if (widget.delete)
                IconButton(
                  onPressed: () => widget.deleteCallback?.call(),
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: context.appColor.error,
                  ),
                ),
              SizedBox(width: 10),
              if (widget.selection != null)
                CircularProgressIndicator(
                  value:
                      ((widget.filament.labelWeight -
                                  widget.filament.weightUsed) /
                              widget.filament.labelWeight)
                          .toDouble(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
