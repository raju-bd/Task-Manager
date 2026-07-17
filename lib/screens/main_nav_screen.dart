import 'package:task_manager/screens/add_new_task_screen.dart';
import 'package:task_manager/screens/all_tasks_screen.dart';
import 'package:task_manager/screens/cancel_task_screen.dart';
import 'package:task_manager/screens/completed_task_screen.dart';
import 'package:task_manager/screens/progress_task_screen.dart';
import 'package:task_manager/screens/update_profile_screen.dart';
import 'package:flutter/material.dart';

import '../widget/tm_appbar.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int selectedIndex = 0;

  List screens = [
    AllTasksScreen(),
    ProgressTaskScreen(),
    CompletedTaskScreen(),
    CancelTaskScreen(),
    UpdateProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (selectedIndex >= 0 && selectedIndex < 4) ? TmAppbar() : null,
      body: screens[selectedIndex],
      floatingActionButton: selectedIndex == 0 ?
        FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewTaskScreen()
              )
            ).then((_) {
              setState(() {});
            });
          },
          backgroundColor: Colors.green,
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index){
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.task_alt), label: 'Task'),
          NavigationDestination(icon: Icon(Icons.refresh), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.task_alt_outlined), label: 'Completed'),
          NavigationDestination(icon: Icon(Icons.cancel_outlined), label: 'Cancel'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ]
      ),
    );
  }
}

