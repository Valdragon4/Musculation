import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'hive_helper.dart';

/// Wrapper pour tester les widgets qui utilisent Riverpod
class TestWrapper extends StatelessWidget {
  final Widget child;
  final List<Override> overrides;

  const TestWrapper({
    required this.child,
    this.overrides = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: child,
      ),
    );
  }
}

/// Extension pour faciliter le test des providers
extension ProviderContainerX on ProviderContainer {
  Future<void> pump() async {
    await Future.delayed(Duration.zero);
  }
}

/// Crée un ProviderContainer avec des overrides pour les tests
ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(
    overrides: overrides,
  );
  
  addTearDown(container.dispose);
  return container;
}

/// Crée un ProviderContainer pour les tests (alias pour createContainer)
ProviderContainer createTestContainer({
  List<Override> overrides = const [],
}) {
  return createContainer(overrides: overrides);
}

/// Setup global pour les tests
Future<void> setupTestEnvironment() async {
  await initHive();
}

/// Cleanup global pour les tests
Future<void> cleanupTestEnvironment() async {
  await cleanupHive();
} 
