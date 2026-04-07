import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:gutrgoopro/bottombar/bottom_controller.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/model/favorite_model.dart';
import 'package:gutrgoopro/search.dart/controller/search_controller.dart';
import 'package:gutrgoopro/uitls/colors.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchScreen extends StatefulWidget {
  final bool fromBottomNav;

  const SearchScreen({
    super.key,
    required this.fromBottomNav,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  late final SearchControllerX _searchCtrl;
  late final HomeController _homeCtrl;
  late final FavoritesController _favCtrl;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool get _hasText => _searchController.text.trim().isNotEmpty;
  final List<String> _hints = ['Web Series...', 'Movies...'];
  int _hintIndex = 0;
  int _charIndex = 0;
  String _currentHint = '';
  bool _isDeleting = false;
  Timer? _typeTimer;
  Timer? _searchDebounceTimer;
  static const Duration _searchDebounceDelay = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startTypewriter();
  }

  void _initializeControllers() {
    _searchController = TextEditingController();
    _searchCtrl = Get.find<SearchControllerX>();
    _homeCtrl = Get.find<HomeController>();
    _favCtrl = Get.find<FavoritesController>();
    _speech = stt.SpeechToText();

    print('✅ SearchScreen initialized');
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ── Speech to Text ───────────────────────────────────────────────────

  /// Toggle microphone listening
  Future<void> _toggleListening() async {
    if (!_isListening) {
      await _startListening();
    } else {
      await _stopListening();
    }
  }

  /// Start listening for speech input
  Future<void> _startListening() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('🎤 Speech Status: $status');

          if (status == 'done') {
            setState(() => _isListening = false);
            // Auto-submit search after speech ends
            if (_searchController.text.trim().isNotEmpty) {
              _onSearchSubmitted(_searchController.text);
            }
          }
        },
        onError: (error) {
          print('❌ Speech Error: $error');
          setState(() => _isListening = false);
          _showSnackbar('Microphone error: $error');
        },
      );

      if (!available) {
        _showSnackbar('Speech recognition not available on this device');
        return;
      }

      setState(() => _isListening = true);

      _speech.listen(
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        onResult: (result) {
          final text = result.recognizedWords;

          if (mounted) {
            setState(() {
              _searchController.text = text;
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchController.text.length),
              );
            });
          }

          _searchCtrl.query.value = text;

          // Auto-submit on final result
          if (result.finalResult && text.trim().isNotEmpty) {
            _onSearchSubmitted(text);
          }
        },
      );

      print('🎤 Started listening');
    } catch (e) {
      print('❌ Error starting speech: $e');
      setState(() => _isListening = false);
      _showSnackbar('Error: Could not start microphone');
    }
  }

  /// Stop listening for speech
  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      setState(() => _isListening = false);
      print('🎤 Stopped listening');
    } catch (e) {
      print('❌ Error stopping speech: $e');
    }
  }

  // ── Search Methods ───────────────────────────────────────────────────

  /// Handle search submission with debouncing
  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;

    _searchDebounceTimer?.cancel();

    _searchDebounceTimer = Timer(_searchDebounceDelay, () {
      final trimmed = query.trim();

      // Add to recent searches
      _searchCtrl.addSearch(trimmed);

      // Perform API search
      _searchCtrl.performSearch(trimmed);

      print('🔍 Searching API for: "$trimmed"');
    });
  }

  /// Clear search input and results
  void _clearSearch() {
    _searchController.clear();
    _searchCtrl.clearSearch();
    setState(() {
      _startTypewriter();
    });
    print('🗑️ Search cleared');
  }

  /// Go back to previous screen
  void _goBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchController.clear();
    _searchCtrl.query.value = '';

    if (widget.fromBottomNav) {
      Get.find<NavigationController>().currentIndex.value = 0;
    } else {
      Get.back();
    }
  }

  /// Open movie detail screen
  void _openDetail(MovieModel movie) {
    _searchCtrl.addSearch(movie.movieTitle);
    Get.to(() => VideoDetailScreen.fromModel(movie));
  }

  // ── Typewriter Animation ─────────────────────────────────────────────

  /// Start typewriter effect for placeholder text
  void _startTypewriter() {
    _typeTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) return;

      final fullText = _hints[_hintIndex];

      setState(() {
        if (!_isDeleting) {
          // Typing phase
          if (_charIndex < fullText.length) {
            _charIndex++;
            _currentHint = fullText.substring(0, _charIndex);
          } else {
            // Done typing, start deleting
            _isDeleting = true;
            timer.cancel();
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (mounted) _startTypewriter();
            });
          }
        } else {
          // Deleting phase
          if (_charIndex > 0) {
            _charIndex--;
            _currentHint = fullText.substring(0, _charIndex);
          } else {
            // Done deleting, move to next hint
            _isDeleting = false;
            _hintIndex = (_hintIndex + 1) % _hints.length;
            timer.cancel();
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _startTypewriter();
            });
          }
        }
      });
    });
  }

  // ── UI Helpers ───────────────────────────────────────────────────────

  /// Show snackbar message
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey.shade900,
      ),
    );
  }

  /// Build network image with loading and error states
  Widget _networkImage(
    String? url, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
  }) {
    final src = url ?? '';
    if (src.isEmpty) return _imageFallback(height: height, width: width);

    return Image.network(
      src,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _imageShimmer(height: height, width: width);
      },
      errorBuilder: (_, __, ___) =>
          _imageFallback(height: height, width: width),
    );
  }

  /// Image loading shimmer
  Widget _imageShimmer({double? height, double? width}) => Container(
    height: height,
    width: width,
    color: Colors.grey.shade900,
    child: const Center(
      child: CircularProgressIndicator(
        color: Colors.white24,
        strokeWidth: 1.5,
      ),
    ),
  );

  /// Image fallback when URL is empty
  Widget _imageFallback({double? height, double? width}) => Container(
    height: height,
    width: width,
    color: Colors.grey,
    child: Icon(Icons.movie, color: Colors.white24, size: 30.sp),
  );

  /// Action button (Save, Detail, Play)
  Widget _actionBtn(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54, width: 1.5),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // BUILD METHOD
  // ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50.h),

                // ── Search Bar ──────────────────────────────────────────
                _buildSearchBar(),

                // ── Recent Searches or Results ──────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    child: Obx(() {
                      final query = _searchCtrl.query.value.trim();

                      // Empty query → show recent searches + recommended
                      if (query.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRecentSearches(),
                            _buildRecommendedGrid(),
                          ],
                        );
                      }

                      // Show API search results
                      return _buildSearchResults();
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Search Bar Widget ────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back Button
        GestureDetector(
          onTap: _goBack,
          child: Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // Search TextField
        Expanded(
          child: SizedBox(
            height: 50.h,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchCtrl.query.value = value;
                setState(() {});

                if (value.isEmpty) {
                  // Clear search
                  _typeTimer?.cancel();
                  _charIndex = 0;
                  _currentHint = '';
                  _isDeleting = false;
                  _startTypewriter();
                  _searchCtrl.clearSearch();
                } else {
                  // Cancel typewriter, trigger debounced search
                  _typeTimer?.cancel();
                  setState(() => _currentHint = '');
                  _onSearchSubmitted(value);
                }
              },
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _onSearchSubmitted(value);
                }
              },
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search $_currentHint',
                hintStyle: TextStyle(
                  color: Colors.white38,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white54,
                  size: 18.sp,
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    if (_hasText) {
                      _clearSearch();
                    } else {
                      _toggleListening();
                    }
                  },
                  child: Icon(
                    _hasText
                        ? Icons.close
                        : (_isListening ? Icons.mic : Icons.mic_none),
                    color: _hasText
                        ? Colors.white
                        : (_isListening ? Colors.red : Colors.white54),
                    size: 20.sp,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade900,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 15.w,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.orangedark,
                    width: 2.w,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.orangedark,
                    width: 2.w,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.orangedark,
                    width: 2.w,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Recent Searches Widget ───────────────────────────────────────────

  Widget _buildRecentSearches() {
    return Obx(() {
      if (_searchCtrl.recentSearches.isEmpty) {
        return const SizedBox();
      }

      return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: _searchCtrl.clearAll,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _searchCtrl.recentSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    _searchCtrl.query.value = search;
                    _typeTimer?.cancel();
                    setState(() => _currentHint = '');
                    _onSearchSubmitted(search);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white12,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          color: Colors.white38,
                          size: 12.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          search,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: () => _searchCtrl.removeSearch(search),
                          child: Icon(
                            Icons.close,
                            color: Colors.white38,
                            size: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 8.h),
            Divider(color: Colors.white12, height: 1.h),
          ],
        ),
      );
    });
  }

  // ── Recommended Grid Widget ──────────────────────────────────────────

  Widget _buildRecommendedGrid() {
    return Obx(() {
      final movies = _getAllSectionMovies();

      if (_homeCtrl.isLoadingSections.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60.h),
            child: const CircularProgressIndicator(
              color: Colors.white24,
              strokeWidth: 2,
            ),
          ),
        );
      }

      if (movies.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Text(
            'Recommended for You',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 0.65,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () => _openDetail(movie),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: _networkImage(movie.verticalPosterUrl),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  // ── Search Results Widget ────────────────────────────────────────────

  Widget _buildSearchResults() {
    return Obx(() {
      // Loading state
      if (_searchCtrl.isSearching.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60.h),
            child: const CircularProgressIndicator(
              color: Colors.white24,
              strokeWidth: 2,
            ),
          ),
        );
      }

      // Error state
      if (_searchCtrl.searchError.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: 40.h),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade400,
                  size: 40.sp,
                ),
                SizedBox(height: 12.h),
                Text(
                  _searchCtrl.searchError.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Results list
      final results = _searchCtrl.searchResults;

      if (results.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60.h),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  color: Colors.white38,
                  size: 50.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No results found for\n"${_searchCtrl.query.value}"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final movie = results[index];
          return GestureDetector(
            onTap: () => _openDetail(movie),
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    child: _networkImage(
                      movie.horizontalBannerUrl.isNotEmpty
                          ? movie.horizontalBannerUrl
                          : movie.verticalPosterUrl,
                      height: 200.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                movie.movieTitle,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // Save button
                     Obx(() {
  final movieId = movie.id;

  // 🔴 SAFETY CHECK
  if (movieId.isEmpty) {
    print("❌ Movie ID missing");
    return SizedBox(); // ya disabled button
  }

  final isFav = _favCtrl.isFavorite(movieId);

  return _actionBtn(
    isFav ? Icons.check_circle : Icons.add_outlined,
    'Save',
    onTap: () {
      _favCtrl.toggleFavorite(
        FavoriteItem(
          id: movieId, // ✅ अब safe है
          title: movie.movieTitle,
          image: movie.verticalPosterUrl,
          videoTrailer: movie.playUrl,
          subtitle: movie.genresString,
        ),
      );
    },
    color: isFav ? Colors.red : Colors.white,
  );
}),
                            SizedBox(width: 12.w),
                            // Detail button
                            _actionBtn(
                              Icons.info_outline,
                              'Detail',
                              onTap: () => _openDetail(movie),
                            ),
                            SizedBox(width: 12.w),
                            // Play button
                            GestureDetector(
                              onTap: () => _openDetail(movie),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.black,
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Play',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          movie.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          movie.genresString,
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // ── Helper Methods ───────────────────────────────────────────────────

  /// Get all unique movies from home sections
  List<MovieModel> _getAllSectionMovies() {
    final seen = <String>{};
    final result = <MovieModel>[];
    for (final section in _homeCtrl.homeSections) {
      for (final movie in section.items) {
        if (seen.add(movie.id)) {
          result.add(movie);
        }
      }
    }
    return result;
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'dart:async';
// import 'package:gutrgoopro/bottombar/bottom_controller.dart';
// import 'package:gutrgoopro/home/getx/home_controller.dart';
// import 'package:gutrgoopro/home/model/movie_model.dart';
// import 'package:gutrgoopro/home/screen/details_screen.dart';
// import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
// import 'package:gutrgoopro/profile/model/favorite_model.dart';
// import 'package:gutrgoopro/search.dart/controller/search_controller.dart';
// import 'package:gutrgoopro/uitls/colors.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class SearchScreen extends StatefulWidget {
//   final bool fromBottomNav;
//   const SearchScreen({super.key, required this.fromBottomNav});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController searchController = TextEditingController();
//   late final SearchControllerX controller;
//   late final HomeController homeController;
//   late final FavoritesController favoritesController;
//   late stt.SpeechToText _speech;
//   bool get _hasText => searchController.text.trim().isNotEmpty;
//   bool _isListening = false;
//   final List<String> _hints = ['Web Series...', 'Movies...'];
//   int _hintIndex = 0;
//   int _charIndex = 0;
//   String _currentHint = '';
//   bool _isDeleting = false;
//   Timer? _typeTimer;

//   List<MovieModel> get _allSectionMovies {
//     final seen = <String>{};
//     final result = <MovieModel>[];
//     for (final section in homeController.homeSections) {
//       for (final movie in section.items) {
//         if (seen.add(movie.id)) {
//           result.add(movie);
//         }
//       }
//     }
//     return result;
//   }

//   @override
//   void initState() {
//     super.initState();
//     controller = Get.find<SearchControllerX>();
//     homeController = Get.find<HomeController>();
//     favoritesController = Get.find<FavoritesController>();
//     _speech = stt.SpeechToText();

//     _startTypewriter();
//   }

//   Future<void> _toggleListening() async {
//     if (!_isListening) {
//       bool available = await _speech.initialize(
//         onStatus: (status) {
//           print('Status: $status');

//           if (status == 'done') {
//             setState(() => _isListening = false);
//           }
//         },
//         onError: (error) {
//           print('Error: $error');
//           setState(() => _isListening = false);
//         },
//       );

//       if (available) {
//         setState(() => _isListening = true);

//         _speech.listen(
//           listenFor: const Duration(seconds: 10),
//           pauseFor: const Duration(seconds: 3),
//           onResult: (result) {
//             final text = result.recognizedWords;

//             searchController.text = text;
//             searchController.selection = TextSelection.fromPosition(
//               TextPosition(offset: searchController.text.length),
//             );

//             controller.query.value = text;

//             if (result.finalResult) {
//               controller.addSearch(text);
//               setState(() => _isListening = false);
//             }
//           },
//         );
//       }
//     } else {
//       setState(() => _isListening = false);
//       _speech.stop();
//     }
//   }

//   void _clearSearch() {
//     searchController.clear();
//     controller.query.value = '';
//     setState(() {}); // refresh UI
//   }

//   void _startTypewriter() {
//     _typeTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
//       if (!mounted) return;
//       final fullText = _hints[_hintIndex];
//       setState(() {
//         if (!_isDeleting) {
//           if (_charIndex < fullText.length) {
//             _charIndex++;
//             _currentHint = fullText.substring(0, _charIndex);
//           } else {
//             _isDeleting = true;
//             timer.cancel();
//             Future.delayed(const Duration(milliseconds: 1200), () {
//               if (mounted) _startTypewriter();
//             });
//           }
//         } else {
//           if (_charIndex > 0) {
//             _charIndex--;
//             _currentHint = fullText.substring(0, _charIndex);
//           } else {
//             _isDeleting = false;
//             _hintIndex = (_hintIndex + 1) % _hints.length;
//             timer.cancel();
//             Future.delayed(const Duration(milliseconds: 300), () {
//               if (mounted) _startTypewriter();
//             });
//           }
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _typeTimer?.cancel();
//     searchController.dispose();
//     super.dispose();
//   }

//   void _goBack() {
//     FocusManager.instance.primaryFocus?.unfocus();
//     searchController.clear();
//     controller.query.value = '';
//     if (widget.fromBottomNav) {
//       Get.find<NavigationController>().currentIndex.value = 0;
//     } else {
//       Get.back();
//     }
//   }

//   void _openDetail(MovieModel movie) {
//     controller.addSearch(movie.movieTitle);
//     Get.to(() => VideoDetailScreen.fromModel(movie));
//   }

//   Widget _networkImage(
//     String? url, {
//     double? height,
//     double? width,
//     BoxFit fit = BoxFit.cover,
//   }) {
//     final src = url ?? '';
//     if (src.isEmpty) return _imageFallback(height: height, width: width);
//     return Image.network(
//       src,
//       height: height,
//       width: width,
//       fit: fit,
//       loadingBuilder: (context, child, progress) {
//         if (progress == null) return child;
//         return _imageShimmer(height: height, width: width);
//       },
//       errorBuilder: (_, __, ___) =>
//           _imageFallback(height: height, width: width),
//     );
//   }

//   Widget _imageShimmer({double? height, double? width}) => Container(
//     height: height,
//     width: width,
//     color: Colors.grey.shade900,
//     child: const Center(
//       child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 1.5),
//     ),
//   );

//   Widget _imageFallback({double? height, double? width}) => Container(
//     height: height,
//     width: width,
//     color: Colors.grey,
//     child: Icon(Icons.movie, color: Colors.white24, size: 30.sp),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _goBack();
//         return false;
//       },
//       child: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Scaffold(
//           resizeToAvoidBottomInset: false,
//           backgroundColor: Colors.black,
//           body: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 50.h),

//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: _goBack,
//                       child: Container(
//                         width: 36.w,
//                         height: 36.h,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade900,
//                           shape: BoxShape.circle,
//                         ),
//                         alignment: Alignment.center,
//                         child: Icon(
//                           Icons.arrow_back,
//                           color: Colors.white,
//                           size: 22.sp,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//                     Expanded(
//                       child: SizedBox(
//                         height: 50.h,
//                         child: TextField(
//                           controller: searchController,
//                           onChanged: (v) {
//                             controller.query.value = v;
//                             setState(() {});
//                             if (v.isEmpty) {
//                               _typeTimer?.cancel();
//                               _charIndex = 0;
//                               _currentHint = '';
//                               _isDeleting = false;
//                               _startTypewriter();
//                             } else {
//                               _typeTimer?.cancel();
//                               setState(() => _currentHint = '');
//                             }
//                           },
//                           onSubmitted: (value) {
//                             if (value.trim().isNotEmpty) {
//                               controller.addSearch(value.trim());
//                             }
//                           },
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14.sp,
//                           ),
//                           decoration: InputDecoration(
//                             isDense: true,
//                             hintText: 'Search $_currentHint',
//                             hintStyle: TextStyle(
//                               color: Colors.white38,
//                               fontSize: 12.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             prefixIcon: Icon(
//                               Icons.search,
//                               color: Colors.white54,
//                               size: 18.sp,
//                             ),
//                             suffixIcon: GestureDetector(
//                               onTap: () {
//                                 if (_hasText) {
//                                   _clearSearch();
//                                 } else {
//                                   _toggleListening();
//                                 }
//                               },
//                               child: Icon(
//                                 _hasText
//                                     ? Icons.close
//                                     : (_isListening
//                                           ? Icons.mic
//                                           : Icons.mic_none),
//                                 color: _hasText
//                                     ? Colors.white
//                                     : (_isListening
//                                           ? Colors.red
//                                           : Colors.white54),
//                                 size: 20.sp,
//                               ),
//                             ),

//                             filled: true,
//                             fillColor: Colors.grey.shade900,
//                             contentPadding: EdgeInsets.symmetric(
//                               vertical: 0,
//                               horizontal: 15.w,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                               borderSide: BorderSide(
//                                 color: AppColors.orangedark,
//                                 width: 2.w,
//                               ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                               borderSide: BorderSide(
//                                 color: AppColors.orangedark,
//                                 width: 2.w,
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                               borderSide: BorderSide(
//                                 color: AppColors.orangedark,
//                                 width: 2.w,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 // ── Recent searches ──────────────────────────────────────
//                 Obx(() {
//                   if (controller.query.value.isEmpty &&
//                       controller.recentSearches.isNotEmpty) {
//                     return Padding(
//                       padding: EdgeInsets.only(top: 16.h),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Recent Searches',
//                                 style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 13.sp,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: controller.clearAll,
//                                 child: Text(
//                                   'Clear All',
//                                   style: TextStyle(
//                                     color: AppColors.orange,
//                                     fontSize: 12.sp,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 10.h),
//                           Wrap(
//                             spacing: 8.w,
//                             runSpacing: 8.h,
//                             children: controller.recentSearches.map((s) {
//                               return GestureDetector(
//                                 onTap: () {
//                                   searchController.text = s;
//                                   controller.query.value = s;
//                                   _typeTimer?.cancel();
//                                   setState(() => _currentHint = '');
//                                 },
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 12.w,
//                                     vertical: 6.h,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade900,
//                                     borderRadius: BorderRadius.circular(20.r),
//                                     border: Border.all(
//                                       color: Colors.white12,
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(
//                                         Icons.history,
//                                         color: Colors.white38,
//                                         size: 12.sp,
//                                       ),
//                                       SizedBox(width: 4.w),
//                                       Text(
//                                         s,
//                                         style: TextStyle(
//                                           color: Colors.white70,
//                                           fontSize: 12.sp,
//                                         ),
//                                       ),
//                                       SizedBox(width: 6.w),
//                                       GestureDetector(
//                                         onTap: () => controller.removeSearch(s),
//                                         child: Icon(
//                                           Icons.close,
//                                           color: Colors.white38,
//                                           size: 12.sp,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                           SizedBox(height: 8.h),
//                           Divider(color: Colors.white12, height: 1.h),
//                         ],
//                       ),
//                     );
//                   }
//                   return const SizedBox();
//                 }),

//                 // ── Results ──────────────────────────────────────────────
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Obx(() {
//                           final query = controller.query.value
//                               .trim()
//                               .toLowerCase();

//                           // Empty query → show recommended grid
//                           if (query.isEmpty) return _allMoviesGrid();

//                           // Filter from all section movies
//                           final filtered = _allSectionMovies
//                               .where(
//                                 (m) =>
//                                     m.movieTitle.toLowerCase().contains(
//                                       query,
//                                     ) ||
//                                     m.genresString.toLowerCase().contains(
//                                       query,
//                                     ) ||
//                                     m.description.toLowerCase().contains(query),
//                               )
//                               .toList();

//                           if (filtered.isEmpty) {
//                             return const Center(
//                               child: Padding(
//                                 padding: EdgeInsets.only(top: 40),
//                                 child: Text(
//                                   'No results found',
//                                   style: TextStyle(color: Colors.white70),
//                                 ),
//                               ),
//                             );
//                           }

//                           return ListView.builder(
//                             shrinkWrap: true,
//                             padding: EdgeInsets.zero,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemCount: filtered.length,
//                             itemBuilder: (context, index) {
//                               final movie = filtered[index];
//                               return GestureDetector(
//                                 onTap: () => _openDetail(movie),
//                                 child: Container(
//                                   margin: EdgeInsets.only(bottom: 16.h),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF1A1A1A),
//                                     borderRadius: BorderRadius.circular(12.r),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(12.r),
//                                           topRight: Radius.circular(12.r),
//                                         ),
//                                         child: _networkImage(
//                                           movie.horizontalBannerUrl.isNotEmpty
//                                               ? movie.horizontalBannerUrl
//                                               : movie.verticalPosterUrl,
//                                           height: 200.h,
//                                           width: double.infinity,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.all(12.w),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                               children: [
//                                                 Expanded(
//                                                   child: Text(
//                                                     movie.movieTitle,
//                                                     maxLines: 2,
//                                                     style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 16.sp,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(width: 8.w),
//                                                 // Save button
//                                                 Obx(() {
//                                                   final inMyList =
//                                                       favoritesController
//                                                           .isInMyList(
//                                                             movie.playUrl,
//                                                           );
//                                                   return _actionBtn(
//                                                     inMyList
//                                                         ? Icons.check_circle
//                                                         : Icons.add_outlined,
//                                                     'Save',
//                                                     onTap: () {
//                                                       if (inMyList) {
//                                                         favoritesController
//                                                             .removeByvideoTrailer(
//                                                               movie.playUrl,
//                                                             );
//                                                       } else {
//                                                         favoritesController
//                                                             .addFavorite(
//                                                               FavoriteItem(
//                                                                 title: movie
//                                                                     .movieTitle,
//                                                                 image: movie
//                                                                     .verticalPosterUrl,
//                                                                 videoTrailer:
//                                                                     movie
//                                                                         .playUrl,
//                                                                 subtitle: movie
//                                                                     .genresString,
//                                                               ),
//                                                             );
//                                                       }
//                                                     },
//                                                     color: inMyList
//                                                         ? Colors.red
//                                                         : Colors.white,
//                                                   );
//                                                 }),
//                                                 SizedBox(width: 12.w),
//                                                 _actionBtn(
//                                                   Icons.info_outline,
//                                                   'Detail',
//                                                   onTap: () =>
//                                                       _openDetail(movie),
//                                                 ),
//                                                 SizedBox(width: 12.w),
//                                                 // Play button
//                                                 GestureDetector(
//                                                   onTap: () =>
//                                                       _openDetail(movie),
//                                                   child: Column(
//                                                     children: [
//                                                       Container(
//                                                         padding: EdgeInsets.all(
//                                                           8.r,
//                                                         ),
//                                                         decoration:
//                                                             const BoxDecoration(
//                                                               color:
//                                                                   Colors.white,
//                                                               shape: BoxShape
//                                                                   .circle,
//                                                             ),
//                                                         child: Icon(
//                                                           Icons.play_arrow,
//                                                           color: Colors.black,
//                                                           size: 20.sp,
//                                                         ),
//                                                       ),
//                                                       SizedBox(height: 4.h),
//                                                       Text(
//                                                         'Play',
//                                                         style: TextStyle(
//                                                           color: Colors.white70,
//                                                           fontSize: 10.sp,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(height: 8.h),
//                                             Text(
//                                               movie.description,
//                                               maxLines: 3,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(
//                                                 color: Colors.white70,
//                                                 fontSize: 12.sp,
//                                                 height: 1.5,
//                                               ),
//                                             ),
//                                             SizedBox(height: 8.h),
//                                             Text(
//                                               movie.genresString,
//                                               style: TextStyle(
//                                                 color: Colors.white38,
//                                                 fontSize: 11.sp,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         }),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Recommended grid (shown when search is empty) ────────────────────────
//   Widget _allMoviesGrid() {
//     return Obx(() {
//       // Rebuild when homeSections changes
//       final movies = _allSectionMovies;
//       if (homeController.isLoadingSections.value) {
//         return const Center(
//           child: Padding(
//             padding: EdgeInsets.only(top: 60),
//             child: CircularProgressIndicator(
//               color: Colors.white24,
//               strokeWidth: 2,
//             ),
//           ),
//         );
//       }
//       if (movies.isEmpty) return const SizedBox();

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 16.h),
//           Text(
//             'Recommended for You',
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 1,
//             ),
//           ),
//           SizedBox(height: 12.h),
//           GridView.builder(
//             shrinkWrap: true,
//             padding: EdgeInsets.zero,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 8.w,
//               mainAxisSpacing: 8.h,
//               childAspectRatio: 0.65,
//             ),
//             itemCount: movies.length,
//             itemBuilder: (context, index) {
//               final movie = movies[index];
//               return GestureDetector(
//                 onTap: () => _openDetail(movie),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8.r),
//                   child: _networkImage(movie.verticalPosterUrl),
//                 ),
//               );
//             },
//           ),
//         ],
//       );
//     });
//   }

//   Widget _actionBtn(
//     IconData icon,
//     String label, {
//     VoidCallback? onTap,
//     Color color = Colors.white,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8.r),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white54, width: 1.5),
//             ),
//             child: Icon(icon, color: color, size: 18.sp),
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             label,
//             style: TextStyle(color: Colors.white70, fontSize: 10.sp),
//           ),
//         ],
//       ),
//     );
//   }
// }
