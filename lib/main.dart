import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './providers/auth_providers.dart';
import './screens/login.dart';
import './screens/register.dart';
import './screens/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return ChangeNotifierProvider.value(
      value: AuthProvider(),
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Consumer<AuthProvider>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Cat Chat!',
            theme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: Color.fromRGBO(42, 117, 228, 1),
                accentColor: Color.fromRGBO(42, 117, 228, 1),
                backgroundColor: Color.fromRGBO(28, 27, 27, 1)),
            home: auth.isAuth
                ? HomeScreen()
                : FutureBuilder(
                    future: auth.autologIn(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? CircularProgressIndicator()
                            : Login(),
                  ),
            debugShowCheckedModeBanner: false,
            routes: {
              '/login-screen': (ctx) => Login(),
              '/register-screen': (ctx) => Register(),
              '/home-screen': (ctx) => HomeScreen(),
            },
          ),
        ),
      ),
    );
  }
}
