import 'package:dio/dio.dart';
import 'package:novacole/utils/api.dart';

class FormResource {
  String? value;
  String? label;

  FormResource({this.label, this.value});

  Future<List<dynamic>> search(
    String url, {
    Map<String, dynamic>? filters,
    Map<String, dynamic>? search,
    String name = '',
    List<Map<String, dynamic>>? resources,
  }) async {
    try {
      Dio dio = await Http().api();
      Response response =
          await dio.post(url, data: {'term': name, 'resources': resources});
      return response.data;
    } on DioException catch (_) {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getValues(
      List<Map<String, dynamic>> resources) async {
    try {
      Dio dio = await Http().api();
      Response response = await dio
          .post('/metamorph/many/search?paginate=0', data: {'resources': resources});
      return response.data;
    } on DioException catch (_) {
      return {};
    } catch (e) {
      return {};
    }
  }
}
