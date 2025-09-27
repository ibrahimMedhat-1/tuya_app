import '../../../../../core/utils/app_imports.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Active Devices',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Placeholder for Active Devices List
            const SizedBox(height: 10),
            Container(
              height: 100, // Placeholder height
              color: Colors.grey[200],
              child: const Center(child: Text('List of active devices here')),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Devices',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Placeholder for Recent Devices List
            const SizedBox(height: 10),
            Container(
              height: 100, // Placeholder height
              color: Colors.grey[200],
              child: const Center(child: Text('List of recent devices here')),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Add Scene (e.g., Navigator.pushNamed(context, addSceneRoute);)
                  },
                  child: const Text('Add Scene'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Add Device (e.g., Navigator.pushNamed(context, addDeviceRoute);)
                  },
                  child: const Text('Add Device'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.pushNamed(Routes.controlDeviceRoute);
                  },
                  child: const Text('Control Device'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
