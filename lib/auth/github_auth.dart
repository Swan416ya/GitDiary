import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubAuth {
  static const String _clientId = 'Ov23liCohDjUZc6JUyD7';
  static const String _scopes = 'repo';
  static const String _apiVersion = '2022-11-28';

  // CORS 代理（解决浏览器跨域问题）
  static const String _corsProxy = 'https://corsproxy.io/?url=';

  static String _proxy(String url) {
    return '$_corsProxy${Uri.encodeComponent(url)}';
  }

  static String get clientId => _clientId;

  // Device Flow - 第一步：请求 device code
  static Future<Map<String, dynamic>> requestDeviceCode() async {
    final response = await http.post(
      Uri.parse(_proxy('https://github.com/login/device/code')),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'client_id': _clientId,
        'scope': _scopes,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Device code 响应: $data');
      return data;
    } else {
      throw Exception('请求 device code 失败: ${response.statusCode} - ${response.body}');
    }
  }

  // Device Flow - 轮询获取 token
  static Future<String?> pollForToken(String deviceCode, int interval) async {
    while (true) {
      await Future.delayed(Duration(seconds: interval));

      final response = await http.post(
        Uri.parse(_proxy('https://github.com/login/oauth/access_token')),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'client_id': _clientId,
          'device_code': deviceCode,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        }),
      );

      final data = json.decode(response.body);

      if (data['access_token'] != null) {
        return data['access_token'] as String;
      }

      final error = data['error'] as String?;
      if (error == 'authorization_pending') {
        continue;
      } else if (error == 'slow_down') {
        final newInterval = data['interval'] as int? ?? interval + 5;
        await Future.delayed(Duration(seconds: newInterval));
        continue;
      } else if (error == 'expired_token') {
        throw Exception('授权码已过期，请重新登录');
      } else if (error == 'access_denied') {
        throw Exception('用户取消了授权');
      } else {
        throw Exception('获取 token 失败: ${data['error_description'] ?? error}');
      }
    }
  }

  // 获取用户信息
  static Future<Map<String, dynamic>> getUserInfo(String token) async {
    final response = await http.get(
      Uri.parse(_proxy('https://api.github.com/user')),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': _apiVersion,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('获取用户信息失败: ${response.statusCode} - ${response.body}');
    }
  }

  // 列出仓库中某个目录下的文件
  static Future<List<Map<String, dynamic>>> listRepoContents(
    String token,
    String owner,
    String repo,
    String path,
  ) async {
    final response = await http.get(
      Uri.parse(_proxy('https://api.github.com/repos/$owner/$repo/contents/$path')),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': _apiVersion,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('获取目录内容失败: ${response.statusCode}');
    }
  }

  // 获取单个文件内容
  static Future<String?> getFileContent(
    String token,
    String owner,
    String repo,
    String path,
  ) async {
    final response = await http.get(
      Uri.parse(_proxy('https://api.github.com/repos/$owner/$repo/contents/$path')),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': _apiVersion,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['content'] as String?;
      if (content != null) {
        // GitHub 返回 base64 编码的内容
        final cleaned = content.replaceAll('\n', '');
        return utf8.decode(base64.decode(cleaned));
      }
      return null;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('获取文件失败: ${response.statusCode}');
    }
  }

  // 获取文件的 sha（用于更新文件时指定版本）
  static Future<String?> getFileSha(
    String token,
    String owner,
    String repo,
    String path,
  ) async {
    final response = await http.get(
      Uri.parse(_proxy('https://api.github.com/repos/$owner/$repo/contents/$path')),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': _apiVersion,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['sha'] as String?;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('获取文件 sha 失败: ${response.statusCode}');
    }
  }

  // 创建或更新文件（以 GitDiary bot 身份提交，不污染用户热力图）
  static Future<void> createOrUpdateFile(
    String token,
    String owner,
    String repo,
    String path,
    String content,
    String commitMessage, {
    String? sha,
  }) async {
    final body = <String, dynamic>{
      'message': commitMessage,
      'content': base64.encode(utf8.encode(content)),
      'branch': 'main',
      'author': {
        'name': 'GitDiary',
        'email': 'gitdiary-bot@users.noreply.github.com',
      },
      'committer': {
        'name': 'GitDiary',
        'email': 'gitdiary-bot@users.noreply.github.com',
      },
    };
    if (sha != null) {
      body['sha'] = sha;
    }

    final response = await http.put(
      Uri.parse(_proxy('https://api.github.com/repos/$owner/$repo/contents/$path')),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': _apiVersion,
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('保存文件失败: ${response.statusCode} - ${response.body}');
    }
  }

  // 列出用户的所有仓库
  static Future<List<Map<String, dynamic>>> listRepos(String token) async {
    List<Map<String, dynamic>> allRepos = [];
    int page = 1;

    while (true) {
      final response = await http.get(
        Uri.parse(_proxy('https://api.github.com/user/repos?per_page=100&page=$page&sort=updated')),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': _apiVersion,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> repos = json.decode(response.body);
        if (repos.isEmpty) break;
        allRepos.addAll(repos.cast<Map<String, dynamic>>());
        if (repos.length < 100) break;
        page++;
      } else {
        throw Exception('获取仓库列表失败: ${response.statusCode}');
      }
    }

    return allRepos;
  }

  // 创建新仓库
  static Future<Map<String, dynamic>> createRepo(
    String token,
    String name, {
    String description = '',
    bool isPrivate = true,
  }) async {
    final response = await http.post(
      Uri.parse(_proxy('https://api.github.com/user/repos')),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': _apiVersion,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'description': description.isEmpty
            ? 'My personal diary (auto-created by GitDiary)'
            : description,
        'private': isPrivate,
        'auto_init': true,
        'has_issues': false,
        'has_projects': false,
        'has_wiki': false,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 422) {
      throw Exception('仓库已存在');
    } else {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? '创建仓库失败');
    }
  }
}
