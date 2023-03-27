import 'dart:convert';

import 'package:dio/dio.dart';

//在实际场景中，拦截器可用于使用JSON Web Tokens (JWT)进行授权、解析 JSON、处理错误以及轻松调试 Dio 网络请求。
class ResultJsonInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 如果你想完成请求并返回一些自定义数据，你可以使用 `handler.resolve(response)`。
    // 如果你想终止请求并触发一个错误,你可以使用 `handler.reject(error)`。

    print('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
    // return handler.next(options);
  }

  //正常响应走这个函数 规范统一返回Json数据格式
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 如果你想终止请求并触发一个错误,你可以使用 `handler.reject(error)`。

    print(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );

    if (response.data != null) {
      // print(response.data);
      //多策略统一处理response;
      if (response.data.runtimeType == String) {
        final resdata = jsonDecode(response.data);
        if (resdata['data'] == null) {
          final Map<String, dynamic> data = <String, dynamic>{};
          data["data"] = resdata;
          response.data = data;
        }
      }
    }

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      response.data = response.data ?? <String, dynamic>{};
      response.data['success'] = response.data['success'] ?? true;
    }
    if (response.statusCode == 404) {
      response.data = response.data ?? <String, dynamic>{};
      response.data['errorMessage'] = '数据不存在!';
    }

    if (response.statusCode == 400) {
      response.data = response.data ?? <String, dynamic>{};
      response.data['errorMessage'] = response.data['error'];
    }


    return super.onResponse(response, handler);
  }

  //异常走这个函数
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // 如果你想完成请求并返回一些自定义数据，你可以使用 `handler.resolve(response)`。

    print(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    print(err);
    // print(err.response?.statusCode);
    // print(err.response.runtimeType);
    // if(err.response?.data=='{}'){
    //   err.response?.data=null;
    // }

    // handler.resolve(
    //   Response(
    //     requestOptions: err.requestOptions,
    //     data: null,
    //   ),
    // );

    // final Map<String, dynamic> data = <String, dynamic>{};
    // data['errorMessage'] = err.message;
    // data['success'] = false;
    // handler.resolve(
    //   Response(
    //     requestOptions: err.requestOptions,
    //     data: data,
    //   ),
    // );
    // handler.next(err);
    // return handler.resolve('err.response');
    // handler.next(err);

    return super.onError(err, handler);
    // return handler.next(err);
  }
}
