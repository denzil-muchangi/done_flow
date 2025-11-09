import 'package:done_flow/core/providers/task_provider.dart';
import 'package:done_flow/core/providers/theme_provider.dart';
import 'package:done_flow/core/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..init()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Done Flow',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MyHomePage(title: 'Done Flow'),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}