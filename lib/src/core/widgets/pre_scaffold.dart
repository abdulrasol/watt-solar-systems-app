import 'package:flutter/material.dart';

class PreScaffold extends StatelessWidget {
  const PreScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.clickBack,
    this.extendBody = true,
  });
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool extendBody;
  final void Function()? clickBack;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: clickBack != null ? (didPop, result) => clickBack!() : null,
      child: Scaffold(
        extendBody: extendBody,
        appBar: AppBar(title: title != null ? Text(title!) : null, actions: actions),
        body: SafeArea(child: child),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        drawer: drawer,
      ),
    );
  }
}
