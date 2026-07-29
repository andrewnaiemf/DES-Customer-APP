import 'package:app/theme/colors.dart';
import 'package:app/core/responsive/responsive.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    required this.text,
    this.textColor,
    this.color,
    this.width,
    this.height,
    this.onPressed,
    this.fontWeight,
    this.fontSize,
    this.borderRadius,
    this.isloading,
    this.elevation,
    this.gradient,
    this.isGradient,
  });

  double? width;
  double? height;
  double? fontSize;
  String text;
  Color? textColor;
  Color? color;
  FontWeight? fontWeight;
  void Function()? onPressed;
  BorderRadiusGeometry? borderRadius;
  bool? isloading = false;
  Gradient? gradient;
  bool? isGradient = false;
  double? elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(6.r(context)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w(context)),
      width: width ?? ResponsiveUtils.width(context, 400),
      height: height ?? ResponsiveUtils.buttonHeight(context, 45),
      child: ElevatedButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: color,
          elevation: elevation ?? 0,
          padding: EdgeInsets.symmetric(
            horizontal: 20.w(context),
            vertical: 5.h(context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(15.r(context)),
            side: const BorderSide(width: 0, color: Colors.transparent),
          ),
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        child: AutoSizeText(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: fontWeight,
            fontSize: fontSize ?? ResponsiveUtils.font(context, 15),
          ),
          minFontSize: 7,
        ),
      ),
    );
  }
}

class CustomButtonLoading extends StatelessWidget {
  CustomButtonLoading({
    super.key,
    this.textColor,
    this.color,
    this.width,
    this.height,
    this.fontWeight,
    this.fontSize,
    this.borderRadius,
    this.isGradient,
    this.gradient,
    this.loadingPadding,
  });

  double? width;
  double? height;
  double? fontSize;
  Color? textColor;
  Color? color;
  FontWeight? fontWeight;
  BorderRadiusGeometry? borderRadius;
  bool? isGradient;
  Gradient? gradient;
  double? loadingPadding;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(15.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 35),
      width: width ?? 430,
      height: height ?? 45,
      child: ElevatedButton(
        onPressed: null,
        style: TextButton.styleFrom(
          backgroundColor:color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(15.0),
            side: const BorderSide(width: 0, color: Colors.transparent),
          ),
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(loadingPadding ?? 0),
          child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              color: textColor,
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButtonOld extends StatelessWidget {
  CustomButtonOld({
    super.key,
    required this.text,
    this.textColor,
    this.color,
    this.width,
    this.height,
    this.onPressed,
    this.fontWeight,
    this.fontSize,
    this.borderRadius,
    this.isloading,
    this.elevation,
    this.gradient,
    this.isGradient,
  });

  double? width;
  double? height;
  double? fontSize;
  String text;
  Color? textColor;
  Color? color;
  FontWeight? fontWeight;
  void Function()? onPressed;
  BorderRadiusGeometry? borderRadius;
  bool? isloading = false;
  Gradient? gradient;
  bool? isGradient = false;
  double? elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(6.0),
        // gradient: isGradient == false
        //     ? null
        //     : gradient ??
        //         const LinearGradient(
        //           begin: Alignment(0.0, -2.49),
        //           end: Alignment.bottomCenter,
        //           colors: [MyColors.redColor, MyColors.mainColor],
        //         ),
      ),
      width: width ?? 240,
      height: height ?? 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: onPressed == null
              ? color?.withOpacity(0.4) ?? MyColors.whiteColor.withOpacity(0.4)
              : isGradient == true
                  ? Colors.transparent
                  : onPressed == null
                      ? const Color(0x2b2b6db4)
                      : color,
          elevation: elevation ?? 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(6.0),
            side: const BorderSide(width: 0, color: Colors.transparent),
          ),
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        child: AutoSizeText(
          text,
          style: TextStyle(
            color: onPressed == null ? Colors.white.withOpacity(0.5) : textColor,
            fontWeight: fontWeight,
            fontSize: fontSize,
          ),
          minFontSize: 7,
        ),
      ),
    );
  }
}

class CustomButtonLoadingOld extends StatelessWidget {
  CustomButtonLoadingOld({
    super.key,
    this.textColor,
    this.color,
    this.width,
    this.height,
    this.fontWeight,
    this.fontSize,
    this.borderRadius,
    this.isGradient,
    this.gradient,
    this.loadingPadding,
  });

  double? width;
  double? height;
  double? fontSize;
  Color? textColor;
  Color? color;
  FontWeight? fontWeight;
  BorderRadiusGeometry? borderRadius;
  bool? isGradient;
  Gradient? gradient;
  double? loadingPadding;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(6.0),
        gradient: isGradient == false
            ? null
            : gradient ??
                const LinearGradient(
                  begin: Alignment(0.0, -2.49),
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF98C1FF), Color(0xFF1552AE)],
                ),
      ),
      width: width ?? 240,
      height: height ?? 40,
      child: ElevatedButton(
        onPressed: null,
        style: TextButton.styleFrom(
          backgroundColor: isGradient == true ? Colors.transparent : color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(6.0),
            side: const BorderSide(width: 0, color: Colors.transparent),
          ),
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(loadingPadding ?? 0),
          child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              color: textColor,
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }
}
