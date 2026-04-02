import 'package:bambuscanner/services/api.dart';
import 'package:bambuscanner/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Offline extends StatelessWidget {
  const Offline({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = context.read<ApiService>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No connection to Server."),
          Button(
            onPressed: () {
              apiService.checkHealth();
            },
            child: Text("Reload"),
          ),
        ],
      ),
    );
  }
}
