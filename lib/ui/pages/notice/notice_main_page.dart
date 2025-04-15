import 'package:flutter/material.dart';
import 'package:pr_h23_irlandes_web/data/model/notice_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/notice_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom_prueba.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticeMainPage extends StatefulWidget {
  const NoticeMainPage({Key? key}) : super(key: key);

  @override
  _NoticeMainPageState createState() => _NoticeMainPageState();
}

class _NoticeMainPageState extends State<NoticeMainPage> {
  final TextEditingController _controller = TextEditingController();
  final NoticeRemoteDataSource noticeRemoteDataSource = NoticeRemoteDataSourceImpl();
  List<NoticeModel> noticeList = [];
  List<NoticeModel> allNotices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    try {
      final notices = await noticeRemoteDataSource.getNotice();
      setState(() {
        allNotices = notices.where((notice) => notice.status == true).toList();
        noticeList = List.from(allNotices);
        filterNotices("");
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando los anuncios: $error")),
      );
    }
  }

  void filterNotices(String searchTerm) {
    setState(() {
      noticeList = allNotices.where((notice) {
        final matchesSearch = searchTerm.isEmpty ||
            notice.title.toLowerCase().contains(searchTerm.toLowerCase());
        final isWithinDateRange = notice.registerCreated.isAfter(
                DateTime.now().subtract(Duration(days: 1))) &&
            notice.registerCreated.isBefore(DateTime.now().add(Duration(days: 14)));
        return matchesSearch && isWithinDateRange;
      }).toList();
    });
  }

  void _showMonthlyEventsModal() {
    final monthlyEvents = allNotices.where((notice) {
      final now = DateTime.now();
      return notice.registerCreated.month == now.month && notice.registerCreated.year == now.year;
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Eventos y Reuniones del Mes"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: monthlyEvents.length,
              itemBuilder: (context, index) {
                final notice = monthlyEvents[index];
                final isPastEvent = notice.registerCreated.isBefore(DateTime.now());

                return ListTile(
                  leading: Icon(
                    notice.type == "Reunion" ? Icons.people : Icons.event,
                    color: notice.type == "Reunion" ? Colors.blue : Colors.red,
                  ),
                  title: Text(
                    notice.title,
                    style: TextStyle(
                      color: isPastEvent ? Colors.grey : Colors.black,
                      decoration: isPastEvent ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                    "Fecha: ${notice.registerCreated.toIso8601String().substring(0, 10)}",
                    style: TextStyle(
                      color: isPastEvent ? Colors.grey : Colors.black54,
                    ),
                  ),
                  tileColor: notice.type == "Reunion" ? Colors.blue[50] : Colors.red[50],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return WillPopScope(
      onWillPop: () async {
        final confirmLogout = await _confirmLogout2(context);
        return !confirmLogout;
      },
      child: Scaffold(
        appBar: const AppBarCustomPrueba(title: 'Anuncios'),
        drawer: CustomDrawer(),
        backgroundColor: const Color(0XFFE3E9F4),
        body: Padding(
          padding: EdgeInsets.only(
            top: 0,
            bottom: isMobile ? 20 : 90,
            left: isMobile ? 10 : isTablet ? 30 : 90,
            right: isMobile ? 10 : isTablet ? 30 : 90,
          ),
          child: Column(
            children: [
              _buildSearchBar(isMobile, isTablet),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showMonthlyEventsModal,
                child: Text("Ver Eventos y Reuniones del Mes"),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _buildNoticeList(isMobile, isTablet),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : isTablet ? 100 : 350,
      ),
      child: isMobile
          ? Column(
              children: [
                Row(
                  children: [
                    const Image(
                      image: AssetImage('assets/ui/lupa.png'),
                      width: 35,
                      height: 35,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Buscar',
                        controller: _controller,
                        onChanged: (p0) {
                          if (p0 != null) {
                            filterNotices(p0);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register_notice');
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xFF044086)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(
                            color: Color(0xFF044086),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Crear anuncio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const Image(
                  image: AssetImage('assets/ui/lupa.png'),
                  width: 35,
                  height: 35,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: 'Buscar',
                    controller: _controller,
                    onChanged: (p0) {
                      if (p0 != null) {
                        filterNotices(p0);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 40),
                SizedBox(
                  width: 150,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register_notice');
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xFF044086)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(
                            color: Color(0xFF044086),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Crear anuncio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNoticeList(bool isMobile, bool isTablet) {
    final meetingNotices = noticeList.where((notice) => notice.type == "Reunion").toList();
    final eventNotices = noticeList.where((notice) => notice.type == "Evento").toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          if (meetingNotices.isNotEmpty) _buildSection("Reuniones", meetingNotices, isMobile, isTablet),
          if (eventNotices.isNotEmpty) _buildSection("Eventos", eventNotices, isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<NoticeModel> notices, bool isMobile, bool isTablet) {
    return Column(
      children: [
        _buildSectionTitle(title),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : isTablet ? 2 : 3,
            childAspectRatio: isMobile ? 1.5 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: notices.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return buildNoticeCard(notices[index], isMobile);
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 20,
            color: const Color(0xFF044086),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNoticeCard(NoticeModel notice, bool isMobile) {
    final cardColor = notice.type == "Evento" ? Color(0xFF720E0F) : Color(0xFF044086);
    final formattedDate = notice.registerCreated.toIso8601String().substring(0, 10);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: cardColor,
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isMobile ? 4 : 8),
            Text(
              notice.description,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 12 : 14,
              ),
              maxLines: isMobile ? 3 : 5,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isMobile ? 4 : 8),
            Text(
              'Fecha: $formattedDate',
              style: TextStyle(
                color: Colors.white70,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmLogout2(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Está seguro de que desea cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
    return confirm ?? false;
  }

  void _logout2(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('personId');
    Navigator.pushReplacementNamed(context, '/');
  }
}