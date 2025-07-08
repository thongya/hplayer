import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  runApp(const AgeCalculatorApp());
}

class AgeCalculatorApp extends StatefulWidget {
  const AgeCalculatorApp({super.key});

  @override
  _AgeCalculatorAppState createState() => _AgeCalculatorAppState();
}

class _AgeCalculatorAppState extends State<AgeCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTheme = prefs.getString('themeMode');
    setState(() {
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });
  }

  Future<void> _saveThemePreference(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }
    await prefs.setString('themeMode', themeString);
  }

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.system) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
      _saveThemePreference(_themeMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Age Calculator',
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      home: AgeCalculatorScreen(onToggleTheme: _toggleTheme),
    );
  }
}

class AgeCalculatorScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const AgeCalculatorScreen({super.key, required this.onToggleTheme});

  @override
  _AgeCalculatorScreenState createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _referenceDateController =
      TextEditingController();

  DateTime? _birthDate;
  DateTime _referenceDate = DateTime.now(); // Default to today

  Map<String, String> _ageDetails = {};
  int _daysUntilNextBirthday = 0;
  int _monthsUntilNextBirthday = 0;
  List<String> _upcomingBirthdays = []; // Store upcoming birthdays

  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy');
  final DateFormat _birthdayFormatter = DateFormat(
    'd MMMM, yyyy - EEEE',
  ); // For displaying date and day

  @override
  void initState() {
    super.initState();
    _referenceDateController.text = _dateFormatter.format(_referenceDate);
    _calculateAge();
  }

  void _calculateAge() {
    if (_birthDate == null) {
      setState(() {
        _ageDetails = {'error': 'Please select your birth date.'};
        _upcomingBirthdays = [];
      });
      return;
    }

    if (_referenceDate.isBefore(_birthDate!)) {
      setState(() {
        _ageDetails = {
          'error': 'Reference date must be after or equal to birth date.',
        };
        _upcomingBirthdays = [];
      });
      return;
    }

    final birth = _birthDate!;
    final reference = _referenceDate;

    int years = reference.year - birth.year;
    int months = reference.month - birth.month;
    int days = reference.day - birth.day;

    if (days < 0) {
      months--;
      days += DateTime(reference.year, reference.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    final totalDays = reference.difference(birth).inDays;
    final totalMonths = years * 12 + months;
    final weeks = totalDays ~/ 7;
    final remainingDays = totalDays % 7;

    final totalHours = totalDays * 24;
    final totalMinutes = totalHours * 60;
    final totalSeconds = totalMinutes * 60;

    // Next Birthday Calculation
    DateTime nextBirthday;
    if (reference.month < birth.month ||
        (reference.month == birth.month && reference.day <= birth.day)) {
      // Birthday is later this year
      nextBirthday = DateTime(reference.year, birth.month, birth.day);
    } else {
      // Birthday is next year
      nextBirthday = DateTime(reference.year + 1, birth.month, birth.day);
    }

    final difference = nextBirthday.difference(reference);
    final monthsUntil =
        (nextBirthday.year - reference.year) * 12 +
        nextBirthday.month -
        reference.month -
        (nextBirthday.day < reference.day ? 1 : 0);
    final daysUntil = difference.inDays;

    // Calculate upcoming birthdays for the next 5 years
    List<String> upcomingBirthdays = [];
    for (int i = 0; i < 5; i++) {
      final futureYear =
          reference.month < birth.month ||
              (reference.month == birth.month && reference.day <= birth.day)
          ? reference.year + i
          : reference.year + i + 1;
      final futureBirthday = DateTime(futureYear, birth.month, birth.day);
      upcomingBirthdays.add(_birthdayFormatter.format(futureBirthday));
    }

    setState(() {
      _monthsUntilNextBirthday = monthsUntil.clamp(0, 12);
      _daysUntilNextBirthday = daysUntil.clamp(0, 365);
      _upcomingBirthdays = upcomingBirthdays;
      _ageDetails = {
        'yearsMonthsDays': '$years years, $months months, and $days days',
        'totalMonths': '$totalMonths months',
        'totalWeeks': '$weeks weeks and $remainingDays days',
        'totalDays': '$totalDays days',
        'totalHours': '$totalHours hours',
        'totalMinutes': '$totalMinutes minutes',
        'totalSeconds': '$totalSeconds seconds',
      };
    });
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = _dateFormatter.format(picked);
      });
      _calculateAge();
    }
  }

  Future<void> _pickReferenceDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _referenceDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2300),
    );
    if (picked != null && picked != _referenceDate) {
      setState(() {
        _referenceDate = picked;
        _referenceDateController.text = _dateFormatter.format(picked);
      });
      _calculateAge();
    }
  }

  void _resetForm() {
    setState(() {
      _birthDate = null;
      _birthDateController.clear();
      _referenceDate = DateTime.now();
      _referenceDateController.text = _dateFormatter.format(_referenceDate);
      _ageDetails.clear();
      _daysUntilNextBirthday = 0;
      _monthsUntilNextBirthday = 0;
      _upcomingBirthdays = [];
    });
    _calculateAge();
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text(
              'Age Calculation Result',
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Birth Date: ${_birthDateController.text}'),
            pw.Text('Reference Date: ${_referenceDateController.text}'),
            pw.SizedBox(height: 10),
            ..._ageDetails.entries.map(
              (entry) => pw.Text(
                '${entry.key.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')} : ${entry.value}',
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Upcoming Birthdays:'),
            ..._upcomingBirthdays.map((birthday) => pw.Text(birthday)).toList(),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/age_report.pdf');
    await file.writeAsBytes(await pdf.save());

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        return await pdf.save();
      },
    );
  }

  Future<File> _generatePDFForSharing() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text(
              'Age Calculation Result',
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Birth Date: ${_birthDateController.text}'),
            pw.Text('Reference Date: ${_referenceDateController.text}'),
            pw.SizedBox(height: 10),
            ..._ageDetails.entries.map(
              (entry) => pw.Text(
                '${entry.key.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')} : ${entry.value}',
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Upcoming Birthdays:'),
            ..._upcomingBirthdays.map((birthday) => pw.Text(birthday)).toList(),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/age_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> _generateCSVForSharing() async {
    final data = [
      ['Field', 'Value'],
      ['Birth Date', _birthDateController.text],
      ['Reference Date', _referenceDateController.text],
      ['Exact Age', _ageDetails['yearsMonthsDays'] ?? 'N/A'],
      ['Total Months', _ageDetails['totalMonths'] ?? 'N/A'],
      ['Total Weeks', _ageDetails['totalWeeks'] ?? 'N/A'],
      ['Total Days', _ageDetails['totalDays'] ?? 'N/A'],
      ['Total Hours', _ageDetails['totalHours'] ?? 'N/A'],
      ['Total Minutes', _ageDetails['totalMinutes'] ?? 'N/A'],
      ['Total Seconds', _ageDetails['totalSeconds'] ?? 'N/A'],
      [
        'Next Birthday in',
        '$_monthsUntilNextBirthday months and $_daysUntilNextBirthday days',
      ],
      for (int i = 0; i < _upcomingBirthdays.length; i++)
        ['Upcoming Birthday ${i + 1}', _upcomingBirthdays[i]],
    ];

    String csv = const ListToCsvConverter().convert(data);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/age_report.csv');
    await file.writeAsString(csv);
    return file;
  }

  Future<void> _shareResults() async {
    if (_ageDetails.containsKey('error') || _ageDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please calculate age before sharing.')),
      );
      return;
    }

    final ageData = _ageDetails.entries
        .map(
          (e) =>
              "${e.key.replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m.group(0)}')}: ${e.value}",
        )
        .join('\n');

    final upcomingBirthdaysText = _upcomingBirthdays
        .asMap()
        .entries
        .map((e) => "Upcoming Birthday ${e.key + 1}: ${e.value}")
        .join('\n');

    final text =
        '''
🎂 Age Calculation Results:
----------------------------
Birth Date: ${_birthDateController.text}
Reference Date: ${_referenceDateController.text}
$ageData
🎉 Next birthday in $_monthsUntilNextBirthday months and $_daysUntilNextBirthday days!
----------------------------
Upcoming Birthdays:
$upcomingBirthdaysText
''';

    // Generate PDF and CSV files for sharing
    final pdfFile = await _generatePDFForSharing();
    final csvFile = await _generateCSVForSharing();

    // Share text and files
    await Share.shareXFiles(
      [
        XFile(pdfFile.path, mimeType: 'application/pdf'),
        XFile(csvFile.path, mimeType: 'text/csv'),
      ],
      text: text,
      subject: 'My Age Report',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Age Calculator'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.dark_mode
                  : Theme.of(context).brightness == Brightness.light
                  ? Icons.light_mode
                  : Icons.brightness_auto,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: 'Birth Date',
                  hintText: 'Select your birth date or DD-MM-YYYY',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickBirthDate(context),
                  ),
                ),
                onTap: () => _pickBirthDate(context),
                readOnly: true,
                validator: (value) {
                  if (_birthDate == null) return 'Please select birth date';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenceDateController,
                decoration: InputDecoration(
                  labelText: 'Reference Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickReferenceDate(context),
                  ),
                ),
                onTap: () => _pickReferenceDate(context),
                readOnly: true,
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (!_ageDetails.containsKey('error') && _ageDetails.isNotEmpty)
                Text(
                  'Current age : ${_ageDetails['yearsMonthsDays']!}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              if (_daysUntilNextBirthday == 0 && _birthDate != null)
                const Text(
                  '🎉 Happy Birthday!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              else if (_daysUntilNextBirthday > 0)
                Text(
                  '🎉 Next birthday in $_monthsUntilNextBirthday months and $_daysUntilNextBirthday days!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 10),
              if (_upcomingBirthdays.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text('Upcoming Birthdays (Next 5 Years)'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _upcomingBirthdays
                        .asMap()
                        .entries
                        .map((e) => Text('${e.key + 1}. ${e.value}'))
                        .toList(),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _calculateAge,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate Age'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_ageDetails.containsKey('error'))
                Text(
                  _ageDetails['error']!,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                )
              else if (_ageDetails.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Summary of your life'),
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Exact Age'),
                      subtitle: Text(_ageDetails['yearsMonthsDays']!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('In Months'),
                      subtitle: Text(_ageDetails['totalMonths']!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.weekend),
                      title: const Text('In Weeks'),
                      subtitle: Text(_ageDetails['totalWeeks']!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.today),
                      title: const Text('In Days'),
                      subtitle: Text(_ageDetails['totalDays']!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('In Hours'),
                      subtitle: Text(_ageDetails['totalHours']!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.timer),
                      title: const Text('In Minutes'),
                      subtitle: Text(_ageDetails['totalMinutes']!),
                    ),
                    ListTile(
                      leading: const Icon(Icons.hourglass_top),
                      title: const Text('In Seconds'),
                      subtitle: Text(_ageDetails['totalSeconds']!),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _generatePDF,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Export PDF'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _generateCSVForSharing,
                          icon: const Icon(Icons.file_download),
                          label: const Text('Export CSV'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _shareResults,
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
