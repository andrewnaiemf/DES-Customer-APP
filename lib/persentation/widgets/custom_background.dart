import 'package:app/data/constants/assets.dart';
import 'package:flutter/material.dart';
class CustomBackground extends StatelessWidget {
  final Widget child;
  final bool isSplash;
  const CustomBackground({Key? key,required this.child,  this.isSplash=false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(isSplash?Assets.splashBg_new:Assets.splashBg),fit: BoxFit.cover)
        ),
        child: child,
      ),
    );
  }
}