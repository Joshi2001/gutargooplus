import 'dart:async';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/custom/coming_soon.dart';
import 'package:gutrgoopro/home/model/banner_model.dart';
import 'package:gutrgoopro/home/model/home_section_model.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';
import 'package:gutrgoopro/home/service/banner_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/screen/view_all_screen.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/model/favorite_model.dart';
import 'package:gutrgoopro/uitls/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());
  final ScrollController scrollController = ScrollController();
  late final PageController heroController;
  final FavoritesController favoritesController =
      Get.find<FavoritesController>();

  int _currentIndex = 0;
  List<Color> _bannerTopColors = [];
  bool _isRefreshing = false;

  LinearGradient get _topGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_getCurrentColor(), _getCurrentColor()],
  );

  LinearGradient get _bannerGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      _getCurrentColor(),
      _getCurrentColor(),
      const Color(0xFF000000),
      const Color(0xFF000000),
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
  );

  Color _getCurrentColor() {
    if (_bannerTopColors.isEmpty || _currentIndex >= _bannerTopColors.length) {
      return Colors.black;
    }
    return _bannerTopColors[_currentIndex];
  }

  @override
  void initState() {
    super.initState();
    heroController = PageController(viewportFraction: 0.90, initialPage: 1);
    ever(controller.bannerMovies, (_) => _extractColors());
    ever(controller.featuredMovies, (_) {
      if (controller.bannerMovies.isEmpty) _extractColors();
    });
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    setState(() => _bannerTopColors = []);
    await controller.fetchHomeData();
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _extractColors() async {
    final List<Color> colors = [];
    final validBanners = controller.bannerMovies
        .where((b) => b.publishStatus && b.mobileImage.isNotEmpty)
        .toList();

    final sourcelist = validBanners.isNotEmpty
        ? validBanners.cast<dynamic>()
        : controller.featuredMovies.cast<dynamic>();

    for (final item in sourcelist) {
      try {
        String imageUrl = '';
        if (item is BannerMovie) {
          imageUrl = item.mobileImage.isNotEmpty
              ? item.mobileImage
              : item.logoImage;
        } else if (item is MovieModel) {
          imageUrl = item.verticalPosterUrl;
        }
        final color = imageUrl.isNotEmpty
            ? await _dominantColorFromNetwork(imageUrl)
            : const Color(0xFF1E3A5F);
        colors.add(color);
      } catch (_) {
        colors.add(const Color(0xFF1E3A5F));
      }
    }

    if (mounted) setState(() => _bannerTopColors = colors);
  }

  Future<Color> _dominantColorFromNetwork(String url) async {
    if (url.isEmpty) return Colors.black;
    final provider = NetworkImage(url);
    final stream = provider.resolve(ImageConfiguration.empty);
    final completer = Completer<ui.Image>();
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (e, _) {
        completer.completeError(e);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    final image = await completer.future;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return Colors.black;
    final pixels = byteData.buffer.asUint8List();
    int rSum = 0, gSum = 0, bSum = 0, count = 0;
    final maxY = (image.height * 0.3).toInt();
    for (int y = 0; y < maxY; y++) {
      for (int x = 0; x < image.width; x++) {
        final i = (y * image.width + x) * 4;
        if (i + 2 >= pixels.length) continue;
        final r = pixels[i], g = pixels[i + 1], b = pixels[i + 2];
        final bright = (r + g + b) / 3;
        if (bright > 30 && bright < 225) {
          rSum += r;
          gSum += g;
          bSum += b;
          count++;
        }
      }
    }
    if (count == 0) return Colors.black;
    return Color.fromARGB(
      255,
      (rSum / count).round(),
      (gSum / count).round(),
      (bSum / count).round(),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.black,
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: Colors.white,
            backgroundColor: Colors.grey.shade900,
            displacement: 20,
            edgeOffset: 160.h,
            strokeWidth: 2.5,
            child: CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  pinned: false,
                  floating: false,
                  snap: false,
                  backgroundColor: Colors.black,
                  automaticallyImplyLeading: false,
                  flexibleSpace: AnimatedContainer(
                    decoration: BoxDecoration(gradient: _topGradient),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 10.h,
                        left: 8.w,
                        right: 8.w,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10.w, top: 20.h),
                            child: Image.asset(
                              "assets/white_logo.png",
                              height: 120.h,
                              width: 140.w,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10.w, top: 20.h),
                            child: _goProButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  floating: false,
                  delegate: CategorySelectorDelegate(
                    child: _categorySelector(),
                    height: 70.h,
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.zero,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _heroBannerSection(),
                      SizedBox(height: Get.height * 0.02),
                      _dynamicSections(),
                      SizedBox(height: 24.h),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dynamicSections() {
    return Obx(() {
      if (controller.isLoadingHome.value) {
        return Column(
          children: List.generate(
            4,
            (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeaderShimmer(),
                _posterRowShimmer(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      }
      if (controller.homeSections.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Text(
              'No content available',
              style: TextStyle(color: Colors.white54, fontSize: 14.sp),
            ),
          ),
        );
      }
      final seen = <String>{};
      final filteredSections = controller.homeSections
          .where((s) => seen.add(s.id))
          .toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: filteredSections.map(_sectionBlock).toList(),
      );
    });
  }

  Widget _sectionBlock(HomeSectionModel section) {
    if (section.items.isEmpty) return const SizedBox.shrink();
    final uniqueMovies = {for (var m in section.items) m.id: m}.values.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(section.title),
        _buildSectionListWithItems(section, uniqueMovies),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSectionListWithItems(
    HomeSectionModel section,
    List<MovieModel> items,
  ) {
    switch (section.displayStyle) {
      case 'index_vertical':
        return _indexVerticalList(items, section.id);
      case 'horizontal_banner':
        return _horizontalBannerList(items);
      default:
        return _standardPosterList(items);
    }
  }

  Widget _indexVerticalList(List<MovieModel> items, String sectionId) {
    final limited = items.take(10).toList();
    return SizedBox(
      height: 170.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 40.w, right: 30.w),
        itemCount: limited.length,
        itemBuilder: (ctx, i) =>
            _top10Card(movie: limited[i], rank: i + 1, sectionId: sectionId),
      ),
    );
  }

  Widget _horizontalBannerList(List<MovieModel> items) {
    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 15.w),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final movie = items[i];
          final imageUrl = movie.horizontalBannerUrl.isNotEmpty
              ? movie.horizontalBannerUrl
              : movie.verticalPosterUrl;
          return GestureDetector(
            onTap: () => _navigateToDetail(movie),
            child: Container(
              width: 180.w,
              margin: EdgeInsets.only(right: 10.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: imageUrl.isNotEmpty
                    ? _cdnImage(
                        imageUrl,
                        height: 100.h,
                        width: 180.w,
                        fit: BoxFit.cover,
                        loadingWidget: _shimmerBase(
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _standardPosterList(List<MovieModel> items) {
    return SizedBox(
      height: 170.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 15.w),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final movie = items[index];
          final cardImage = movie.verticalPosterUrl;

          return GestureDetector(
            onTap: () => _navigateToDetail(movie),
            child: Container(
              width: 100.w,
              margin: EdgeInsets.only(right: 10.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: cardImage.isNotEmpty
                    ? _cdnImage(
                        cardImage,
                        height: 170.h,
                        width: 100.w,
                        fit: BoxFit.cover,
                        loadingWidget: _shimmerBase(
                          child: Container(
                            height: 170.h,
                            width: 100.w,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        errorWidget: _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _shimmerBase({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade700,
      child: child,
    );
  }

  Widget _sectionHeaderShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: _shimmerBase(
        child: Container(
          width: 140.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  Widget _posterRowShimmer() {
    return SizedBox(
      height: 170.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 15.w),
        itemCount: 6,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade900,
          highlightColor: Colors.grey.shade800,
          child: Container(
            width: 100.w,
            height: 170.h,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroBannerShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade800,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 420.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _top10Card({
    required MovieModel movie,
    required int rank,
    required String sectionId,
  }) {
    final cardImage = movie.verticalPosterUrl;
    return GestureDetector(
      onTap: () => _navigateToDetail(movie),
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: 50.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(left: -30.w, bottom: 5.h, child: _rankNumber(rank)),
            Positioned(
              left: 30.w,
              top: 5.h,
              bottom: 5.h,
              child: Hero(
                tag: 'top10_${sectionId}_${movie.id}_$rank',
                child: Container(
                  width: 100.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: cardImage.isNotEmpty
                        ? _cdnImage(
                            cardImage,
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingWidget: _shimmerBase(
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: Container(color: Colors.grey.shade800),
                          )
                        : Container(color: Colors.grey.shade800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rankNumber(int rank) {
    final strokeStyle = (Paint p) => TextStyle(
      fontSize: 145.sp,
      fontWeight: FontWeight.w900,
      height: 0.82,
      letterSpacing: -5,
      fontFamily: 'Impact',
      foreground: p,
    );
    return Stack(
      children: [
        Text(
          '$rank',
          style: strokeStyle(
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 12.w
              ..color = Colors.black,
          ),
        ),
        Text(
          '$rank',
          style: strokeStyle(
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8.w
              ..color = Colors.grey.shade900,
          ),
        ),
        Text(
          '$rank',
          style: TextStyle(
            fontSize: 145.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 0.82,
            letterSpacing: -5,
            fontFamily: 'Impact',
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.9),
                blurRadius: 25,
                offset: const Offset(3, 3),
              ),
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(() => ViewAllScreen(title: title)),
            child: Text(
              'View All',
              style: TextStyle(color: AppColors.orange, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBannerSection() {
    return Obx(() {
      final validBanners = controller.bannerMovies
          .where((b) => b.publishStatus && b.mobileImage.isNotEmpty)
          .toList();

      final isLoading = controller.isLoadingBanners.value;
      if (isLoading) {
        return SizedBox(height: 420.h, child: _heroBannerShimmer());
      }
      if (validBanners.isEmpty && controller.featuredMovies.isEmpty) {
        return SizedBox(height: 20.h);
      }

      final sourceList = validBanners.isNotEmpty
          ? validBanners.cast<dynamic>()
          : controller.featuredMovies.cast<dynamic>();

      final banners = _looping(sourceList);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.bounceInOut,
        decoration: BoxDecoration(gradient: _bannerGradient),
        child: SizedBox(
          height: 420.h,
          child: PageView.builder(
            controller: heroController,
            itemCount: banners.length,
            physics: const PageScrollPhysics(),
            onPageChanged: (index) {
              final len = sourceList.length;
              if (index == 0) {
                Future.delayed(
                  const Duration(milliseconds: 300),
                  () => heroController.jumpToPage(banners.length - 2),
                );
                setState(() => _currentIndex = len - 1);
              } else if (index == banners.length - 1) {
                Future.delayed(
                  const Duration(milliseconds: 300),
                  () => heroController.jumpToPage(1),
                );
                setState(() => _currentIndex = 0);
              } else {
                setState(() => _currentIndex = index - 1);
              }
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: heroController,
                builder: (context, child) {
                  final page =
                      heroController.hasClients &&
                          heroController.position.haveDimensions
                      ? (heroController.page ??
                            heroController.initialPage.toDouble())
                      : heroController.initialPage.toDouble();
                  final distance = (page - index).abs();
                  final scale = (1 - distance * 0.04).clamp(0.96, 1.0);
                  final opacity = (1 - distance * 0.08).clamp(0.90, 1.0);
                  return Transform.translate(
                    offset: Offset(0, distance * 8),
                    child: Transform.scale(
                      scale: Curves.easeOutCubic.transform(scale),
                      child: Opacity(opacity: opacity, child: child),
                    ),
                  );
                },
                child: _heroCard(banners[index]),
              );
            },
          ),
        ),
      );
    });
  }

  List<dynamic> _looping(List<dynamic> list) {
    if (list.isEmpty) return [];
    return [list.last, ...list, list.first];
  }

  Widget _heroCard(dynamic item) {
    late String titleText;
    late String genresText;
    late String logoUrl;
    late String bannerUrl;
    late VoidCallback onWatchNow;
    late VoidCallback onSave;
    late bool inList;

    if (item is BannerMovie) {
      titleText = item.title;
      genresText = item.genres.join(', ');
      logoUrl = item.logoImage;
      bannerUrl = item.mobileImage.isNotEmpty
          ? item.mobileImage
          : item.logoImage;
      onWatchNow = () => _navigateToBannerDetail(item);
      onSave = () {
        favoritesController.toggleFavorite(
          FavoriteItem(
            id: item.id,
            title: item.title,
            image: item.mobileImage,
            videoTrailer: item.trailerUrl,
            subtitle: item.genres.join(', '),
          ),
        );
      };
      inList = favoritesController.isFavorite(item.trailerUrl);
    } else if (item is MovieModel) {
      titleText = item.movieTitle;
      genresText = item.genresString;
      logoUrl = item.logoUrl;
      bannerUrl = item.horizontalBannerUrl.isNotEmpty
          ? item.horizontalBannerUrl
          : item.verticalPosterUrl;
      onWatchNow = () => _navigateToDetail(item);
      onSave = () {
        favoritesController.toggleFavorite(
          FavoriteItem(
            id: item.id,
            title: item.movieTitle,
            image: item.verticalPosterUrl,
            videoTrailer: item.playUrl,
            subtitle: item.genresString,
          ),
        );
      };
      inList = favoritesController.isFavorite(item.playUrl);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            _buildBannerImage(bannerUrl),
            Container(
              height: 400.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: Column(
                children: [
                  logoUrl.isNotEmpty
                      ? _cdnImage(
                          logoUrl,
                          height: 50.h,
                          width: 180.w,
                          fit: BoxFit.contain,
                        )
                      : Text(
                          titleText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                          ),
                        ),
                  SizedBox(height: 5.h),
                  // Text(genresText,
                  //     style: TextStyle(
                  //         color: Colors.white70, fontSize: 10.sp)),
                  // SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: onWatchNow,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.play_arrow,
                                color: Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Watch Now',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerImage(String url) {
    if (url.isEmpty) {
      return Container(height: 400.h, color: Colors.grey.shade900);
    }

    return _cdnImage(
      url,
      height: 400.h,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingWidget: _heroBannerShimmer(),
      errorWidget: Container(height: 400.h, color: Colors.grey.shade900),
    );
  }

  Widget _categorySelector() {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        padding: EdgeInsets.only(left: 10.w, right: 8.w, top: 25.h),
        decoration: BoxDecoration(gradient: _topGradient),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(controller.categoryNames.length, (index) {
              final isSelected =
                  controller.selectedCategoryIndex.value == index;
              return GestureDetector(
                onTap: () => _onCategoryTap(index),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 32.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      controller.categoryNames[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _onCategoryTap(int index) {
    controller.selectCategory(index);
    setState(() {
      _bannerTopColors = [];
      _currentIndex = 0;
    });
    ever(controller.bannerMovies, (_) => _extractColors());
  }

  // Widget _searchButton() {
  //   return GestureDetector(
  //     onTap: () => Get.to(() => SearchScreen(fromBottomNav: false)),
  //     child: const Padding(
  //       padding: EdgeInsets.only(right: 10),
  //       child: Icon(Icons.search_outlined, color: Colors.white, size: 28),
  //     ),
  //   );
  // }
  Widget _goProButton() {
    return GestureDetector(
      onTap: () {
        showComingSoonPlansPopup(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.crown, color: Colors.black, size: 16.sp),
            SizedBox(width: 4),
            Text(
              "Go Pro",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cdnImage(
    String url, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    Widget? loadingWidget,
    Widget? errorWidget,
  }) {
    if (url.isEmpty) {
      return errorWidget ?? Container(color: Colors.grey.shade800);
    }

    final safeWidth = (width != null && width.isFinite) ? width.toInt() : null;

    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      memCacheWidth: safeWidth,
      placeholder: (_, __) =>
          loadingWidget ??
          _shimmerBase(child: Container(color: Colors.grey.shade800)),
      errorWidget: (_, __, ___) =>
          errorWidget ?? Container(color: Colors.grey.shade800),
    );
  }

  void _navigateToBannerDetail(BannerMovie banner) async {
    if (banner.isSingleMovie && banner.effectiveMovieId != null) {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
        barrierColor: Colors.black54,
      );

      final movieId = banner.effectiveMovieId!;

      final results = await Future.wait([
        BannerMovieService.fetchMovieDetail(movieId),
        BannerMovieService.fetchMovieTrailerUrl(movieId),
        BannerMovieService.fetchMoviePlayUrl(movieId),
      ]);

      Get.back();

      final detail = results[0] as Map<String, dynamic>?;
      final trailerUrl = results[1] as String;
      final playUrl = results[2] as String? ?? '';

      debugPrint('🎬 movieId: $movieId');
      debugPrint('🎬 playUrl: $playUrl');
      debugPrint('🎬 trailerUrl: $trailerUrl');

      if (playUrl.isNotEmpty) {
        final enrichedBanner = banner.copyWith(
          movieUrl: playUrl,
          trailerUrl: trailerUrl.isNotEmpty ? trailerUrl : banner.trailerUrl,
          description: detail?['description']?.toString() ?? banner.description,
          logoImage: banner.logoImage.isNotEmpty
              ? banner.logoImage
              : detail?['logoUrl']?.toString() ?? '',
          mobileImage: banner.mobileImage.isNotEmpty
              ? banner.mobileImage
              : detail?['horizontalBannerUrl']?.toString() ?? '',
        );

        if (!mounted) return;
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                VideoDetailScreen.fromBanner(enrichedBanner),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      } else {
        Get.snackbar(
          'Unavailable',
          'Video not available for this title',
          backgroundColor: Colors.grey.shade900,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      if (!mounted) return;
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => VideoDetailScreen.fromBanner(banner),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  void _navigateToDetail(MovieModel movie) async {
    if (movie.isPartial) {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
        barrierColor: Colors.black54,
      );

      try {
        final fullMovie = await BannerMovieService.fetchMovieDetail(movie.id);

        Get.back();

        if (fullMovie != null) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  VideoDetailScreen.fromModel(fullMovie as MovieModel),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          );
        }
      } catch (e) {
        Get.back();
        Get.snackbar(
          'Error',
          'Failed to load movie details',
          backgroundColor: Colors.grey.shade900,
          colorText: Colors.white,
        );
      }
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => VideoDetailScreen.fromModel(movie),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    color: Colors.grey.shade800,
    child: Icon(Icons.movie, color: Colors.white54, size: 24.sp),
  );
}

class CategorySelectorDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  CategorySelectorDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(CategorySelectorDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
