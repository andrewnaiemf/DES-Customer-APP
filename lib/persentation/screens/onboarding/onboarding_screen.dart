// import 'package:app/core/responsive/responsive.dart';
// import 'dart:async';
//
// import 'package:app/data/constants/assets.dart';
// import 'package:app/helpers/my_navigation.dart';
// import 'package:app/persentation/screens/auth/login_screen.dart';
// import 'package:app/persentation/widgets/directional_arrow.dart';
// import 'package:app/theme/colors.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:gif_view/gif_view.dart';
//
// class OnBoardingScreen extends StatefulWidget {
//   const OnBoardingScreen({super.key});
//
//   @override
//   State<OnBoardingScreen> createState() => _OnBoardingScreenState();
// }
//
// class _OnBoardingScreenState extends State<OnBoardingScreen> with SingleTickerProviderStateMixin {
//   bool showGif=false;
//   @override
//   void initState() {
//     Timer(Duration(seconds: 19), () {
//         setState(() {showGif=true; });
//         // print(DateTime.now());
//         Timer(Duration(seconds: 20, milliseconds: 600), () {
//           MyNavigator.navigateTo(context, LoginScreen(),);
//         });
//     });
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       backgroundColor: MyColors.background,
//       body: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         decoration: BoxDecoration(
//             image: DecorationImage(
//                 image: AssetImage(Assets.backGround2), fit: BoxFit.fill),
//             ),
//         child: Stack(
//           children: [
//             Center(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Center(
//                       child: SizedBox(
//                         width: 399.999,
//                         height: 299.99925,
//                         child: GifView.asset(
//                           Assets.welcomeGIF,
//                           width: double.infinity,
//                           height: double.infinity,
//                         ),
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'More Than One Application'.tr(),
//                           style: TextStyle(
//                               fontSize: 27.99993,
//                               color: MyColors.green2,
//                               fontWeight: FontWeight.w600,
//                               height: 1.999995),
//                         ),
//                         Text(
//                           'A friend to keep track of your bills'.tr(),
//                           style: TextStyle(
//                               fontSize: 19.99995,
//                               color: MyColors.black,
//                               fontWeight: FontWeight.w500,
//                               height: 1.999995),
//                         ),
//                         Text(
//                           'Easily And Smoothly'.tr(),
//                           style: TextStyle(
//                               fontSize: 19.99995,
//                               color: MyColors.black,
//                               fontWeight: FontWeight.w700,
//                               height: 0.9999975),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 149.999625),
//                     Container(
//                       width: 299.99925,
//                       height: 199.9995,
//                       color: Colors.transparent,
//
//                     ),
//                  /*   Center(
//                       child: GestureDetector(
//                         onTap: () {
//                           // MyNavigator.navigateOffAll(context, LoginScreen());
//                           _gifController.play();
//                           setState(() { });
//                           print("RRR");
//                          *//* Timer(Duration(seconds: 1), () {
//                             MyNavigator.navigateOffAll(context, LoginScreen());
//                           });*//*
//                         },
//                         child: CircleAvatar(
//                           backgroundColor: MyColors.green2,
//                           radius: 29.999925,
//                           child: Icon(
//                             Icons.arrow_back_ios_new_rounded,
//                             color: MyColors.black,
//                             size: 27.99993,
//                           ),
//                           // child: Transform.flip(flipX: true, child: SvgPicture.asset(AssetsSVG.next)),
//                         ),
//                       ),
//                     ),*/
//                   ],
//                 ),
//               ),
//             ),
//             showGif?Image.asset(
//               // controller: _gifController,
//               Assets.routing,
//               width: double.infinity,
//               height: height,
//               fit: BoxFit.fitHeight,
//             ):SizedBox(),
//           ],
//         ),
//       ),
//     );
//   }
// }
// // class OnBoardingScreen extends StatelessWidget {
// //   const OnBoardingScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: MyColors.scaffoldColor,
// //       body: Center(
// //         child: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.center,
// //             children: [
// //               // Center(
// //               //   child: Transform.scale(
// //               //     scale: 1.199997,
// //               //     child: SizedBox(
// //               //       width: double.infinity,
// //               //       height: 299.99925,
// //               //       child: SvgPicture.asset(
// //               //         AssetsSVG.onbording,
// //               //         width: double.infinity,
// //               //         height: double.infinity,
// //               //       ),
// //               //     ),
// //               //   ),
// //               // ),
// //               Padding(
// //                 padding: const EdgeInsets.all(19.99995),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     if (context.locale.languageCode == 'ar')
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Image.asset(Assets.intro),
// //                           Text(
// //                             'More Than One Application'.tr(),
// //                             style: const TextStyle(
// //                               fontSize: 36.9999075,
// //                               color: Colors.black,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           Text(
// //                             'A friend to keep track of your bills'.tr(),
// //                             style: const TextStyle(
// //                               fontSize: 25.999935,
// //                               color: MyColors.mainColor,
// //                               fontWeight: FontWeight.w200,
// //                             ),
// //                           ),
// //                           Text(
// //                             'Easily'.tr(),
// //                             style: const TextStyle(
// //                               fontSize: 25.999935,
// //                               color: MyColors.mainColor,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                           Text(
// //                             'And Smoothly'.tr(),
// //                             style: const TextStyle(
// //                               fontSize: 25.999935,
// //                               color: MyColors.mainColor,
// //                               fontWeight: FontWeight.w200,
// //                             ),
// //                           ),
// //                         ],
// //                       )
// //                     else
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'More Than One Application'.tr(),
// //                             style: const TextStyle(
// //                               fontSize: 36.9999075,
// //                               color: Colors.black,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           Text.rich(TextSpan(children: [
// //                             TextSpan(children: [
// //                               TextSpan(
// //                                 text: 'A friend to keep track of your bills'.tr(),
// //                                 style: const TextStyle(
// //                                   fontSize: 25.999935,
// //                                   color: MyColors.mainColor,
// //                                   fontWeight: FontWeight.w200,
// //                                 ),
// //                               ),
// //                               TextSpan(
// //                                 text: ' ${'Easily'.tr()} ',
// //                                 style: const TextStyle(
// //                                   fontSize: 25.999935,
// //                                   color: MyColors.mainColor,
// //                                   fontWeight: FontWeight.w600,
// //                                 ),
// //                               ),
// //                               TextSpan(
// //                                 text: 'And Smoothly'.tr(),
// //                                 style: const TextStyle(
// //                                   fontSize: 25.999935,
// //                                   color: MyColors.mainColor,
// //                                   fontWeight: FontWeight.w200,
// //                                 ),
// //                               ),
// //                             ]),
// //                           ])),
// //                         ],
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(height: 29.999925),
// //               GestureDetector(
// //                 onTap: () {
// //                   MyNavigator.navigateOffAll(context, LoginScreen());
// //                 },
// //                 child: SvgPicture.asset(
// //                   AssetsSVG.nextOn,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
