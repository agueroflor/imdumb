import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/local/shared_prefs_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _sharedPrefsService = serviceLocator<SharedPrefsService>();

  String _initialMessage = 'Loading...';
  bool _experimentalSearchEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromLocalStorage();
  }

  void _loadDataFromLocalStorage() {
    final config = _sharedPrefsService.getConfig();

    if (config != null) {
      setState(() {
        _initialMessage = config['initial_message'] ?? 'Welcome to IMDUMB!';
        _experimentalSearchEnabled = config['enable_experimental_search'] ?? false;
        _isLoading = false;
      });
    } else {
      setState(() {
        _initialMessage = 'No data available';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMDUMB'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display initial message
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Message',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _initialMessage,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display experimental search toggle status
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feature Toggles',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _experimentalSearchEnabled
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _experimentalSearchEnabled
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Experimental Search: ${_experimentalSearchEnabled ? 'Enabled' : 'Disabled'}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Info text
                  Text(
                    'Data loaded from local storage (SharedPreferences)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}
