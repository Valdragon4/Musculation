import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:musculation/services/image_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageService Tests', () {
    late ImageService imageService;

    setUp(() {
      imageService = ImageService();
    });

    group('takePhoto', () {
      test('should handle camera pick errors gracefully', () async {
        // Simuler une erreur de permission
        const channel = MethodChannel('plugins.flutter.io/image_picker');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'PERMISSION_DENIED');
        });

        final result = await imageService.takePhoto();

        expect(result, isNull);

        // Restaurer le handler par défaut
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });
    });

    group('pickImageFromGallery', () {
      test('should handle gallery pick errors gracefully', () async {
        // Simuler une erreur de permission
        const channel = MethodChannel('plugins.flutter.io/image_picker');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'PERMISSION_DENIED');
        });

        final result = await imageService.pickImageFromGallery();

        expect(result, isNull);

        // Restaurer le handler par défaut
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });
    });

    group('requestInitialPermissions', () {
      test('should handle permission request errors gracefully', () async {
        // Simuler une erreur de permission
        const channel = MethodChannel('plugins.flutter.io/permission_handler');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'PERMISSION_DENIED');
        });

        final result = await imageService.requestInitialPermissions();

        expect(result, isFalse);

        // Restaurer le handler par défaut
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });
    });

    group('Error Handling', () {
      test('should handle permission denied errors', () async {
        const channel = MethodChannel('plugins.flutter.io/image_picker');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'PERMISSION_DENIED');
        });

        final result = await imageService.takePhoto();

        expect(result, isNull);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      test('should handle storage access errors', () async {
        const channel = MethodChannel('plugins.flutter.io/image_picker');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'STORAGE_ACCESS_DENIED');
        });

        final result = await imageService.pickImageFromGallery();

        expect(result, isNull);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      test('should handle device not available errors', () async {
        const channel = MethodChannel('plugins.flutter.io/image_picker');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'CAMERA_NOT_AVAILABLE');
        });

        final result = await imageService.takePhoto();

        expect(result, isNull);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });
    });

    group('Service Initialization', () {
      test('should create ImageService instance', () {
        expect(imageService, isNotNull);
        expect(imageService, isA<ImageService>());
      });
    });
  });
} 
