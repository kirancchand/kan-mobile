import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mv_app/data/models/admin_hierarchy.dart';
import 'package:mv_app/data/repositories/admin_repository.dart';
import 'package:mv_app/features/admin/admin_login_screen.dart';

void main() {
  test('Admin repository starts without accounts, analytics or records',
      () async {
    final repo = AdminRepository();
    expect(repo.accounts, isEmpty);
    expect(await repo.getAllLocationAnalytics(), isEmpty);
    expect(await repo.getRegisteredEntities('loc_1'), isEmpty);
    expect(await repo.getTransactions('loc_1'), isEmpty);
    expect(await repo.getAnalyticsForLocation('loc_1'), isNull);
    expect(() => repo.accountById('main'), throwsArgumentError);
  });

  test('Explicit assigned accounts remain scoped to their hierarchy', () {
    final repo = AdminRepository(assignedAccounts: const [
      AdminAccount(
          id: 'root', name: 'Root', level: AdminLevel.main, territory: 'Root'),
      AdminAccount(
          id: 'a',
          name: 'A',
          level: AdminLevel.branch,
          territory: 'A',
          parentId: 'root',
          locationId: 'a'),
      AdminAccount(
          id: 'b',
          name: 'B',
          level: AdminLevel.branch,
          territory: 'B',
          parentId: 'root',
          locationId: 'b'),
    ]);
    expect(repo.canView('root', 'a'), isTrue);
    expect(repo.canView('a', 'b'), isFalse);
    expect(() => repo.getUsers(viewerId: 'a', targetId: 'b'), throwsStateError);
    expect(repo.getOverview(viewerId: 'root', targetId: 'root').children,
        hasLength(2));
  });

  testWidgets('Admin entry cannot log in by choosing a demo territory',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminLoginScreen()));
    expect(find.byType(DropdownButtonFormField<AdminLevel>), findsNothing);
    expect(find.textContaining('Administrator sign-in is not available'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
