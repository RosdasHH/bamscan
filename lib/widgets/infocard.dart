import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
import 'package:bambuscanner/theme/app_theme.dart';
import 'package:bambuscanner/widgets/button.dart';
import 'package:bambuscanner/widgets/textinput.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoCard extends StatefulWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.progress,
    this.spoolColor,
    this.more,
    this.onTap,
    this.apiname,
    this.spool,
  });
  final IconData icon;
  final String title;
  final String? value;
  final double? progress;
  final Color? spoolColor;
  final Widget? more;
  final Function? onTap;
  final String? apiname;
  final Spool? spool;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  void initState() {
    super.initState();
    textEditingController.text = widget.value ?? "";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value == null) return SizedBox.shrink(); //Nothing
    return Row(
      children: [
        Expanded(
          child: Card(
            child: InkWell(
              onTap:
                  widget.more != null ||
                      widget.onTap != null ||
                      widget.apiname != null
                  ? () {
                      if (widget.onTap != null) {
                        widget.onTap!();
                      }
                      if (widget.more != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => widget.more!),
                        );
                      }
                      if (widget.apiname != null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextInput(
                                      controller: textEditingController,
                                    ),
                                    Row(
                                      spacing: 10,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Button(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          backgroundColor: Colors.transparent,
                                          child: Text("Cancel"),
                                        ),
                                        Button(
                                          onPressed: () async {
                                            if (widget.apiname != null &&
                                                widget.spool != null) {
                                              AvailableFilaments
                                              availableFilaments = context
                                                  .read<AvailableFilaments>();
                                              await availableFilaments
                                                  .patchSpool(
                                                    widget.spool!.id.toString(),
                                                    {
                                                      widget.apiname!:
                                                          textEditingController
                                                              .text,
                                                    },
                                                  );
                                            }
                                            if (!context.mounted) {
                                              return;
                                            }
                                            Navigator.pop(context);
                                          },
                                          child: Text("Save"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(16),
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
                                    color: context.appColor.primary,
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
                            Row(
                              children: [
                                Text(widget.value!),
                                if (widget.more != null)
                                  Icon(Icons.chevron_right_rounded),
                              ],
                            ),
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
