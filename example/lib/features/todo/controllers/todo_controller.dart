import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';

/// Controller for the Todo feature
class TodoController {
  /// The store to use for state management
  StateStore? _store;
  
  /// The state key for todos
  static final String todoStateKey = StateKey.forFeature('todo', 'items');
  
  /// Set the store to use for state management
  void setStore(StateStore store) {
    _store = store;
  }
  
  /// Get the store to use for state management
  StateStore get store => _store ?? StateStore.instance;
  
  /// Get the current todos list
  List<Map<String, dynamic>> getTodos() {
    try {
      return store.getComplexValue<List<Map<String, dynamic>>>(todoStateKey);
    } catch (e) {
      debugPrint('Error getting todos: $e');
      return [];
    }
  }
  
  /// Add a new todo
  bool addTodo(String title, {required BuildContext context}) {
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo title cannot be empty')),
      );
      return false;
    }
    
    try {
      // Get the current todos and create a deep copy
      final todos = _deepCopyTodos(getTodos());
      
      // Generate a new ID
      final newId = todos.isEmpty 
          ? 1 
          : todos.map<int>((todo) => todo['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
      
      // Create a completely new list with the new todo
      final newTodos = [
        ...todos,
        {
          'id': newId,
          'title': title,
          'completed': false,
        }
      ];
      
      // Update the state with the new list
      store.setComplexValue<List<Map<String, dynamic>>>(todoStateKey, newTodos);
      
      debugPrint('TodoController: Added new todo "${title}" with id $newId, total count: ${newTodos.length}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo added successfully')),
      );
      return true;
    } catch (e) {
      debugPrint('Error adding todo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding todo: $e')),
      );
      return false;
    }
  }
  
  /// Toggle the completion status of a todo
  void toggleTodoCompletion(int index, {required BuildContext context}) {
    try {
      // Get the current todos and create a deep copy
      final todos = _deepCopyTodos(getTodos());
      
      if (index < 0 || index >= todos.length) {
        throw Exception('Invalid todo index: $index');
      }
      
      // Toggle the completed status
      todos[index]['completed'] = !(todos[index]['completed'] as bool);
      
      // Update the state with the new list
      store.setComplexValue<List<Map<String, dynamic>>>(todoStateKey, todos);
      
      final todoTitle = todos[index]['title'];
      final isCompleted = todos[index]['completed'];
      debugPrint('TodoController: Toggled todo "$todoTitle" at index $index, completed: $isCompleted');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todo ${isCompleted ? 'completed' : 'marked as incomplete'}')),
      );
    } catch (e) {
      debugPrint('Error toggling todo completion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling todo completion: $e')),
      );
    }
  }
  
  /// Delete a todo by ID
  void deleteTodo(int id, {required BuildContext context}) {
    try {
      // Get the current todos and create a deep copy
      final todos = _deepCopyTodos(getTodos());
      
      // Find the todo to delete
      final todoToDelete = todos.firstWhere(
        (todo) => todo['id'] == id,
        orElse: () => throw Exception('Todo with id $id not found'),
      );
      
      // Remove the todo with the given ID
      final newTodos = todos.where((todo) => todo['id'] as int != id).toList();
      
      // Update the state with the new list
      store.setComplexValue<List<Map<String, dynamic>>>(todoStateKey, newTodos);
      
      final todoTitle = todoToDelete['title'];
      debugPrint('TodoController: Deleted todo "$todoTitle" with id $id, remaining count: ${newTodos.length}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo deleted successfully')),
      );
    } catch (e) {
      debugPrint('Error deleting todo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting todo: $e')),
      );
    }
  }
  
  /// Create a deep copy of the todos list
  List<Map<String, dynamic>> _deepCopyTodos(List<Map<String, dynamic>> todos) {
    return todos.map((todo) => Map<String, dynamic>.from(todo)).toList();
  }
}
