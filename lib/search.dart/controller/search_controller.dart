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

    try {
      isSearching.value = true;
      searchError.value = '';

      print('🔍 Searching: "$trimmed"');

      final results = await _searchService.searchMovies(trimmed);

      searchResults.value = results;
      query.value = trimmed;

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


  void addSearch(String search, {bool updateQuery = false}) {
    final trimmed = search.trim();

    if (trimmed.isEmpty) return;

    recentSearches.removeWhere(
      (s) => s.toLowerCase() == trimmed.toLowerCase(),
    );

    recentSearches.insert(0, trimmed);

    if (recentSearches.length > _maxRecentSearches) {
      recentSearches.removeRange(
        _maxRecentSearches,
        recentSearches.length,
      );
    }

    _saveRecentSearches();

    if (updateQuery) {
      query.value = trimmed;
    }

    print('✅ Added: "$trimmed"');
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
      await _prefs.setStringList(
        _recentSearchesKey,
        recentSearches.toList(),
      );

      print('💾 Saved (${recentSearches.length})');
    } catch (e) {
      print('❌ Save error: $e');
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final saved =
          _prefs.getStringList(_recentSearchesKey) ?? [];

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
// import 'package:get/get_rx/src/rx_types/rx_types.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SearchControllerX extends GetxController {
//   var query = ''.obs;
//   var recentSearches = <String>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadRecentSearches();
//   }
//   void addSearch(String search, {bool updateQuery = false}) {
//     if (search.trim().isEmpty) return;
    
//     final trimmed = search.trim();
    
//     recentSearches.remove(trimmed);
    
//     recentSearches.insert(0, trimmed);
    
//     if (recentSearches.length > 10) {
//       recentSearches.removeLast();
//     }
//     saveRecentSearches();
      
//     if (updateQuery) {
//       query.value = trimmed;
//     }
    
//     print('✅ Recent searches: ${recentSearches.toList()}');
//   }

//   void removeSearch(String search) {
//     recentSearches.remove(search);
//     saveRecentSearches();
//   }

//   void clearAll() {
//     recentSearches.clear();
//     saveRecentSearches();
//   }

//   Future<void> saveRecentSearches() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList('recent_searches', recentSearches.toList());
//   }

//   Future<void> loadRecentSearches() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getStringList('recent_searches') ?? [];
//     recentSearches.value = saved;
//     print('📂 Loaded recent searches: $saved');
//   }
// }