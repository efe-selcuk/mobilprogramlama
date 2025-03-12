import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobilprogramlama/pages/home_page.dart';
import 'package:mobilprogramlama/services/auth_service.dart';
import 'package:mobilprogramlama/widgets/custom_button.dart';
import 'package:mobilprogramlama/widgets/custom_textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String errorMessage = "";

  Future<void> registerUser() async {
    // Tüm alanların doldurulduğunu kontrol et
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = "Tüm alanları doldurun!";
      });
      return;
    }

    // Şifrelerin eşleştiğini kontrol et
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = "Şifreler eşleşmiyor!";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final userModel = await _authService.registerUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: 'user', // Varsayılan olarak normal kullanıcı rolü
      );

      if (userModel != null) {
        // Kayıt başarılı -> Ana sayfaya yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "Kayıt başarısız!";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kayıt Ol"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Hesap Oluştur",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              SizedBox(height: 8),
              Text(
                "Yeni bir hesap oluşturmak için bilgilerinizi girin",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 32),
              CustomTextField(
                hintText: "Ad Soyad",
                controller: nameController,
              ),
              SizedBox(height: 12),
              CustomTextField(
                hintText: "E-posta",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              CustomTextField(
                hintText: "Şifre",
                controller: passwordController,
                isPassword: true,
              ),
              SizedBox(height: 12),
              CustomTextField(
                hintText: "Şifreyi Tekrar Girin",
                controller: confirmPasswordController,
                isPassword: true,
              ),
              SizedBox(height: 12),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 12),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : CustomButton(
                text: "Kayıt Ol",
                onPressed: registerUser,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
