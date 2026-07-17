import 'package:flutter/material.dart';
import 'package:task_manager/utils/app_colors.dart';
import 'package:task_manager/widget/screen_bg.dart';
import 'reset_password_screen.dart';

class ForgotPasswordOTPScreen extends StatefulWidget {
  final String email;

  const ForgotPasswordOTPScreen({
    super.key,
    required this.email,
  });

  @override
  State<ForgotPasswordOTPScreen> createState() => _ForgotPasswordOTPScreenState();
}

class _ForgotPasswordOTPScreenState extends State<ForgotPasswordOTPScreen> {
  List<TextEditingController> otpControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  bool isLoading = false;
  int resendCountdown = 0;

  String getOTPValue() {
    return otpControllers.map((c) => c.text).join();
  }

  Future<void> verifyOTP() async {
    String otp = getOTPValue();
    
    if(otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter complete OTP'))
      );
      return;
    }

    setState(() => isLoading = true);

    // Simulate OTP verification - In production, call your API
    await Future.delayed(Duration(seconds: 2));

    setState(() => isLoading = false);

    // Navigate to reset password screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(
          email: widget.email,
          otp: otp,
        ),
      ),
    );
  }

  Future<void> resendOTP() async {
    setState(() => resendCountdown = 60);

    // Simulate resending OTP - In production, call your API
    await Future.delayed(Duration(seconds: 2));

    for(int i = 60; i > 0; i--) {
      await Future.delayed(Duration(seconds: 1));
      if(mounted) {
        setState(() => resendCountdown = i);
      }
    }

    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to ${widget.email}'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.PColor,
        title: Text('Verify OTP'),
        elevation: 0,
      ),
      body: ScreenBG(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Text(
                  'PIN Verification',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16),
                Text(
                  'A 4-digit PIN has been sent to\n${widget.email}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 40),
                
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 60,
                      child: TextField(
                        controller: otpControllers[index],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: EdgeInsets.all(12),
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        onChanged: (value) {
                          if(value.isNotEmpty && index < 3) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                SizedBox(height: 40),
                
                FilledButton(
                  onPressed: isLoading ? null : verifyOTP,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ),
                ),
                SizedBox(height: 32),
                
                // Resend OTP Section
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Didn\'t receive PIN?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 12),
                      if(resendCountdown > 0)
                        Text(
                          'Resend in ${resendCountdown}s',
                          style: TextStyle(
                            color: AppColors.PColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: resendOTP,
                          child: Text(
                            'Resend PIN',
                            style: TextStyle(
                              color: AppColors.PColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for(var controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
