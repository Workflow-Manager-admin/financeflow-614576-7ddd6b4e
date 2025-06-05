import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:financeflow_frontend/main.dart';
import 'package:financeflow_frontend/providers/transaction_provider.dart';
import 'package:financeflow_frontend/providers/user_provider.dart';
import 'package:financeflow_frontend/providers/savings_provider.dart';
import 'package:financeflow_frontend/screens/dashboard_screen.dart';
import 'package:financeflow_frontend/screens/transactions_screen.dart';
import 'package:financeflow_frontend/screens/add_transaction_screen.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget createTestApp({Widget? home}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(prefs),
        ),
        ChangeNotifierProxyProvider<TransactionProvider, SavingsProvider>(
          create: (context) => SavingsProvider(
            prefs,
            Provider.of<TransactionProvider>(context, listen: false),
          ),
          update: (context, transactions, previous) =>
              SavingsProvider(prefs, transactions),
        ),
      ],
      child: MaterialApp(
        home: home ?? const FinanceFlowApp(),
      ),
    );
  }

  testWidgets('FinanceFlow app shows dashboard initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('Navigation bar switches between screens',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Initially on Dashboard
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Tap Transactions tab
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);

    // Tap Recurring tab
    await tester.tap(find.text('Recurring'));
    await tester.pumpAndSettle();
    expect(find.text('Recurring Payments'), findsOneWidget);
  });

  testWidgets('Add transaction button shows add transaction screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(find.text('Add Transaction'), findsOneWidget);
  });

  testWidgets('Premium toggle changes user status',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Find and tap the premium toggle button
    await tester.tap(find.byIcon(Icons.workspace_premium_outlined));
    await tester.pumpAndSettle();

    // Verify that the icon changed to the premium version
    expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
  });

  testWidgets('Dashboard shows transaction summary cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
  });

  testWidgets('Add transaction form validation works',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(home: const AddTransactionScreen()));
    await tester.pumpAndSettle();

    // Try to save without entering data
    await tester.tap(find.text('Save Transaction'));
    await tester.pumpAndSettle();

    // Verify validation errors are shown
    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.text('Please enter an amount'), findsOneWidget);

    // Enter valid data
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'), 'Test Transaction');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount'), '100.00');
    await tester.pumpAndSettle();

    // Save again
    await tester.tap(find.text('Save Transaction'));
    await tester.pumpAndSettle();

    // Should navigate back
    expect(find.byType(AddTransactionScreen), findsNothing);
  });
}
