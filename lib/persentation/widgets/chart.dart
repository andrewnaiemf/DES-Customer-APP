// import 'package:app/business_logic/Statistic_cubit/statistic_cubit.dart';
// import 'package:app/models/Statistics/statistics_model.dart';
// import 'package:app/theme/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class LineChartWidget extends StatefulWidget {
//   const LineChartWidget({Key? key}) : super(key: key);
//
//   @override
//   State<LineChartWidget> createState() => _LineChartWidgetState();
// }
//
// class _LineChartWidgetState extends State<LineChartWidget> {
//
//   @override
//   void initState() {
//    context.read<StatisticCubit>().getStatistic();
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<StatisticCubit, StatisticState>(
//       builder: (context, state) {
//         if (state is StatisticLoading) {
//           return Container();
//         } else if (state is StatisticLoaded) {
//           return _buildChart(state.model.data?.year??[]);
//         }
//         return Container(); // Handle other states if necessary
//       },
//     );
//   }
//
//   Widget _buildChart(List<Year>? years) {
//     if (years == null || years.isEmpty) {
//       return Center(child: Text('No data available'));
//     }
//
//     return Stack(
//       children: <Widget>[
//         AspectRatio(
//           aspectRatio: 1.70,
//           child: Padding(
//             padding: const EdgeInsets.only(
//               right: 18,
//               left: 12,
//               top: 24,
//               bottom: 12,
//             ),
//             child: LineChart(
//               LineChartData(
//                 lineBarsData: [
//                   _buildLineChartBarData(years, 'total_paid_amount', MyColors.yellow),
//                   _buildLineChartBarData(years, 'total_due_amount', Colors.green),
//                 ],
//
//                 titlesData: FlTitlesData(
//                 //
//                 //   // Your title configurations
//                 // ),
//                 // borderData: FlBorderData(
//                 //   // Your border configurations
//                 // ),
//                 //       titlesData: FlTitlesData(
//         rightTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         topTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             reservedSize: 30,
//             getTitlesWidget: bottomTitleWidgets,
//             interval: 1,
//           ),
//         ),
//         leftTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             reservedSize: 30,
//             getTitlesWidget: leftTitleWidgets,
//             // interval: 1,
//           ),
//         ),
//         //   sideTitles: SideTitles(
//         //     showTitles: true,
//         //     interval: 1,
//         //   ),
//         // ),
//       ),
//       borderData: FlBorderData(
//         show: true,
//         border: Border.all(color: Colors.transparent),
//       ),
//
//                 // Your other chart data configurations
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   LineChartBarData _buildLineChartBarData(List<Year> years, String key, Color color) {
//     List<FlSpot> spots = [];
//     for (int i = 0; i < years.length; i++) {
//       int? value;
//       if (key == 'total_paid_amount') {
//         value = int.parse(years[i].totalPaidAmount.toString());
//       } else if (key == 'total_due_amount') {
//         value = years[i].totalDueAmount?.toInt();
//       }
//       if (value != null) {
//         spots.add(FlSpot(i.toDouble(), value.toDouble()));
//       }
//     }
//
//     return LineChartBarData(
//       spots: spots,
//       isCurved: true,
//       color: color,
//       barWidth: 4,
//       belowBarData: BarAreaData(show: false),
//           // isStrokeCapRound: true,
//           dotData: const FlDotData(
//             show: false,
//           ),
//     );
//   }
// }
// // import 'package:app/business_logic/Statistic_cubit/statistic_cubit.dart';
// // import 'package:app/persentation/widgets/Loading_widget.dart';
// // import 'package:app/theme/colors.dart';
// // import 'package:fl_chart/fl_chart.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// //
// // class LineChartWidget extends StatefulWidget {
// //   const LineChartWidget({super.key});
// //
// //   @override
// //   State<LineChartWidget> createState() => _LineChartSample2State();
// // }
// //
// // class _LineChartSample2State extends State<LineChartWidget> {
// //   List<Color> gradientColors = [
// //     MyColors.redColor,
// //     MyColors.redColor,
// //   ];
// //
// //   bool showAvg = false;
// //   @override
// //   void initState() {
// //     context.read<StatisticCubit>().getStatistic();
// //     super.initState();
// //   }
// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocBuilder<StatisticCubit, StatisticState>(
// //   builder: (context, state) {
// //     if(state is StatisticLoading){
// //       return MyLoadingTransperant();
// //     }
// //     else if(state is StatisticLoaded){
// //       return Stack(
// //         children: <Widget>[
// //           AspectRatio(
// //             aspectRatio: 1.70,
// //             child: Padding(
// //               padding: const EdgeInsets.only(
// //                 right: 18,
// //                 left: 12,
// //                 top: 24,
// //                 bottom: 12,
// //               ),
// //               child: LineChart(
// //                 showAvg ? avgData() : mainData(),
// //               ),
// //             ),
// //           ),
// //           SizedBox(
// //             width: 60,
// //             height: 34,
// //             child: TextButton(
// //               onPressed: () {
// //                 setState(() {
// //                   showAvg = !showAvg;
// //                 });
// //               },
// //               child: Text(
// //                 'avg',
// //                 style: TextStyle(
// //                   fontSize: 12,
// //                   color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       );
// //
// //     }
// //     return Container();
// //   },
// // );
// //   }
// //
//   Widget bottomTitleWidgets(double value, TitleMeta meta) {
//     const style = TextStyle(
//       fontWeight: FontWeight.bold,
//       fontSize: 12,
//       color: MyColors.whiteColor
//     );
//     String text;
//     switch (value.toInt()) {
//       case 0:
//         text = '1';
//         break;
//       case 1:
//         text = '2';
//         break;
//       case 2:
//         text = '3';
//         break;
//       case 3:
//         text = '4';
//         break;
//       case 4:
//         text = '5';
//         break;
//       case 5:
//         text = '6';
//         break;
//       case 6:
//         text = '7';
//         break;
//       case 7:
//         text = '8';
//         break;
//       case 8:
//         text = '9';
//         break;
//       case 9:
//         text = '10';
//         break;
//       case 10:
//         text = '11';
//         break;
//       case 11:
//         text = '12';
//         break;
//       default:
//         text = '';
//         break;
//     }
//
//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       child: Text(text, style: style),
//     );
//   }
// Widget leftTitleWidgets(double value, TitleMeta meta) {
//   const style = TextStyle(
//     // fontWeight: FontWeight.bold,
//     fontSize: 12,
//       color: MyColors.whiteColor
//   );
//   int intValue = value.toInt(); // Convert double to integer
//   return RotatedBox(
//     quarterTurns: 4,
//     child: Text("$intValue", style: style), // Display integer value
//   );
// }
//
//   //
// //   Widget leftTitleWidgets(double value, TitleMeta meta) {
// //     const style = TextStyle(
// //       fontWeight: FontWeight.bold,
// //       fontSize: 15,
// //     );
// //     String text;
// //     switch (value.toInt()) {
// //       case 1:
// //         text = '10K';
// //         break;
// //       case 3:
// //         text = '30k';
// //         break;
// //       case 5:
// //         text = '50k';
// //         break;
// //       default:
// //         return Container();
// //     }
// //
// //     return Text(text, style: style, textAlign: TextAlign.left);
// //   }
// //
// //   LineChartData mainData() {
// //     return LineChartData(
// //       gridData: FlGridData(
// //         show: true,
// //         drawVerticalLine: true,
// //         horizontalInterval: 1,
// //         verticalInterval: 1,
// //         getDrawingHorizontalLine: (value) {
// //           return const FlLine(
// //             color: MyColors.redColor,
// //             strokeWidth: 0,
// //           );
// //         },
// //         getDrawingVerticalLine: (value) {
// //           return const FlLine(
// //             color: MyColors.redColor,
// //             strokeWidth: 0,
// //           );
// //         },
// //       ),
// //       titlesData: FlTitlesData(
// //         show: true,
// //         rightTitles: const AxisTitles(
// //           sideTitles: SideTitles(showTitles: false),
// //         ),
// //         topTitles: const AxisTitles(
// //           sideTitles: SideTitles(showTitles: false),
// //         ),
// //         bottomTitles: AxisTitles(
// //           sideTitles: SideTitles(
// //             showTitles: true,
// //             reservedSize: 30,
// //             interval: 1,
// //             getTitlesWidget: bottomTitleWidgets,
// //           ),
// //         ),
// //         leftTitles: AxisTitles(
// //           sideTitles: SideTitles(
// //             showTitles: true,
// //             interval: 1,
// //             getTitlesWidget: leftTitleWidgets,
// //             reservedSize: 42,
// //           ),
// //         ),
// //       ),
// //       borderData: FlBorderData(
// //         show: true,
// //         border: Border.all(color: Colors.transparent),
// //       ),
// //       minX: 0,
// //       maxX: 11,
// //       minY: 0,
// //       maxY: 6,
// //       lineBarsData: [
// //         LineChartBarData(
// //           spots: const [
// //             FlSpot(0, 3),
// //             FlSpot(2.6, 2),
// //             FlSpot(4.9, 5),
// //             FlSpot(6.8, 3.1),
// //             FlSpot(8, 4),
// //             FlSpot(9.5, 3),
// //             FlSpot(11, 4),
// //           ],
// //           isCurved: true,
// //           gradient: LinearGradient(
// //             colors: gradientColors,
// //           ),
// //           barWidth: 7,
// //           isStrokeCapRound: true,
// //           dotData: const FlDotData(
// //             show: false,
// //           ),
// //           // belowBarData: BarAreaData(
// //           //   show: true,
// //           //   gradient: LinearGradient(
// //           //     colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
// //           //   ),
// //           // ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   LineChartData avgData() {
// //     return LineChartData(
// //       lineTouchData: const LineTouchData(
// //         enabled: false,
// //       ),
// //       gridData: FlGridData(
// //         show: true,
// //         drawHorizontalLine: true,
// //         verticalInterval: 1,
// //         horizontalInterval: 1,
// //         getDrawingVerticalLine: (value) {
// //           return const FlLine(
// //             color: MyColors.whiteColor,
// //             strokeWidth: 1,
// //           );
// //         },
// //         getDrawingHorizontalLine: (value) {
// //           return const FlLine(
// //             color: MyColors.whiteColor,
// //             strokeWidth: 1,
// //           );
// //         },
// //       ),
// //       titlesData: FlTitlesData(
// //         show: true,
// //         bottomTitles: AxisTitles(
// //           sideTitles: SideTitles(
// //             showTitles: true,
// //             reservedSize: 30,
// //             getTitlesWidget: bottomTitleWidgets,
// //             interval: 1,
// //           ),
// //         ),
// //         leftTitles: AxisTitles(
// //           sideTitles: SideTitles(
// //             showTitles: true,
// //             getTitlesWidget: leftTitleWidgets,
// //             reservedSize: 42,
// //             interval: 1,
// //           ),
// //         ),
// //         topTitles: const AxisTitles(
// //           sideTitles: SideTitles(showTitles: false),
// //         ),
// //         rightTitles: const AxisTitles(
// //           sideTitles: SideTitles(showTitles: false),
// //         ),
// //       ),
// //       borderData: FlBorderData(
// //         show: true,
// //         border: Border.all(color: MyColors.whiteColor),
// //       ),
// //       minX: 0,
// //       maxX: 11,
// //       minY: 0,
// //       maxY: 6,
// //       lineBarsData: [
// //         LineChartBarData(
// //           spots: const [
// //             FlSpot(0, 3.44),
// //             FlSpot(2.6, 3.44),
// //             FlSpot(4.9, 3.44),
// //             FlSpot(6.8, 3.44),
// //             FlSpot(8, 3.44),
// //             FlSpot(9.5, 3.44),
// //             FlSpot(11, 3.44),
// //           ],
// //           isCurved: true,
// //           gradient: LinearGradient(
// //             colors: [
// //               ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
// //               ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
// //             ],
// //           ),
// //           barWidth: 5,
// //           isStrokeCapRound: true,
// //           dotData: const FlDotData(
// //             show: false,
// //           ),
// //           belowBarData: BarAreaData(
// //             show: true,
// //             gradient: LinearGradient(
// //               colors: [
// //                 ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!.withOpacity(0.1),
// //                 ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!.withOpacity(0.1),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
