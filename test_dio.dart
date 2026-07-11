import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    await dio.post(
      'http://127.0.0.1:5182/v1/auth/login',
      data: {
        'username': 'gokul@gmail.com',
        'password': 'wrongpassword',
        'tenant_id': 'SYSTEM_TENANT',
      },
    );
  } on DioException catch (e) {
    print('DioException caught!');
    print('e.response: ${e.response}');
    print('e.response.data: ${e.response?.data}');
    print('e.response.data type: ${e.response?.data.runtimeType}');
    
    try {
      final msg = e.response?.data?['error'] ?? 'Login failed. Please check your credentials.';
      print('msg: $msg');
    } catch (e2) {
      print('Exception while accessing data: $e2');
    }
  } catch (e) {
    print('Other exception: $e');
  }
}
