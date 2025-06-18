import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:filmflow/core/config/env_config.dart';
import 'package:filmflow/core/utils/validation_helper.dart';

void main() {
  group('Security Tests', () {
    setUpAll(() async {
      // テスト環境でdotenvを初期化
      dotenv.testLoad(fileInput: '''
TMDB_API_KEY=testtmdbapikeyforsecuritytesting32chars
TMDB_BASE_URL=https://api.themoviedb.org/3
FIREBASE_PROJECT_ID=test-project-id
''');
    });

    test('Environment configuration security validation', () {
      // 実際の環境設定のセキュリティ検証
      expect(EnvConfig.tmdbApiKey, isNotEmpty,
        reason: 'TMDB API key should be loaded from environment');
      
      // 危険なプレースホルダーでないことを確認
      final dangerousPlaceholders = [
        'your_api_key_here',
        'API_KEY',
        'test_key',
        'dummy_key',
        '12345',
        'abc123',
      ];
      
      for (final placeholder in dangerousPlaceholders) {
        expect(EnvConfig.tmdbApiKey.toLowerCase(), 
               isNot(equals(placeholder.toLowerCase())),
               reason: 'API key should not be placeholder: $placeholder');
      }
      
      // API keyの形式検証（TMDb APIキーの一般的な形式）
      expect(EnvConfig.tmdbApiKey.length, greaterThanOrEqualTo(32),
        reason: 'TMDb API key should be at least 32 characters');
      
      expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(EnvConfig.tmdbApiKey), isTrue,
        reason: 'API key should contain only alphanumeric characters');
    });

    test('Network security validation', () {
      // HTTPS通信の強制確認
      expect(EnvConfig.tmdbBaseUrl.startsWith('https://'), isTrue,
        reason: 'All API endpoints must use HTTPS');
      
      // 正規のTMDb APIエンドポイントであることを確認
      final validTmdbUrls = [
        'https://api.themoviedb.org/3',
        'https://api.themoviedb.org/4',
      ];
      
      expect(validTmdbUrls.contains(EnvConfig.tmdbBaseUrl), isTrue,
        reason: 'Should use official TMDb API endpoint');
      
      // 不正なプロトコルや危険なURLパターンの検出
      final dangerousPatterns = [
        'http://',
        'localhost',
        '127.0.0.1',
        '192.168.',
        '10.0.',
        'file://',
        'ftp://',
      ];
      
      for (final pattern in dangerousPatterns) {
        expect(EnvConfig.tmdbBaseUrl.toLowerCase(), 
               isNot(contains(pattern)),
               reason: 'URL should not contain dangerous pattern: $pattern');
      }
    });

    test('Input validation security tests', () {
      // 実際の入力値検証のセキュリティテスト
      
      // SQLインジェクション攻撃パターンのテスト
      final sqlInjectionPayloads = [
        "'; DROP TABLE users; --",
        "1' OR '1'='1",
        "admin'--",
        "' UNION SELECT * FROM users--",
        "'; DELETE FROM reviews; --",
      ];
      
      for (final payload in sqlInjectionPayloads) {
        final sanitized = ValidationHelper.sanitizeInput(payload);
        
        // 危険な文字列が除去されていることを確認
        expect(sanitized, isNot(contains('DROP')));
        expect(sanitized, isNot(contains('DELETE')));
        expect(sanitized, isNot(contains('UNION')));
        expect(sanitized, isNot(contains("'")));
        expect(sanitized, isNot(contains('--')));
        
        print('SQL Injection test: "$payload" -> "$sanitized"');
      }
      
      // XSS攻撃パターンのテスト
      final xssPayloads = [
        '<script>alert("xss")</script>',
        '<img src="x" onerror="alert(1)">',
        'javascript:alert(1)',
        '<svg onload="alert(1)">',
        '"><script>alert(document.cookie)</script>',
      ];
      
      for (final payload in xssPayloads) {
        final sanitized = ValidationHelper.sanitizeInput(payload);
        
        // 危険なHTMLタグとスクリプトが除去されていることを確認
        expect(sanitized, isNot(contains('<script')));
        expect(sanitized, isNot(contains('javascript:')));
        expect(sanitized, isNot(contains('onerror')));
        expect(sanitized, isNot(contains('onload')));
        expect(sanitized, isNot(contains('alert')));
        
        print('XSS test: "$payload" -> "$sanitized"');
      }
    });

    test('Data length and format validation', () {
      // データ長と形式の検証テスト
      
      // 極端に長い入力のテスト
      final extremelyLongInput = 'A' * 100000;
      final sanitized = ValidationHelper.sanitizeInput(extremelyLongInput);
      
      expect(sanitized.length, lessThanOrEqualTo(1000),
        reason: 'Input should be truncated to reasonable length');
      
      // 特殊文字の処理テスト
      final specialCharInput = '!@#\$%^&*()_+{}|:"<>?[];\'\\,./`~';
      final sanitizedSpecial = ValidationHelper.sanitizeInput(specialCharInput);
      
      // 危険な文字が除去されていることを確認
      expect(sanitizedSpecial, isNot(contains('<')));
      expect(sanitizedSpecial, isNot(contains('>')));
      expect(sanitizedSpecial, isNot(contains("'")));
      expect(sanitizedSpecial, isNot(contains('"')));
      
      // 国際文字の適切な処理テスト
      final unicodeInput = 'こんにちは世界 🌍 Ñiño café résumé';
      final sanitizedUnicode = ValidationHelper.sanitizeInput(unicodeInput);
      
      expect(sanitizedUnicode, contains('こんにちは'));
      expect(sanitizedUnicode, contains('世界'));
      
      print('Special chars: "$specialCharInput" -> "$sanitizedSpecial"');
      print('Unicode: "$unicodeInput" -> "$sanitizedUnicode"');
    });

    test('Email and rating validation security', () {
      // 実際のバリデーション関数のセキュリティテスト
      
      // メールアドレスの検証
      final validEmails = [
        'user@example.com',
        'test.user+tag@domain.co.uk',
        'user123@test-domain.org',
      ];
      
      final invalidEmails = [
        'invalid-email',
        '@example.com',
        'user@',
        'user space@example.com',
        '<script>alert(1)</script>@evil.com',
        'javascript:alert(1)@evil.com',
      ];
      
      for (final email in validEmails) {
        expect(ValidationHelper.isValidEmail(email), isTrue,
          reason: 'Valid email should pass: $email');
      }
      
      for (final email in invalidEmails) {
        expect(ValidationHelper.isValidEmail(email), isFalse,
          reason: 'Invalid email should fail: $email');
      }
      
      // 評価値の検証
      final validRatings = [0.0, 1.0, 2.5, 4.5, 5.0];
      final invalidRatings = [-1.0, 6.0, double.infinity, double.nan];
      
      for (final rating in validRatings) {
        expect(ValidationHelper.isValidRating(rating), isTrue,
          reason: 'Valid rating should pass: $rating');
      }
      
      for (final rating in invalidRatings) {
        expect(ValidationHelper.isValidRating(rating), isFalse,
          reason: 'Invalid rating should fail: $rating');
      }
    });

    test('Password and authentication patterns security', () {
      // 認証パターンのセキュリティテスト
      
      // 弱いパスワードパターンの検出
      final weakPasswords = [
        'password',
        '123456',
        'qwerty',
        'admin',
        'password123',
        '111111',
        'abc123',
      ];
      
      for (final password in weakPasswords) {
        expect(ValidationHelper.isWeakPassword(password), isTrue,
          reason: 'Weak password should be detected: $password');
      }
      
      // 強いパスワードパターンの検証
      final strongPasswords = [
        'MyStr0ng!Password2024',
        'Complex#Pass123Word',
        'Secure&Password456!',
      ];
      
      for (final password in strongPasswords) {
        expect(ValidationHelper.isWeakPassword(password), isFalse,
          reason: 'Strong password should not be flagged as weak: $password');
      }
    });

    test('URL and file path validation security', () {
      // URLとファイルパスの検証セキュリティテスト
      
      // 安全なURL
      final safeUrls = [
        'https://api.themoviedb.org/3/movie/123',
        'https://image.tmdb.org/t/p/w500/poster.jpg',
        'https://www.example.com/safe-path',
      ];
      
      // 危険なURL
      final dangerousUrls = [
        'javascript:alert(1)',
        'data:text/html,<script>alert(1)</script>',
        'file:///etc/passwd',
        'ftp://malicious.com/payload',
        'http://localhost:3000/admin',
        '../../../etc/passwd',
        'https://evil.com/../../sensitive',
      ];
      
      for (final url in safeUrls) {
        expect(ValidationHelper.isSafeUrl(url), isTrue,
          reason: 'Safe URL should pass: $url');
      }
      
      for (final url in dangerousUrls) {
        expect(ValidationHelper.isSafeUrl(url), isFalse,
          reason: 'Dangerous URL should fail: $url');
      }
      
      print('URL Security validation completed');
    });
  });
}