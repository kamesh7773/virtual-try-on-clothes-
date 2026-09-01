import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:virtual_try_on/features/try_on/view_models/catalog_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    // Hold a subscription so the provider is not auto-disposed between reads,
    // the way a mounted widget would keep it alive.
    container.listen(catalogViewModelProvider, (_, _) {}, fireImmediately: true);
  });
  tearDown(() => container.dispose());

  CatalogViewModel viewModel() =>
      container.read(catalogViewModelProvider.notifier);

  test('starts empty and populates after load', () async {
    expect(container.read(catalogViewModelProvider).hasGarments, isFalse);

    await viewModel().load();

    final state = container.read(catalogViewModelProvider);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    expect(state.garments, hasLength(8));
    expect(state.selectedIndex, 0);
    expect(state.selected, isNotNull);
  });

  test('next wraps around at the end of the catalog', () async {
    await viewModel().load();
    final total = container.read(catalogViewModelProvider).total;

    for (var i = 0; i < total; i++) {
      viewModel().next();
    }

    expect(container.read(catalogViewModelProvider).selectedIndex, 0);
  });

  test('previous wraps backwards from the first garment', () async {
    await viewModel().load();
    final total = container.read(catalogViewModelProvider).total;

    viewModel().previous();

    expect(
      container.read(catalogViewModelProvider).selectedIndex,
      total - 1,
    );
  });

  test('select ignores an out-of-range index', () async {
    await viewModel().load();

    viewModel().select(99);
    expect(container.read(catalogViewModelProvider).selectedIndex, 0);

    viewModel().select(-1);
    expect(container.read(catalogViewModelProvider).selectedIndex, 0);
  });

  test('selectById moves to the matching garment', () async {
    await viewModel().load();
    final target = container.read(catalogViewModelProvider).garments[3];

    viewModel().selectById(target.id);

    expect(container.read(catalogViewModelProvider).selected, target);
  });

  test('selectedGarment provider tracks the selection', () async {
    await viewModel().load();
    expect(container.read(selectedGarmentProvider)?.id, 'm1');

    viewModel().next();

    expect(container.read(selectedGarmentProvider)?.id, 'm2');
  });

  test('displayPosition is 1-based for the counter', () async {
    await viewModel().load();
    expect(container.read(catalogViewModelProvider).displayPosition, 1);

    viewModel().next();

    expect(container.read(catalogViewModelProvider).displayPosition, 2);
  });
}
