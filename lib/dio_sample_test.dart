

import 'dart:convert';

import 'dio_sample.dart';

// class RoomApi extends BaseApi {
//   RoomApi() : super('/users/1');
//   void setParam(String  jsonStr) => params.addAll(jsonDecode(jsonStr));
//
// }

class UsersApi extends BaseApi {
  UsersApi() : super('/users');
  void setParam(String  jsonStr) => params.addAll(jsonDecode(jsonStr));
}

class UserApi extends BaseApi {
  UserApi({required int id}) : super('/users/$id');
  void setParam(String  jsonStr) => params.addAll(jsonDecode(jsonStr));
}

class UserPutApi extends BaseApi {
  UserPutApi({required int id}) : super('/users/$id',httpMethod: HttpMethod.put);
  void setParam(String  jsonStr) => params.addAll(jsonDecode(jsonStr));
}

class UserDelApi extends BaseApi {
  UserDelApi({required int id}) : super('/users/$id',httpMethod: HttpMethod.delete);
}

class ResourcesApi extends BaseApi {
  ResourcesApi() : super('/unknown');
  void setParam(String  jsonStr) => params.addAll(jsonDecode(jsonStr));
}

class UserCreateApi extends BaseApi {
  UserCreateApi(): super('/users',httpMethod: HttpMethod.post);
  void setParam(String  jsonStr) => params.addAll(jsonDecode(jsonStr));
  // set setId(int roomId) => params['id'] = '$roomId';
  // void setId(int i) => params['id'] = '$i';
}


// 	curl    		-H "Authorization: Bearer ${jwt_token}" http://127.0.0.1/api/inventory/1-1
// class InveApi extends BaseApi {
//   InveApi() : super('/users');
//   void setParam(String  jsonStr) => params.addAll(jsonDecode(jsonStr));
// }

class InveApi extends BaseApi {
  InveApi({required String id}) : super('http://127.0.0.1/api/inventory/$id');
  void setParam(String  jsonStr) => params.addAll(jsonDecode(jsonStr));
}


void main() {
  // //增删改查 四种方法
  // //
  // UsersApi ra=UsersApi();
  // ra.setParam( '{"page": 2}');
  // ra.request().then((value) => print(value));
  // //
  // UserPutApi rpa=UserPutApi(id:2);
  // const jsonString = '{"name": "moy","job": "it leader"}';
  // rpa.setParam(jsonString);
  // rpa.request();
  
  // UserApi ua1=UserApi(id:2);
  // ua1.request();

  // UserDelApi ud1=UserDelApi(id:2);
  // ud1.request();
  
  // UserCreateApi uca=UserCreateApi();
  // const jsonString1 = '{"name": "moy_new","job": "it leader"}';
  // uca.setParam(jsonString1);
  // uca.request();

  // // 404异常
  // UserApi ua23=UserApi(id:23);
  // ua23.request().then((value) => print(value));

  // // 超时异常 TODO 自动重试
  // ResourcesApi resa=ResourcesApi();
  // resa.setParam( '{"page": 2,"delay":11}');
  // resa.request();

  InveApi inve=InveApi(id:"1-1");
  inve.request();

}
