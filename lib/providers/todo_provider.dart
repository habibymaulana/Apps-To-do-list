import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo.dart';

class TodoProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TodoProvider() {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .orderBy('dueDate')
          .get();

      _todos = snapshot.docs.map((doc) {
        final data = doc.data();
        return Todo(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          dueDate: (data['dueDate'] as Timestamp).toDate(),
          isCompleted: data['isCompleted'] ?? false,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      _error = 'Failed to load todos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        return;
      }

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .add({
        'title': todo.title,
        'description': todo.description,
        'dueDate': Timestamp.fromDate(todo.dueDate),
        'isCompleted': todo.isCompleted,
      });

      final newTodo = Todo(
        id: docRef.id,
        title: todo.title,
        description: todo.description,
        dueDate: todo.dueDate,
        isCompleted: todo.isCompleted,
      );

      _todos.add(newTodo);
      _todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add todo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        return;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .doc(todo.id)
          .update({
        'title': todo.title,
        'description': todo.description,
        'dueDate': Timestamp.fromDate(todo.dueDate),
        'isCompleted': todo.isCompleted,
      });

      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        _todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update todo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        return;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .doc(id)
          .delete();

      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete todo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTodoStatus(String id) async {
    try {
      final todo = _todos.firstWhere((t) => t.id == id);
      final updatedTodo = Todo(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        dueDate: todo.dueDate,
        isCompleted: !todo.isCompleted,
      );

      await updateTodo(updatedTodo);
    } catch (e) {
      _error = 'Failed to toggle todo status: $e';
      notifyListeners();
    }
  }

  List<Todo> getTodosForDate(DateTime date) {
    return _todos.where((todo) {
      return todo.dueDate.year == date.year &&
          todo.dueDate.month == date.month &&
          todo.dueDate.day == date.day;
    }).toList();
  }
} 