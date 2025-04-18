import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pr_h23_irlandes_web/data/model/access_model.dart';
import 'package:pr_h23_irlandes_web/data/model/person_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/access_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/data/remote/user_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/infraestructure/global/global_methods.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:crypto/crypto.dart';



class EditCredentialPage extends StatefulWidget {
  final PersonaModel personModel;
  const EditCredentialPage({super.key, required this.personModel});

  @override
  State<EditCredentialPage> createState() => _EditCredentialPageState();
}

const List<String> list = <String>['Padre', 'Administrador', 'Docente', "Estudiante"];
PersonaDataSourceImpl personDataSource = PersonaDataSourceImpl();



class _EditCredentialPageState extends State<EditCredentialPage> {

  AccessRemoteDataSourceImpl accessDataSource = AccessRemoteDataSourceImpl();

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: MarkerId(widget.personModel.latitude.toString()+widget.personModel.longitude.toString()),
        position: LatLng(widget.personModel.latitude, widget.personModel.longitude),
        infoWindow: InfoWindow(
          title: 'New Marker',
          snippet: 'Lat: ${widget.personModel.latitude}, Lng: ${widget.personModel.longitude}',
        ),
      ),
    );
    cambiar();

    loadAccessAndSetEmail();
  }
  String aux ="";
  Future<void> loadAccessAndSetEmail() async {
    AccessModel? accessBinary = await accessDataSource.getAccessByReference(widget.personModel.id);
    print('decodificado : ' +widget.personModel.id);
    if (accessBinary != null) {
      // Decodificar el acceso de binario a String
      String decodedAccess = deco(accessBinary.acess);
      print('decodificado : ' +accessBinary.acess);
      // Establecer el controlador de email
      setState(() {
        aux = decodedAccess;
        print('decodificado : $aux');
      });
    }
  }



  //MARKERW BEGIN
  //METODO MAPAGOGOLE
  final controllerLatitude = TextEditingController();
  final controllerLongitude = TextEditingController();
  final LatLng _initialPosition = LatLng(-17.3833, -66.1667);

  final LatLngBounds _cochabambaBounds = LatLngBounds(
    //southwest: LatLng(-17.4725, -66.4512), // Límite suroeste de Cochabamba
    //northeast: LatLng(-17.3055, -65.9995), // Límite noreste de Cochabamba
    southwest: LatLng(-22.8726, -69.6447), // Límite suroeste de Bolivia
    northeast: LatLng(-9.6697, -57.4966),
  );

  late GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(widget.personModel.latitude, widget.personModel.longitude),
        14, // Zoom level
      ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    // Verificar si la nueva posición de la cámara está fuera de los límites de Cochabamba
    if (!_cochabambaBounds.contains(position.target)) {
      // Si está fuera de los límites, mover la cámara de vuelta a Cochabamba
      _mapController
          .animateCamera(CameraUpdate.newLatLngBounds(_cochabambaBounds, 0));
    }
  }

  final Set<Marker> _markers = {};
  //ssssssss
  double _markerInfoLati =0;
  double _markerInfoLong =0;

  double _markLATI =0;
  double _markLONG =0;
  void _onMapTapped(LatLng position) {
    setState(() {
      // Limpia el conjunto de marcadores antes de agregar uno nuevo
      _markers.clear();
      _markers.add(Marker(
        markerId:
        MarkerId(position.toString()), // Usar la posición como ID único
        position: position,
        infoWindow: InfoWindow(
          title: 'New Marker',
          snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
        ),
      ));
      setState(() {
        _markerInfoLati = position.latitude;
        print('Latitude: $_markerInfoLati' );
        _markLATI=_markerInfoLati;
        _markerInfoLong = position.longitude;
        print('Latitude: $_markerInfoLong' );
        _markLONG=_markerInfoLong;

      });

    });

    cambiar();
    //_writeToDirectionField();
  }
  // Campo de clase para almacenar la información del marcador


  String mostrarMarcador() {
    String latu = '';
    String longu = '';

    if (_markers.isNotEmpty) {
      latu = _markers.first.position.latitude.toString();
    }
    if (_markers.isNotEmpty) {
      longu = _markers.first.position.longitude.toString();
    }
    String eje = latu + '||' + longu;
    ;
    return eje;
  }
  void cambiar(){
    controllerLatitud.text= _markerInfoLati.toString();
    controllerLongitud.text= _markerInfoLong.toString();
  }

  String _varlo = "";
  //METODO CARGAR





  //METODO MAPAGOOGLE-FIN
  final controllerName = TextEditingController();
  final controllerFirstSurname = TextEditingController();
  final controllerSecondSurname = TextEditingController();
  final controllerCI = TextEditingController();
  final controllerCellphone = TextEditingController();
  final controllerPhone = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerDirection = TextEditingController();
  final controllerRole = TextEditingController();
  final controllerGrade = TextEditingController();
  final controllerLatitud = TextEditingController();
  final controllerLongitud = TextEditingController();
  final controllerPassword = TextEditingController();
  bool validationCheck(){
    if(controllerName.text != "" &&
        controllerFirstSurname.text != "" &&
        controllerSecondSurname.text != "" &&
        controllerCI.text != "" &&
        controllerCellphone.text != "" && controllerCellphone.text.length == 8 &&
        isValidEmail(controllerEmail.text) &&
        controllerDirection.text != ""){
      return true;
    }
    else{
      return false;
    }
  }

  bool isValidEmail(String value){
    return RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    controllerName.text=widget.personModel.name;
    controllerFirstSurname.text = widget.personModel.lastname;
    controllerSecondSurname.text = aux;
    controllerCI.text = widget.personModel.ci;
    controllerCellphone.text = widget.personModel.cellphone;
    controllerPhone.text = widget.personModel.telephone;
    //controllerEmail.text = widget.personModel.mail;

    controllerDirection.text = widget.personModel.direction;
    controllerPassword.text = "";
    controllerRole.text= widget.personModel.rol;

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 227, 233, 244),
        appBar: const AppBarCustom(
            title: ""
        ),
        body: Column(
            children: [
              Expanded(
                  child: Row(
                      children: [
                        Expanded(
                            child: ListView(
                                children: [
                                  Column(
                                      children: [

                                        Padding(
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Nombre:", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                                                  const SizedBox(height: 10),
                                                  SizedBox(
                                                      width: 250,
                                                      child: TextField(
                                                          controller: controllerName,
                                                          decoration: const InputDecoration(
                                                              border: OutlineInputBorder(),
                                                              filled: true,
                                                              fillColor: Colors.white
                                                          )
                                                      )
                                                  )
                                                ]
                                            )
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Apellido Paterno:", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                                                  const SizedBox(height: 10),
                                                  SizedBox(
                                                      width: 250,
                                                      child: TextField(
                                                          controller: controllerFirstSurname,
                                                          decoration: const InputDecoration(
                                                            border: OutlineInputBorder(),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          )
                                                      )
                                                  )
                                                ]
                                            )
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Apellido Materno:", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                                                  const SizedBox(height: 10),
                                                  SizedBox(
                                                      width: 250,
                                                      child: TextField(
                                                          controller: controllerSecondSurname,
                                                          decoration: const InputDecoration(
                                                            border: OutlineInputBorder(),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          )
                                                      )
                                                  )
                                                ]
                                            )
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Introdusca la nueva contraseña:", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                                                  const SizedBox(height: 10),
                                                  SizedBox(
                                                      width: 250,
                                                      child: TextField(
                                                          controller: controllerPassword,
                                                          decoration: const InputDecoration(
                                                            border: OutlineInputBorder(),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          )
                                                      )
                                                  )
                                                ]
                                            )
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Carnet de Identidad:", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                                                  const SizedBox(height: 10),
                                                  SizedBox(
                                                      width: 250,
                                                      child: TextField(
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter.allow(
                                                              RegExp(
                                                                "[0-9]",
                                                              ),
                                                            ),
                                                          ],
                                                          controller: controllerCI,
                                                          decoration: const InputDecoration(
                                                            border: OutlineInputBorder(),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          )
                                                      )
                                                  )
                                                ]
                                            )
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Celular:", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                                                  const SizedBox(height: 10),
                                                  SizedBox(
                                                      width: 250,
                                                      child: TextField(
                                                          maxLength: 8,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter.allow(
                                                              RegExp(
                                                                "[0-9]",
                                                              ),
                                                            ),
                                                          ],
                                                          controller: controllerCellphone,
                                                          decoration: const InputDecoration(
                                                            border: OutlineInputBorder(),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          )
                                                      )
                                                  )
                                                ]
                                            )
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Teléfono:", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                                                  const SizedBox(height: 10),
                                                  SizedBox(
                                                      width: 250,
                                                      child: TextField(
                                                          maxLength: 10,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter.allow(
                                                              RegExp(
                                                                "[0-9]",
                                                              ),
                                                            ),
                                                          ],
                                                          controller: controllerPhone,
                                                          decoration: const InputDecoration(
                                                            border: OutlineInputBorder(),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          )
                                                      )
                                                  )
                                                ]
                                            )
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Dirección:", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                                                  const SizedBox(height: 10),
                                                  SizedBox(
                                                      width: 250,
                                                      child: TextField(
                                                          controller: controllerDirection,
                                                          decoration: const InputDecoration(
                                                            border: OutlineInputBorder(),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          )
                                                      )
                                                  )
                                                ]
                                            )
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Correo:", style: TextStyle(fontSize: 15, color: Colors.blue[900])),
                                                  const SizedBox(height: 10),
                                                  SizedBox(
                                                      width: 250,
                                                      child: TextField(
                                                          controller: controllerEmail,
                                                          decoration: const InputDecoration(
                                                            border: OutlineInputBorder(),
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                          )
                                                      )
                                                  )
                                                ]
                                            )
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[900],
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              if(validationCheck()){

                                                final person = PersonaModel(
                                                    username: widget.personModel.username,
                                                    password: hashPassword(controllerPassword.text),
                                                    rol: controllerRole.text,
                                                    cellphone: controllerCellphone.text,
                                                    ci: controllerCI.text,
                                                    direction: controllerDirection.text,
                                                    id: widget.personModel.id,
                                                    fatherId: widget.personModel.fatherId,
                                                    motherId: widget.personModel.motherId,
                                                    lastname: controllerSecondSurname.text,
                                                    grade: controllerGrade.text,
                                                    mail: controllerEmail.text,
                                                    name: controllerName.text,
                                                    resgisterdate: widget.personModel.resgisterdate,
                                                    status: widget.personModel.status,
                                                    surname: controllerFirstSurname.text,
                                                    telephone: controllerPhone.text,
                                                    latitude: double.parse(controllerLatitud.text),
                                                    longitude: double.parse(controllerLongitud.text),
                                                    motherReference: "",
                                                    fatherReference: "",
                                                    updatedate: DateTime.now());

                                                try{
                                                  personDataSource.updatePerson(widget.personModel.id, person);
                                                  accessDataSource.updateAccess(widget.personModel.id, encryptToBinary(controllerPassword.text));
                                                  GlobalMethods.showSuccessSnackBar(context, "Usuario actualizado con éxito");
                                                  //Navigator.pop(context);
                                                  Navigator.pushNamed(context, '/admin_dashboard');
                                                }
                                                catch(error){
                                                  GlobalMethods.showSuccessSnackBar(context, error.toString());
                                                }
                                              }
                                              else{
                                                GlobalMethods.showErrorSnackBar(context, "Datos no válidos. Asegúrese de haber ingresado los datos correctamente.");
                                              }
                                            },
                                            child: const Text("Actualizar",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ))
                                        ),
                                        const SizedBox(height: 20)
                                      ]
                                  )
                                ]
                            )
                        )])
              )]
        )
    );
  }

  String hashPassword(String password) {
    // Encriptar la contraseña con SHA-256
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
  String deco(String binary) {
    // Divide la cadena binaria en grupos de 8 bits (1 byte)
    List<String> bytes = [];
    for (int i = 0; i < binary.length; i += 8) {
      bytes.add(binary.substring(i, i + 8));
    }

    // Convierte cada byte a un carácter
    String decodedMessage = '';
    for (String byte in bytes) {
      int charCode = int.parse(byte, radix: 2); // Convierte el byte binario a un número entero
      decodedMessage += String.fromCharCode(charCode); // Convierte el código a un carácter
    }

    return decodedMessage; // Devuelve el mensaje decodificado
  }

  String encryptToBinary(String text) {
    StringBuffer binaryString = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      // Convertir cada carácter a su código ASCII y luego a binario
      String binaryChar = text.codeUnitAt(i).toRadixString(2).padLeft(8, '0');
      binaryString.write(binaryChar);
    }

    return binaryString.toString();
  }
}