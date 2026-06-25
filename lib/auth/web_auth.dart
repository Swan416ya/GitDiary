import 'package:flutter/foundation.dart';

/// Web 端专用的 GitHub OAuth 工具
/// 由于 dart:html 只能在 web 平台使用，我们提供一个跨平台的接口
class WebAuth {
  /// 从当前页面 URL 的 fragment 中获取 token
  /// 只在 web 端有效，其他平台返回 null
  static String? getTokenFromUrlFragment() {
    if (!kIsWeb) return null;
    // 这里实际会使用 dart:html 来获取 window.location.hash
    // 但由于条件编译，我们需要在 web 专用的文件中实现
    return null;
  }
}
