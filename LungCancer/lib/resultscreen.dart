import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'api.dart';

class PredictionListScreen extends StatefulWidget {
  @override
  _PredictionListScreenState createState() => _PredictionListScreenState();
}

class _PredictionListScreenState extends State<PredictionListScreen> {
  bool _isLoading = true;
  List<dynamic> _predictions = [];
  String? _errorMessage;

  // PC LAN IP ve port
  final String serverUrl = 'http://10.161.224.1:5079'; // Bunu kendi PC IP’sine göre değiştir

  @override
  void initState() {
    super.initState();
    _fetchPredictions();
  }

  Future<void> _fetchPredictions() async {
    if (!ApiService.isLoggedIn()) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Not logged in. Please login first.";
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$serverUrl/api/Prediction/history'),
        headers: {
          'Authorization': 'Bearer ${ApiService.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _predictions = json.decode(response.body);
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Unauthorized. Please login again.";
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to fetch data (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  double truncateTo2Decimals(dynamic value) {
    try {
      double doubleValue = value is int ? value.toDouble() : value as double;
      return (doubleValue * 100).floorToDouble() / 100;
    } catch (_) {
      return 0;
    }
  }

  Widget _buildPredictionCard(Map<String, dynamic> item) {
    String formattedDate = '';
    try {
      if (item['createdAt'] != null) {
        DateTime date = DateTime.parse(item['createdAt']);
        formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
      }
    } catch (_) {
      formattedDate = item['createdAt'] ?? '';
    }

    // Image URL oluştur
    String? imageUrl;
    if (item['imagePath'] != null && item['imagePath'].toString().isNotEmpty) {
      imageUrl = '$serverUrl${item['imagePath']}';
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey,
                      child: const Center(
                          child: Icon(Icons.broken_image, size: 50)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Confidence: ${truncateTo2Decimals(item['confidence'] ?? 0)}%",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Type: ${item['result'] ?? 'Unknown'}",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.deepPurple[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (formattedDate.isNotEmpty)
                  Text(
                    "Date: $formattedDate",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Records'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(
            child: CircularProgressIndicator(color: Colors.white))
            : _errorMessage != null
            ? Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        )
            : _predictions.isEmpty
            ? const Center(
          child: Text(
            'No records found',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
            : ListView.builder(
          itemCount: _predictions.length,
          itemBuilder: (context, index) =>
              _buildPredictionCard(_predictions[index]),
        ),
      ),
    );
  }
}
