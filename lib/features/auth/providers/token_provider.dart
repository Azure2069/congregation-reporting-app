import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/api/api_client.dart';

final authTokenProvider = StateProvider<String?>((ref) => null);