import 'package:app/business_logic/orders/cubit/orders_cubit.dart';
import 'package:app/persentation/widgets/buttons.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showForceMakeAlert(BuildContext context,selectedDate,address,useLoyalty) {
  return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Set background color to white
          child: Container(
            width: MediaQuery.of(context).size.width-50,
            height: 180,
            decoration: BoxDecoration(
                color: MyColors.whiteColor,
                borderRadius: BorderRadius.circular(20)
            ),
            padding: EdgeInsets.all(20.0), // Add more padding
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,crossAxisAlignment: CrossAxisAlignment.center,children: [
              Text("can not make order before pay overdue  invoices".tr(),style: TextStyle(fontSize: 18),textAlign: TextAlign.center),
              SizedBox(height: 10,),
              CustomButton(
                text: 'Force Make'.tr(),
                onPressed: ()async {
                  // Navigator.pop(context);
                  await OrdersCubit.get(context).addForceOrder(
                    context: context,
                    dateTime: selectedDate,
                    brancheModel: OrdersCubit.get(context).selectedBranch!,
                    address: address,
                    useLoyalty: useLoyalty
                  );
                },
                color: MyColors.mainColor,
                width: 130,
                textColor: Colors.white,
                borderRadius: BorderRadius.circular(30),
              )
            ],
            ),
          ),
        );
      }
  );
}