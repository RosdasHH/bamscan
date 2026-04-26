import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/helper/showsnackbar.dart';
import 'package:bamscan/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Qrscan extends StatefulWidget {
  const Qrscan({super.key, this.spools});
  final List<Spool>? spools;

  @override
  State<Qrscan> createState() => _QrscanState();
}

class _QrscanState extends State<Qrscan> {
  @override
  Widget build(BuildContext context) {
    bool found = false;
    return MobileScanner(
      overlayBuilder: (context, constraints) {
        return Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.6), BlendMode.srcOut),
              child: Stack(
                children: [
                  Center(
                    child: SizedBox.square(
                      dimension: 300,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: context.appColor.base1, width: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(child: CornerBorder(size: 300)),
          ],
        );
      },
      onDetect: (scannedCode) {
        if (scannedCode.barcodes.first.rawValue == null || found == true) {
          return;
        }
        String? qr = scannedCode.barcodes.first.rawValue;
        if (widget.spools == null) {
          found = true;
          Navigator.pop(context, qr);
        } else {
          found = true;
          final List<Spool> spools = widget.spools!.where((x) => x.qrcode == qr).toList();
          if (spools.length > 1) {
            Navigator.pop(context);
            showSnackbar(context, "Multiple Assignments: ${spools.where((x) => x.qrcode == qr).map((x) => x.id)}", context.appColor.error);
          }
          if (spools.length == 1) {
            Navigator.pop(context, spools.first);
          } else {
            showSnackbar(context, "No Spool found!", context.appColor.error);
            Navigator.pop(context, null);
          }
        }
      },
    );
  }
}

class CornerBorder extends StatelessWidget {
  final double size;

  const CornerBorder({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _CornerPainter(Colors.white));
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;

  _CornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 40.0;
    final r = 30.0;

    final path = Path();

    path.moveTo(0, r + cornerLength);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.lineTo(r + cornerLength, 0);

    path.moveTo(size.width - r - cornerLength, 0);
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);
    path.lineTo(size.width, r + cornerLength);

    path.moveTo(size.width, size.height - r - cornerLength);
    path.lineTo(size.width, size.height - r);
    path.quadraticBezierTo(size.width, size.height, size.width - r, size.height);
    path.lineTo(size.width - r - cornerLength, size.height);

    path.moveTo(r + cornerLength, size.height);
    path.lineTo(r, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - r);
    path.lineTo(0, size.height - r - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
