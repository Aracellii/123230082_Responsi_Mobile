import 'package:flutter/material.dart';
import 'package:latres/storage/hive_service.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = 'Guest User';
  String _email = 'guest@example.com';
  
  bool _loggedIn = false;
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }
  
  Future<void> _loadState() async {
    final logged = await AuthService.isLoggedIn();
    final username = await AuthService.getUsername();
    
    setState(() {
      _loggedIn = logged;
      if (logged && username != null && username.isNotEmpty) {
        _username = username.split('@').first;
        _email = username;
      } else {
        _username = 'Guest User';
        _email = 'guest@example.com';
      }
    });

    if (!mounted) return;
    if (!logged && !_redirecting) {
      _redirecting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final result = await Navigator.of(
          context,
        ).push<bool?>(MaterialPageRoute(builder: (_) => const LoginPage()));

        _redirecting = false;

        if (result == true) {
          await _loadState();
        }
      });
    }
  }

  Future<void> _onLoginPressed() async {
    final result = await Navigator.of(
      context,
    ).push<bool?>(MaterialPageRoute(builder: (_) => const LoginPage()));

    if (result == true) {
      await _loadState();
    }
  }

  Future<void> _onLogoutPressed() async {
    await AuthService.logout();
    await _loadState();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out')));

    // force redirect to login after logout (avoid duplicate pushes)
    if (!_redirecting) {
      _redirecting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.of(
          context,
        ).push<bool?>(MaterialPageRoute(builder: (_) => const LoginPage()));
        _redirecting = false;
        await _loadState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 12),
        CircleAvatar(
          radius: 56,
          child: Text(
            _username.isNotEmpty ? _username[0].toUpperCase() : 'G',
            style: const TextStyle(fontSize: 40),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _username,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
         const SizedBox(height: 16),
        Text(
          _username,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _email,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loggedIn ? _onLogoutPressed : _onLoginPressed,
            child: Text(_loggedIn ? 'Logout' : 'Login'),
          ),
        ),
      ],
    );
  }
}
