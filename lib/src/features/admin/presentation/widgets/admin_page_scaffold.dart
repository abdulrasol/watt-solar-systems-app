import 'package:flutter/material.dart';

class AdminPageScaffold extends StatelessWidget {
  const AdminPageScaffold({super.key, required this.child, this.actions = const []});

  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(color: Colors.transparent, child: child);
  }
}
