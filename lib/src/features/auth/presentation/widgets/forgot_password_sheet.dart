import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:validatorless/validatorless.dart';
import 'package:solar_hub/src/utils/toast_service.dart';

class ForgotPasswordSheet extends StatelessWidget {
  ForgotPasswordSheet({super.key});

  final TextEditingController _emailController = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reset Password', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), // TODO: add translation
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Enter your email address and we will send you a link to reset your password.', // TODO: add translation
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validatorless.multiple([Validatorless.required('Email is required'), Validatorless.email('Invalid email')]), // TODO: add translation
              decoration: InputDecoration(
                labelText: 'Email', // TODO: add translation
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: RoundedLoadingButton(
              controller: _btnController,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    //  await _authController.sendPasswordResetEmail(_emailController.text);
                    _btnController.success();
                    context.pop();
                    ToastService.success(context, 'Success', 'Password reset email sent!'); // TODO: add translation
                  } catch (e) {
                    _btnController.error();
                    await Future.delayed(const Duration(seconds: 1));
                    _btnController.reset();
                    if (context.mounted) {
                      ToastService.error(context, 'Error', e.toString()); // TODO: add translation
                    }
                  }
                } else {
                  _btnController.error();
                  await Future.delayed(const Duration(seconds: 1));
                  _btnController.reset();
                }
              },
              color: Theme.of(context).primaryColor,
              child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)), // TODO: add translation
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
