extension FriendlyIterables<E> on Iterable<E> {

  /// Checks whether any element of this iterable satisfies [test].
  ///
  /// Implemented with [any].
  bool none(bool test(E element)) => !this.any(test);
}
