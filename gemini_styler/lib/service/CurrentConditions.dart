import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrentConditions {
  final String temperature;
  final String weatherDescription;
  final String location;

  CurrentConditions({
    required this.temperature,
    required this.weatherDescription,
    required this.location,
  });
}

Future<CurrentConditions> getCurrentConditions() async {
  // Step 1: Get location from IP address
  final locationResponse = await http.get(
    Uri.parse('https://ipapi.co/json/'),
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
    },
  );

  if (locationResponse.statusCode != 200) {
    throw Exception('Failed to get location data');
  }
  final locationData = json.decode(locationResponse.body);
  final lat = locationData['latitude'];
  final lon = locationData['longitude'];
  final city = locationData['city'];
  final country = locationData['country_name'];

  // Step 2: Get weather data from OpenWeatherMap
  // Replace 'YOUR_API_KEY' with your actual OpenWeatherMap API key
  String apiKey = dotenv.env['OPEN_WEATHER_API_KEY'] ?? '';
  final weatherResponse = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric')
  );
  if (weatherResponse.statusCode != 200) {
    throw Exception('Failed to get weather data');
  }
  final weatherData = json.decode(weatherResponse.body);

  // Step 3: Extract relevant information
  final temperature = weatherData['main']['temp'].toString();
  final weatherDescription = weatherData['weather'][0]['description'];
  final location = '$city, $country';

  return CurrentConditions(
    temperature: temperature,
    weatherDescription: weatherDescription,
    location: location,
  );
}

// Example usage
// void main() async {
//   try {
//     final conditions = await getCurrentConditions();
//     print('Temperature: ${conditions.temperature}°C');
//     print('Weather: ${conditions.weatherDescription}');
//     print('Location: ${conditions.location}');
//   } catch (e) {
//     print('Error: $e');
//   }
// }