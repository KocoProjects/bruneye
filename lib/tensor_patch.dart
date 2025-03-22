import 'dart:typed_data';
import 'dart:collection';

extension TensorPatch on List<int> {
  UnmodifiableListView<int> get unmodifiable => UnmodifiableListView(this);
}

extension Uint8ListPatch on Uint8List {
  UnmodifiableListView<int> get unmodifiable => UnmodifiableListView(this);
}