import 'package:flutter/material.dart';
import 'package:gd_sphere/sphere.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Sphere Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SphereGesture(),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SphereGesture extends StatefulWidget {
  const SphereGesture({super.key});

  @override
  State<SphereGesture> createState() => _SphereGestureState();
}

class _SphereGestureState extends State<SphereGesture> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Auto rotate All Axis',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Sphere.rotate(
              size: 300,
              alphaEnabled: false,
              children: List.generate(
                100,
                (i) => ClipOval(
                  child: Image.network('https://i.pravatar.cc/30?u=$i'),
                ),
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Auto rotate X-Axis',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Sphere.rotate(
              size: 300,
              alphaEnabled: false,
              isRotationX: true,
              isRotationY: false,
              children: List.generate(
                100,
                (i) => ClipOval(
                  child: Image.network('https://i.pravatar.cc/30?u=$i'),
                ),
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Auto rotate Y-Axis',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Sphere.rotate(
              size: 300,
              alphaEnabled: false,
              isRotationX: false,
              isRotationY: true,
              children: List.generate(
                100,
                (i) => ClipOval(
                  child: Image.network('https://i.pravatar.cc/30?u=$i'),
                ),
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Gesture',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Sphere.gesture(
              size: 300,
              alphaEnabled: false,
              children: List.generate(
                100,
                (i) => ClipOval(
                  child: Image.network('https://i.pravatar.cc/30?u=$i'),
                ),
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Sphere With Depth Enabled (Alpha)',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Sphere.gesture(
              size: 300,
              alphaEnabled: true,
              children: List.generate(
                100,
                (i) => ClipOval(
                  child: Image.network('https://i.pravatar.cc/30?u=$i'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
