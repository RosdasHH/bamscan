import 'package:bamscan/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, required this.child, required this.loading, this.loadingMessage});
  final bool loading;
  final String? loadingMessage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: context.appColor.base1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                if (loadingMessage != null) ...[SizedBox(height: 20), Text(loadingMessage!)],
              ],
            ),
          ),
      ],
    );
  }
}
