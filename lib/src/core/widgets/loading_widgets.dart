import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidgets extends StatelessWidget {
  const LoadingWidgets({this.dimssable = false, super.key});
  final bool dimssable;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SpinKitCubeGrid(color: Theme.of(context).primaryColor, size: 50.0),
    );
  }
}
