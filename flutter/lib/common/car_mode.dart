import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/models/platform_model.dart';

import '../common.dart';

/// Car mode adapts the mobile UI to wide, always-on car head units such as the
/// BYD DiLink used by the Dolphin. It is opt-in, but enabled automatically on
/// devices that report a BYD/DiLink build fingerprint.
class CarMode {
  CarMode._();

  static const optionKey = 'dilink-car-mode';
  static const double textScale = 1.1;

  static final ValueNotifier<bool> enabled = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> detected = ValueNotifier<bool>(false);

  static final UniqueKey wakelockKey = UniqueKey();

  static bool get isEnabled => enabled.value;

  /// Reads the persisted option and auto-detects the head unit on first run.
  static Future<void> init() async {
    if (!isAndroid) return;
    final stored = bind.mainGetLocalOption(key: optionKey);
    if (stored.isEmpty) {
      final look = await _deviceLooksLikeDiLink();
      detected.value = look;
      if (look) {
        enabled.value = true;
        await bind.mainSetLocalOption(key: optionKey, value: 'Y');
        await applySystemUi();
      }
      return;
    }
    enabled.value = stored == 'Y';
    if (enabled.value) {
      await applySystemUi();
    }
  }

  static Future<void> setEnabled(bool value) async {
    if (enabled.value == value) return;
    enabled.value = value;
    await bind.mainSetLocalOption(key: optionKey, value: value ? 'Y' : 'N');
    if (value) {
      await applySystemUi();
    } else {
      await restoreSystemUi();
    }
  }

  /// Immersive fullscreen plus keep-screen-on while car mode is active.
  static Future<void> applySystemUi() async {
    if (!isAndroid || !enabled.value) return;
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {}
    WakelockManager.enable(wakelockKey, isServer: true);
  }

  static Future<void> restoreSystemUi() async {
    if (!isAndroid) return;
    WakelockManager.disable(wakelockKey);
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    } catch (_) {}
  }

  static Future<bool> _deviceLooksLikeDiLink() async {
    try {
      final info =
          await platformFFI.invokeMethodWithResult<Map>('get_device_info');
      return looksLikeDiLink(info);
    } catch (_) {
      return false;
    }
  }

  static bool looksLikeDiLink(Map? info) {
    if (info == null) return false;
    final text = [
      info['manufacturer'],
      info['brand'],
      info['model'],
      info['device'],
      info['product'],
    ].whereType<String>().join(' ').toLowerCase();
    if (text.isEmpty) return false;
    final tokens = text.split(RegExp(r'[^a-z0-9]+'));
    return tokens.contains('byd') ||
        tokens.contains('dilink') ||
        tokens.contains('denza') ||
        tokens.contains('yangwang') ||
        text.contains('dilink');
  }
}
