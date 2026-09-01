// Typed argument objects for named routes.
//
// Pass these via `Navigator.pushNamed(name, arguments: ...)` (or
// `NavigationService.pushNamed(name, arguments: ...)`) and extract them
// inside `RouteGenerator.generateRoute` with
// `settings.arguments as <ScreenName>Args?`. Always keep them immutable.

// ----------------------- Auth Routes Arguments ----------------------- //
class LoginScreenArgs {
  /// `true` when the user just signed out — lets the login screen show
  /// a "you've been signed out" affordance instead of the default welcome.
  final bool fromLogout;

  const LoginScreenArgs({this.fromLogout = false});
}
