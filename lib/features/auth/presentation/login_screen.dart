import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isOtpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo/Title
                const Icon(Icons.local_shipping, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Driver Tablet',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '(555) 123-4567',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Add phone validation logic here
                    return null;
                  },
                  enabled: !_isOtpSent,
                ),
                const SizedBox(height: 16),

                // OTP Field (shown only after OTP is sent)
                if (_isOtpSent) ...[
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter OTP',
                      hintText: '123456',
                      prefixIcon: Icon(Icons.security),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      if (value.length != 6) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Text(_isOtpSent ? 'Verify OTP' : 'Send OTP'),
                ),

                // Resend OTP button (shown only after OTP is sent)
                if (_isOtpSent) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _handleResendOtp,
                    child: const Text('Resend OTP'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      if (_isOtpSent) {
        _verifyOtp();
      } else {
        _sendOtp();
      }
    }
  }

  void _sendOtp() {
    // TODO: Implement OTP sending logic with Dio
    // For now, simulate the process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _isOtpSent = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP sent successfully')));
    });
  }

  void _verifyOtp() {
    // TODO: Implement OTP verification logic with Dio
    // For now, simulate the process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // Navigate to dashboard using GoRouter
      context.go('/dashboard');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful')));
    });
  }

  void _handleResendOtp() {
    // TODO: Implement resend OTP logic with cooldown
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('OTP resent')));
  }
}
