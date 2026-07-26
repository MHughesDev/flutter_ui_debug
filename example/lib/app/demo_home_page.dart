import 'package:flutter/material.dart';
import 'package:flutter_ui_debug/flutter_ui_debug.dart';
import '../demos/sample_app/sample_app_animations_demo.dart';
import '../demos/showcase_demos/comprehensive_showcase_demo.dart';
import 'debug_control_panel.dart';

class DemoPage {
  final String title;
  final IconData icon;
  final Widget Function() builder;

  const DemoPage({
    required this.title,
    required this.icon,
    required this.builder,
  });
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  int _selectedIndex = 0;

  final List<DemoPage> _demos = [
    const DemoPage(
      title: 'Comprehensive Showcase',
      icon: Icons.dashboard,
      builder: ComprehensiveShowcaseDemo.new,
    ),
    const DemoPage(
      title: 'Sample App (navigation)',
      icon: Icons.navigation,
      builder: SampleAppAnimationsDemo.new,
    ),
  ];

  bool _showFloatingPanel = false;

  void _toggleFloatingPanel() {
    setState(() {
      _showFloatingPanel = !_showFloatingPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_demos[_selectedIndex].title),
        actions: [
          IconButton(
            icon: Icon(_showFloatingPanel ? Icons.close : Icons.settings),
            onPressed: _toggleFloatingPanel,
            tooltip: 'Debug Controls',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flutter UI Debug',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Feature Demos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ..._demos.asMap().entries.map((entry) {
              final index = entry.key;
              final demo = entry.value;
              return ListTile(
                leading: Icon(demo.icon),
                title: Text(demo.title),
                selected: _selectedIndex == index,
                selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                onTap: () {
                  setState(() => _selectedIndex = index);
                  Navigator.pop(context);
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Debug Controls'),
              onTap: () {
                Navigator.pop(context);
                _toggleFloatingPanel();
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Main demo content
          _demos[_selectedIndex].builder(),
          
          // Global debug overlays
          if (UIDebugConfig.isEnabled(UIDebugCapability.frameRateMonitor))
            const Positioned(
              top: 16,
              right: 16,
              child: FrameRateMonitor(),
            ),
          
          // Floating debug control panel
          if (_showFloatingPanel)
            GestureDetector(
              onTap: () {
                // Close panel when tapping outside
                _toggleFloatingPanel();
              },
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: GestureDetector(
                  onTap: () {}, // Prevent taps on panel from closing
                  child: FloatingDebugControlPanel(
                    onClose: _toggleFloatingPanel,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFloatingPanel,
        tooltip: 'Debug Controls',
        backgroundColor: _showFloatingPanel ? Colors.red : Colors.blue,
        child: Icon(_showFloatingPanel ? Icons.close : Icons.tune),
      ),
    );
  }
}
