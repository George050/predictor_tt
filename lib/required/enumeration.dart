import 'dart:collection' show UnmodifiableListView;
import 'package:flutter/material.dart';

typedef StateEntry = DropdownMenuEntry<StateLabel>;

enum StateLabel {
  available("available", "доступен"),
  pending("pending", "в ожидании"),
  sold("sold", "продан"),
  empty("", "");

  const StateLabel(this.state, this.label);
  final String state;
  final String label;

  static final List<StateEntry> entries = UnmodifiableListView<StateEntry>(
    values.map<StateEntry>(
          (StateLabel state) => StateEntry(
        value: state,
        label: state.label,
      ),
    ),
  );
}