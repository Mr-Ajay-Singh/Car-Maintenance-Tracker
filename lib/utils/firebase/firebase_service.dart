import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseService {
  static FirebaseService? _instance;
  late final FirebaseRemoteConfig _remoteConfig;
  
  FirebaseService._();
  
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }
  
  Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // Initialize Remote Config
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      
      // Set default values
      await _remoteConfig.setDefaults({
        'hello_world': 'Hello from default config!',
        'dynamic_banner': '''
          Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎉 Welcome to Protein Tracker!',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Track your daily protein intake and reach your goals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          )
        '''
      });
      
      // Fetch and activate
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
    }
  }
  
  String getHelloWorld() {
    try {
      debugPrint("Hello World:- ${_remoteConfig.getString('hello_world')}");
      return _remoteConfig.getString('hello_world');
    } catch (e) {
      debugPrint('Error fetching hello_world: $e');
      return 'Error fetching value';
    }
  } 
  
  String getDynamicBanner() {
    try {
      return _remoteConfig.getString('dynamic_banner');
    } catch (e) {
      debugPrint('Error fetching dynamic_banner: $e');
      return '';
    }
  }
}
