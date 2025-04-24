import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<Map<String, dynamic>> _initialTodos = [
    {'id': 1, 'title': 'Learn Flutter', 'completed': true},
    {'id': 2, 'title': 'Master State Management', 'completed': false},
    {'id': 3, 'title': 'Build Amazing Apps', 'completed': false},
  ];
  
  late ComplexStateNotifier<List<Map<String, dynamic>>> _todosNotifier;
  final TextEditingController _newTodoController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    try {
      // Try to get the existing notifier
      _todosNotifier = StateStore.instance.getComplexState<List<Map<String, dynamic>>>('todos');
      debugPrint('TodoPage.initState: Successfully retrieved todos state: ${_todosNotifier.value.length} items');
    } catch (e) {
      // Register if not found
      debugPrint('TodoPage.initState: Error retrieving todos state: $e');
      StateStore.instance.registerComplex<List<Map<String, dynamic>>>('todos', _initialTodos);
      _todosNotifier = StateStore.instance.getComplexState<List<Map<String, dynamic>>>('todos');
    }
  }
  
  @override
  void dispose() {
    _newTodoController.dispose();
    super.dispose();
  }
  
  void _addTodo() {
    if (_newTodoController.text.isEmpty) return;
    
    debugPrint('TodoPage._addTodo: Adding new todo with title: ${_newTodoController.text}');
    
    // Get current todos and create a deep copy
    final currentTodos = List<Map<String, dynamic>>.from(_todosNotifier.value.map((todo) => Map<String, dynamic>.from(todo)));
    
    // Generate new ID
    final newId = currentTodos.isEmpty 
        ? 1 
        : currentTodos.map<int>((todo) => todo['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
    
    // Add new todo
    final newTodos = [
      ...currentTodos,
      {
        'id': newId,
        'title': _newTodoController.text,
        'completed': false,
      }
    ];
    
    // Update the state
    _todosNotifier.update(newTodos);
    debugPrint('TodoPage._addTodo: Updated todos, new count: ${newTodos.length}');
    
    _newTodoController.clear();
    
    // Force rebuild
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todo added successfully')),
    );
  }
  
  void _toggleTodoCompletion(int index) {
    debugPrint('TodoPage._toggleTodoCompletion: Toggling completion for todo at index $index');
    
    // Get current todos and create a deep copy
    final currentTodos = List<Map<String, dynamic>>.from(_todosNotifier.value.map((todo) => Map<String, dynamic>.from(todo)));
    
    // Update the todo
    currentTodos[index] = {
      ...currentTodos[index],
      'completed': !(currentTodos[index]['completed'] as bool),
    };
    
    // Update the state
    _todosNotifier.update(currentTodos);
    debugPrint('TodoPage._toggleTodoCompletion: Updated todo at index $index');
    
    // Force rebuild
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todo updated successfully')),
    );
  }
  
  void _deleteTodo(int id) {
    debugPrint('TodoPage._deleteTodo: Deleting todo with id $id');
    
    // Get current todos and create a deep copy
    final currentTodos = List<Map<String, dynamic>>.from(_todosNotifier.value.map((todo) => Map<String, dynamic>.from(todo)));
    
    // Remove the todo
    final newTodos = currentTodos.where((todo) => todo['id'] != id).toList();
    
    // Update the state
    _todosNotifier.update(newTodos);
    debugPrint('TodoPage._deleteTodo: Deleted todo, new count: ${newTodos.length}');
    
    // Force rebuild
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todo deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the latest todos from the notifier
    final todos = _todosNotifier.value;
    debugPrint('TodoPage.build: Building TodoPage with ${todos.length} todos');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List Example'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTodoController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new todo...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('No todos yet. Add one above!'))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return ListTile(
                        leading: Checkbox(
                          value: todo['completed'] as bool,
                          onChanged: (_) => _toggleTodoCompletion(index),
                        ),
                        title: Text(
                          todo['title'] as String,
                          style: TextStyle(
                            decoration: todo['completed'] as bool ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTodo(todo['id'] as int),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
