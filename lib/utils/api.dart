import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:novacole/controllers/auth_provider.dart';
import 'package:novacole/main.dart';
import 'package:novacole/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Http {
  final String? contentType;

  Http({
    this.contentType = 'application/json',
  });

  static const apiUrl = 'https://api-v2.novacole.com/api';

  Future<Dio> api({
    String? contentType,
    ResponseType responseType = ResponseType.json,
  }) async {
    UserModel? user = await UserModel.fromLocalStorage();
    String? token = user?.token;
    BaseOptions options = BaseOptions(
      baseUrl: apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 600),
      sendTimeout: const Duration(seconds: 30),
      contentType: contentType ?? 'application/json',
      responseType: responseType,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'academic': user?.academic,
        'school': user?.school,
      },
    );
    Dio dio = Dio(options);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.data != null &&
              ['post', 'patch', 'put', 'delete']
                  .contains(options.method.toString().toLowerCase())) {
            if (options.data.runtimeType == FormData) {
              options.data.fields.add(MapEntry('created_by', user?.id ?? ''));
            } else {
              options.data['created_by'] = user?.id;
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          try {
            String? message = e.response?.data?['message'];
            if (message != null) {
              Fluttertoast.showToast(
                msg: message,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }

          if (e.response?.statusCode == 401) {
            authProvider.logout().then((value) {
              navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
            });
          }
          return handler.next(e);
        },
      ),
    );
    return dio;
  }

  Future<SharedPreferences> local() async {
    return await SharedPreferences.getInstance();
  }
}
