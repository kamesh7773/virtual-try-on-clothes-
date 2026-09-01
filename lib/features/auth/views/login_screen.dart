import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/routes/route_arguments.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../view_models/auth_view_model.dart';

const _demoEmail = 'john@mail.com';
const _demoPassword = 'changeme';

class LoginScreen extends HookConsumerWidget {
  final LoginScreenArgs args;

  const LoginScreen({super.key, this.args = const LoginScreenArgs()});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailCtrl = useTextEditingController(text: _demoEmail);
    final passwordCtrl = useTextEditingController(text: _demoPassword);
    final obscure = useState(true);
    final formKey = useMemoized(() => GlobalKey<FormState>(), const []);

    final state = ref.watch(authViewModelProvider);

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;
      final ok = await ref.read(authViewModelProvider.notifier).login(
            email: emailCtrl.text.trim(),
            password: passwordCtrl.text,
          );
      if (!ok) return;
      if (!context.mounted) return;
      await ref
          .read(navigationServiceProvider.notifier)
          .pushNamedAndRemoveUntil(Routes.home);
    }

    void fillDemo() {
      emailCtrl.text = _demoEmail;
      passwordCtrl.text = _demoPassword;
    }

    return AppScaffold(
      appBar: const CustomAppBar(
        title: 'Sign in',
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Icon(
                  Icons.lock_outline,
                  size: 72,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  args.fromLogout ? 'Signed out' : 'Welcome back',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  args.fromLogout
                      ? 'Sign in again to continue managing products.'
                      : 'Sign in with your Platzi Fake Store account.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enabled: !state.isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: obscure.value,
                  enabled: !state.isLoading,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => obscure.value = !obscure.value,
                    ),
                  ),
                  validator: (v) => Validators.password(v, minLength: 4),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Sign in',
                  icon: Icons.login,
                  isLoading: state.isLoading,
                  onPressed: submit,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: state.isLoading ? null : fillDemo,
                  child: const Text('Use demo credentials'),
                ),
                const SizedBox(height: 24),
                const _DemoCredentialsHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoCredentialsHint extends StatelessWidget {
  const _DemoCredentialsHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.info, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                children: [
                  TextSpan(text: 'Demo account: '),
                  TextSpan(
                    text: '$_demoEmail / $_demoPassword',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
