import 'package:get/get.dart';
import 'package:gutrgoopro/search.dart/service/search_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';

class SearchControllerX extends GetxController {
  final query = ''.obs;
  final recentSearches = <String>[].obs;
  final searchResults = <MovieModel>[].obs;
  final isSearching = false.obs;
  final searchError = ''.obs;
  final isInitialized = false.obs;

  late final SearchService _searchService;
  late SharedPreferences _prefs;

  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  @override
  void onInit() {
    super.onInit();
    _initDependencies();
  }

  Future<void> _initDependencies() async {
    _searchService = SearchService();
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadRecentSearches();
      isInitialized.value = true;
      print('✅ Controller initialized');
    } catch (e) {
      print('❌ Init error: $e');
    }
  }

  Future<void> performSearch(String searchQuery) async {
    final trimmed = searchQuery.trim();

    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    // ✅ Fix: Don't search if same query is already loaded
    if (trimmed == query.value && searchResults.isNotEmpty) return;

    try {
      isSearching.value = true;
      searchError.value = '';
      query.value = trimmed;

      print('🔍 Searching: "$trimmed"');

      final results = await _searchService.searchMovies(trimmed);

      searchResults.value = results;

      // ✅ Fix: Save to recents only after successful search
      if (results.isNotEmpty) {
        addRecentSearch(trimmed);
      }

      print('✅ Found ${results.length} results');

    } on SearchException catch (e) {
      searchError.value = e.message;
      searchResults.clear();
      print('⚠️ Search error: ${e.message}');
    } catch (e) {
      searchError.value = 'Something went wrong';
      searchResults.clear();
      print('❌ Unexpected error: $e');
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() {
    searchResults.clear();
    searchError.value = '';
    query.value = '';
    print('🗑️ Search cleared');
  }

  // ✅ Fix: Renamed to avoid confusion — call this only for recent searches
  void addRecentSearch(String search, {bool updateQuery = false}) {
    final trimmed = search.trim();
    if (trimmed.isEmpty) return;

    recentSearches.removeWhere(
      (s) => s.toLowerCase() == trimmed.toLowerCase(),
    );

    recentSearches.insert(0, trimmed);

    if (recentSearches.length > _maxRecentSearches) {
      recentSearches.removeRange(_maxRecentSearches, recentSearches.length);
    }

    _saveRecentSearches();

    if (updateQuery) {
      query.value = trimmed;
    }

    print('✅ Added to recents: "$trimmed"');
  }

  void removeSearch(String search) {
    recentSearches.remove(search);
    _saveRecentSearches();
    print('🗑️ Removed: "$search"');
  }

  void clearAll() {
    recentSearches.clear();
    _saveRecentSearches();
    print('🗑️ All cleared');
  }

  Future<void> _saveRecentSearches() async {
    try {
      await _prefs.setStringList(_recentSearchesKey, recentSearches.toList());
      print('💾 Saved (${recentSearches.length})');
    } catch (e) {
      print('❌ Save error: $e');
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final saved = _prefs.getStringList(_recentSearchesKey) ?? [];
      recentSearches.value = saved;
      print('📂 Loaded ${saved.length} items');
    } catch (e) {
      print('❌ Load error: $e');
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}