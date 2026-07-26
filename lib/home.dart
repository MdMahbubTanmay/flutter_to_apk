

import 'package:flutter/material.dart';
import 'chat.dart';
import 'history.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainHomeScreen(),
    );
  }
}
class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B14),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xff3b2d54),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.accessible_forward,
                  color: Colors.white,
                  size: 50.0,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Legal GPS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Apnar Ayini Pothprodorshok',
                style: TextStyle(
                  color: const Color(0xff663399),
                  fontSize: 15,
                ),
              ),
              const Expanded(child: SizedBox(height: 15)),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 10, left: 30, right: 30),
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xff161224),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xff3b2d54)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning, color: Colors.white, size: 35),
                    const SizedBox(height: 60, width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How To use!!',
                          style: TextStyle(
                            color: Colors.purple[50],
                            fontSize: 20,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const Text(
                          'jante eikahne click korun',
                          style: TextStyle(
                            color: const Color(0xff663399),
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox(height: 30)),
              Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Common Shomossa',
                        style: TextStyle(color: const Color(0xff663399)),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: 100,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xff161224),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xff3b2d54),
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.monetization_on,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                Text(
                                  'Beton',
                                  style: TextStyle(
                                    color: Color(0xff663399),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: 100,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xff161224),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xff3b2d54),
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.house,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                Text(
                                  'Barih Vara',
                                  style: TextStyle(
                                    color: Color(0xff663399),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: 100,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xff161224),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xff3b2d54),
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.area_chart,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                Text(
                                  'Jomi',
                                  style: TextStyle(
                                    color: Color(0xff663399),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: 100,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xff161224),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xff3b2d54),
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_android,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                Text(
                                  'Phone Harano',
                                  style: TextStyle(
                                    color: Color(0xff663399),
                                  ),
                                ),
                              ],
                            ),

),
),
],
),
],
),
),
],
),
),
),
bottomNavigationBar: BottomNavigationBar(
type: BottomNavigationBarType.fixed,
backgroundColor: const Color(0xff161224),
selectedItemColor: Colors.white,
unselectedItemColor: const Color(0xff63567D),
currentIndex: 0,
onTap: (index) {
if (index == 1) {
Navigator.push(
context,
PageRouteBuilder(
pageBuilder: (context, animation, secondaryAnimation) => const ChatScreen(),
transitionDuration: Duration.zero,
reverseTransitionDuration: Duration.zero,
),
);
}
else if (index == 3) { 
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HistoryScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
},
items: const [
BottomNavigationBarItem(
icon: Icon(Icons.home),
label: 'Home',
),
BottomNavigationBarItem(
icon: Icon(Icons.chat),
label: 'Chat',
),
BottomNavigationBarItem(
icon: Icon(Icons.lock),
label: 'Lock',
),
BottomNavigationBarItem(
icon: Icon(Icons.history),
label: 'History',
),
],
),
);
}
}
