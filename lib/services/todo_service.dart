import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';

class TodoService {
  final CollectionReference _todosCollection =
      FirebaseFirestore.instance.collection('todos');

  Future<void> addTodo(Todo todo) async {
    try {
      await _todosCollection.doc(todo.id).set(todo.toMap());
    } catch (e) {
      print('Error adding todo: $e');
      rethrow;
    }
  }

  Stream<List<Todo>> getTodos() {
    try {
      return _todosCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Todo.fromMap(data);
            })
            .toList();
      });
    } catch (e) {
      print('Error getting todos: $e');
      rethrow;
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _todosCollection.doc(todo.id).update(todo.toMap());
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _todosCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }
} 