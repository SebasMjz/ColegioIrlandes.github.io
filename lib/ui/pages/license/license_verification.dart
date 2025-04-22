import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/License_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/license_remote_datasource.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;

class LicenseVerification extends StatefulWidget {
  final String id;
  final String? action;
  const LicenseVerification({super.key, required this.id, this.action});

  @override
  State<LicenseVerification> createState() => _LicenseVerification();
}

class _LicenseVerification extends State<LicenseVerification> {
  LicenseRemoteDatasourceImpl licenseRemoteDatasourceImpl =
      LicenseRemoteDatasourceImpl();
  final _screenshotController = ScreenshotController();

  Future<LicenseModel> refreshLicenses(String id) async {
    return licenseRemoteDatasourceImpl.getLicenseByID(id);
  }

  String formatDate(String date) {
    DateFormat inputFormat = DateFormat("MMM d, yyyy", "en_US");
    DateTime inputDate = inputFormat.parse(date);

    // Formateando la fecha al formato deseado
    String formattedDate =
        DateFormat("dd 'de' MMMM 'de' yyyy", 'es_ES').format(inputDate);
    return formattedDate;
  }

  Future<void> _generatePdf(BuildContext context, LicenseModel license) async {
    try {
      final pdf = pw.Document();

      // Captura la imagen si existe una justificación
      Uint8List? screenshot;
      if (license.justification != null && license.justification!.isNotEmpty) {
        screenshot = await _screenshotController.capture();
      }

      // Estilos personalizados
      final headerStyle = pw.TextStyle(
        fontSize: 22,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue800,
      );

      final contentStyle = pw.TextStyle(
        fontSize: 14,
        color: PdfColors.black,
      );

      final noteStyle = pw.TextStyle(
        fontSize: 12,
        color: PdfColors.grey600,
        fontStyle: pw.FontStyle.italic,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado
                pw.Center(
                  child: pw.Text(
                    'AUTORIZACIÓN DE SALIDA',
                    style: headerStyle,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(color: PdfColors.blue800, thickness: 1.5),
                pw.SizedBox(height: 30),

                // Información del estudiante
                pw.Text('DATOS DEL ESTUDIANTE',
                    style: contentStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue700,
                    )),
                pw.SizedBox(height: 15),

                pw.Text(
                    'Nombre completo: ${license.user!.name} ${license.user!.lastname} ${license.user!.surname}',
                    style: contentStyle),
                pw.SizedBox(height: 8),
                pw.Text('Curso/Grado: ${license.user!.grade}',
                    style: contentStyle),
                pw.SizedBox(height: 20),

                // Detalles de la licencia
                pw.Text('DETALLES DE LA LICENCIA',
                    style: contentStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue700,
                    )),
                pw.SizedBox(height: 15),

                pw.Text('Fecha: ${formatDate(license.license_date)}',
                    style: contentStyle),
                pw.SizedBox(height: 8),
                pw.Text('Hora de salida: ${license.departure_time}',
                    style: contentStyle),
                pw.SizedBox(height: 8),
                pw.Text('Hora de regreso: ${license.return_time}',
                    style: contentStyle),
                pw.SizedBox(height: 8),
                pw.Text('Motivo: ${license.reason}', style: contentStyle),
                pw.SizedBox(height: 30),

                // Justificación
                pw.Text('JUSTIFICATIVO',
                    style: contentStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue700,
                    )),
                pw.SizedBox(height: 10),

                if (license.justification != null &&
                    license.justification!.isNotEmpty &&
                    screenshot != null)
                  pw.Container(
                    alignment: pw.Alignment.center,
                    child: pw.Image(
                      pw.MemoryImage(screenshot),
                      width: 300,
                      height: 200,
                      fit: pw.BoxFit.contain,
                    ),
                  )
                else
                  pw.Text(
                    'No se adjuntó justificativo',
                    style: contentStyle.copyWith(color: PdfColors.grey),
                  ),

                // Pie de página
                pw.SizedBox(height: 40),
                pw.Divider(color: PdfColors.blue800),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Generado el ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: noteStyle,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Guardar y descargar PDF
      final Uint8List pdfBytes = await pdf.save();
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final fileName =
          'Licencia_${license.user!.name}_${license.user!.lastname}.pdf';

      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();

      html.Url.revokeObjectUrl(url);

      // Mostrar notificación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF generado exitosamente'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar el PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showMessageDialog(
      BuildContext context, String iconSource, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              iconSource,
              width: 30,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF044086),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text(
              "Aceptar",
              style: TextStyle(
                color: Color(0xFF044086),
                fontSize: 15,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (title == 'Correcto') {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final leftPadding = screenWidth * 0.075;
    final rightPadding = screenWidth * 0.075;

    String formatDate(String date) {
      DateFormat inputFormat = DateFormat("MMM d, yyyy", "en_US");
      DateTime inputDate = inputFormat.parse(date);

      // Formateando la fecha al formato deseado
      String formattedDate =
          DateFormat("dd 'de' MMMM 'de' yyyy", 'es_ES').format(inputDate);
      return formattedDate;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE3E9F4),
      appBar: AppBar(
          toolbarHeight: 75,
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth * 0.6,
              constraints: const BoxConstraints(
                minWidth: 700.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE3E9F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: FutureBuilder<LicenseModel>(
                    future: refreshLicenses(widget.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error al cargar la licencia.'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(
                            child: Text('No se encontró la licencia.'));
                      } else {
                        LicenseModel? license = snapshot.data;
                        return Screenshot(
                          controller: _screenshotController,
                          child: ListView.builder(
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.all(10),
                                margin: EdgeInsets.only(
                                    top: 20,
                                    bottom: 10,
                                    left: leftPadding,
                                    right: rightPadding),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    const Center(
                                      child: Image(
                                          image:
                                              AssetImage('assets/ui/logo.png'),
                                          width: 100),
                                    ),
                                    const Text('Detalles de la licencia',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Color(0xFF044086),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      children: [
                                        CustomRow('Estudiante: ',
                                            '${license!.user!.name} ${license.user!.lastname} ${license.user!.surname}'),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CustomRow(
                                            'Curso: ', license.user!.grade),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CustomRow('Fecha: ',
                                            formatDate(license.license_date)),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CustomRow(
                                            'De: ', license.departure_time),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CustomRow(
                                            'Hasta: ', license.return_time),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        CustomRow('Motivo: ', license.reason),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Align(
                                          alignment: Alignment.center,
                                          child: Text('Justificativo:',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Color(0xFF044086),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        if (license.justification != '')
                                          Center(
                                            child: Image.network(
                                              license.justification,
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                return const Text(
                                                    'Error al cargar la imagen');
                                              },
                                            ),
                                          ),
                                        if (license.justification == '')
                                          const Text(
                                              'El usuario no subio un justificativo')
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  )),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Obtener la licencia del futuro
          LicenseModel license = await refreshLicenses(widget.id);
          // Generar y descargar el PDF
          await _generatePdf(context, license);
        },
        child: Icon(Icons.download),
      ),
    );
  }
}

class CustomRow extends StatelessWidget {
  const CustomRow(this.label, this.text, {super.key});
  final String label;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF044086),
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(text, style: const TextStyle(color: Colors.black87, fontSize: 16)),
      ],
    );
  }
}
