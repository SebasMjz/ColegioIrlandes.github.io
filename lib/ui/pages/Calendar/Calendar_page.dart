import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pr_h23_irlandes_web/ui/pages/notice/notice_management_page.dart';
import 'package:pr_h23_irlandes_web/data/model/notice_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/notice_remote_datasource.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate = DateTime.now();
  final ValueNotifier<List<String>> _selectedEvents = ValueNotifier([]);
  final noticeRemoteDataSource = NoticeRemoteDataSourceImpl();
  List<NoticeModel> notices = [];
  late Map<DateTime, List<String>> _events;

  @override
  void initState() {
    super.initState();
    _events = _loadEvents();
    _selectedEvents.value =
        _events[_selectedDate] ?? []; // Inicializar eventos seleccionados
    loadNotices();
  }

  Map<DateTime, List<String>> _loadEvents() {
    Map<DateTime, List<String>> events = {};

    // Agregar eventos para cada fecha con notificaciones
    for (var notice in notices) {
      DateTime noticeDate = notice.registerCreated;
      DateTime dateWithoutTime =
          DateTime(noticeDate.year, noticeDate.month, noticeDate.day);

      // Agregar la fecha al mapa de eventos
      if (!events.containsKey(dateWithoutTime)) {
        events[dateWithoutTime] = [];
      }

      // Agregar la notificación como un evento para esa fecha
      events[dateWithoutTime]?.add(notice.title);
    }

    return events;
  }

  Future<void> loadNotices() async {
    final loadedNotices = await noticeRemoteDataSource.getNotice();
    setState(() {
      notices = loadedNotices.where((notice) => notice.status).toList();
      _events =
          _loadEvents(); // Asegurar que el calendario se actualiza con los eventos
    });
  }

  Widget _buildEventList() {
    final eventsForSelectedDay = _events[_selectedDate] ?? [];

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'La fecha Seleccionada es  ${DateFormat('yyyy-MM-dd').format(_selectedDate)}:',
            style: TextStyle(color: Color(0xFF044086), fontSize: 20),
          ),
          SizedBox(height: 10),
          for (var event in eventsForSelectedDay)
            Text(
              event,
              style: TextStyle(fontSize: 16),
            ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showEventDetailsModal(
      BuildContext context, List<NoticeModel> notificationsForSelectedDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eventos y Reuniones del Día',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF044086),
                  ),
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey[300]),
                SizedBox(height: 10),
                if (notificationsForSelectedDate.isEmpty)
                  Center(
                    child: Text(
                      'No hay eventos para esta fecha.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ),
                if (notificationsForSelectedDate.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: 400), // Limita la altura del contenido
                    child: ListView(
                      shrinkWrap: true,
                      children: notificationsForSelectedDate.map((notice) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: notice.type == "Evento"
                                  ? Color(0xFF720E0F)
                                  : Color(0xFF044086),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      notice.type == "Evento"
                                          ? Icons.event
                                          : Icons.people,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      notice.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Tipo: ${notice.type}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  notice.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.warning,
                                        animType: AnimType.scale,
                                        title: 'Eliminar Anuncio',
                                        desc:
                                            '¿Seguro que quieres eliminar este anuncio?',
                                        btnCancelOnPress: () {},
                                        btnOkOnPress: () async {
                                          await noticeRemoteDataSource
                                              .softDeleteNotice(notice);
                                          loadNotices();
                                          Navigator.pop(
                                              context); // Cierra el modal después de eliminar
                                        },
                                        width: 400,
                                      ).show();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Color.fromARGB(
                                                  255, 187, 204, 35)),
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                              EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 10)),
                                    ),
                                    child: Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Cierra el modal
                    },
                    child: Text(
                      'Cerrar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF044086),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // Verifica si hay eventos para la fecha seleccionada
    final hasEvents = _events.containsKey(
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day));

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario de Notificaciones'),
        backgroundColor: Color(0xFF044086),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              focusedDay: _selectedDate,
              firstDay: DateTime.utc(2023, 04, 15),
              lastDay: DateTime.utc(2050, 04, 15),
              eventLoader: (day) {
                DateTime normalizedDay = DateTime(day.year, day.month, day.day);
                return _events[normalizedDay] ?? [];
              },
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (DateTime date) {
                return isSameDay(_selectedDate, date);
              },
              onDaySelected: (selectedDate, focusedDate) {
                setState(() {
                  _selectedDate = selectedDate;
                });
                _selectedEvents.value = _events[selectedDate] ?? [];
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 10, // Ajusta la posición hacia abajo
                      left: 0, // Centra el punto debajo de la fecha
                      right: 0,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Color(0xFF044086), // Color del punto
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: hasEvents
                    ? () {
                        // Filtra las notificaciones para la fecha seleccionada
                        final notificationsForSelectedDate =
                            notices.where((notice) {
                          final noticeDate = notice.registerCreated;
                          return noticeDate.year == _selectedDate.year &&
                              noticeDate.month == _selectedDate.month &&
                              noticeDate.day == _selectedDate.day;
                        }).toList();

                        // Muestra el modal con los detalles de los eventos
                        _showEventDetailsModal(
                            context, notificationsForSelectedDate);
                      }
                    : null, // Deshabilita el botón si no hay eventos
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      hasEvents ? Color(0xFF044086) : Colors.grey),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                ),
                child: Text(
                  'Ver Eventos y Reuniones del Día',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManagementNoticePage(
                      selectedDate: _selectedDate,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF064187)),
              ),
              child: Text(
                'Registrar Notificación para esta Fecha',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Calendar Page',
    home: CalendarPage(),
  ));
}
