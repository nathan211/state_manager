import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';
import '../states/todo_state.dart';

/// Controller class for the todo feature
/// Handles business logic and state interactions
class TodoController {
  /// Get the current todos list
  List<Map<String, dynamic>> getTodos() {
    return TodoState.getNotifier().value;
  }
  
  /// Create a deep copy of the todos list
  List<Map<String, dynamic>> _deepCopyTodos(List<Map<String, dynamic>> todos) {
    return todos.map((todo) => Map<String, dynamic>.from(todo)).toList();
  }
  
  /// Add a new todo with the given title
  /// Returns true if successful, false otherwise
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
      final notifier = StateStore.instance.getComplexState<List<Map<String, dynamic>>>(TodoState.stateKey);
      notifier.update(newTodos);
      
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
  
  /// Toggle the completion status of a todo at the given index
  void toggleTodoCompletion(int index, {required BuildContext context}) {
    try {
      // Get the current todos and create a deep copy
      final todos = _deepCopyTodos(getTodos());
      
      if (index < 0 || index >= todos.length) {
        throw Exception('Invalid todo index: $index');
      }
      
      // Create a new map for the updated todo
      final updatedTodo = Map<String, dynamic>.from(todos[index]);
      updatedTodo['completed'] = !(updatedTodo['completed'] as bool);
      
      // Create a completely new list with the updated todo
      final newTodos = List<Map<String, dynamic>>.from(todos);
      newTodos[index] = updatedTodo;
      
      // Update the state with the new list
      final notifier = StateStore.instance.getComplexState<List<Map<String, dynamic>>>(TodoState.stateKey);
      notifier.update(newTodos);
      
      final todoTitle = updatedTodo['title'];
      final isCompleted = updatedTodo['completed'];
      debugPrint('TodoController: Toggled todo "$todoTitle" at index $index, completed: $isCompleted');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todo ${isCompleted ? 'completed' : 'marked as incomplete'}')),
      );
    } catch (e) {
      debugPrint('Error updating todo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating todo: $e')),
      );
    }
  }
  
  /// Delete a todo with the given id
  void deleteTodo(int id, {required BuildContext context}) {
    try {
      // Get the current todos and create a deep copy
      final todos = _deepCopyTodos(getTodos());
      
      // Find the todo to delete
      final todoToDelete = todos.firstWhere(
        (todo) => todo['id'] == id,
        orElse: () => throw Exception('Todo with id $id not found'),
      );
      
      // Create a completely new list without the todo
      final newTodos = todos.where((todo) => todo['id'] != id).toList();
      
      // Update the state with the new list
      final notifier = StateStore.instance.getComplexState<List<Map<String, dynamic>>>(TodoState.stateKey);
      notifier.update(newTodos);
      
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
}
