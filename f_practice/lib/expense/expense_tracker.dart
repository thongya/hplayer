import 'package:f_practice/expense/expense_model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: expense_Track()));
}

class expense_Track extends StatelessWidget {
  const expense_Track({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: expense_Tracker()); // Corrected this line
  }
}

class expense_Tracker extends StatefulWidget {
  expense_Tracker({super.key}); // Consider adding const if no parameters change

  @override
  State<expense_Tracker> createState() => _expense_TrackerState();
}

class _expense_TrackerState extends State<expense_Tracker> {
  final List<String> items = ['Bill', 'Food', 'Transport', 'Shopping', 'Other'];
  final List<Expense> _expenses = [];

  double total = 0.0;
  // ... other total variables (consider if these are all needed or if you can calculate them from _expenses)

  void _showForm(BuildContext context) {
    String? selectedCategory = items[0];
    TextEditingController titleController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Good for when keyboard appears
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 15, // Adjust for keyboard
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title')),
              SizedBox(height: 10),
              TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount')),
              SizedBox(height: 10),
              DropdownButtonFormField<String>( // Specify type for better type safety
                value: selectedCategory, // Set initial value
                items: items
                    .map(
                      (item) =>
                      DropdownMenuItem(value: item, child: Text(item)),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) { // Add null check
                    setState(() { // Update selectedCategory within setState if it affects UI immediately
                      selectedCategory = value;
                    });
                  }
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 20), // Increased spacing
              SizedBox( // Ensure button is visible and appropriately sized
                height: 50, // Give it a specific height
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final title = titleController.text;
                    final amountString = amountController.text;
                    final currentCategory = selectedCategory; // Use the one from the showModalBottomSheet scope

                    if (title.isNotEmpty && amountString.isNotEmpty && currentCategory != null) {
                      final amount = double.tryParse(amountString);
                      if (amount != null && amount > 0) { // Check if parsing was successful and amount is valid
                        _addExpense(
                          title,
                          amount,
                          selectedDate, // You might want to allow picking a date too
                          currentCategory,
                        );
                        Navigator.pop(context);
                      } else {
                        // Show error: Invalid amount
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter a valid amount.')),
                        );
                      }
                    } else {
                      // Show error: Fields are empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all fields.')),
                      );
                    }
                  },
                  child: Text('Add Expense'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addExpense(
      String title,
      double amount,
      DateTime date,
      String category,
      ) {
    setState(() {
      _expenses.add(
        Expense(title: title, amount: amount, date: date, category: category),
      );
      total += amount;
      // You might want to update specific category totals here as well
      // e.g., if (category == 'Food') totalFood += amount;
    });
  }

  // THIS IS THE CORRECT PLACEMENT FOR THE BUILD METHOD OF _expense_TrackerState
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker"),
        actions: [
          IconButton(
            onPressed: () => _showForm(context),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Increased padding
                  child: Text(
                    'Total: \$${total.toStringAsFixed(2)}', // Format currency
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _expenses.isEmpty
                  ? Center(child: Text("No expenses added yet. Tap '+' to add.")) // Show message when list is empty
                  : ListView.builder(
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  final expense = _expenses[index]; // For readability
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Add some margin
                    child: ListTile(
                      leading: CircleAvatar(
                        // You could customize color based on category
                        backgroundColor: Colors.blueAccent,
                        child: Text(expense.category.substring(0,1).toUpperCase()), // Show first letter
                      ),
                      title: Text(expense.title, style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('${expense.category} - ${expense.date.toLocal().toString().split(' ')[0]}'), // Format date
                      trailing: Text('\$${expense.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)), // Format amount
                      // Optional: Add an onTap or onLongPress for deleting/editing
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
