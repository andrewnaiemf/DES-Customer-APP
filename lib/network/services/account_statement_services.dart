import 'dart:convert';
import 'dart:developer';
import 'package:app/data/constants/api_constants.dart';
import 'package:app/models/account_statement_model/AccountStatementModel/AccountStatementModel2.dart';
import 'package:app/models/account_statement_model/account_statement_model.dart';
import 'package:app/network/dio_helper.dart';
import 'package:dio/dio.dart';

class AccountStatementServices {
  Future<AccountStatementModel2?> getAccountStatementServices(String filter,String branch_id,) async {
    print("branch_id $branch_id");
    print("filter $filter");
    print("filter $filter");
    print("EndPoints ${EndPoints.accountStatement+"?branch_id=$branch_id&filter[date_range]=$filter"}");
    final response = await DioHelper.get(path: EndPoints.accountStatement+"?branch_id=$branch_id&filter[date_range]=$filter",
    //     queryParameters:{
    //   "filter[date_range]": "$filter",
    //   "branch_id": "$branch_id",
    // },
        options: Options(headers: {"per-page": 10000}));
    final responseMap = response.data; // ✅ FIXED

    // var responseMap = jsonDecode(response.data.toString());
    if(response.statusCode! >= 200 &&response.statusCode! < 300){
      print(response.data.toString());
      print("getAccountStatementServices statusCode 200");
      return AccountStatementModel2.fromJson(responseMap);
      // return AccountStatementModel2.fromJson(responseMap);
    }else{
      print(response.toString());
      print("Failed to getAccountStatementServices.");
      return null;
    }
  }

  // static String endPoint = EndPoints.accountStatement;
  // static List<AccountStatementModel> data = [];
  // static Future<List<AccountStatementModel>> getData(Map<String, dynamic>? queryParameters) async {
  //   data.clear();
  //   try {
  //     DioHelper.dio.options.headers.addAll({"per-page": 10000});
  //     var result = await DioHelper.get(path: endPoint, queryParameters: queryParameters);
  //     DioHelper.dio.options.headers.remove('per-page');
  //     if (result.statusCode == 200) {
  //       log('Get $endPoint Success');
  //       for (var element in result.data['data']['data']) {
  //         data.add(AccountStatementModel.fromJson(element));
  //       }
  //       return data;
  //     } else {
  //       log('Unable To Get $endPoint');
  //     }
  //   } catch (e) {
  //     log('$e');
  //   }
  //   return data;
  // }
}
