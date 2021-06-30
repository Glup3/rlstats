import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rlstats/service/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (ctx) => ctx.read<AuthService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'RL Stats',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'RL Stats'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
                future: _initialization,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('sth went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    final firebaseUser = context.watch<User?>();

                    if (firebaseUser != null) {
                      return Column(
                        children: [
                          Text(firebaseUser.displayName ?? 'Username'),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<AuthService>().signOut(),
                            child: Text('Sign Out'),
                          ),
                        ],
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: () =>
                            context.read<AuthService>().signInWithGoogle(),
                        child: Text('Sign In'),
                      );
                    }
                  }

                  return Text('loading');
                }),
          ],
        ),
      ),
    );
  }
}
