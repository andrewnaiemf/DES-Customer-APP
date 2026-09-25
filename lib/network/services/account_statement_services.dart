import 'dart:convert';
import 'dart:developer';
import 'package:app/data/constants/api_constants.dart';
import 'package:app/models/account_statement_model/AccountStatementModel/AccountStatementModel2.dart';
import 'package:app/models/account_statement_model/account_statement_model.dart';
import 'package:app/network/dio_helper.dart';
import 'package:dio/dio.dart';

class AccountStatementServices {
  Future<AccountStatementModel2?> getAccountStatementServices(String filter,String branch_id,) async {
    log('account-statement filter=$filter branch_id=$branch_id');
    final response = await DioHelper.get(
      path: EndPoints.accountStatement,
      queryParameters: {
        'filter[date_range]': filter,
        'branch_id': branch_id,
        'per_page': 500,
      },
      options: Options(headers: {'per-page': 500}),
    );
    final responseMap = response.data;

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300 &&
        responseMap is Map) {
      return AccountStatementModel2.fromJson(
        Map<String, dynamic>.from(responseMap),
      );
    }
    log('Failed to getAccountStatementServices: ${response.statusCode}');
    return null;
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
