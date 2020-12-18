
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
class DioUtil {
  static Dio dio = Dio();


  /// get
  static Future get(String url) async {
    dio.options.baseUrl = "https://www.peppa.me";
    try {
      Response response = await dio.get(url);
      return response.data;
    } catch(error) {
      debugPrint(error.toString());
    } finally {
    }
  }
}