import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter User CRUD',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const UserListPage(),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final String? website;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.phone,
    this.website,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
      phone: json['phone'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (username != null) 'username': username,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
    };
  }
}

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/users';

  // Create
  Future<User> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': user.name,
          'email': user.email,
        }),
      );

      if (response.statusCode == 201) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create user: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Read
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  // Update
  Future<User> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }

  // Delete
  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final ApiService _apiService = ApiService();
  late Future<List<User>> _userList;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userList = _apiService.fetchUsers();
  }

  void _refreshUsers() {
    setState(() {
      _userList = _apiService.fetchUsers();
    });
  }

  void _addUser() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both name and email')),
      );
      return;
    }

    try {
      await _apiService.createUser(
        User(
          id: 0,
          name: _nameController.text,
          email: _emailController.text,
        ),
      );
      _nameController.clear();
      _emailController.clear();
      _refreshUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            if (user.username != null) Text('Username: ${user.username}'),
            if (user.phone != null) Text('Phone: ${user.phone}'),
            if (user.website != null) Text('Website: ${user.website}'),
            Text('ID: ${user.id}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(int id) async {
    try {
      await _apiService.deleteUser(id);
      _refreshUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
                ElevatedButton(
                  onPressed: _addUser,
                  child: const Text('Add User'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _userList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final user = snapshot.data![index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        onTap: () => _showUserDetails(user),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteUser(user.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}