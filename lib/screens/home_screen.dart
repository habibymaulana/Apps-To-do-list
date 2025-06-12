import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/todo_provider.dart';
import '../providers/auth_provider.dart';
import '../models/todo.dart';
import '../widgets/notification_dialog.dart';
import 'add_todo_screen.dart';
import 'edit_todo_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isInitialized = false;
  Map<DateTime, List<Todo>> _events = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _initializeAuth();
    _loadEvents();
  }

  void _loadEvents() {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    setState(() {
      _events = {};
      for (var todo in todoProvider.todos) {
        final date = DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
        if (_events[date] == null) {
          _events[date] = [];
        }
        _events[date]!.add(todo);
      }
    });
  }

  Future<void> _initializeAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.verifyAuthState();
    if (!authProvider.isAuthenticated) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => NotificationDialog(
        message: message,
        isSuccess: true,
      ),
    );
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => NotificationDialog(
        message: message,
        isSuccess: false,
      ),
    );
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Logout failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todo List',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF2D3748)),
            onPressed: _handleLogout,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F7FA),
              const Color(0xFFE4E8F0),
              const Color(0xFFD1D9E6),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 100),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF4A5568),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: const Color(0xFF4A5568),
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: GoogleFonts.poppins(
                      color: const Color(0xFF2D3748),
                    ),
                    weekendTextStyle: GoogleFonts.poppins(
                      color: const Color(0xFF6B7A8F),
                    ),
                    markerDecoration: BoxDecoration(
                      color: const Color(0xFF4A5568),
                      shape: BoxShape.circle,
                    ),
                    markerSize: 6.0,
                    markerMargin: const EdgeInsets.symmetric(horizontal: 1.0),
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: GoogleFonts.poppins(
                      color: const Color(0xFF2D3748),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    formatButtonTextStyle: GoogleFonts.poppins(
                      color: const Color(0xFF4A5568),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE4E8F0),
                      ),
                    ),
                  ),
                  eventLoader: (day) {
                    return _events[day] ?? [];
                  },
                ),
              ),
              Expanded(
                child: Consumer<TodoProvider>(
                  builder: (context, todoProvider, child) {
                    final todos = todoProvider.todos.toList();
                    todos.sort((a, b) => a.dueDate.compareTo(b.dueDate));
                    if (todos.isEmpty) {
                      return Center(
                        child: Text(
                          'No todos yet',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF6B7A8F),
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              todo.title,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF2D3748),
                                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Text(
                              todo.description,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF6B7A8F),
                                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: todo.isCompleted,
                                  onChanged: (value) {
                                    todoProvider.toggleTodoStatus(todo.id);
                                    _showSuccessMessage('Todo status updated');
                                  },
                                  activeColor: const Color(0xFF4A5568),
                                  checkColor: Colors.white,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF6B7A8F)),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditTodoScreen(todo: todo),
                                      ),
                                    );
                                    if (result == true && mounted) {
                                      _loadEvents();
                                      _showSuccessMessage('Todo updated successfully');
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Color(0xFF6B7A8F)),
                                  onPressed: () {
                                    todoProvider.deleteTodo(todo.id);
                                    _loadEvents();
                                    _showSuccessMessage('Todo deleted successfully');
                                  },
                                ),
                              ],
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTodoScreen(
                selectedDate: _selectedDay,
              ),
            ),
          );
          
          if (result == true && mounted) {
            _loadEvents();
            _showSuccessMessage('Todo added successfully');
          }
        },
        backgroundColor: const Color(0xFF4A5568),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
} 