import 'dart:io';
import 'dart:typed_data';

import 'package:bamscan/helper/showsnackbar.dart';
import 'package:bamscan/provider/available_printers.dart';
import 'package:bamscan/services/storage.dart';
import 'package:bamscan/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MjpegView extends StatefulWidget {
  final String url;
  const MjpegView({super.key, required this.url});

  @override
  State<MjpegView> createState() => _MjpegViewState();
}

class _MjpegViewState extends State<MjpegView> {
  Uint8List? frame;
  HttpClient? client;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() async {
    client = HttpClient();
    AvailablePrinters availablePrinters = context.read<AvailablePrinters>();
    await availablePrinters.updateStreamToken();
    print(Uri.parse("${widget.url}?token=${StorageService().getSecureString(StorageService.kCamToken)}"));
    final request = await client!.getUrl(Uri.parse("${widget.url}?token=${await StorageService().getSecureString(StorageService.kCamToken)}"));
    final response = await request.close();

    if (response.statusCode == 401) {
      //Auth failed
      if (!mounted) return;
      AvailablePrinters availablePrinters = context.read<AvailablePrinters>();
      await availablePrinters.updateStreamToken();
      _start();
      return;
    }

    List<int> buffer = [];

    response.listen(
      (data) {
        buffer.addAll(data);

        int start = _indexOf(buffer, [0xFF, 0xD8]);
        int end = _indexOf(buffer, [0xFF, 0xD9]);

        if (start != -1 && end != -1 && end > start) {
          final jpg = buffer.sublist(start, end + 2);

          if (mounted) {
            setState(() {
              frame = Uint8List.fromList(jpg);
            });
          }

          buffer = buffer.sublist(end + 2);
        }
      },
      onError: (e) {
        showSnackbar(context, e, context.appColor.error);
      },
    );
  }

  int _indexOf(List<int> data, List<int> pattern) {
    for (int i = 0; i < data.length - pattern.length; i++) {
      bool found = true;
      for (int j = 0; j < pattern.length; j++) {
        if (data[i + j] != pattern[j]) {
          found = false;
          break;
        }
      }
      if (found) return i;
    }
    return -1;
  }

  @override
  void dispose() {
    client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return frame == null ? const Center(child: CircularProgressIndicator()) : Image.memory(frame!, gaplessPlayback: true);
  }
}
