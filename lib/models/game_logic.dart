import 'dart:collection';

import 'package:goban/data_classes/position.dart';
import 'package:goban/goban.dart';

/// A go board, with a size, positioned stones, and decoration.
abstract class GobanModel {
  /// Size of one side of the board, e.g. 9
  int get size;

  /// Every Position on the board, in rows, starting from the top left corner.
  /// Includes empty positions.
  List<Move> positions();

  /// The Position at the given offset
  Move positionAt(int x, int y);

  /// Play a stone to the board.
  ///
  /// This updates the board accordingly:
  /// * assert the spot is empty
  /// * check against Ko
  /// * check opposite color neighboring groups for kills
  /// * check for suicide
  /// * update friendly neighboring groups
  ///
  /// Consider passing back a result here instead.
  bool play(Move position);

  /// A position on which to render a potential placement (mouse hover).
  /// TODO: Move this into a 'decoration' abstraction.
  Move ghost;
}

/// A Goban that enforce some rules of the game: capture, ko (TODO), and suicide.
class GobanWithRules implements GobanModel {

  @override
  final int size;

  /// All positions on the board; at the beginning, they are all [StoneColor.Empty].
//  List<Move> _positions;

  BoardMap _positions;

  @override
  Move ghost;

  GobanWithRules(this.size) {
    _positions = BoardMap(size);
  }

  @override
  List<Move> positions() => _positions.getAll();

  @override
  Move positionAt(int x, int y) {
    assert( x >= 0 && x < size);
    assert( y >= 0 && y < size);

    return _positions[x][y];
  }

  @override
  bool play(final Move newPosition) {
    final current = positionAt(newPosition.x, newPosition.y);

    // Special case :: 'play' with no color.  Allow this to implement an 'eraser' tool.
    // This can cause no kills and is always legal.
    if (newPosition.isEmpty) {
      _positions.set(newPosition);
      return true;
    }

    // Can't play at an occupied space.
    if (!current.isEmpty) {
      print('ILLEGAL MOVE : Cant play at an occupied position');
      return false;
    }

    // Check for kills.
    // -- Get neighboring, opposing groups.
    final List<Set<Move>> neighborEnemyGroups = _neighbors(newPosition)
        .where((p) => p.color != null && p.color == newPosition.color.flipped())
        .map((p) => _getGroup(p))
        .toList();
    //    print('Got ${neighborEnemyGroups.length} enemy neighbors');

    // -- Check their liberty. Kill any in atari (the new stone will remove this last liberty)
    Set<Move> killed = {};
    neighborEnemyGroups.forEach((group) {
      int liberty = _calcLiberty(group);
      //      print('Neighbor has $liberty liberty');
      if (liberty == 1) {
        print('Killing group $group');
        killed.addAll(group);
      }
    });

    // Check against KO ( TODO )

    // Check against suicide.
    // TODO: This is broken. The stone isn't placed yet, so...
    // update: should be fixed now, just double check.
    if (killed.isEmpty && _calcLiberty(_getGroup(newPosition)) == 0) {
      print('ILLEGAL MOVE : Suicide is forbidden.');
      return false;
    }

    // Add the stone and remove any killed ones
    _positions.set(newPosition);
    killed.forEach((p) => _positions.set(p.cleared()));

    // Print neighbors
    print('New Position in group size ${_getGroup(newPosition).length}');
    return true;
  }

  List<Move> _neighbors(Move p) {
    return [
      if (p.y != 0) positionAt(p.x, p.y - 1), // Top
      if (p.y != size - 1) positionAt(p.x, p.y + 1), // Bottom
      if (p.x != 0) positionAt(p.x - 1, p.y), // Left
      if (p.x != size - 1) positionAt(p.x + 1, p.y), // Right
    ];
  }

  Set<Move> _getGroup(Move p) {
    assert(!p.isEmpty, 'Cannot get groups for an empty Position');

    Set<Move> stones = {p}; // One-stone group
    Set<Move> seen = {};
    Queue<Move> neighbors = Queue();
    neighbors.addAll(_neighbors(p));

    while(neighbors.isNotEmpty) {
      Move neighbor = neighbors.removeFirst();

      if (seen.contains(neighbor)) continue;
      seen.add(neighbor);

      if (neighbor.color == p.color) {
        stones.add(neighbor);
        neighbors.addAll(_neighbors(neighbor));
      }
    }
    return stones;
  }

//  /// Count up the liberty for a given group.
//  ///
//  /// Each unique empty neighbor of any stone in the group counts as a liberty.
//  _calcLiberty(Set<Move> group) =>
//      group.expand((p) => _neighbors(p))                // get all neighbors
//          .toSet()                                      // filter out repeats
//          .where((neighbor) => !group.contains(neighbor)) // Ignore positions in this group itself; this is important as it may not yet be on the board
//          .where((neighbor) => neighbor.isEmpty)        // count only empty ones
//          .length;                                      // get the length.
//}

  /// Count up the liberty for a given group.
  ///
  /// Each unique empty neighbor of any stone in the group counts as a liberty.
  _calcLiberty(Set<Move> group) {
    Iterable<Move> positions = group.expand((p) => _neighbors(p));
    positions = positions.toSet();
    positions = positions.where((neighbor) =>
      !group.any((g) => neighbor.x == g.x && neighbor.y == g.y));
    positions = positions.where((neighbor) => neighbor.isEmpty);
    return positions.length;
  }
}

/// A "map" to where stones are on the board.  Access like GobanMap[2][32]
class BoardMap {
  final int size;

  // List of columns of positions, starting with the left-most column.
  final List<List<Move>> _columns;

  BoardMap(this.size) :
    _columns = List.generate(size, (x) => List.generate(size, (y) => Move.empty(x, y)));

  List<Move> operator [](int x) => _columns[x];

  void set(Move move) => this[move.x][move.y] = move;

  List<Move> getAll() =>
      _columns.fold([], (_, moves) => _..addAll(moves));

  @override
  String toString() {
    return '$size' + _columns.expand((row) => row).join('');
  }
}

/// A node in a tree of Moves. Mutable.
class MoveTree extends TreeNode<Move> {
  final Move move;

  MoveTree(this.move);

  MoveTree get previous => parent;

  void addMove(Move newMove) => addBranch(MoveTree(newMove));
}



/// Utility Class to represent a node in a tree.
/// * There can be multiple [branches] from a given node. [branches] is ordered.
/// * Nodes can back-link via [parent].
/// * This class is mutable.
class TreeNode<T> {
  TreeNode<T> parent;
  final List<TreeNode<T>> branches = [];

  /// Constructor. No parent and empty branches by default.
  TreeNode();

  int get depth => ancestors().length;
  bool get isLeaf => branches.isEmpty;
  MoveTree get next => this[0];

  operator [](int branch) => branches[branch];

  Iterable<TreeNode<T>> ancestors() sync* {
    var current = this;
    while ((current = current.parent) != null) {
      yield current;
    }
  }

  /// Attach [newBranch] to this one.
  void addBranch(TreeNode<T> newBranch) {
    // Put that MoveTree on this one
    branches.add(newBranch);

    // And set that one's parent here
    newBranch.parent = this;
  }
}