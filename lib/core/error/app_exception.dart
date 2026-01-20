import 'package:dio/dio.dart';

abstract class AppException implements Exception {
  final String message;
  final String userFriendlyMessage;

  const AppException(this.message, this.userFriendlyMessage);

  @override
  String toString() => message;
}

class NoInternetException extends AppException {
  const NoInternetException()
      : super(
          'No internet connection',
          'No hay conexión a internet. Por favor, verifica tu conexión e intenta nuevamente.',
        );
}

class TimeoutException extends AppException {
  const TimeoutException()
      : super(
          'Request timeout',
          'La solicitud tardó demasiado. Por favor, intenta nuevamente.',
        );
}

class ServerException extends AppException {
  const ServerException([String? message])
      : super(
          message ?? 'Server error',
          'Ocurrió un error en el servidor. Por favor, intenta más tarde.',
        );
}

class NetworkException extends AppException {
  const NetworkException([String? message])
      : super(
          message ?? 'Network error',
          'Error de red. Por favor, verifica tu conexión.',
        );
}

class UnknownException extends AppException {
  const UnknownException([String? message])
      : super(
          message ?? 'Unknown error',
          'Ocurrió un error inesperado. Por favor, intenta nuevamente.',
        );
}

class AppExceptionHandler {
  static AppException handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NoInternetException();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null && statusCode >= 500) {
          return const ServerException();
        }
        return NetworkException(
          'Error ${statusCode ?? 'desconocido'}: ${error.response?.statusMessage ?? 'Sin respuesta'}',
        );

      case DioExceptionType.cancel:
        return const UnknownException('Solicitud cancelada');

      case DioExceptionType.badCertificate:
        return const NetworkException('Certificado SSL inválido');

      case DioExceptionType.unknown:
        if (error.error != null && error.error.toString().contains('SocketException')) {
          return const NoInternetException();
        }
        return UnknownException(error.message);
    }
  }

  static AppException handleException(dynamic error) {
    if (error is DioException) {
      return handleDioException(error);
    }
    if (error is AppException) {
      return error;
    }
    return UnknownException(error.toString());
  }
}
