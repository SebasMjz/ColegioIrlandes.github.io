import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';  
import 'package:intl/intl.dart';
import 'package:pr_h23_irlandes_web/data/model/notice_model.dart';
import 'package:pr_h23_irlandes_web/data/remote/notice_remote_datasource.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/app_bar_custom_prueba.dart';
import 'package:pr_h23_irlandes_web/ui/pages/Calendar/Calendar_page.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_drawer.dart';
import 'package:pr_h23_irlandes_web/ui/widgets/custom_text_field.dart';

class ManagementNoticePage extends StatefulWidget {
  final DateTime? selectedDate;
  ManagementNoticePage({required this.selectedDate});

  @override
  _ManagementNoticePageState createState() => _ManagementNoticePageState();
}

class _ManagementNoticePageState extends State<ManagementNoticePage> {
  String _tipo = 'Reunion';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late DateTime _currentDateTime;
  bool isEditable = false;
  NoticeModel? noticeSelect;
  String tituloAux = '';
  String typeAux = '';
  late DateTime registerDateAux;
  String descriptionAux = '';
  bool isHovered = false;
  final formKey = GlobalKey<FormState>();

  final noticeRemoteDataSource = NoticeRemoteDataSourceImpl();
  
  final Set<int> selectedRows = Set<int>();
  List<NoticeModel> notices = [];
  String datePickerText = 'Seleccione la fecha limite';

  @override
  void initState() {
    super.initState();
    _currentDateTime = DateTime.now();
    loadNotices();
  }

  Future<void> loadNotices() async {
    final loadedNotices = await noticeRemoteDataSource.getNotice();
    setState(() {
      notices = loadedNotices.where((notice) => notice.status).toList();
    });
  }

