import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pr_h23_irlandes_web/data/model/calls_model.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/calls_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/infraestructure/global/global_methods.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom.dart';

class CreateCallsPage extends StatefulWidget {
  const CreateCallsPage({Key? key}) : super(key: key);

  @override
  _CreateCallsPageState createState() => _CreateCallsPageState();
}

final PersonaDataSourceImpl personDataSource = PersonaDataSourceImpl();
late List<PersonaModel> users = [];
Future<void> refreshUsers() async {
  users = await personDataSource.readPeople();
  users = users..sort((item1, item2) => item1.lastname.toLowerCase().compareTo(item2.lastname.toLowerCase()));
}

class _CreateCallsPageState extends State<CreateCallsPage> {

  AttentionCallsRemoteDataSource callsRemoteDataSource = AttentionCallsRemoteDataSource();

  final controllerStudentName = TextEditingController();
  final controllerTeacherName = TextEditingController();
  final controllerMotive = TextEditingController();
  var studentId = "";
  String? selectedLevel;
  String? selectedGrade;
  List<String> gradeOptions = [];
  bool validationCheck() {
    if (controllerStudentName.text != "" &&
        controllerTeacherName.text != "" &&
        controllerMotive.text != "") {
      return true;
    } else {
      return false;
    }
  }

  var teacher;
  var student;
  late final Future userFuture = refreshUsers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 227, 233, 244),
        appBar: const AppBarCustom(title: "Registro de notificaciones estudiantiles"),
        body: FutureBuilder(
            future: userFuture,
            builder: (context, snapshot){
              if(users.isEmpty){
                return const Center(
                    child: CircularProgressIndicator()
                );
              }
              else {
                final List<DropdownMenuEntry<PersonaModel>> iconEntries = <DropdownMenuEntry<PersonaModel>>[];
                for (final PersonaModel user in users) {
                  iconEntries.add(DropdownMenuEntry<PersonaModel>(
                      value: user,
                      label:"${user.name} ${user.lastname} ${user.surname}"));
                }

                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                              children: [
                                Text("Nombre del Estudiante:",
                                    style: TextStyle(fontSize: 15, color: Colors.blue[900])
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: 250,
                                  child: DropdownMenu<PersonaModel>(
                                    controller: controllerStudentName,
                                    enableFilter: true,
                                    leadingIcon: const Icon(Icons.search),
                                    dropdownMenuEntries: iconEntries,
                                    inputDecorationTheme: const InputDecorationTheme(
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                                    ),
                                    onSelected: (PersonaModel? icon) {
                                      setState(() {
                                        student = "${icon!.name} ${icon.lastname} ${icon.surname}";
                                        studentId = icon.fatherId + ' ' + icon.motherId;
                                      });
                                    },
                                  ),
                                ),
                              ]
                          ),
                          const SizedBox(height: 20),
                          Column(
                              children: [
                                Text("Nombre del Docente:",
                                    style: TextStyle(fontSize: 15, color: Colors.blue[900])
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: 250,
                                  child: DropdownMenu<PersonaModel>(
                                    controller: controllerTeacherName,
                                    enableFilter: true,
                                    leadingIcon: const Icon(Icons.search),
                                    dropdownMenuEntries: iconEntries,
                                    inputDecorationTheme: const InputDecorationTheme(
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                                    ),
                                    onSelected: (PersonaModel? icon) {
                                      setState(() {
                                        teacher = "${icon!.name} ${icon.lastname} ${icon.surname}";
                                      });
                                    },
                                  ),
                                ),
                              ]
                          ),
                          const SizedBox(height: 20),
                          Column(
                              children: [
                                Text("Motivo:",
                                    style: TextStyle(fontSize: 15, color: Colors.blue[900])
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 250,
                                    child: TextField(
                                        maxLength: 100,
                                        maxLines: 4,
                                        controller: controllerMotive,
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white)
                                    )
                                )
                              ]
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 250,
                            child: DropdownButtonFormField<String>(
                              value: selectedLevel,
                              hint: const Text('Nivel'),
                              onChanged: (value) {
                                setState(() {
                                  selectedLevel = value;
                                  if (value == 'Inicial') {
                                    gradeOptions = ['1ra seccion', '2da seccion'];
                                    selectedGrade = '1ra seccion'; // Asigna el primer grado cuando cambia el nivel
                                  } else if (value == 'Primaria' || value == 'Secundaria') {
                                    gradeOptions = ['1er', '2do', '3er', '4to', '5to', '6to'];
                                    selectedGrade = '1er'; // Asigna el primer grado cuando cambia el nivel
                                  }
                                });
                              },
                              items: ['Inicial', 'Primaria', 'Secundaria']
                                  .map((label) => DropdownMenuItem(
                                child: Text(label),
                                value: label,
                              ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 250,
                            child: DropdownButtonFormField<String>(
                              value: selectedGrade,
                              hint: const Text('Grado'),
                              onChanged: (value) {
                                setState(() {
                                  selectedGrade = value!;
                                });
                              },
                              items: gradeOptions
                                  .map((label) => DropdownMenuItem(
                                child: Text(label),
                                value: label,
                              ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                elevation: 0
                            ),
                            onPressed: () {
                              if (validationCheck()) {
                                List<String> parts = studentId.split(' '); // Divide la cadena por el espacio en dos partes
                                String fatherId = parts[0]; // Primera parte
                                String motherId = parts[1];

                                final call = AttentionCallsModel(
                                    id: "",
                                    student: student,
                                    teacher: teacher,
                                    motive: controllerMotive.text,
                                    level: selectedLevel ?? '',
                                    course: selectedGrade ?? '',
                                    studentId: fatherId,
                                    registrationDate: DateTime.now().toString()
                                );

                                // Crea solo una notificación
                                callsRemoteDataSource.createAttentionCall(call);

                                GlobalMethods.showSuccessSnackBar(context, "Notificación agregada con éxito");
                                Navigator.pushNamed(context, '/attention_calls');
                              } else {
                                GlobalMethods.showErrorSnackBar(context, "Asegúrese de haber llenado todos los campos correctamente.");
                              }
                            },
                            child: const Text(
                              "Añadir",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ]
                    )
                );
              }
            }
        )
    );
  }
}
