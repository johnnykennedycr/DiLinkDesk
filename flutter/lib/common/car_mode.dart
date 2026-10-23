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
  static const fullscreenOptionKey = 'dilink-fullscreen';
  static const double textScale = 1.1;

  static final ValueNotifier<bool> enabled = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> detected = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> fullscreen = ValueNotifier<bool>(true);

  static final UniqueKey wakelockKey = UniqueKey();

  static bool get isEnabled => enabled.value;
  static bool get isFullscreen => fullscreen.value;

  /// Reads the persisted options and auto-detects the head unit on first run.
  static Future<void> init() async {
    if (!isAndroid) return;
    final stored = bind.mainGetLocalOption(key: optionKey);
    if (stored.isEmpty) {
      final look = await _deviceLooksLikeDiLink();
      detected.value = look;
      if (look) {
        enabled.value = true;
        await bind.mainSetLocalOption(key: optionKey, value: 'Y');
      }
    } else {
      enabled.value = stored == 'Y';
    }
    final storedFullscreen = bind.mainGetLocalOption(key: fullscreenOptionKey);
    fullscreen.value =
        storedFullscreen.isEmpty ? enabled.value : storedFullscreen == 'Y';
    await applyAll();
  }

  static Future<void> setEnabled(bool value) async {
    if (enabled.value == value) return;
    enabled.value = value;
    await bind.mainSetLocalOption(key: optionKey, value: value ? 'Y' : 'N');
    applyWakelock();
  }

  static Future<void> setFullscreen(bool value) async {
    if (fullscreen.value == value) return;
    fullscreen.value = value;
    await bind.mainSetLocalOption(
        key: fullscreenOptionKey, value: value ? 'Y' : 'N');
    await applySystemUi();
  }

  static Future<void> applyAll() async {
    await applySystemUi();
    applyWakelock();
  }

  /// Hides the DiLink status and navigation bars when fullscreen is enabled.
  static Future<void> applySystemUi() async {
    if (!isAndroid) return;
    try {
      if (fullscreen.value) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values);
      }
    } catch (_) {}
  }

  /// Keeps the screen on while car mode is active.
  static void applyWakelock() {
    if (!isAndroid) return;
    if (enabled.value) {
      WakelockManager.enable(wakelockKey, isServer: true);
    } else {
      WakelockManager.disable(wakelockKey);
    }
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
