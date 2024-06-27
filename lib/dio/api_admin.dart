// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';

import 'dio_client.dart';

class RemoteDataSourceImpl {
  final DioClient dioClient;
  RemoteDataSourceImpl({required this.dioClient});

  Future getAdmin() async {
    try {
      final response = await dioClient.post("action/findOne", data: {
        "collection": "user_admin",
        "database": "appClone",
        "dataSource": "app-clone",
        "filter": {"_id": "65d30c86c716ab63a211158b"}
      });
      if (response.statusCode == 200) {
        final list = response.data['document'];
        return list;
      } else {
        throw ServerException(response);
      }
    } on DioError catch (e) {
      throw ServerException(e);
    }
  }

  Future updateAdmin(String pass) async {
    try {
      final response = await dioClient.post("action/updateOne", data: {
        "collection": "user_admin",
        "database": "appClone",
        "dataSource": "app-clone",
        "filter": {"_id": "65d30c86c716ab63a211158b"},
        "update": {
          "\$set": {"pass": pass}
        }
      });
      if (response.statusCode == 200) {
        final list = response.data['document'];
        return list;
      } else {
        throw ServerException(response);
      }
    } on DioError catch (e) {
      throw ServerException(e);
    }
  }

  Future getListApp() async {
    try {
      final response = await dioClient.post(
        "action/find",
        data: {
          "collection": "app_clone",
          "database": "appClone",
          "dataSource": "app-clone"
        },
      );
      if (response.statusCode == 200) {
        final list = response.data['documents'] as List;
        return list;
      } else {
        throw ServerException(response);
      }
    } on DioError catch (e) {
      throw ServerException(e);
    }
  }

  Future updateItem(String id, String url, bool superApp) async {
    try {
      final response = await dioClient.post(
        "action/updateOne",
        data: {
          "collection": "app_clone",
          "database": "appClone",
          "dataSource": "app-clone",
          "filter": {"_id": id},
          "update": {
            "\$set": {"h5": url, "super": superApp}
          }
        },
      );
      if (response.statusCode == 200) {
        final list = response.data['document'];
        return list;
      } else {
        throw ServerException(response);
      }
    } on DioError catch (e) {
      throw ServerException(e);
    }
  }
}
