import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/calls_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/calls_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom.dart';

class CallsHistory extends StatefulWidget {
  const CallsHistory({Key? key}) : super(key: key);

  @override
  CallsHistoryState createState() => CallsHistoryState();
}

final AttentionCallsRemoteDataSource _attentionCallsDataSource = AttentionCallsRemoteDataSource();
final PersonaDataSourceImpl personaDataSource = PersonaDataSourceImpl();

List<AttentionCallsModel> attentionCalls = [];

Future<List<AttentionCallsModel>> refreshAttentionCalls() async {
  attentionCalls = await _attentionCallsDataSource.getAttentionCalls();
  attentionCalls = attentionCalls..sort((item1, item2) => item2.registrationDate.compareTo(item1.registrationDate));
  return attentionCalls;
}

class CallsHistoryState extends State<CallsHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 233, 244),
      appBar: const AppBarCustom(
        title: 'Historial de Notificaciones estudiantiles',
      ),
      body: Center(
        child: FutureBuilder<List<AttentionCallsModel>>(
        future: refreshAttentionCalls(),
        builder: (context, snapshot) {
          if (snapshot.hasData){
              return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, int index) {
                      return Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      margin: const EdgeInsets.all(10),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child:Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        const Column(children: [
                          Text("Docente",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Estudiante",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Motivo",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Nivel",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Curso",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Fecha de creación",
                              style: TextStyle(fontWeight: FontWeight.bold))
                        ]),
                        Column(children: [
                          Text(snapshot.data![index].teacher),
                          Text(snapshot.data![index].student),
                          Text(snapshot.data![index].motive),
                          Text(snapshot.data![index].level),
                          Text(snapshot.data![index].course),
                          Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(snapshot.data![index].registrationDate)))
                        ])
                      ])
                      ));
                    }
                  )
                ),
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/notice_main');
                      },
                      child: const Text("Volver al menú principal",
                      style: TextStyle(
                                    color: Colors
                                        .white,
                                  ))
                    )
                  ]
                )
              ]
            );
          }
          else{
            return const CircularProgressIndicator();
          }
        }
      ))
    );
  }
}