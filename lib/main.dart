import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Version: 1.0.0',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'This app provides current weather information for your location using the OpenWeatherMap API.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Location name'),
            Text('• Current temperature'),
            Text('• Weather condition'),
          ],
        ),
      ),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String _location = '';
  double _temperature = 0;
  String _weatherType = '';
  String _iconCode = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocationWeather();
  }

  Future<void> _getCurrentLocationWeather() async {
    try {
      Position position = await _determinePosition();
      await _getWeatherData(position.latitude, position.longitude);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getWeatherData(double lat, double lon) async {
    const apiKey = '04f88d4f125d6b70ca5dca279c6ade4a';
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _location = data['city']['name'];
        _temperature = data['list'][0]['main']['temp'];
        _weatherType = data['list'][0]['weather'][0]['description'];
        _iconCode = data['list'][0]['weather'][0]['icon'];
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 187, 79, 206),
        centerTitle: true,
        title: _location.isEmpty
            ? const Text(
                'Weather loading...',
                style: TextStyle(fontSize: 28, color: Colors.white),
              )
            : Text(_location,
                style: const TextStyle(fontSize: 28, color: Colors.white)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _location.isEmpty
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'http://openweathermap.org/img/wn/$_iconCode@4x.png',
                        width: 200,
                        height: 200,
                      ),
                      Text(
                        '${_temperature.round()}°C',
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _weatherType,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
          BottomAppBar(
            color: Colors.transparent,
            padding: const EdgeInsets.only(bottom: 20),
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              iconSize: 50,
              color: const Color.fromARGB(255, 187, 79, 206),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
