---
description: Guidelines for using Riverpod code generation in the Indikosh app
globs: lib/**/*.dart
alwaysApply: false
---
# Riverpod State Management

## Providers

- Use @riverpod annotation
- Handle loading states
- Implement error handling
- Use service injection
- Handle navigation through NavigationService
- Example:

```dart
@riverpod
class UserProvider extends _$UserProvider {
  NavigationService get _navigationService =>
      ref.read(navigationServiceProvider.notifier);

  @override
  AsyncValue<UserModel> build(String userId) {
    return const AsyncValue.loading();
  }

  Future<void> fetchUser() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(userRepositoryProvider);
      final response = await repository.getUser(userId);
      
      if (response.isSuccess && response.data != null) {
        state = AsyncValue.data(response.data!);
      } else {
        state = AsyncValue.error(
          response.message ?? 'Failed to load user',
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    try {
      final repository = ref.read(userRepositoryProvider);
      final response = await repository.updateUser(userId, data);
      
      if (response.isSuccess) {
        await fetchUser();
      } else {
        throw Exception(response.message ?? 'Failed to update user');
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

## Error Handling

- Use try-catch blocks
- Show user-friendly error messages
- Log errors for debugging
- Handle different error types
- Example:

```dart
Future<void> login(String email, String password) async {
  try {
    state = state.copyWith(isLoading: true);
    
    final repository = ref.read(authRepositoryProvider);
    final response = await repository.login(email, password);
    
    if (response.isSuccess && response.data != null) {
      await ref.read(secureStorageProvider.notifier).saveToken(response.data!);
      ref.read(navigationServiceProvider.notifier).navigateToAndRemoveUntil(Routes.home);
    } else {
      throw Exception(response.message ?? 'Login failed');
    }
  } on DioException catch (e) {
    final errorMessage = _formatDioError(e);
    state = state.copyWith(
      isLoading: false,
      error: errorMessage,
    );
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
  }
}

String _formatDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Connection timeout. Please check your internet connection.';
    case DioExceptionType.badResponse:
      if (e.response?.statusCode == 401) {
        return 'Invalid email or password.';
      } else if (e.response?.statusCode == 422) {
        return 'Validation error. Please check your input.';
      } else if (e.response?.statusCode == 500) {
        return 'Server error. Please try again later.';
      }
      return 'An error occurred. Please try again.';
    default:
      return 'An unexpected error occurred. Please try again.';
  }
}
```

## Form Handling

- Use TextEditingController for input fields
- Implement proper validation
- Use FocusNode for focus management
- Handle form submission
- Example:

```dart
class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginViewModel = ref.watch(loginViewModelProvider.notifier);
    final loginState = ref.watch(loginViewModelProvider);

    // Form controllers
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    // Focus nodes
    final emailFocus = useFocusNode();
    final passwordFocus = useFocusNode();

    // Form validation
    useEffect(() {
      void validateEmail() {
        if (!emailFocus.hasFocus && emailController.text.isNotEmpty) {
          loginViewModel.validateEmail(emailController.text);
        }
      }

      emailFocus.addListener(validateEmail);
      return () => emailFocus.removeListener(validateEmail);
    }, [emailFocus]);

    // Form submission
    Future<void> handleSubmit() async {
      if (loginViewModel.validateForm(
        email: emailController.text,
        password: passwordController.text,
      )) {
        await loginViewModel.login(
          emailController.text,
          passwordController.text,
        );
      }
    }

    return Column(
      children: [
        TextFormField(
          controller: emailController,
          focusNode: emailFocus,
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: loginState.validation.emailError,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => passwordFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          focusNode: passwordFocus,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: loginState.validation.passwordError,
          ),
          obscureText: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => handleSubmit(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: loginState.isLoading ? null : handleSubmit,
          child: loginState.isLoading
              ? const CircularProgressIndicator()
              : const Text('Login'),
        ),
      ],
    );
  }
}
```