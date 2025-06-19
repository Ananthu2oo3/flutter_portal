import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Map<String, dynamic>>> _futureNotifications;

  @override
  void initState() {
    super.initState();
    _futureNotifications = fetchNotifications();
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    const String apiUrl = 'http://localhost:3000/api/notification';

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final token = prefs.getString('jwt_token') ?? '';

    if (username.isEmpty || token.isEmpty) {
      throw Exception('Missing username or token.');
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"username": username}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == 'SUCCESS') {
        return (data['data'] as List).cast<Map<String, dynamic>>();
      } else {
        throw Exception(data['message'] ?? 'No data found');
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  /// ✅ Helper to convert /Date(XXXXXXXXXX)/ to dd/MM/yyyy
  String formatSAPDate(dynamic value) {
    final regex = RegExp(r'\/Date\((\d+)\)\/');
    final match = regex.firstMatch(value.toString());
    if (match != null) {
      final millis = int.parse(match.group(1)!);
      final date = DateTime.fromMillisecondsSinceEpoch(millis);
      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";
    }
    return value.toString();
  }

  /// ✅ Helper to convert ISO 8601 duration PT... to HH:mm:ss
  String formatISOTime(String value) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(value);
    if (match != null) {
      final hours = match.group(1)?.padLeft(2, '0') ?? '00';
      final minutes = match.group(2)?.padLeft(2, '0') ?? '00';
      final seconds = match.group(3)?.padLeft(2, '0') ?? '00';
      return '$hours:$minutes:$seconds';
    }
    return value;
  }

  /// ✅ Combined helper for both
  String formatCellValue(dynamic value) {
    final stringValue = value.toString();

    if (stringValue.contains('/Date(')) {
      return formatSAPDate(stringValue);
    }

    if (stringValue.startsWith('PT')) {
      return formatISOTime(stringValue);
    }

    return stringValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20), // 20px top and bottom
          child: Text(
            'Notification Data',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureNotifications,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No notifications found.'));
              } else {
                final data = snapshot.data!;
                final columns = data.first.keys.toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        MaterialStateProperty.all(const Color.fromARGB(255, 132, 0, 0)),
                    headingTextStyle: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    columns: columns
                        .map(
                          (col) => DataColumn(
                            label: Text(col),
                          ),
                        )
                        .toList(),
                    rows: data.map((row) {
                      return DataRow(
                        cells: columns.map((col) {
                          final value = row[col] ?? '';
                          return DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              child: Text(
                                formatCellValue(value),
                                style: GoogleFonts.poppins(
                                  textStyle:
                                      const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                    dataRowColor: MaterialStateProperty.all(Colors.white),
                    dataTextStyle: GoogleFonts.poppins(
                      textStyle: const TextStyle(color: Colors.black),
                    ),
                    border: TableBorder.all(
                        color: Colors.grey.shade300, width: 0.5),
                    dividerThickness: 0.0,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
