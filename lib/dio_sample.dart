import 'dart:convert';

import 'package:dio/dio.dart';
import 'dio_interceptor.dart';
// import 'http/http_parse.dart';
// import 'http/http_response.dart';
// import 'http/http_transformer.dart';
// import 'http/default_http_transformer.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'sp.dart';

enum HttpMethod { post, get, put, patch, delete }

typedef ParseObject = dynamic Function(dynamic originMap);

extension ListExt on List<dynamic> {
  List<T> parseObj<T>(ParseObject covert) {
    return List<T>.from(map(covert)).toList();
  }
}

extension ResultJsonExt on ResultJson? {
  bool get requestIsSuccess =>
      this != null && this!.success == true && this!.errors.isEmpty;
}

abstract class BaseModel<T> {
  T fromJson(Map<String, dynamic> map);
}

class ResultJson {
  final bool success;
  final String errorMessage;
  final List<dynamic> errors;
  final dynamic data;

  ResultJson(
      {required this.success,
      required this.errorMessage,
      required this.errors,
      required this.data});

  factory ResultJson.fromJson(Map<String, dynamic> map) {
    return ResultJson(
        success: map['success'] ?? false,
        errorMessage: map['errorMessage'] ?? '',
        errors: map['errors'] ?? [],
        data: map['data']);
  }

  //打印
  void printDataJson() {
    print(jsonEncode(data));
  }

  //转数组
  List<dynamic> parseList() {
    return data as List<dynamic>;
  }

  List<T> dataCovertToList<T>(ParseObject covert) {
    return parseList().parseObj<T>(covert).toList();
  }

  @override
  String toString() {
    return '==============\n是否成功:${success ? '成功' : '失败'} data类型:${data.runtimeType} \n错误消息:$errorMessage\n错误列表:$errors\n数据:$data\n==============';
  }
}

abstract class BaseApi {
  static String host = 'https://reqres.in/api';

  final String url;
  final HttpMethod httpMethod;
  final Map<String, dynamic> params = <String, dynamic>{};

  BaseApi(this.url, {this.httpMethod = HttpMethod.get});

