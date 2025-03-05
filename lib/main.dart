import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobilprogramlama/pages/auth/login_page.dart';
import 'package:mobilprogramlama/pages/home_page.dart';
import 'package:mobilprogramlama/pages/admin/admin_dashboard.dart';
import 'package:mobilprogramlama/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter motorunun hazır olmasını sağlar
  await Firebase.initializeApp(); // Firebase'i başlat
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // Kullanıcı oturum açmış, rol kontrolü yap
              return FutureBuilder<String>(
                future: _authService.getCurrentUserRole(),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.done) {
                    // Rol verisi geldiğinde yönlendirme yap
                    final role = roleSnapshot.data;
                    
                    if (role == 'admin') {
                      return AdminDashboard();
                    } else {
                      return HomePage();
                    }
                  }
                  
                  // Rol verisi yüklenirken bir gösterge göster
                  return Scaffold(body: Center(child: CircularProgressIndicator()));
                },
              );
            }
            
            // Kullanıcı oturum açmamış, login sayfasına yönlendir
            return LoginPage();
          }
          
          // StreamBuilder bağlantısı kurulurken bir gösterge göster
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}
