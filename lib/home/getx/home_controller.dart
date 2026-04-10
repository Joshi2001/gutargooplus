import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/model/banner_model.dart';
import 'package:gutrgoopro/home/model/category_model.dart';
import 'package:gutrgoopro/home/model/home_section_model.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/repo/repo_home_section.dart';
import 'package:gutrgoopro/home/service/banner_service.dart';
import 'package:gutrgoopro/home/service/category_service.dart';
import 'package:gutrgoopro/uitls/local_store.dart';

class HomeController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final RxBool isTopBarSolid = false.obs;
  final RxInt selectedCategoryIndex = 0.obs;
final RxString userToken = ''.obs;
  final RxBool isLoadingBanners = true.obs;
  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingSections = true.obs;
  final RxBool isLoadingTrending = false.obs;
  final RxString errorMessage = ''.obs;
bool _isDataLoaded = false;
  final RxList<BannerMovie> allBanners = <BannerMovie>[].obs;
var isLoadingHome = true.obs;
  final RxList<HomeSectionModel> allSections = <HomeSectionModel>[].obs;
  final RxList<HomeSectionModel> homeSections = <HomeSectionModel>[].obs;

  final RxList<BannerMovie> bannerMovies = <BannerMovie>[].obs;
  final RxList<MovieModel> featuredMovies = <MovieModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  final RxList<Map<String, dynamic>> bannerLegacyList =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> continueWatching =
      <Map<String, dynamic>>[].obs;

  final HomeSectionRepository _sectionRepo = HomeSectionRepository();

  List<String> get categoryNames {
    if (categories.isEmpty) {
      return ['Home', 'Movies', 'TV Shows', 'Web Series'];
    }
    return ['Home', ...categories.map((c) => c.name)];
  }

  CategoryModel? get selectedCategory {
    final idx = selectedCategoryIndex.value;
    if (idx == 0) return null;
    final dynamicIndex = idx - 1;
    if (dynamicIndex < categories.length) return categories[dynamicIndex];
    return null;
  }

  List<MovieModel> get trendingMovies =>
      homeSections.expand((s) => s.items).toList();

  List<Map<String, dynamic>> get trendingList {
    final result = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final section in homeSections) {
      for (final movie in section.items) {
        if (!seen.add(movie.id)) continue;
        result.add({
          '_id': movie.id,
          'title': movie.movieTitle,
          'image': movie.verticalPosterUrl,
          'subtitle': movie.genresString,
          'videoTrailer': movie.trailerUrl,
          'videoMovies': movie.playUrl,
          'dis': movie.description,
          'logoImage': movie.logoUrl,
          'imdbRating': movie.imdbRating,
          'ageRating': movie.ageRating,
        });
      }
    }
    return result;
  }

  final RxInt selectedLiveMatchIndex = 0.obs;
  final RxInt currentBannerIndex = 0.obs;
  PageController? pageController;
  Timer? _timer;

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    _applyFilter();
    _applyBannerFilter();
  }

  void selectLiveMatch(int index) => selectedLiveMatchIndex.value = index;
  void clearContinueWatching() => continueWatching.clear();
  void onBannerPageChanged(int index) => currentBannerIndex.value = index;

  void _applyFilter() {
  final category = selectedCategory;

  if (category == null) {
    homeSections.assignAll(allSections);
    return;
  }

  final filtered = allSections.where((section) {

    if (section.categoryId == category.id) return true;


    return false;
  }).toList();

  homeSections.assignAll(filtered);
}
    Future<void> fetchHomeData() async {
       try {
    isLoadingHome.value = true;

    await Future.wait([
      _fetchCategories(),
        _fetchBanners(),
        _fetchSections(),
    ]);
  } finally {
    isLoadingHome.value = false;
  }
  }

  Future<void> _fetchCategories() async {
  try {
    isLoadingCategories.value = true;
    final result = await CategoryService.fetchCategories();
    categories.assignAll(result);
  } catch (e) {
    debugPrint('_fetchCategories error: $e');

    categories.clear();
  } finally {
    isLoadingCategories.value = false;
  }
}
  Future<void> _fetchBanners() async {
    try {
      isLoadingBanners.value = true;
      errorMessage.value = '';
      final banners = await BannerMovieService.fetchAllBanners(limit: 50);
      allBanners.assignAll(banners);
      _applyBannerFilter();
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('_fetchBanners error: $e');
    } finally {
      isLoadingBanners.value = false;
    }
  }

  void _applyBannerFilter() {
    final category = selectedCategory;
    if (category == null) {
      bannerMovies.assignAll(allBanners);
    } else {
      final filtered = allBanners
          .where((b) => b.categoryId == category.id)
          .toList();
      bannerMovies.assignAll(filtered);
    }
    bannerLegacyList.assignAll(
      bannerMovies.map(_bannerToLegacyMap).toList(),
    );
    debugPrint(
      '🎯 Banner filter: category=${category?.name ?? "Home"} '
      '→ ${bannerMovies.length} banners',
    );
  }


  Future<void> _fetchSections() async {
  try {
    isLoadingSections.value = true;
    isLoadingTrending.value = true;

    final sections = await _sectionRepo.fetchSections();

    allSections.assignAll(sections);
    _applyFilter();

    debugPrint('✅ allSections: ${allSections.length}, homeSections: ${homeSections.length}');
  } catch (e) {
    debugPrint('❌ _fetchSections error: $e');
    homeSections.clear();
  } finally {
    isLoadingSections.value = false;
    isLoadingTrending.value = false;
  }
}
  Future<void> fetchSectionsByCategory(String categoryId) async {
    try {
      isLoadingSections.value = true;
      final sections =
          await _sectionRepo.fetchSections(categoryId: categoryId);
      allSections.assignAll(sections);
      homeSections.assignAll(sections);
    } catch (e) {
      debugPrint('fetchSectionsByCategory error: $e');
      homeSections.clear();
    } finally {
      isLoadingSections.value = false;
    }
  }

  Map<String, dynamic> _bannerToLegacyMap(BannerMovie b) => {
        'id': b.id,
        'image': b.mobileImage,
        'title': b.title,
        'subtitle': b.genres.join(', '),
        'videoTrailer': b.trailerUrl.isNotEmpty ? b.trailerUrl : b.movieUrl,
        'videoMovies': b.movieUrl,
        'dis': b.description,
        'logoImage': b.logoImage,
        'live': false,
        'imdbRating': b.imdbRating,
        'ageRating': b.ageLimit,
      };

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (pageController == null || !pageController!.hasClients) return;
      final max = bannerMovies.isEmpty
          ? featuredMovies.length
          : bannerMovies.length;
      if (max == 0) return;
      final next = (currentBannerIndex.value + 1) % max;
      pageController!.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchHomeData();
  //    loadToken();
  //   _startAutoScroll();
  //   scrollController.addListener(() {
  //     isTopBarSolid.value = scrollController.offset > 0;
  //   });
  // }
  @override
void onInit() {
  super.onInit();

  if (!_isDataLoaded) {
    fetchHomeData();
    _isDataLoaded = true;
  }

  loadToken();
  _startAutoScroll();

  scrollController.addListener(() {
    isTopBarSolid.value = scrollController.offset > 0;
  });
}
Future<void> loadToken() async {
  final token = await LocalStore.getToken();
  userToken.value = token ?? '';
  print("🔑 Loaded Token: ${userToken.value}");
}
  @override
  void onClose() {
    _timer?.cancel();
    pageController?.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
