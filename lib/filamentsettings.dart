import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/theme/app_color.dart';
import 'package:bambuscanner/utils/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FilamentSettings extends StatefulWidget {
  const FilamentSettings({super.key, required this.spool});
  final Spool spool;

  @override
  State<FilamentSettings> createState() => FilamentSettingsState();
}

class FilamentSettingsState extends State<FilamentSettings> {
  @override
  Widget build(BuildContext context) {
    final Color filamentColor = toFlutterColor(widget.spool.rgba);
    final Color filamentConformTextColor = getContrastColor(filamentColor);
    final appColor = Theme.of(context).extension<AppColor>()!;

    return Scaffold(
      appBar: AppBar(title: Text("Edit Spool")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: toFlutterColor(widget.spool.rgba),
                        ),
                        child: Center(
                          child: Text(
                            widget.spool.material,
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: filamentConformTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              InfoCard(
                icon: Icons.abc,
                title: "Color Name:",
                value: widget.spool.colorName,
              ),
              InfoCard(
                icon: Icons.precision_manufacturing,
                title: "Brand:",
                value: widget.spool.brand,
              ),
              InfoCard(
                icon: MdiIcons.weight,
                title: "Weight:",
                value:
                    "${widget.spool.labelWeight - widget.spool.weightUsed}/${widget.spool.labelWeight}",
                spoolColor: appColor.primary,
                progress:
                    (widget.spool.labelWeight - widget.spool.weightUsed) /
                    widget.spool.labelWeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatefulWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.progress,
    this.spoolColor,
  });
  final IconData icon;
  final String title;
  final String value;
  final double? progress;
  final Color? spoolColor;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).extension<AppColor>()!;
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Card(
              child: SizedBox(
                height: 70,
                child: Stack(
                  children: [
                    if (widget.progress != null && widget.spoolColor != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: widget.progress!.clamp(0.0, 1.0),
                            child: SizedBox.expand(
                              child: Container(
                                color: widget.spoolColor!.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(20),
                      child: SizedBox(
                        height: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(
                                    widget.icon,
                                    color: appColor.primary,
                                  ),
                                ),
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Text(widget.value),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
