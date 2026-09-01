import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_service.g.dart';

@Riverpod(keepAlive: true)
class NavigationService extends _$NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void build() {}

  BuildContext? get currentContext => navigatorKey.currentContext;

  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, void>(
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
    RoutePredicate? predicate,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  void pop<T extends Object?>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop<T>(result);
    }
  }

  void popUntil(String routeName) {
    navigatorKey.currentState?.popUntil(ModalRoute.withName(routeName));
  }
}
