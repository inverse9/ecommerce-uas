import 'package:flutter/material.dart';
import 'transactions_page.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Username'),
            subtitle: Text('User123'),
            onTap: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Email'),
            subtitle: Text('user@example.com'),
            onTap: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone'),
            subtitle: Text('+123 456 789'),
            onTap: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
          ListTile(
            title: Text('Transactions'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransactionsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
        ],
      ),
    );
  }
}
