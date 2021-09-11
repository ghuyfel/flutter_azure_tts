class Log {
  static bool _enabled = false;

  static void enable() => _enabled = true;

  static void disable() => _enabled = false;

  static bool get isEnabled => _enabled;
  static String package = "[flutter_azure_tts]";

  static void d(String message, [String? tag]) {
    if (isEnabled) print("$package -> ${tag ?? ""} : $message");
  }
}
