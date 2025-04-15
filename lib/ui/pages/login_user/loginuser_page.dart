import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/infraestructure/global/global_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginUserPage extends StatefulWidget {
  const LoginUserPage({super.key});

  @override
  State<LoginUserPage> createState() => _LoginUserPageState();
}

class _LoginUserPageState extends State<LoginUserPage> {
  final PersonaDataSource _usuarioDataSource = PersonaDataSourceImpl();
  bool obscurePassword = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          color: const Color(0xFFE3E9F4),
          child: Center(
            child: isMobile ? _buildMobileLayout(l10n) : _buildDesktopLayout(l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogoContainer(l10n),
        _buildLoginForm(l10n),
      ],
    );
  }

  Widget _buildMobileLayout(AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          _buildLogoContainer(l10n),
          const SizedBox(height: 20),
          _buildLoginForm(l10n),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLogoContainer(AppLocalizations l10n) {
    return Container(
      width: 350,
      height: 350,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Card(
        color: const Color(0xFF044086),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/ui/logo.png',
                width: 100,
                height: 100,
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  l10n.school_name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AppLocalizations l10n) {
    return Container(
      width: 350,
      height: 350,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      child: Card(
        color: const Color(0xFFF1F1F1),
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width < 600 ? 12.0 : 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.login_prompt,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 20,
                    color: const Color(0xff3D5269),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildUsernameField(l10n),
                const SizedBox(height: 10),
                _buildPasswordField(l10n),
                const SizedBox(height: 20),
                _buildLoginButton(l10n),
                if (MediaQuery.of(context).size.width >= 600) ...[
                  const SizedBox(height: 5),
                  const Divider(
                    color: Color(0x00767676),
                    height: 20,
                    thickness: 2,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    l10n.login_guest_button,
                    style: const TextStyle(
                      color: Color(0x00767676),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField(AppLocalizations l10n) {
    return TextFormField(
      controller: usernameController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: l10n.user_prompt,
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width < 600 ? 12 : 16,
          horizontal: 12,
        ),
      ),
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return TextFormField(
      controller: passwordController,
      obscureText: obscurePassword,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: l10n.passwd_prompt,
        prefixIcon: const Icon(Icons.password_outlined),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
          icon: obscurePassword
              ? const Icon(Icons.visibility_outlined)
              : const Icon(Icons.visibility_off_outlined),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width < 600 ? 12 : 16,
          horizontal: 12,
        ),
      ),
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff044086),
        minimumSize: Size.fromHeight(
          MediaQuery.of(context).size.width < 600 ? 45 : 50,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: _handleLogin,
      child: Text(
        l10n.login_btn,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final username = usernameController.text;
    final password = passwordController.text;
    
    try {
      PersonaModel? persona;
      PersonaModel usuario = PersonaModel.AdminHarcoded;
      
      if (username == usuario.username && password == usuario.password) {
        persona = PersonaModel.AdminHarcoded;
      } else {
        persona = await _authenticate(username, password);
      }

      if (persona != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('personId', persona.id);

        switch (persona.rol) {
          case 'administrador':
            Navigator.pushNamed(context, '/notice_main');
            break;
          case 'psicologia_uno':
          case 'psicologia_dos':
            Navigator.pushNamed(context, '/psicologia_page');
            break;
          case 'coordinacion_uno':
          case 'coordinacion_dos':
            Navigator.pushNamed(context, '/Coordination_Page');
            break;
          case 'Administrador de Area':
            Navigator.pushNamed(context, '/admin_area_main');
            break;
          case 'HardcodedAdmin':
            Navigator.pushNamed(context, '/register_postulation_hardcoded');
            break;
          default:
            GlobalMethods.showToast("Usuario no tiene permiso de acceso");
        }
      } else {
        GlobalMethods.showToast("Error al iniciar sesión");
      }
    } catch (e) {
      GlobalMethods.showToast("Error al iniciar sesión: $e");
    }
  }

  Future<PersonaModel?> _authenticate(String username, String password) async {
    try {
      var bytes = utf8.encode(password);
      var digest = sha256.convert(bytes);
      return await _usuarioDataSource.iniciarSesion(
          username, digest.toString());
    } catch (e) {
      print("Error al iniciar sesión: $e");
      return null;
    }
  }
}