import 'package:flutter/material.dart';

class CompanyPageScaffold extends StatelessWidget {
  const CompanyPageScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(color: Colors.transparent, child: child);
  }
}
