import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:novacole/utils/api.dart';
import 'package:path_provider/path_provider.dart';

class MasterCrudModel {
  final String model;

  MasterCrudModel(this.model);

  Future<dynamic> search({
    String? paginate = '1',
    int? page = 1,
    int? perPage = 30,
    List<Map<String, dynamic>>? filters,
    Map<String, dynamic>? search,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      Dio dio = await Http().api();
      var form = {...?data};
      List<Map<String, dynamic>> mergedFilters =
          List<Map<String, dynamic>>.from(data?['filters'] ?? []);
      if (filters != null) mergedFilters.addAll(filters);
      if (search != null) form['search'] = search;

      form['filters'] = mergedFilters;

      Response response = await dio.post(
        '/metamorph/search/$model',
        data: form,
        queryParameters: {
          'paginate': paginate,
          'page': page,
          'per_page': perPage,
          ...?query
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> get(String id,
      {Map<String, dynamic>? query}) async {
    try {
      Dio dio = await Http().api();
      Response response =
          await dio.get('/metamorph/master/$model/$id', queryParameters: query);
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e.response);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>?> find(String uri) async {
    try {
      Dio dio = await Http().api();
      Response response = await dio.get(uri);
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e.response);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> create(Object data) async {
    try {
      Dio dio = await Http().api();
      Response r = await dio.post('/metamorph/master/$model', data: data);
      return Map<String, dynamic>.from(r.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e.response);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> update(String id, Object data) async {
    try {
      Dio dio = await Http().api();
      Response r = await dio.patch('/metamorph/master/$model/$id', data: data);
      return Map<String, dynamic>.from(r.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e.response);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>?> post(
    String uri, {
    Map<String, dynamic>? data,
  }) async {
    try {
      Dio dio = await Http().api();
      Response response = await dio.post(uri, data: data);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        if (kDebugMode) {
          print(e);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  static Future download(
      String uri, String fileName, Map<String, dynamic> data) async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      String filePath = "${dir.path}/$fileName";
      Dio dio = await Http().api(
        contentType: 'application/json',
        responseType: ResponseType.bytes,
      );
      dynamic response = await dio.post(uri, data: {...data});
      File file = File(filePath);
      await file.writeAsBytes(List<int>.from(response.data), flush: true);
      return filePath;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>?> patch(
      String uri, Map<String, dynamic> data) async {
    try {
      Dio dio = await Http().api();
      Response response = await dio.patch(uri, data: data);
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e.response);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> load(
    String uri, {
    Map<String, dynamic>? data,
  }) async {
    try {
      Dio dio = await Http().api();
      Response response = await dio.post(uri, data: data);
      return List.generate(
        List.from(response.data).length,
        (index) => Map<String, dynamic>.from(List.from(response.data)[index]),
      );
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>?> delete(
    String id,
    String model, {
    Map<String, dynamic>? data,
  }) async {
    try {
      Dio dio = await Http().api();
      Response r = await dio.delete('/metamorph/master/$model/$id', data: data);
      return r.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(e.response);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }
}
