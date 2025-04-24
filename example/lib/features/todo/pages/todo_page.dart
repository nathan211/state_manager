import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';
import '../controllers/todo_controller.dart';
import '../states/todo_state.dart';

/// Todo list example page demonstrating complex state management
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  /// Controller for handling business logic
  final _controller = TodoController();
  
  /// Controller for the new todo text field
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure todos state is registered
    TodoState.register();
    debugPrint('TodoPage: State registered in initState');
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Add a new todo
  void _addTodo() {
    if (_controller.addTodo(_textController.text, context: context)) {
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('TodoPage: Building page');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List Example'),
      ),
      body: Column(
        children: [
          // Add todo form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
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
          
          // Todo list using ComplexStateBuilder for reactivity
          Expanded(
            child: ComplexStateBuilder<List<Map<String, dynamic>>>(
              stateKey: TodoState.stateKey,
              initialValue: TodoState.initialValue,
              builder: (context, todos) {
                debugPrint('TodoPage: ComplexStateBuilder rebuilding with ${todos.length} todos');
                
                if (todos.isEmpty) {
                  return const Center(
                    child: Text('No todos yet. Add one above!'),
                  );
                }
                
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return _TodoItem(
                      id: todo['id'] as int,
                      title: todo['title'] as String,
                      completed: todo['completed'] as bool,
                      index: index,
                      onToggle: () => _controller.toggleTodoCompletion(index, context: context),
                      onDelete: () => _controller.deleteTodo(todo['id'] as int, context: context),
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

/// A single todo item in the list
class _TodoItem extends StatelessWidget {
  final int id;
  final String title;
  final bool completed;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TodoItem({
    required this.id,
    required this.title,
    required this.completed,
    required this.index,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: completed,
        onChanged: (_) => onToggle(),
      ),
      title: Text(
        title,
        style: TextStyle(
          decoration: completed ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}
