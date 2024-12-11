import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ViewDatabaseScreen extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final Future<void> Function() onDataUpdate;

  const ViewDatabaseScreen(this.data, {required this.onDataUpdate, super.key});

  @override
  State<ViewDatabaseScreen> createState() => _ViewDatabaseScreenState();
}

class _ViewDatabaseScreenState extends State<ViewDatabaseScreen> {
  late Map<String, List<Map<String, dynamic>>> groupedData;

  @override
  void initState() {
    super.initState();
    _groupData();
  }

  void _groupData() {
    groupedData = {};
    for (var row in widget.data) {
      String timestamp = row['timestamp'] ?? 'Unknown';
      if (!groupedData.containsKey(timestamp)) {
        groupedData[timestamp] = [];
      }
      groupedData[timestamp]!.add(row);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View and Export Data',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportToCSV(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              ListView.builder(
                itemBuilder: (context, index) {
                  String timestamp = groupedData.keys.elementAt(index);
                  List<Map<String, dynamic>> group = groupedData[timestamp]!;

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Imported at: $timestamp',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _confirmDelete(context, timestamp),
                                ),
                              ],
                            ),
                            ...group.map((row) {
                              return ListTile(
                                title: Text(row['type'] ?? 'Unknown'),
                                subtitle: Text(row['value'] ?? 'Unknown'),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: groupedData.keys.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String timestamp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteData(timestamp);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteData(String timestamp) {
    setState(() {
      groupedData.remove(timestamp);
      widget.data.removeWhere((row) => row['timestamp'] == timestamp);
      
    });
    widget.onDataUpdate();
  }

  _exportToCSV(BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/carddata.csv';
    final file = File(path);

    // Tao file CSV
    String csvData = 'Type,Value,Timestamp\n';
    for (var row in widget.data) {
      csvData +=
          '${row['type'] ?? 'Unknown'},${row['value'] ?? 'Unknown'},${row['timestamp'] ?? 'Unknown'}\n';
    }

    // Ghi file
    await file.writeAsString(csvData);

    // Hien thi thong bao
    await ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data exported to CSV successfully!")),
    );
    print(path);

    //Chia se file
    await Share.shareXFiles([XFile(path)],
        text: 'Exported data from Card Scanner');
  }
}
