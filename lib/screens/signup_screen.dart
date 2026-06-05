import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;
  final VoidCallback onBackToLogin;

  const RegisterScreen({
    super.key, 
    required this.onRegisterSuccess, 
    required this.onBackToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // 👈 Phone အတွက် ထပ်တိုး
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController(); // 👈 OTP ရိုက်ဖို့ ထပ်တိုး

  final ApiService _apiService = ApiService();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  bool _isOtpStage = false; // 👈 true ဖြစ်သွားရင် OTP ရိုက်တဲ့ Screen UI ကို ပြောင်းပြမယ်

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // 1️⃣ အဆင့် (၁) - အချက်အလက်တွေ ဖြည့်ပြီး OTP လှမ်းပို့ခိုင်းတဲ့ Function
  void _submitRegistrationInfo() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('ကျေးဇူးပြု၍ အချက်အလက်များ အပြည့်အစုံဖြည့်ပါ');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('စကားဝှက်များ ကိုက်ညီမှု မရှိပါ');
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Backend ဆီကို OTP အရင်ပို့ခိုင်းတဲ့ API လှမ်းခေါ်မယ်
      // (မှတ်ချက် - Shin Thant ရဲ့ backend မှာ /auth/send-otp API ဆောက်ထားရပါမယ်)
      await _apiService.sendOtp(email: email); 
      
      _showSnackBar('မင်းရဲ့ Gmail ထဲကို OTP ဂဏန်း ပို့ပေးလိုက်ပါပြီ');
      
      setState(() {
        _isOtpStage = true; // ✨ အောင်မြင်ရင် OTP ရိုက်တဲ့ အဆင့်ကို ကူးလိုက်ပြီ!
      });
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception:', ''));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // 2️⃣ အဆင့် (၂) - User ရိုက်ထည့်လိုက်တဲ့ OTP ကို စစ်ဆေးပြီး တကယ် အကောင့်ဆောက်မယ့် Function
void _verifyOtpAndRegister() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      _showSnackBar('ကျေးဇူးပြု၍ OTP ဂဏန်း ရိုက်ထည့်ပေးပါ');
      return;
    }

    setState(() { _isLoading = true; });

    try {
      bool isOtpValid = await _apiService.verifyOtp(email: email, otp: otp);

      if (isOtpValid) {
      
        await _apiService.registerUser(
          name: _nameController.text.trim(),
          email: email,
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          imageFile: _imageFile,
        );

        widget.onRegisterSuccess();
      } else {
        _showSnackBar('OTP ဂဏန်း မှားယွင်းနေပါသည်');
      }
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception:', ''));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              // ✨ _isOtpStage ပေါ်မူတည်ပြီး UI မျက်နှာပြင်ကို အလိုအလျောက် ခွဲပြပေးမယ်
              child: _isOtpStage ? _buildOtpUI() : _buildRegistrationFormUI(),
            ),
          ),
        ),
      ),
    );
  }

  // 📝 ရှေ့တန်း Form ဖြည့်ရမည့် UI (Step 1)
  Widget _buildRegistrationFormUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create Account',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
        ),
        const Text(
          'Sign up to get started on your shopping profile',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Profile Image Picker
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[200],
                backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null ? Icon(Icons.person, size: 55, color: Colors.grey[400]) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        // 📞 Phone Number TextField (အသစ်တိုးထားတာ)
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_clock_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _isLoading ? null : _submitRegistrationInfo,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: widget.onBackToLogin,
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
          child: const Text('Already have an account? Login'),
          ),
        ],
      );
  }

  // 📧 Email Verification / OTP ရိုက်ရမည့် UI (Step 2)
  Widget _buildOtpUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_unread_outlined, size: 80, color: Theme.of(context).primaryColor),
        const SizedBox(height: 24),
        const Text(
          'Email Verification',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'မင်းရဲ့ Email (${_emailController.text}) ဆီကို ပို့လိုက်တဲ့ OTP ဂဏန်းကို ရိုက်ထည့်ပေးပါ',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 32),

        // OTP ရိုက်ရမယ့် အကွက်
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
          decoration: InputDecoration(
            hintText: '000000',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtpAndRegister,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Verify & Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),

        // ပြန်ပြင်ချင်ရင် နောက်ပြန်ဆုတ်ဖို့ ခလုတ်
        TextButton(
          onPressed: () {
            setState(() { _isOtpStage = false; });
          },
          child: const Text('Back to Edit Info', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}