  Future<ResultJson?> request() async {
    // Future<HttpResponse?> request() async {
    // print(host + url);
    // print(params);
    // print(methed);

    final dio = Dio(
      BaseOptions(
        baseUrl: host,
        connectTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );


    final tokenDio = Dio();
    tokenDio.options = dio.options;
    tokenDio.interceptors.add(LogInterceptor(responseBody: true)); //Open log;

    // String auth_url="https://reqres.in/api/login";
    String auth_url = "http://127.0.0.1/api/login";
    String tokenkey = "token";
    String? csrfToken;
    // String? csrfToken =  SpUtil().get(tokenkey);
    // final data = {"email": "eve.holt@reqres.in","password": "cityslicka"};
    // curl -v -X POST -H "Content-Type: application/json" http://127.0.0.1/api/login -d '{"name":"mobinbeijing","pwd":"moB20071213","checkcode":123456}' -k
    final data = {"name": "mobinbeijing", "pwd": "moB20071213"};

    // 统一鉴权处理
    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        print('send request：path:${options.path}，baseURL:${options.baseUrl}');

        if (csrfToken == null) {
          print('no token，request token firstly...');

          final result = await tokenDio.post(auth_url, data: data);

          if (result.statusCode != null && result.statusCode! ~/ 100 == 2) {
            /// assume `token` is in response body
            // final body = jsonDecode(result.data) as Map<String, dynamic>?;
            // print(result.data.runtimeType);
            // print("=====================================");
            // print(result.headers["authorization"].runtimeType);
            // print(result.headers["authorization"]?.first);

            if (null != result.headers["authorization"]) {
              options.headers['authorization'] =
                  csrfToken = result.headers["authorization"]?.first;
              print('request token succeed, value: $csrfToken');
              print(
                'continue to perform request：path:${options.path}，baseURL:${options.path}',
              );

              // Map<String, Object> data = response_map['data'];
              // final prefs = await SharedPreferences.getInstance();
              // final setTokenResult = await prefs.setString('user_token', csrfToken);
              // await prefs.setInt('user_phone', data['phone']);
              // await prefs.setString('user_phone', data['name']);
              // if(setTokenResult){
              //     debugPrint('保存登录token成功');
              //     Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => route == null,);
              // }else{
              //     debugPrint('error, 保存登录token失败');
              // }

              return handler.next(options);
            }

            // final body={};
            // body["data"] = result.data;
            // if (body != null && body.containsKey('data')) {
            //   options.headers['csrfToken'] = csrfToken = body['data']['token'];
            //   // await SpUtil().set(tokenkey, csrfToken);
            //   print('request token succeed, value: $csrfToken');
            //   print(
            //     'continue to perform request：path:${options.path}，baseURL:${options.path}',
            //   );
            //   return handler.next(options);
            // }
          }

          return handler.reject(
            DioError(requestOptions: result.requestOptions),
            true,
          );
        }
        // options.headers['csrfToken'] = csrfToken;
        options.headers['authorization'] = csrfToken;

        return handler.next(options);
      },
      onError: (error, handler) async {
        /// Assume 401 stands for token expired
        ///假设401代表令牌过期
        if (error.response?.statusCode == 401) {
          print('the token has expired, need to receive new token');
          final options = error.response!.requestOptions;

          /// assume receiving the token has no errors
          /// to check `null-safety` and error handling
          /// please check inside the [onRequest] closure
          ///假设接收令牌没有错误
          ///检查“空安全”和错误处理
          ///请检查[onRequest]闭包内部
          final tokenResult = await tokenDio.post(auth_url, data: data);

          /// update [csrfToken]
          /// assume `token` is in response body
          ///更新[csrfToken]
          ///假定“token”在响应主体中
          // final body = jsonDecode(tokenResult.data) as Map<String, dynamic>?;
          // // final body={};
          // // body["data"] = tokenResult.data;
          // options.headers['csrfToken'] = csrfToken = body!['data']['token'];

          options.headers['authorization'] =
              csrfToken = tokenResult.headers["authorization"]?.first;

          // await SpUtil().set(tokenkey, csrfToken);
          // if (options.headers['csrfToken'] != null) {
          if (options.headers['authorization'] != null) {
            print('the token has been updated');

            /// since the api has no state, force to pass the 401 error
            /// by adding query parameter
            ///由于api没有状态，因此强制传递401错误
            ///通过添加查询参数
            final originResult = await dio.fetch(options..path += '&pass=true');
            if (originResult.statusCode != null &&
                originResult.statusCode! ~/ 100 == 2) {
              return handler.resolve(originResult);
            }
          }
          print('the token has not been updated');
          return handler.reject(
            DioError(requestOptions: options),
          );
        }
        return handler.next(error);
      },
    ));
    dio.interceptors.add(ResultJsonInterceptor());
    dio.interceptors.add(LogInterceptor(responseBody: true)); //Open log;


    try {
      final response = await dio.request(url,
          options: Options(method: methed), //baseUrl 可覆盖
          queryParameters: params,
          data: params);
      final data = response.data;
      return ResultJson.fromJson(data);
      // }
    } on DioError catch (e) {
      return ResultJson.fromJson({
        "success": false,
        "errorMessage": e.message,
        // errors: map['errors'] ?? [],
        "data": {"code": e.response?.statusCode}
      });

      return ResultJson.fromJson({
        "code": e.response?.statusCode,
        "errorMessage": e.message,
        "success": false,
      });
    }

  }

  //请求方法,
  String get methed => getMethod();

  String getMethod() {
    switch (httpMethod) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.patch:
        return 'PATCH';
      case HttpMethod.delete:
        return 'DELETE';
      default:
        return "POST";
    }
  }
}
