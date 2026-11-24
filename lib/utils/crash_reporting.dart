import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Pelaporan error ke Firebase Crashlytics.
///
/// Dashboard: Firebase Console > project viva-kencana-apps-425bf > Crashlytics.
class CrashReporting {
  CrashReporting._();

  static bool _enabled = false;

  /// Firebase hanya dikonfigurasi untuk Android dan iOS (lib/firebase_options.dart).
  static bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Dipanggil sekali di main(), setelah WidgetsFlutterBinding.ensureInitialized().
  ///
  /// Laporan hanya dikirim dari build release/profile, supaya error saat
  /// development tidak memenuhi dashboard.
  static Future<void> init() async {
    if (!_supported) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );

      /// Error dari framework Flutter (build, layout, gesture, ...).
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      /// Error async yang tidak tertangkap di luar framework Flutter.
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      _enabled = true;
    } catch (e, s) {
      /// Gagal inisialisasi Firebase tidak boleh membuat aplikasi tidak jalan.
      debugPrint('CrashReporting.init gagal: $e\n$s');
    }
  }

  /// Catat error yang sudah ditangkap (non-fatal), misalnya kegagalan API.
  /// [reason] tampil di dashboard sebagai keterangan singkat.
  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
  }) async {
    if (!_enabled) return;
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
    );
  }

  /// Tandai laporan dengan user yang sedang login. Kosongkan saat logout.
  static Future<void> setUser(String userId) async {
    if (!_enabled) return;
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Konteks tambahan yang ikut tampil di setiap laporan (tab "Keys").
  static Future<void> setKey(String key, Object value) async {
    if (!_enabled) return;
    await FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  /// Catatan singkat yang ikut tampil di laporan berikutnya (tab "Logs").
  static void log(String message) {
    if (!_enabled) return;
    FirebaseCrashlytics.instance.log(message);
  }
}
