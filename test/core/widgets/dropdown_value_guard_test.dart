import 'package:backlog_vault/core/widgets/dropdown_value_guard.dart';
import 'package:test/test.dart';

void main() {
  test('keeps a dropdown value only when it exists exactly once', () {
    expect(safeDropdownValue('pc', [null, 'pc', 'switch']), 'pc');
    expect(safeDropdownValue('missing', [null, 'pc', 'switch']), isNull);
    expect(safeDropdownValue('pc', [null, 'pc', 'pc']), isNull);
    expect(safeDropdownValue<String>(null, [null, 'pc']), isNull);
  });
}
