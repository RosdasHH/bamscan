import 'package:bambuscanner/theme/app_theme.dart';
import 'package:flutter/material.dart';

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
  });
  final IconData icon;
  final String title;
  final String? value;
  final double? progress;
  final Color? spoolColor;
  final Widget? more;
  final Function? onTap;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.value == null) return SizedBox.shrink(); //Nothing
    return Row(
      children: [
        Expanded(
          child: Card(
            child: InkWell(
              onTap: widget.more != null || widget.onTap != null
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
