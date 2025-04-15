import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pr_h23_irlandes_web/infraestructure/global/global_methods.dart';
import 'package:pr_h23_irlandes_web/ui/pages/Calendar/Calendar_page.dart';
import 'package:pr_h23_irlandes_web/ui/pages/admin/dashboard.dart';
import 'package:pr_h23_irlandes_web/ui/pages/administration_area/credential_view_admin.dart';
import 'package:pr_h23_irlandes_web/ui/pages/atention_calls/attention_calls.dart';
import 'package:pr_h23_irlandes_web/ui/pages/atention_calls/create_call.dart';
import 'package:pr_h23_irlandes_web/ui/pages/atention_calls/history_calls.dart';
import 'package:pr_h23_irlandes_web/ui/pages/coordination/CoordinationHomePage.dart';
import 'package:pr_h23_irlandes_web/ui/pages/coordination/Postulation_Coordination_Details.dart';
import 'package:pr_h23_irlandes_web/ui/pages/login_user/loginuser_page.dart';
import 'package:pr_h23_irlandes_web/ui/pages/edit_password.dart';
import 'package:pr_h23_irlandes_web/ui/pages/interview/interview_management.dart';
import 'package:pr_h23_irlandes_web/ui/pages/interview/interview_schedule.dart';
import 'package:pr_h23_irlandes_web/ui/pages/license/history_licenses_page.dart';
import 'package:pr_h23_irlandes_web/ui/pages/license/license_verification.dart';
import 'package:pr_h23_irlandes_web/ui/pages/license/licenses.dart';
import 'package:pr_h23_irlandes_web/ui/pages/menu_options.dart';
import 'package:pr_h23_irlandes_web/ui/pages/postulations/register_postulation__hardcoded.dart';
import 'package:pr_h23_irlandes_web/ui/pages/psychology/postulation_detail_psychology.dart';
import 'package:pr_h23_irlandes_web/ui/pages/psychology/register_module_postulation.dart';
import 'package:pr_h23_irlandes_web/ui/pages/user_profile.dart';
import 'package:pr_h23_irlandes_web/ui/pages/psychology/PsychologistHomePage.dart';
import 'package:pr_h23_irlandes_web/ui/pages/menu_options_psico.dart';
import 'package:pr_h23_irlandes_web/ui/pages/psychology/report_page.dart';
import 'package:pr_h23_irlandes_web/ui/pages/psychology/report_register.dart';
import 'package:pr_h23_irlandes_web/ui/pages/psychology/report_details.dart';
import 'package:pr_h23_irlandes_web/ui/pages/coordination/coordination_page.dart';
import 'package:pr_h23_irlandes_web/ui/pages/coordination/coordination_register.dart';
import 'package:pr_h23_irlandes_web/ui/pages/coordination/coordination_details.dart';
import 'package:pr_h23_irlandes_web/ui/pages/administration_area/administration_area_main.dart';
import 'package:pr_h23_irlandes_web/ui/pages/administration_area/report_details_area_admin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pr_h23_irlandes_web/ui/pages/notice/notice_main_page.dart';
import 'package:pr_h23_irlandes_web/ui/pages/notice/notice_management_page.dart';
import 'package:pr_h23_irlandes_web/ui/pages/postulations/postulation_details.dart';
import 'package:pr_h23_irlandes_web/ui/pages/postulations/register_postulation.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuración de orientación preferida
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Deshabilitar manipulación de URL
  SystemChannels.navigation.setMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'url') {
      return null;
    }
  });

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Colegio Irlandés',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'), // Español
        Locale('en'), // Inglés
      ],
      locale: const Locale('es'), // Idioma por defecto
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: GlobalMethods.primaryColor),
        primaryColor: GlobalMethods.primaryColor,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 600 ? 20 : 24,
          ),
          titleMedium: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 20,
          ),
          bodyLarge: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
          ),
          bodyMedium: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
          ),
        ),
      ),
      initialRoute: '/',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(context).size.width < 600 ? 1.0 : 1.2,
          ),
          child: child!,
        );
      },
      routes: {
        '/': (context) => const LoginUserPage(),
        '/optionmenu': (context) => const OptionsMenuPage(),
        '/optionmenu_psico': (context) => const OptionsMenuPagePsico(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/notice_main': (context) => const NoticeMainPage(),
        '/register_notice': (context) => ManagementNoticePage(selectedDate: DateTime.now()),
        '/register_postulation': (context) => const RegisterPostulation(),
        '/register_postulation_psyco': (context) => const RegisterModulePostulation(),
        '/interview_management': (context) => const InterviewManagement(),
        '/licences': (context) => const Licenses(),
        '/history_licences': (context) => const HistoryLicenses(),
        '/interview_schedule': (context) => const InterviewSchedule(),
        '/attention_calls': (context) => const AttentionCallsPage(),
        '/edit_password': (context) => const EditPassword(),
        '/create_call': (context) => const CreateCallsPage(),
        '/user_profile': (context) => const UserProfilePage(),
        '/calls_history': (context) => const CallsHistory(),
        '/CalendarPage': (context) => CalendarPage(),
        '/license_verification': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;
          final String productId = arguments['id'];
          return LicenseVerification(id: productId);
        },
        '/postulation_details': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;
          final String postulationID = arguments['id'];
          return PostulationDetails(id: postulationID);
        },
        '/postulation_details_psychology': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;
          final String postulationID = arguments['id'];
          return PostulationDetailsPsychology(id: postulationID);
        },
        '/psicologia_page': (context) => const PsychologistHomePage(),
        '/report_management': (context) => const ReportPage(),
        '/report_details': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;
          final String reportID = arguments['id'];
          return ReportDetails(id: reportID);
        },
        '/postulation_details_Coordination': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;
          final String postulationID = arguments['id'];
          return PostulationDetailsCoordination(id: postulationID);
        },
        '/register_report': (context) => const RegisterReport(),
        '/Coordination_Page': (context) => const CoordinacionPage(),
        '/Coordination_Register': (context) => const RegisterCoordinacionReport(),
        '/report_coordinacion_details': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;
          final String reportCoordID = arguments['id'];
          return ReportCoordDetails(id: reportCoordID);
        },
        '/admin_area_main': (context) => const AdministrationHomePage(),
        '/report_details_admin_area': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;
          final String reportCoordID = arguments['id'];
          return ReportCoordDetails_AdminArea(id: reportCoordID);
        },
        '/Coordinationhomepage': (context) => const Coordinationhomepage(),
        '/register_postulation_hardcoded': (context) => const RegisterPostulationHardCoded(),
        '/credential_view_home': (context) => const CredentialHomePage(),
      },
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget desktopLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    required this.desktopLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobileLayout;
        } else {
          return desktopLayout;
        }
      },
    );
  }
}

class ResponsivePage extends StatelessWidget {
  final Widget mobileView;
  final Widget desktopView;
  final bool showAppBar;
  final String? title;

  const ResponsivePage({
    super.key,
    required this.mobileView,
    required this.desktopView,
    this.showAppBar = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: title != null ? Text(title!) : null,
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveLayout(
            mobileLayout: Padding(
              padding: const EdgeInsets.all(16.0),
              child: mobileView,
            ),
            desktopLayout: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1,
                vertical: 16,
              ),
              child: desktopView,
            ),
          ),
        ),
      ),
    );
  }
}