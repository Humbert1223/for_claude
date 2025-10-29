import 'package:dio/dio.dart';
import 'package:novacole/utils/api.dart';

class CoreForm {
  CoreForm();

  Future<List<dynamic>?> search({String? formType = ''}) async {
    try {
      Dio dio = await Http().api();
      Response response =
          await dio.get('/metamorph/forms?paginate=0&type=${formType!}');
      return response.data;
    } on DioException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> find(String id) async {
    try {
      Dio dio = await Http().api();
      Response response = await dio.get('/metamorph/forms/$id');
      return response.data;
    } on DioException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> get({required String entity}) async {
    try {
      Dio dio = await Http().api();
      Response response = await dio.post('/core/forms/$entity');
      return response.data;
    } on DioException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }
}
