import 'package:app/theme/colors.dart';
import 'package:flutter/material.dart';

class LangWidget extends StatefulWidget {
  const LangWidget({super.key});

  @override
  State<LangWidget> createState() => _LangWidgetState();
}

class _LangWidgetState extends State<LangWidget> {
  String selectedLang = 'ar';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        width: 93.0,
        height: 29.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedLang = 'en';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selectedLang == 'en' ? MyColors.redColor : MyColors.whiteColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'EN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedLang == 'en' ? MyColors.whiteColor : MyColors.redColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedLang = 'ar';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selectedLang == 'ar' ? MyColors.redColor : MyColors.whiteColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'ع',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedLang == 'ar' ? MyColors.whiteColor : MyColors.redColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
