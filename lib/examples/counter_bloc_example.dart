// BLoC Pattern Implementation Example
// This file demonstrates the BLoC pattern as required by the assignment

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class CounterEvent {}

class CounterIncrement extends CounterEvent {}
class CounterDecrement extends CounterEvent {}
class CounterReset extends CounterEvent {}

// BLoC
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    // Handle increment event
    on<CounterIncrement>((event, emit) {
      emit(state + 1);
    });

    // Handle decrement event
    on<CounterDecrement>((event, emit) {
      emit(state - 1);
    });

    // Handle reset event
    on<CounterReset>((event, emit) {
      emit(0);
    });
  }
}

// UI Implementation
class CounterBlocPage extends StatelessWidget {
  const CounterBlocPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLoC Counter Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Counter Value:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            BlocBuilder<CounterBloc, int>(
              builder: (context, count) {
                return Text(
                  '$count',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: count > 0 
                        ? Colors.green 
                        : count < 0 
                            ? Colors.red 
                            : Colors.grey,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    context.read<CounterBloc>().add(CounterDecrement());
                  },
                  heroTag: "decrement",
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
                FloatingActionButton(
                  onPressed: () {
                    context.read<CounterBloc>().add(CounterReset());
                  },
                  heroTag: "reset",
                  backgroundColor: Colors.grey,
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),
                FloatingActionButton(
                  onPressed: () {
                    context.read<CounterBloc>().add(CounterIncrement());
                  },
                  heroTag: "increment",
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 32),
            BlocListener<CounterBloc, int>(
              listener: (context, state) {
                if (state == 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Counter reached 10! 🎉'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state == -10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Counter reached -10! 😅'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// State Management Comparison Widget
class StateManagementComparison extends StatelessWidget {
  const StateManagementComparison({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Management Patterns'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildComparisonCard(
              title: 'Provider Pattern',
              description: 'Simple, lightweight state management using ChangeNotifier',
              useCase: 'Small to medium apps with straightforward state',
              advantages: [
                'Easy to learn and implement',
                'Minimal boilerplate code',
                'Good performance for simple states',
                'Direct integration with Flutter'
              ],
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildComparisonCard(
              title: 'BLoC Pattern',
              description: 'Business Logic Component with Stream-based architecture',
              useCase: 'Large apps with complex business logic',
              advantages: [
                'Separation of business logic',
                'Highly testable',
                'Predictable state changes',
                'Great for complex apps'
              ],
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildComparisonCard(
              title: 'Riverpod',
              description: 'Provider 2.0 with compile-time safety and better testing',
              useCase: 'Modern apps requiring advanced features',
              advantages: [
                'Compile-time safety',
                'No BuildContext dependency',
                'Better testing support',
                'Advanced composition'
              ],
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard({
    required String title,
    required String description,
    required String useCase,
    required List<String> advantages,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Use Case: $useCase',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Advantages:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            ...advantages.map((advantage) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      advantage,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}