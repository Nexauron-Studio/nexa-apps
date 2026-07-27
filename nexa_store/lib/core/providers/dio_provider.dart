import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_store/core/dio/dio_client.dart';

final dioProvider = Provider<Dio>((ref) => DioClient.instance);
