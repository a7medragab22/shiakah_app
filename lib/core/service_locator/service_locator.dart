import '../../features/auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../extensions/extensions.dart';
import 'package:get_it/get_it.dart';

import '../../main.dart';
import '../helpers/helpers.dart';
import '../http/http.dart';
import '../local_storage/local_storage.dart';
import 'scanner/scanner.dart';
import '../../features/home/blocs/wardrobe_scanner/wardrobe_scanner_bloc.dart';
import '../../features/home/data/services/wardrobe_remote_data_source.dart';
import '../../features/home/data/services/outfit_remote_data_source.dart';
import '../../features/home/blocs/add_to_closet/add_to_closet_cubit.dart';
import '../../features/home/blocs/my_closet/my_closet_cubit.dart';
import '../../features/home/blocs/my_looks/my_looks_cubit.dart';

export 'scanner/scanner.dart';
export '../../features/home/blocs/wardrobe_scanner/wardrobe_scanner_bloc.dart';
export '../../features/home/data/models/add_to_closet_response_model.dart';
export '../../features/home/data/models/my_closet_response_model.dart';
export '../../features/home/data/models/my_looks_response_model.dart';
export '../../features/home/data/services/wardrobe_remote_data_source.dart';
export '../../features/home/data/services/outfit_remote_data_source.dart';
export '../../features/home/blocs/add_to_closet/add_to_closet_cubit.dart';
export '../../features/home/blocs/my_closet/my_closet_cubit.dart';
export '../../features/home/blocs/my_looks/my_looks_cubit.dart';

part 'init/init.dart';
part 'auth_service_locator/auth_service_locator.dart';
part 'shared_service_locator/shared_service_locator.dart';
part 'hive_service_locator/hive_service_locator.dart';
part 'scanner_service_locator/scanner_service_locator.dart';
