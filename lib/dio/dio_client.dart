// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Provider of [DioClient]
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

class DioClient {
  late final Dio _dio;
  DioClient()
      : _dio = Dio(
          BaseOptions(
              baseUrl:
                  "https://ap-southeast-1.aws.data.mongodb-api.com/app/data-rwkqd/endpoint/data/v1/",
              connectTimeout: Duration(seconds: 3),
              receiveTimeout: Duration(seconds: 3),
              headers: {
                'Content-Type': 'application/json',
                "apiKey":
                    "NStZZg11p6WqGHstqmHPbsf6VSaMLKcSlhBOA934rwyRS6JNnkKgS58DjxEoikSm",
                "Access-Control-Allow-Origin":
                    "https://ap-southeast-1.aws.data.mongodb-api.com",
                'Accept': '*/*'
              },
              responseType: ResponseType.json),
        )..interceptors
            .addAll([AuthorizationInterceptor(), LoggerInterceptor()]);

  // GET METHOD
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioError {
      rethrow;
    }
  }

  // POST METHOD
  Future<Response> post(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        url,
        data: data,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT METHOD
  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE METHOD
  Future<dynamic> delete(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final Response response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

/// This interceptor is used to show request and response logs
class LoggerInterceptor extends Interceptor {
  Logger logger =
      Logger(printer: PrettyPrinter(methodCount: 0, printTime: true));

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    logger.e('${options.method} request ==> $requestPath'); //Error log
    logger.d('Error type: ${err.error} \n '
        'Error message: ${err.message}'); //Debug log
    handler.next(err); //Continue with the Error
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('${options.method} request ==> $requestPath'); //Info log
    handler.next(options); // continue with the Request
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('STATUSCODE: ${response.statusCode} \n '
        'STATUSMESSAGE: ${response.statusMessage} \n'
        'HEADERS: ${response.headers} \n'
        'Data: ${response.data}'); // Debug log
    handler.next(response); // continue with the Response
  }
}

/// This interceptor intercepts GET request and add "Authorization" header
/// and then, send it to the [API]
class AuthorizationInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_needAuthorizationHeader(options)) {
      // adds the access-token with the header
      options.headers['Authorization'] =
          "HbWgnOGvcmb1dhhIoMF6aZc1JJjnWCXFpSAfp2JjsOjjtcCrHC8DhTIQU6pvrTFG";
    }
    handler.next(options); // continue with the request
  }

  bool _needAuthorizationHeader(RequestOptions options) {
    if (options.method == 'GET') {
      return true;
    }
    return false;
  }
}

enum ServerExceptionType {
  requestCancelled,

  badCertificate,

  unauthorisedRequest,

  connectionError,

  badRequest,

  notFound,

  requestTimeout,

  sendTimeout,

  recieveTimeout,

  conflict,

  internalServerError,

  notImplemented,

  serviceUnavailable,

  SocketException,

  formatException,

  unableToProcess,

  defaultError,

  unexpectedError,
}

class ServerException extends Equatable implements Exception {
  final String name, message;
  final int? statusCode;
  final ServerExceptionType exceptionType;

  ServerException._({
    required this.message,
    this.exceptionType = ServerExceptionType.unexpectedError,
    int? statusCode,
  })  : statusCode = statusCode ?? 500,
        name = exceptionType.name;

  factory ServerException(dynamic error) {
    late ServerException serverException;
    try {
      if (error is DioError) {
        switch (error.type) {
          case DioErrorType.cancel:
            serverException = ServerException._(
                exceptionType: ServerExceptionType.requestCancelled,
                statusCode: error.response?.statusCode,
                message: 'Request to the server has been canceled');
            break;

          case DioErrorType.connectionTimeout:
            serverException = ServerException._(
                exceptionType: ServerExceptionType.requestTimeout,
                statusCode: error.response?.statusCode,
                message: 'Connection timeout');
            break;

          case DioErrorType.receiveTimeout:
            serverException = ServerException._(
                exceptionType: ServerExceptionType.recieveTimeout,
                statusCode: error.response?.statusCode,
                message: 'Receive timeout');
            break;

          case DioErrorType.sendTimeout:
            serverException = ServerException._(
                exceptionType: ServerExceptionType.sendTimeout,
                statusCode: error.response?.statusCode,
                message: 'Send timeout');
            break;

          case DioErrorType.connectionError:
            serverException = ServerException._(
                exceptionType: ServerExceptionType.connectionError,
                message: 'Connection error');
            break;
          case DioErrorType.badCertificate:
            serverException = ServerException._(
                exceptionType: ServerExceptionType.badCertificate,
                message: 'Bad certificate');
            break;
          case DioErrorType.unknown:
            if (error.error
                .toString()
                .contains(ServerExceptionType.SocketException.name)) {
              serverException = ServerException._(
                  statusCode: error.response?.statusCode,
                  message: 'Verify your internet connection');
            } else {
              serverException = ServerException._(
                  exceptionType: ServerExceptionType.unexpectedError,
                  statusCode: error.response?.statusCode,
                  message: 'Unexpected error');
            }
            break;

          case DioErrorType.badResponse:
            switch (error.response?.statusCode) {
              case 400:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.badRequest,
                    message: 'Bad request.');
                break;
              case 401:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.unauthorisedRequest,
                    message: 'Authentication failure');
                break;
              case 403:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.unauthorisedRequest,
                    message: 'User is not authorized to access API');
                break;
              case 404:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.notFound,
                    message: 'Request ressource does not exist');
                break;
              case 405:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.unauthorisedRequest,
                    message: 'Operation not allowed');
                break;
              case 415:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.notImplemented,
                    message: 'Media type unsupported');
                break;
              case 422:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.unableToProcess,
                    message: 'validation data failure');
                break;
              case 429:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.conflict,
                    message: 'too much requests');
                break;
              case 500:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.internalServerError,
                    message: 'Internal server error');
                break;
              case 503:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.serviceUnavailable,
                    message: 'Service unavailable');
                break;
              default:
                serverException = ServerException._(
                    exceptionType: ServerExceptionType.unexpectedError,
                    message: 'Unexpected error');
            }
            break;
        }
      } else {
        serverException = ServerException._(
            exceptionType: ServerExceptionType.unexpectedError,
            message: 'Unexpected error');
      }
    } on FormatException catch (e) {
      serverException = ServerException._(
          exceptionType: ServerExceptionType.formatException,
          message: e.message);
    } on Exception catch (_) {
      serverException = ServerException._(
          exceptionType: ServerExceptionType.unexpectedError,
          message: 'Unexpected error');
    }
    return serverException;
  }

  @override
  List<Object?> get props => [name, statusCode, exceptionType];
}
