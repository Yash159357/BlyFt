enum NewsCategory {
  general,
  technology,
  sports,
  entertainment,
  business,
  health,
  politics;

  static NewsCategory fromIndex(int index) {
    return NewsCategory.values[index];
  }
}

