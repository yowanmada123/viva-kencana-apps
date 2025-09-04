import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'bloc/auth/authentication/authentication_bloc.dart';
import 'bloc/sales_activity/checkin/sales_activity_form_checkin_bloc.dart';
import 'bloc/sales_activity/history_visit/history_visit_detail/sales_activity_history_visit_detail_bloc.dart';
import 'bloc/sales_activity/history_visit/sales_activity_history_visit_bloc.dart';
import 'bloc/sales_activity/sales_activity_form_bloc.dart';
import 'bloc/update/update_bloc.dart';
import 'data/data_providers/rest_api/auth_rest.dart';
import 'data/data_providers/rest_api/authorization_rest/authorization_rest.dart';
import 'data/data_providers/rest_api/batch_rest/batch_rest.dart';
import 'data/data_providers/rest_api/entity_rest/entity_rest.dart';
import 'data/data_providers/rest_api/sales_activity_rest/sales_activity_rest.dart';
import 'data/data_providers/shared-preferences/shared_preferences_key.dart';
import 'data/data_providers/shared-preferences/shared_preferences_manager.dart';
import 'data/repository/auth_repository.dart';
import 'data/repository/authorization_repository.dart';
import 'data/repository/batch_repository.dart';
import 'data/repository/entity_repository.dart';
import 'data/repository/sales_repository.dart';
import 'environment.dart';
import 'presentation/entity/entity_screen.dart';
import 'presentation/login/login_form_screen.dart';
import 'utils/interceptors/dio_request_token_interceptor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  final authSharedPref = SharedPreferencesManager(
    key: SharedPreferencesKey.authKey,
  );

  final dioClient = Dio(Environment.dioBaseOptions)
    ..interceptors.addAll([DioRequestTokenInterceptor()]);

  final authRest = AuthRest(dioClient);
  final batchRest = BatchRest(dioClient);
  final entityRest = EntityRest(dioClient);
  final authorizationRest = AuthorizationRest(dioClient);
  final salesActivityRest = SalesActivityRest(dioClient);

  final authRepository = AuthRepository(
    authRest: authRest,
    authSharedPref: authSharedPref,
  );
  final batchRepository = BatchRepository(batchRest: batchRest);
  final entityRepository = EntityRepository(entityRest: entityRest);
  final authorizationRepository = AuthorizationRepository(authorizationRest: authorizationRest);
  final salesActivityRepository = SalesActivityRepository(salesActivityRest: salesActivityRest);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: batchRepository),
        RepositoryProvider.value(value: entityRepository),
        RepositoryProvider.value(value: authorizationRepository),
        RepositoryProvider.value(value: salesActivityRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(lazy: false, create: (context) => AuthenticationBloc()),
          BlocProvider(lazy: false, create: (context) => UpdateBloc()..add(CheckForUpdate())),
          BlocProvider(lazy: false, create: (context) => SalesActivityFormBloc(salesActivityRepository: salesActivityRepository)),
          BlocProvider(lazy: false, create: (context) => SalesActivityFormCheckInBloc(salesActivityRepository: salesActivityRepository)),
          BlocProvider(lazy: false, create: (context) => SalesActivityHistoryVisitBloc(salesActivityRepository: salesActivityRepository)),
          BlocProvider(lazy: false, create: (context) => SalesActivityHistoryVisitDetailBloc(salesActivityRepository: salesActivityRepository)),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder:
          (context, widget) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Viva Kencana Ekspedisi',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              primaryColor: Color(0xff1E4694),
              hintColor: Color(0xffF1F1F1),
              disabledColor: Color(0xff808186),
              secondaryHeaderColor: Color(0xff575353),
              fontFamily: "Poppins",
              textTheme: TextTheme(
                labelSmall: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12,
                ),
                labelMedium: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                ),
                labelLarge: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                headlineLarge: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            home: BlocListener<UpdateBloc, UpdateState>(
              listener: (context, state) {
                if (state is UpdateAvailable) {
                  _showUpdateDialog(context, state);
                }
              },
              child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    // final user = state.user;
                    if (true) {
                      return EntityScreen();
                    }
                  }
                  return LoginFormScreen();
                },
              ),
            ),
          ),
    );
  }

  void _showUpdateDialog(BuildContext context, UpdateAvailable state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Update Tersedia'),
            content: Text(
              'Versi ${state.latestVersion} tersedia:\n\n${state.updateNotes}',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => _handleUpdate(context, state),
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleUpdate(
    BuildContext context,
    UpdateAvailable state,
  ) async {
    Navigator.pop(context);

    if (!await _checkStoragePermission(context)) return;

    if (!await _checkInstallPermission(context)) return;

    await _downloadAndInstallUpdate(context, state);
  }

  Future<bool> _checkStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        final status = await Permission.manageExternalStorage.request();
        if (status.isGranted) return true;
      } else {
        final status = await Permission.storage.request();
        if (status.isGranted) return true;
      }

      _showErrorDialog(context, 'Izin penyimpanan tidak diberikan.');
      return false;
    }

    return true;
  }

  Future<bool> _checkInstallPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 26) {
        final status = await Permission.requestInstallPackages.request();
        if (status.isGranted) return true;

        _showErrorDialog(
          context,
          'Izin install dari sumber tidak dikenal tidak diberikan.',
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _downloadAndInstallUpdate(
    BuildContext context,
    UpdateAvailable state,
  ) async {
    try {
      final tempDir = await getExternalStorageDirectory();
      final filePath = '${tempDir!.path}/update.apk';

      await Dio().download(
        state.apkUrl,
        filePath,
        options: Options(receiveTimeout: const Duration(seconds: 300)),
      );

      await OpenFile.open(filePath);
    } catch (e) {
      _showErrorDialog(context, 'Gagal mengunduh update: ${e.toString()}');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
