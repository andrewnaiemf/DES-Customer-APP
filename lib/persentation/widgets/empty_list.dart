import 'package:app/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class EmptyList extends StatelessWidget {
  final String icon ,title;
  const EmptyList({Key? key,required this.title,required this.icon}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      child: Center(child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
        SvgPicture.asset(icon , width: 150,height: 150,color: MyColors.green,),
        SizedBox(height: 10,),
        Text(" لا يوجد $title  جديده ")
      ]),),
    );
  }
}
