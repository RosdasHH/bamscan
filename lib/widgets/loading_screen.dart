import 'package:bambuscanner/theme/app_theme.dart';
import 'package:bambuscanner/utils/color.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    required this.child,
    required this.loading,
    this.loadingMessage,
  });
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
            color: getContrastColor(
              context.appColor.base1,
            ).withValues(alpha: 0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                if (loadingMessage != null) Text(loadingMessage!),
              ],
            ),
          ),
      ],
    );
  }
}
