import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vivakencanaapp/bloc/approval_pr/approval_pr_department/approval_pr_department_bloc.dart';
import 'package:vivakencanaapp/bloc/approval_pr/approval_pr_list/approval_pr_list_bloc.dart';
import 'package:vivakencanaapp/bloc/approval_pr/approve_pr/approve_pr_bloc.dart';
import 'package:vivakencanaapp/bloc/stock_opname/mill/mill_bloc.dart';
import 'package:vivakencanaapp/data/data_providers/rest_api/approval/approval_pr_rest.dart';

import 'package:vivakencanaapp/bloc/authorization/credentials/credentials_bloc.dart';
import 'package:vivakencanaapp/data/repository/approval_pr_repository.dart';
import 'package:vivakencanaapp/data/repository/stock_opname/mill_repository.dart';
import 'package:vivakencanaapp/data/repository/stock_opname/opname_stock_dtl_repository.dart';
import 'package:vivakencanaapp/models/stock_opname/stock_opname_hdr.dart';

import 'bloc/auth/authentication/authentication_bloc.dart';
import 'bloc/sales_activity/checkin/sales_activity_form_checkin_bloc.dart';
import 'bloc/sales_activity/history_visit/history_visit_detail/list_image/sales_activity_history_visit_detail_list_image_bloc.dart';
import 'bloc/sales_activity/history_visit/history_visit_detail/sales_activity_history_visit_detail_bloc.dart';
import 'bloc/sales_activity/history_visit/history_visit_detail/upload_image/sales_activity_history_visit_upload_image_bloc.dart';
import 'bloc/sales_activity/history_visit/sales_activity_history_visit_bloc.dart';
import 'bloc/sales_activity/sales_activity_form_bloc.dart';
import 'bloc/stock_opname/stock_opname_dtl/stock_opname_dtl_bloc.dart';
import 'bloc/stock_opname/stock_opname_hdr/stock_opname_hdr_bloc.dart';
import 'bloc/update/update_bloc.dart';
import 'data/data_providers/rest_api/auth_rest.dart';
import 'data/data_providers/rest_api/authorization_rest/authorization_rest.dart';
import 'data/data_providers/rest_api/batch_rest/batch_rest.dart';
import 'data/data_providers/rest_api/entity_rest/entity_rest.dart';
import 'data/data_providers/rest_api/sales_activity_rest/sales_activity_rest.dart';
import 'data/data_providers/rest_api/stock_opname/mill_rest.dart';
import 'data/data_providers/rest_api/stock_opname/opname_stock_dtl_rest.dart';
import 'data/data_providers/rest_api/stock_opname/opname_stock_hdr_rest.dart';
import 'data/data_providers/shared-preferences/shared_preferences_key.dart';
import 'data/data_providers/shared-preferences/shared_preferences_manager.dart';
import 'data/repository/auth_repository.dart';
import 'data/repository/authorization_repository.dart';
import 'data/repository/batch_repository.dart';
import 'data/repository/entity_repository.dart';
import 'data/repository/sales_repository.dart';
import 'data/repository/stock_opname/opname_stock_hdr_repository.dart';
import 'environment.dart';
import 'presentation/entity/entity_screen.dart';
import 'presentation/login/login_form_screen.dart';
import 'utils/interceptors/dio_request_token_interceptor.dart';
import 'utils/sales_activity/sales_activity_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  SalesActivitySyncService().syncPendingActivities();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  final authSharedPref = SharedPreferencesManager(
    key: SharedPreferencesKey.authKey,
  );

  final authClient = Dio(AuthEnvironment.dioBaseOptions)
    ..interceptors.addAll([DioRequestTokenInterceptor()]);
  final dioClient = Dio(Environment.dioBaseOptions)
    ..interceptors.addAll([DioRequestTokenInterceptor()]);
  final tesClient = Dio(Environment.dioBaseOptions)
    // Aktifkan untuk Production
    // final tesClient = Dio(DevEnvironment.dioBaseOptions)
    // Aktifkan untuk Test Development
    ..interceptors.addAll([DioRequestTokenInterceptor()]);
  final kmbClient = Dio(KmbEnvironment.dioBaseOptions)
    ..interceptors.addAll([DioRequestTokenInterceptor()]);
  final androidKencanaClient = Dio(AndroidKencanaEnvironment.dioBaseOptions)
    ..interceptors.addAll([DioRequestTokenInterceptor()]);

  final authRest = AuthRest(authClient);
  final batchRest = BatchRest(dioClient);
  final entityRest = EntityRest(dioClient);
  final authorizationRest = AuthorizationRest(authClient);
  final salesActivityRest = SalesActivityRest(dioClient);
  final approvalPrRest = ApprovalPRRest(tesClient);
  final millRest = MillRest(kmbClient);
  final opnameStockHdrRest = OpnameStockHdrRest(androidKencanaClient);
  final opnameStockDtlRest = OpnameStockDtlRest(androidKencanaClient);

  final authRepository = AuthRepository(
    authRest: authRest,
    authSharedPref: authSharedPref,
  );
  final batchRepository = BatchRepository(batchRest: batchRest);
  final entityRepository = EntityRepository(entityRest: entityRest);
  final authorizationRepository = AuthorizationRepository(
    authorizationRest: authorizationRest,
  );
  final salesActivityRepository = SalesActivityRepository(
    salesActivityRest: salesActivityRest,
  );
  final approvalPrRepository = ApprovalPRRepository(
    approvalPRRest: approvalPrRest,
  );
  final millRepository = MillRepository(millRest: millRest);
  final opnameStockHdrRepository = OpnameStockHdrRepository(opnameStockHdrRest);
  final opnameStockDtlRepository = OpnameStockDtlRepository(opnameStockDtlRest);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: batchRepository),
        RepositoryProvider.value(value: entityRepository),
        RepositoryProvider.value(value: authorizationRepository),
        RepositoryProvider.value(value: salesActivityRepository),
        RepositoryProvider.value(value: approvalPrRepository),
        RepositoryProvider.value(value: millRepository),
        RepositoryProvider.value(value: opnameStockHdrRepository),
        RepositoryProvider.value(value: opnameStockDtlRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(lazy: false, create: (context) => AuthenticationBloc()),
          BlocProvider(
            lazy: false,
            create: (context) => UpdateBloc()..add(CheckForUpdate()),
          ),
          BlocProvider(
            lazy: false,
            create:
                (context) => SalesActivityFormBloc(
                  salesActivityRepository: salesActivityRepository,
                ),
          ),
          BlocProvider(
            lazy: false,
            create:
                (context) => SalesActivityFormCheckInBloc(
                  salesActivityRepository: salesActivityRepository,
                ),
          ),
          BlocProvider(
            lazy: false,
            create:
                (context) => SalesActivityHistoryVisitBloc(
                  salesActivityRepository: salesActivityRepository,
                ),
          ),
          BlocProvider(
            lazy: false,
            create:
                (context) => SalesActivityHistoryVisitDetailBloc(
                  salesActivityRepository: salesActivityRepository,
                ),
          ),
          BlocProvider(
            lazy: false,
            create:
                (context) => SalesActivityHistoryVisitUploadImageBloc(
                  salesActivityRepository: salesActivityRepository,
                ),
          ),
          BlocProvider(
            lazy: false,
            create:
                (context) => SalesActivityHistoryVisitDetailListImageBloc(
                  salesActivityRepository: salesActivityRepository,
                ),
          ),
          BlocProvider(
            lazy: false,
            create:
                (context) => CredentialsBloc(
                  authorizationRepository: authorizationRepository,
                ),
          ),
          BlocProvider(
            lazy: false,
            create:
                (context) => ApprovalPrDepartmentBloc(
                  approvalPRRepository: approvalPrRepository,
                ),
          ),
          BlocProvider(
            lazy: false,
            create:
                (context) => ApprovalPrListBloc(
                  approvalPRRepository: approvalPrRepository,
                ),
          ),
          BlocProvider(
            lazy: false,
            create:
                (context) =>
                    ApprovePrBloc(approvalPRRepository: approvalPrRepository),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => MillBloc(millRepository: millRepository),
          ),
          BlocProvider(
            lazy: false,
            create:
                (context) => OpnameStockHdrBloc(
                  opnameStockHdrRepository: opnameStockHdrRepository,
                ),
          ),
          BlocProvider(
            lazy: false,
            create:
                (context) => StockOpnameDtlBloc(
                  opnamestockdtlrepository: opnameStockDtlRepository,
                ),
          ),
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
              primaryColor: Color(0xff570DE6),
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
                } else if (state is UpdateDownloaded) {
                  Navigator.pop(context);
                  OpenFile.open(state.filePath);
                } else if (state is UpdateError) {
                  Navigator.pop(context);
                  _showErrorDialog(context, state.message);
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
          (_) => PopScope(
            canPop: false,
            child: AlertDialog(
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

    context.read<UpdateBloc>().add(DownloadUpdate(state.apkUrl));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(
                "Sedang Memperbarui…",
                style: TextStyle(fontSize: 16.w),
              ),
              content: BlocBuilder<UpdateBloc, UpdateState>(
                buildWhen: (prev, curr) => curr is UpdateDownloading,
                builder: (context, state) {
                  double progress = 0.0;
                  if (state is UpdateDownloading) {
                    progress = state.progress;
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 12),
                      Text("${(progress * 100).toStringAsFixed(0)}%"),
                    ],
                  );
                },
              ),
            ),
          ),
    );
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