  void showConfirmationDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Confirmación',
      desc: message,
      btnOkOnPress: () {},
      width: MediaQuery.of(context).size.width * 0.8, // Responsive width
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Administración de anuncios',
          style: GoogleFonts.barlow(
            textStyle: TextStyle(
              color: Color(0xFF3D5269),
              fontSize: isMobile ? 18 : 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 75,
        elevation: 0,
        leading: Center(
          child: Builder(
            builder: (context) => IconButton(
              iconSize: isMobile ? 40 : 50,
              icon: Image(image: AssetImage('assets/ui/barra-de-menus.png')),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        actions: [
          IconButton(
            iconSize: 2,
            icon: Image.asset(
              'assets/ui/home.png',
              width: isMobile ? 40 : 50,
            ),
            onPressed: () => Navigator.pushNamed(context, '/notice_main'),
          )
        ],
      ),
      drawer: CustomDrawer(),
      body: isMobile 
          ? _buildMobileLayout()
          : _buildDesktopTabletLayout(isTablet),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              margin: const EdgeInsets.only(bottom: 20),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: 'Titulo',
                        controller: _titleController,
                        validator: (value) => value!.isEmpty ? 'Por favor, ingresa un título.' : null,
                      ),
                      SizedBox(height: 16),
                      _buildTypeDropdown(),
                      SizedBox(height: 16),
                      CustomTextField(
                        label: 'Descripción',
                        maxLines: 4,
                        controller: _descriptionController,
                        validator: (value) => value!.isEmpty ? 'Por favor, ingresa una descripción.' : null,
                      ),
                      SizedBox(height: 16),
                      _buildActionButtons(true),
                    ],
                  ),
                ),
              ),
            ),
            
            // Notices Table Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width * 1.5,
                  child: _buildNoticesTable(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTabletLayout(bool isTablet) {
    return Row(
      children: [
        Expanded(
          flex: isTablet ? 2 : 1,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            margin: EdgeInsets.all(isTablet ? 12 : 20),
            color: Colors.white,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 12 : 20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Titulo',
                      controller: _titleController,
                      validator: (value) => value!.isEmpty ? 'Por favor, ingresa un título.' : null,
                    ),
                    SizedBox(height: 16),
                    _buildTypeDropdown(),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Descripción',
                      maxLines: 6,
                      controller: _descriptionController,
                      validator: (value) => value!.isEmpty ? 'Por favor, ingresa una descripción.' : null,
                    ),
                    Spacer(),
                    _buildActionButtons(false),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: isTablet ? 3 : 2,
          child: Container(
            margin: EdgeInsets.all(isTablet ? 12 : 20),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: isTablet ? 800 : 1000,
                  child: _buildNoticesTable(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _tipo,
      onChanged: (value) => setState(() => _tipo = value!),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.white, width: 0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: const [
        DropdownMenuItem<String>(
          value: 'Reunion',
          child: Text('Reunion', style: TextStyle(color: Color(0xFF044086))),
        ),
        DropdownMenuItem<String>(
          value: 'Evento',
          child: Text('Evento', style: TextStyle(color: Color(0xff044086))),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Wrap(
      spacing: isMobile ? 8 : 16,
      runSpacing: isMobile ? 8 : 0,
      children: [
        _buildActionButton(
          icon: 'assets/ui/insertar.png',
          label: 'Registrar',
          onTap: isEditable
              ? null
              : () async {
                  if (formKey.currentState!.validate()) {
                    final newNotice = NoticeModel(
                      id: '',
                      title: _titleController.text,
                      type: _tipo,
                      description: _descriptionController.text,
                      status: true,
                      registerCreated: widget.selectedDate ?? DateTime.now(),
                      updateDate: _currentDateTime,
                    );

                    showConfirmationDialog('¡Se agregó correctamente!');
                    await noticeRemoteDataSource.addNotice(newNotice);
                    loadNotices();
                    setState(() {
                      _titleController.text = '';
                      _tipo = 'Reunion';
                      _descriptionController.text = '';
                    });
                  }
                },
        ),
        _buildActionButton(
          icon: 'assets/ui/limpiar.png',
          label: 'Limpiar',
          onTap: () {
            setState(() {
              isEditable = false;
              noticeSelect = null;
              _titleController.text = '';
              _tipo = 'Reunion';
              _descriptionController.text = '';
            });
          },
        ),
        _buildActionButton(
          icon: 'assets/ui/editar.png',
          label: 'Editar Anuncio',
          onTap: () {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              animType: AnimType.scale,
              title: 'Editar Anuncio',
              desc: '¿Seguro que quieres editar este anuncio?',
              btnCancelOnPress: () {},
              btnOkOnPress: isEditable
                  ? () async {
                      if (formKey.currentState!.validate() && noticeSelect != null) {
                        noticeSelect!.title = _titleController.text;
                        noticeSelect!.type = _tipo;
                        noticeSelect!.description = _descriptionController.text;
                        noticeSelect!.updateDate = _currentDateTime;
                        noticeSelect!.status = true;

                        await noticeRemoteDataSource.updateNotice(noticeSelect!);
                        loadNotices();

                        setState(() {
                          isEditable = false;
                          noticeSelect = null;
                          _titleController.text = '';
                          _tipo = 'Reunion';
                          _descriptionController.text = '';
                        });
                      }
                    }
                  : null,
              width: MediaQuery.of(context).size.width * 0.8,
            ).show();
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({required String icon, required String label, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              icon,
              width: 30,
              height: 30,
              color: Color(0xFF044086),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF044086),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticesTable() {
    return FutureBuilder(
      future: loadNotices(),
      builder: (context, snapshot) {
        if (notices.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          return DataTable(
            columnSpacing: 20,
            dataRowMinHeight: 25,
            dataRowMaxHeight: 150,
            showCheckboxColumn: false,
            columns: [
              DataColumn(label: Text('Título')),
              DataColumn(label: Text('Tipo')),
              DataColumn(label: Text('Descripción')),
              DataColumn(label: Text('Eliminar')),
            ],
            rows: notices.asMap().entries.map((entry) {
              final index = entry.key;
              final anuncio = entry.value;

              return DataRow(
                selected: selectedRows.contains(index),
                onSelectChanged: (isSelected) {
                  setState(() {
                    if (isSelected!) {
                      selectedRows.add(index);
                      noticeSelect = anuncio;
                      isEditable = true;
                      _titleController.text = anuncio.title;
                      _tipo = anuncio.type;
                      _descriptionController.text = anuncio.description;
                    } else {
                      selectedRows.remove(index);
                    }
                  });
                },
                cells: [
                  DataCell(
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 150),
                      child: Text(
                        anuncio.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(anuncio.type)),
                  DataCell(
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300),
                      child: Text(
                        anuncio.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: InkWell(
                        onTap: () {
                          noticeSelect = notices[index];
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.warning,
                            animType: AnimType.scale,
                            title: 'Eliminar Anuncio',
                            desc: '¿Seguro que quieres eliminar este anuncio?',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () async {
                              noticeSelect!.status = false;
                              await noticeRemoteDataSource.softDeleteNotice(noticeSelect!);
                              loadNotices();
                              setState(() {
                                selectedRows.remove(index);
                                noticeSelect = null;
                              });
                            },
                            width: MediaQuery.of(context).size.width * 0.8,
                          ).show();
                        },
                        child: Icon(
                          Icons.delete,
                          size: 25,
                          color: Color(0xFF044086),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        }
      },
    );
  }
}