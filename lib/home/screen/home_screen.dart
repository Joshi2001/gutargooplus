import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/model/banner_model.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';
import 'package:gutrgoopro/home/screen/view_all_screen.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/model/favorite_model.dart';
import 'package:gutrgoopro/search.dart/search_screen.dart';
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
  final isInMyList = false.obs;

  List<Color> _bannerTopColors = [];

  LinearGradient get _topGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [

      // _getCurrentColor().withOpacity(0.9),
      // _getCurrentColor().withOpacity(0.9),
        _getCurrentColor(),
      _getCurrentColor(),

    ],
  );

  LinearGradient get _bannerGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [

      // _getCurrentColor().withOpacity(0.9),
      // _getCurrentColor().withOpacity(0.9),
      // const Color(0xFF000000).withOpacity(0.9),
      // const Color(0xFF000000),

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
    SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,      
      statusBarIconBrightness: Brightness.light,
    ),
  );
    heroController = PageController(viewportFraction: 0.90, initialPage: 1);
    _extractColorsFromBanners();
  }

  Future<void> _extractColorsFromBanners() async {
    List<Color> extractedColors = [];
    for (var banner in heroBanners) {
      try {
        Color dominantColor = await _getImageDominantColor(
          banner.backgroundImage,
        );
        extractedColors.add(dominantColor);
      } catch (e) {
        extractedColors.add(const Color(0xFF1E3A5F));
      }
    }
   if (mounted) setState(() { 
    _bannerTopColors = extractedColors;
  });
  }

  Future<Color> _getImageDominantColor(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 100,
      targetHeight: 100,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (byteData == null) return Colors.black;

    final pixels = byteData.buffer.asUint8List();

    int redSum = 0;
    int greenSum = 0;
    int blueSum = 0;
    int count = 0;

    int maxY = (image.height * 0.3).toInt();
    for (int y = 0; y < maxY; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixelIndex = (y * image.width + x) * 4;
        if (pixelIndex + 2 < pixels.length) {
          final r = pixels[pixelIndex];
          final g = pixels[pixelIndex + 1];
          final b = pixels[pixelIndex + 2];
          final brightness = (r + g + b) / 3;
          if (brightness > 30 && brightness < 225) {
            redSum += r;
            greenSum += g;
            blueSum += b;
            count++;
          }
        }
      }
    }

    if (count == 0) return Colors.black;

    final avgRed = (redSum / count).round();
    final avgGreen = (greenSum / count).round();
    final avgBlue = (blueSum / count).round();

    return Color.fromARGB(255, avgRed, avgGreen, avgBlue);
  }

  @override
  void dispose() {
    scrollController.dispose();
    heroController.dispose();
    super.dispose();
  }

  @override
 Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
  gradient: _bannerGradient,
),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent, 
          body: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                pinned: false,
                floating: false,
                snap: false,
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                flexibleSpace: AnimatedContainer(
                  decoration: BoxDecoration(gradient: _topGradient),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10.w,top: 7.h),
                          child: Image.asset(
                            "assets/white_logo.png",
                            height: 100.h,
                            width: 120.w,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10.w,top: 7.h),
                          child: _subscribeButton(),
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
                  height: 50.h,                 
                ),
              ),
              // SliverPersistentHeader(
              //   pinned: true,
              //   floating: false,
              //   delegate: CategorySelectorDelegate(
              //     child: _categorySelector(),
              //     height:MediaQuery.of(context).padding.top,
              //   ),
              // ),
              SliverPadding(
                padding: EdgeInsets.zero,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _heroBanner(),
                    // SizedBox(height: Get.height * 0.02),
                     _bottomSections(),
                    // _sectionHeader("Trending Now"),
                    // _trendingSection(controller),
                    // _sectionHeader("Top 10"),
                    // _top10SectionImproved(controller),
                    // SizedBox(height: 12.h),
                    // _sectionHeader("Popular"),
                    // popular(controller),
                    // _sectionHeader("Trending Now"),
                    // _trendingSection(controller),
                  ]),
                ),
              ),
            ],
          ),
        ),
             ),
        ));
  }
Widget _bottomSections() {
  return Container(
    color: Colors.black,
    child: Column(
      children: [
        _sectionHeader("Trending Now"),
        _trendingSection(controller),
        _sectionHeader("Top 10"),
        _top10SectionImproved(controller),
        SizedBox(height: 12.h),
      ],
    ),
  );
}
  Widget _categorySelector() {
  return Obx(
    () => AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(left: 10.w, right: 8.w,),
      decoration: BoxDecoration(gradient: _topGradient),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            controller.categoryNames.length,
            (index) {
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
                      color: 
                           Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      controller.categoryNames[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color
                            : Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
  void _onCategoryTap(int index) {
    String categoryName = controller.categoryNames[index]
        .toString()
        .toLowerCase();
    if (categoryName == 'Home' || categoryName == 'movies') {
      controller.selectedCategoryIndex.value = index;
    } else if (categoryName == 'tv shows') {
      controller.selectedCategoryIndex.value = index;
      _showComingSoonDialog(
        'No TV Show Right Now',
        'We will add soon more TV Shows',
      );
    } else if (categoryName == 'web series') {
      controller.selectedCategoryIndex.value = index;
      _showComingSoonDialog(
        'No Web Series Right Now',
        'We will add soon more Web Series',
      );
    } else {
      controller.selectedCategoryIndex.value = index;
    }
  }

  void _showComingSoonDialog(String title, String subtitle) {
    showDialog(
      context: Get.context!,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.h, sigmaY: 10.w),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              width: 0.8.sw,
              padding: EdgeInsets.all(24.sp),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _getCurrentColor().withOpacity(0.95),
                    const Color(0xFF000000).withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade700, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade800, Colors.grey.shade900],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.shade600),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _subscribeButton() {
    return GestureDetector(
      onTap: () => Get.to(() => SearchScreen(fromBottomNav: false)),
      child: const Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.search_outlined, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }
  List<HeroBannerModel> get loopingBanners {
    if (heroBanners.isEmpty) return [];
    return [heroBanners.last, ...heroBanners, heroBanners.first];
  }

  Widget _heroBanner() {
    final banners = loopingBanners;
    return Column(
      children: [
        AnimatedContainer(
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
  if (index == 0) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (heroController.hasClients) // ✅
        heroController.jumpToPage(banners.length - 2);
    });
    if (mounted) setState(() => _currentIndex = heroBanners.length - 1); // ✅
  } else if (index == banners.length - 1) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (heroController.hasClients) // ✅
        heroController.jumpToPage(1);
    });
    if (mounted) setState(() => _currentIndex = 0); // ✅
  } else {
    if (mounted) setState(() => _currentIndex = index - 1); // ✅
  }
},
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: heroController,
                  builder: (context, child) {
                    double page =
                        heroController.hasClients &&
                            heroController.position.haveDimensions
                        ? (heroController.page ??
                              heroController.initialPage.toDouble())
                        : heroController.initialPage.toDouble();
                    final distance = (page - index).abs();
                    final scale = (1 - (distance * 0.04)).clamp(0.96, 1.0);
                    final opacity = (1 - (distance * 0.08)).clamp(0.90, 1.0);
                    final translateY = distance * 8;
                    return Transform.translate(
                      offset: Offset(0, translateY),
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
        ),
      ],
    );
  }

  Widget _heroCard(HeroBannerModel banner) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            Image.asset(
              banner.backgroundImage,
              height: 400.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    banner.logoImage,
                    height: 50.h,
                    width: 180.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    banner.genres,
                    style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => VideoDetailScreen(
                              videoTrailer: banner.videoTrailer,
                              videoMoives: banner.videoMovie,
                              image: banner.backgroundImage,
                              subtitle: banner.genres,
                              videoTitle: banner.title,
                              dis: banner.dis,
                               logoImage: banner.logoImage,
                            ),
                            transition: Transition.fadeIn,
                            duration: const Duration(milliseconds: 300),
                          );
                        },

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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow,
                                color: Colors.black,
                                size: 18,
                              ),
                              SizedBox(width: 3),
                              Text(
                                "Watch Now",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Obx(() {
                        final isFavorite = favoritesController.isFavorite(
                          banner.videoTrailer,
                        );

                        return GestureDetector(
                          onTap: () {
                          
                            if (favoritesController.isFavorite(
                              banner.videoTrailer,
                            )) {
                              favoritesController.removeByvideoTrailer(
                                banner.videoTrailer,
                              );
                            } else {
                              favoritesController.addFavorite(
                                FavoriteItem(
                                  title: banner.title,
                                  image: banner.backgroundImage,
                                  videoTrailer: banner.videoTrailer,
                                  subtitle: banner.genres,
                                ),
                              );
                            }
                          },
                          child: Container(
                            height: 40.r, 
                            width: 40.r,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  isFavorite ? Icons.check : Icons.add,
                                  key: ValueKey<bool>(isFavorite),
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
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

  final List<HeroBannerModel> heroBanners = [
    HeroBannerModel(
      backgroundImage: 'assets/3.jpeg',
      logoImage: 'assets/logo3.png',
      title: "Sumeru",
      genres: 'ROMANCE, MUSICAL, COMEDY',
      videoTrailer:
          'https://vz-fd5fa6c8-ece.b-cdn.net/74cd202a-fad1-4a09-9db0-95469c58e6f0/playlist.m3u8',
      videoMovie:
          'https://vz-fd5fa6c8-ece.b-cdn.net/1da2826f-84ed-4f42-9941-47ba419f9f57/playlist.m3u8',
      dis:
          'Bhavar Paratp Singh has left everything is search of his father and he meets Savi accidentally who came for her destination wedding in Harsil. The story further continues in their struggle of finding Bhavar\'s father and they eventually fall in love in the journey',
    ),
    HeroBannerModel(
      backgroundImage: 'assets/img1.png',

      title: "The Networker (Trailer)",
      logoImage: 'assets/thenetworking.png',
      genres: 'Hindi • Comedy • Thriller',
      videoTrailer:
          'https://vz-fd5fa6c8-ece.b-cdn.net/24d07fc8-2468-45f9-95be-290a06553197/playlist.m3u8',
      videoMovie:
          "https://vz-fd5fa6c8-ece.b-cdn.net/24d07fc8-2468-45f9-95be-290a06553197/playlist.m3u8",
      dis:
          'After his MLM company fails, Aditya partners with networker Lallan and friend Raghav to launch new ventures backed by Pradhan. They hire a motivational speaker and fake MD before absconding to Dubai with investors',
    ),
    HeroBannerModel(
      backgroundImage: 'assets/img3.png',
      title: "Alien Frank",
      logoImage: 'assets/Alien.png',
      genres: 'Hindi • Comedy • Thriller',
      videoTrailer:
          'https://vz-fd5fa6c8-ece.b-cdn.net/0c0f5ae6-316d-48c3-8ea1-4de616bb62ec/playlist.m3u8',
      videoMovie:
          'https://vz-fd5fa6c8-ece.b-cdn.net/fa890afd-7f35-4cf1-a8f4-fb6131948bd3/playlist.m3u8',
      dis:
          'Alien Frank is a thought-provoking Hindi movie that explores the life of Adolf Hitler through his own perspective—a never-seen-before angle that challenges history, truth, and propaganda',
    ),
    HeroBannerModel(
      backgroundImage: 'assets/awasaan_banner.jpg',
      logoImage: 'assets/awasaan_logo.png',
      title: "Awasaan",
      genres: 'Hindi • Drama ',
      videoTrailer:
          'https://vz-fd5fa6c8-ece.b-cdn.net/5f48d5c0-af80-48a7-bfc1-93017cf7ee2b/playlist.m3u8',
      videoMovie:
          'https://vz-fd5fa6c8-ece.b-cdn.net/5f48d5c0-af80-48a7-bfc1-93017cf7ee2b/playlist.m3u8',
      dis:
          'This film tells the story of a 27 year old boy named Satyawan Shukla who hails from Prayagraj and from a lower middle class family. His father is a poor priest and mother house wife, his father falls pray to a social change which urges him to make his son engineer for which he has to sell 50% of his farm l and. After not finding a satisfactory job Satyawan leaves for Lucknow and there he prepares for a government job and at the same time searching for a private job. He struggles to find a s mall pay scale job, which could not support his family economics as a result Satyawan is forced t o do small and odd jobs even though he has to sell newspapers and repair mobile phones, but suddenly a Government job vacancy comes on his way he happily goes to apply for it but on finding that there is only 2 vacancies for general category. He decided not to apply for it and at the same time he finds that if he can manage a government officer he may get a government job, he does it and becomes a car driver of a government officer after spending some time he persuades the officer for one job in exchange of Rs. 15 Lakh. Satyawan father sells his every piece of land and gives 15 lakh to that officer. Now the question is will Satyawan get one job in a government department or will something else happen to Satyawan?',
    ),
    HeroBannerModel(
      backgroundImage: 'assets/red_banner.jpg',
      logoImage: 'assets/red_logo.png',
      title: "The Red Land",
      genres: 'Crime • Drama • Action',
      videoTrailer:
          'https://vz-fd5fa6c8-ece.b-cdn.net/ca6482b3-f5c9-4e82-a5bb-25c21b327a2f/playlist.m3u8',
      videoMovie:
          'https://vz-fd5fa6c8-ece.b-cdn.net/34764e34-c1a3-4b5b-a31f-e7e36b2b566c/playlist.m3u8',
      dis:
          'Two tyrant brothers Amarpal Singh and Samarpal Singh who have ruled the land on their own terms for more than threedecades, cross path with a young boy AjitYadav who happens to be the son of theirdriver. Then begins the battle of casteism,power, and greed that threatens the throneof the land without law – The Red Land',
    ),
  ];

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
            onTap: () {
              Get.to(() => ViewAllScreen(title: title));
            },
            child: Text(
              "View All",
              style: TextStyle(color: AppColors.orange, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendingSection(HomeController controller) {
    return SizedBox(
      height: 190.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 15.w),
        itemCount: controller.trendingList.length,
        itemBuilder: (context, index) {
          final item = controller.trendingList[index];
          return GestureDetector(
            onTap: () {
              Get.to(
                () => VideoDetailScreen(
                  videoTrailer: item['videoTrailer'] as String,
                  videoMoives:
                      item['videoMovies'] as String? ??
                      item['videoTrailer'] as String,
                  image: item['image'] as String? ?? "",
                  subtitle: item['subtitle'] as String? ?? "",
                  videoTitle: item['title'],
                  dis: item['dis'], logoImage: '',
                
                ),
              );
            },
            child: Container(
              width: 100.w,
              margin: EdgeInsets.only(right: 10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: Image.asset(
                          item['image'] as String,
                          height: 170.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
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

Widget _top10SectionImproved(HomeController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 190.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(left: 40.w, right: 30.w),
          itemCount: controller.top10List.length > 10
              ? 10
              : controller.top10List.length,
          itemBuilder: (context, index) {
            return _buildNetflixTop10Card(
              item: controller.top10List[index],
              rank: index + 1,
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildNetflixTop10Card({
  required Map<String, dynamic> item,
  required int rank,
}) {
  return GestureDetector(
    onTap: () {
      Get.to(
        () => VideoDetailScreen(
          videoTrailer: item['videoTrailer'] as String,
          videoMoives:
              item['videoMovies'] as String? ?? item['videoTrailer'] as String,
          image: item['image'] as String? ?? "",
          subtitle: item['subtitle'] as String? ?? "",
          videoTitle: item['title'],
          dis: item['dis'], logoImage: '',
        ),
      );
    },
    child: Container(
      width: 150.w,
      margin: EdgeInsets.only(right: 50.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: -30.w, bottom: 5.h, child: _buildRankNumber(rank)),

          Positioned(
            left: 30,
            top: 5.h,
            bottom: 5.h,
            child: Hero(
              tag: 'top10_${item['videoTrailer']}',
              child: Container(
                width: 120.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Stack(
                    children: [
                      Image.asset(
                        item['image'] as String,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildRankNumber(int rank) {
  return Stack(
    children: [
      Text(
        '$rank',
        style: TextStyle(
          fontSize: 145.sp,
          fontWeight: FontWeight.w900,
          height: 0.82,
          letterSpacing: -5,
          fontFamily: 'Impact',
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 12.w
            ..color = Colors.black,
        ),
      ),

      Text(
        '$rank',
        style: TextStyle(
          fontSize: 145.sp,
          fontWeight: FontWeight.w900,
          height: 0.82,
          letterSpacing: -5,
          fontFamily: 'Impact',
          foreground: Paint()
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
              offset: Offset(3, 3),
            ),
            Shadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget popular(HomeController controller) {
  return SizedBox(
    height: 250.h,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 15.w),
      itemCount: controller.continueWatching.length,
      itemBuilder: (context, index) {
        final item = controller.continueWatching[index];
        return GestureDetector(
          onTap: () {
            Get.to(
              () => VideoDetailScreen(
                videoTrailer: item['videoTrailer'] as String,
                videoMoives:
                    item['videoMovies'] as String? ??
                    item['videoTrailer'] as String,
                image: item['image'] as String? ?? "",
                subtitle: item['subtitle'] as String? ?? "",
                videoTitle: item['title'],
                dis: item['dis'], logoImage: '',
              ),
            );
          },
          child: Container(
            width: 140.w,
            margin: EdgeInsets.only(right: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: Image.asset(
                        item['image'] as String,
                        height: 240.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// import 'dart:ui';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:gutrgoopro/home/getx/home_controller.dart';
// import 'package:gutrgoopro/home/model/banner_model.dart';
// import 'package:gutrgoopro/home/screen/details_screen.dart';
// import 'package:gutrgoopro/home/screen/view_all_screen.dart';
// import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
// import 'package:gutrgoopro/profile/model/favorite_model.dart';
// import 'package:gutrgoopro/search.dart/search_screen.dart';
// import 'package:gutrgoopro/uitls/colors.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final HomeController controller = Get.put(HomeController());
//   final ScrollController scrollController = ScrollController();
//   late final PageController heroController;
//   final FavoritesController favoritesController =
//       Get.find<FavoritesController>();
//   int _currentIndex = 0;
//   final isInMyList = false.obs;

//   List<Color> _bannerTopColors = [];

//   LinearGradient get _topGradient => LinearGradient(
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//     colors: [
//       // _getCurrentColor().withOpacity(0.9),
//       // _getCurrentColor().withOpacity(0.9),
//         _getCurrentColor(),
//       _getCurrentColor(),
//     ],
//   );

//   LinearGradient get _bannerGradient => LinearGradient(
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//     colors: [
//       // _getCurrentColor().withOpacity(0.9),
//       // _getCurrentColor().withOpacity(0.9),
//       // const Color(0xFF000000).withOpacity(0.9),
//       // const Color(0xFF000000),
//        _getCurrentColor(),
//       _getCurrentColor(),
//       const Color(0xFF000000),
//       const Color(0xFF000000),
//     ],
//     stops: const [0.0, 0.3, 0.7, 1.0],
//   );

//   Color _getCurrentColor() {
//     if (_bannerTopColors.isEmpty || _currentIndex >= _bannerTopColors.length) {
//       return Colors.black;
//     }
//     return _bannerTopColors[_currentIndex];
//   }

//   @override
//   void initState() {
//     super.initState();
//     heroController = PageController(viewportFraction: 0.90, initialPage: 1);
//     _extractColorsFromBanners();
    
//   }

//   Future<void> _extractColorsFromBanners() async {
//     List<Color> extractedColors = [];
//     for (var banner in heroBanners) {
//       try {
//         Color dominantColor = await _getImageDominantColor(
//           banner.backgroundImage,
//         );
//         extractedColors.add(dominantColor);
//       } catch (e) {
//         extractedColors.add(const Color(0xFF1E3A5F));
//       }
//     }
//     setState(() {
//       _bannerTopColors = extractedColors;
//     });
//   }

//   Future<Color> _getImageDominantColor(String imagePath) async {
//     final ByteData data = await rootBundle.load(imagePath);
//     final codec = await ui.instantiateImageCodec(
//       data.buffer.asUint8List(),
//       targetWidth: 100,
//       targetHeight: 100,
//     );
//     final frame = await codec.getNextFrame();
//     final image = frame.image;

//     final ByteData? byteData = await image.toByteData(
//       format: ui.ImageByteFormat.rawRgba,
//     );
//     if (byteData == null) return Colors.black;

//     final pixels = byteData.buffer.asUint8List();

//     int redSum = 0;
//     int greenSum = 0;
//     int blueSum = 0;
//     int count = 0;

//     int maxY = (image.height * 0.3).toInt();
//     for (int y = 0; y < maxY; y++) {
//       for (int x = 0; x < image.width; x++) {
//         final pixelIndex = (y * image.width + x) * 4;
//         if (pixelIndex + 2 < pixels.length) {
//           final r = pixels[pixelIndex];
//           final g = pixels[pixelIndex + 1];
//           final b = pixels[pixelIndex + 2];
//           final brightness = (r + g + b) / 3;
//           if (brightness > 30 && brightness < 225) {
//             redSum += r;
//             greenSum += g;
//             blueSum += b;
//             count++;
//           }
//         }
//       }
//     }

//     if (count == 0) return Colors.black;

//     final avgRed = (redSum / count).round();
//     final avgGreen = (greenSum / count).round();
//     final avgBlue = (blueSum / count).round();

//     return Color.fromARGB(255, avgRed, avgGreen, avgBlue);
//   }

//   @override
//   void dispose() {
//     scrollController.dispose();
//     heroController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//   onWillPop: () async {
//     return true;
//   },child:
//     GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child:
//        Scaffold(
//         resizeToAvoidBottomInset: true,
//         backgroundColor: Colors.black,
//         body: CustomScrollView(
//           controller: scrollController,
//           slivers: [
//             SliverAppBar(
//              pinned: false,
//             floating: false,  
//             snap: false, 
//               backgroundColor: Colors.black,
//                automaticallyImplyLeading: false,
//               flexibleSpace: AnimatedContainer(
//                 decoration: BoxDecoration(gradient: _topGradient),
//                 duration: const Duration(milliseconds: 600),
//                 curve: Curves.easeInOut,
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     top: MediaQuery.of(context).padding.top+10.h,
//                     left: 8.w,
//                     right: 8.w,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.only(left: 10.w,top: 20.h),
//                         child: Image.asset(
//                           "assets/white_logo.png",
//                           height: 120.h,
//                           width: 140.w,
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(right: 10.w,top: 20.h),
//                         child: _subscribeButton(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SliverPersistentHeader(
//               pinned: true,
//               floating: false,
//               delegate: CategorySelectorDelegate(
//                 child: _categorySelector(),
//                 height:75.h
//               ),
//             ),
//             SliverPadding(
//               padding: EdgeInsets.zero,
//               sliver: SliverList(
//                 delegate: SliverChildListDelegate([
//                   _heroBanner(),
//                   SizedBox(height: Get.height * 0.02),
//                   _sectionHeader("Trending Now"),
//                   _trendingSection(controller),
//                   _sectionHeader("Top 10"),
//                   _top10SectionImproved(controller),
//                   SizedBox(height: 12.h),
//                   // _sectionHeader("Popular"),
//                   // popular(controller),
//                   // _sectionHeader("Trending Now"),
//                   // _trendingSection(controller),
//                 ]),
//               ),
//             ),
//           ],
//         ),
//       ),
//         )    );
//   }

//   Widget _categorySelector() {
//   return Obx(
//     () => AnimatedContainer(
//       duration: const Duration(milliseconds: 600),
//       curve: Curves.easeInOut,
//       padding: EdgeInsets.only(left: 10.w, right: 8.w,top: 25.h),
//       decoration: BoxDecoration(gradient: _topGradient),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: List.generate(
//             controller.categoryNames.length,
//             (index) {
//               final isSelected =
//                   controller.selectedCategoryIndex.value == index;
//               return GestureDetector(
//                 onTap: () => _onCategoryTap(index),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 2.w),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 250),
//                    height: 32.h,
//                     padding: EdgeInsets.symmetric(horizontal: 14.w),
//                     decoration: BoxDecoration(
//                       color: 
//                            Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(30.r),
//                     ),
//                     alignment: Alignment.center,
//                     child: Text(
//                       controller.categoryNames[index],
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color
//                             : Colors.white,
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     ),
//   );
// }
//   void _onCategoryTap(int index) {
//     String categoryName = controller.categoryNames[index]
//         .toString()
//         .toLowerCase();
//     if (categoryName == 'Home' || categoryName == 'movies') {
//       controller.selectedCategoryIndex.value = index;
//     } else if (categoryName == 'tv shows') {
//       controller.selectedCategoryIndex.value = index;
//       _showComingSoonDialog(
//         'No TV Show Right Now',
//         'We will add soon more TV Shows',
//       );
//     } else if (categoryName == 'web series') {
//       controller.selectedCategoryIndex.value = index;
//       _showComingSoonDialog(
//         'No Web Series Right Now',
//         'We will add soon more Web Series',
//       );
//     } else {
//       controller.selectedCategoryIndex.value = index;
//     }
//   }

//   void _showComingSoonDialog(String title, String subtitle) {
//     showDialog(
//       context: Get.context!,
//       barrierColor: Colors.black.withOpacity(0.5),
//       builder: (BuildContext context) {
//         return BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10.h, sigmaY: 10.w),
//           child: Dialog(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             child: Container(
//               width: 0.8.sw,
//               padding: EdgeInsets.all(24.sp),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     _getCurrentColor().withOpacity(0.95),
//                     const Color(0xFF000000).withOpacity(0.95),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.grey.shade700, width: 1),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     title,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     subtitle,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
//                   ),
//                   const SizedBox(height: 24),
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 40,
//                         vertical: 12,
//                       ),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.grey.shade800, Colors.grey.shade900],
//                         ),
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(color: Colors.grey.shade600),
//                       ),
//                       child: const Text(
//                         'OK',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _subscribeButton() {
//     return GestureDetector(
//       onTap: () => Get.to(() => SearchScreen(fromBottomNav: false)),
//       child: const Row(
//         children: [
//           Padding(
//             padding: EdgeInsets.only(right: 10),
//             child: Icon(Icons.search_outlined, color: Colors.white, size: 28),
//           )
//         ],
//       ),
//     );
//   }
//   List<HeroBannerModel> get loopingBanners {
//     if (heroBanners.isEmpty) return [];
//     return [heroBanners.last, ...heroBanners, heroBanners.first];
//   }

//   Widget _heroBanner() {
//     final banners = loopingBanners;
//     return Column(
//       children: [
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.bounceInOut,
//           decoration: BoxDecoration(gradient: _bannerGradient),
//           child: SizedBox(
//             height: 420.h,
//             child: PageView.builder(
//               controller: heroController,
//               itemCount: banners.length,
//               physics: const PageScrollPhysics(),
//               onPageChanged: (index) {
//                 if (index == 0) {
//                   Future.delayed(const Duration(milliseconds: 300), () {
//                     heroController.jumpToPage(banners.length - 2);
//                   });
//                   setState(() {
//                     _currentIndex = heroBanners.length - 1;
//                   });
//                 } else if (index == banners.length - 1) {
//                   Future.delayed(const Duration(milliseconds: 300), () {
//                     heroController.jumpToPage(1);
//                   });
//                   setState(() {
//                     _currentIndex = 0;
//                   });
//                 } else {
//                   setState(() {
//                     _currentIndex = index - 1;
//                   });
//                 }
//               },
//               itemBuilder: (context, index) {
//                 return AnimatedBuilder(
//                   animation: heroController,
//                   builder: (context, child) {
//                     double page =
//                         heroController.hasClients &&
//                             heroController.position.haveDimensions
//                         ? (heroController.page ??
//                               heroController.initialPage.toDouble())
//                         : heroController.initialPage.toDouble();
//                     final distance = (page - index).abs();
//                     final scale = (1 - (distance * 0.04)).clamp(0.96, 1.0);
//                     final opacity = (1 - (distance * 0.08)).clamp(0.90, 1.0);
//                     final translateY = distance * 8;
//                     return Transform.translate(
//                       offset: Offset(0, translateY),
//                       child: Transform.scale(
//                         scale: Curves.easeOutCubic.transform(scale),
//                         child: Opacity(opacity: opacity, child: child),
//                       ),
//                     );
//                   },
//                   child: _heroCard(banners[index]),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _heroCard(HeroBannerModel banner) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 6.w),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12.r),
//         child: Stack(
//           children: [
//             Image.asset(
//               banner.backgroundImage,
//               height: 400.h,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//             Container(
//               height: 400.h,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Colors.black54, Colors.transparent, Colors.black87],
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 20.w,
//               right: 20.w,
//               bottom: 20.h,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     banner.logoImage,
//                     height: 50.h,
//                     width: 180.w,
//                     fit: BoxFit.contain,
//                   ),
//                   SizedBox(height: 3.h),
//                   Text(
//                     banner.genres,
//                     style: TextStyle(color: Colors.white70, fontSize: 10.sp),
//                   ),
//                   SizedBox(height: 16.h),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Get.to(
//                             () => VideoDetailScreen(
//                               videoTrailer: banner.videoTrailer,
//                               videoMoives: banner.videoMovie,
//                               image: banner.backgroundImage,
//                               subtitle: banner.genres,
//                               videoTitle: banner.title,
//                               dis: banner.dis,
//                                logoImage: banner.logoImage,
//                             ),
//                             transition: Transition.fadeIn,
//                             duration: const Duration(milliseconds: 300),
//                           );
//                         },

//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 18.w,
//                             vertical: 10.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.play_arrow,
//                                 color: Colors.black,
//                                 size: 18,
//                               ),
//                               SizedBox(width: 3),
//                               Text(
//                                 "Watch Now",
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 12.sp,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Obx(() {
//                         final isFavorite = favoritesController.isFavorite(
//                           banner.videoTrailer,
//                         );

//                         return GestureDetector(
//                           onTap: () {
                          
//                             if (favoritesController.isFavorite(
//                               banner.videoTrailer,
//                             )) {
//                               favoritesController.removeByvideoTrailer(
//                                 banner.videoTrailer,
//                               );
//                             } else {
//                               favoritesController.addFavorite(
//                                 FavoriteItem(
//                                   title: banner.title,
//                                   image: banner.backgroundImage,
//                                   videoTrailer: banner.videoTrailer,
//                                   subtitle: banner.genres,
//                                 ),
//                               );
//                             }
//                           },
//                           child: Container(
//                             height: 40.r, 
//                             width: 40.r,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Center(
//                               child: AnimatedSwitcher(
//                                 duration: const Duration(milliseconds: 300),
//                                 transitionBuilder: (child, animation) {
//                                   return ScaleTransition(
//                                     scale: animation,
//                                     child: child,
//                                   );
//                                 },
//                                 child: Icon(
//                                   isFavorite ? Icons.check : Icons.add,
//                                   key: ValueKey<bool>(isFavorite),
//                                   color: Colors.white,
//                                   size: 16.sp,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   final List<HeroBannerModel> heroBanners = [
//     HeroBannerModel(
//       backgroundImage: 'assets/3.jpeg',
//       logoImage: 'assets/logo3.png',
//       title: "Sumeru",
//       genres: 'Hindi • Comedy • Thriller',
//       videoTrailer:
//           'https://vz-fd5fa6c8-ece.b-cdn.net/74cd202a-fad1-4a09-9db0-95469c58e6f0/playlist.m3u8',
//       videoMovie:
//           'https://vz-fd5fa6c8-ece.b-cdn.net/1da2826f-84ed-4f42-9941-47ba419f9f57/playlist.m3u8',
//       dis:
//           'Bhavar Paratp Singh has left everything is search of his father and he meets Savi accidentally who came for her destination wedding in Harsil. The story further continues in their struggle of finding Bhavar\'s father and they eventually fall in love in the journey',
//     ),
//     HeroBannerModel(
//       backgroundImage: 'assets/img1.png',

//       title: "The Networker (Trailer)",
//       logoImage: 'assets/thenetworking.png',
//       genres: 'Hindi • Comedy • Thriller',
//       videoTrailer:
//           'https://vz-fd5fa6c8-ece.b-cdn.net/24d07fc8-2468-45f9-95be-290a06553197/playlist.m3u8',
//       videoMovie:
//           "https://vz-fd5fa6c8-ece.b-cdn.net/24d07fc8-2468-45f9-95be-290a06553197/playlist.m3u8",
//       dis:
//           'After his MLM company fails, Aditya partners with networker Lallan and friend Raghav to launch new ventures backed by Pradhan. They hire a motivational speaker and fake MD before absconding to Dubai with investors',
//     ),
//     HeroBannerModel(
//       backgroundImage: 'assets/img3.png',
//       title: "Alien Frank",
//       logoImage: 'assets/Alien.png',
//       genres: 'Hindi • Comedy • Thriller',
//       videoTrailer:
//           'https://vz-fd5fa6c8-ece.b-cdn.net/0c0f5ae6-316d-48c3-8ea1-4de616bb62ec/playlist.m3u8',
//       videoMovie:
//           'https://vz-fd5fa6c8-ece.b-cdn.net/fa890afd-7f35-4cf1-a8f4-fb6131948bd3/playlist.m3u8',
//       dis:
//           'Alien Frank is a thought-provoking Hindi movie that explores the life of Adolf Hitler through his own perspective—a never-seen-before angle that challenges history, truth, and propaganda',
//     ),
//     HeroBannerModel(
//       backgroundImage: 'assets/awasaan_banner.jpg',
//       logoImage: 'assets/awasaan_logo.png',
//       title: "Awasaan",
//       genres: 'Hindi • Comedy • Thriller',
//       videoTrailer:
//           'https://vz-fd5fa6c8-ece.b-cdn.net/5f48d5c0-af80-48a7-bfc1-93017cf7ee2b/playlist.m3u8',
//       videoMovie:
//           'https://vz-fd5fa6c8-ece.b-cdn.net/5f48d5c0-af80-48a7-bfc1-93017cf7ee2b/playlist.m3u8',
//       dis:
//           'Bhavar Paratp Singh has left everything is search of his father and he meets Savi accidentally who came for her destination wedding in Harsil. The story further continues in their struggle of finding Bhavar\'s father and they eventually fall in love in the journey',
//     ),
//     HeroBannerModel(
//       backgroundImage: 'assets/red_banner.jpg',
//       logoImage: 'assets/red_logo.png',
//       title: "The Red Land",
//       genres: 'Hindi • Comedy • Thriller',
//       videoTrailer:
//           'https://vz-fd5fa6c8-ece.b-cdn.net/ca6482b3-f5c9-4e82-a5bb-25c21b327a2f/playlist.m3u8',
//       videoMovie:
//           'https://vz-fd5fa6c8-ece.b-cdn.net/ca6482b3-f5c9-4e82-a5bb-25c21b327a2f/playlist.m3u8',
//       dis:
//           'Bhavar Paratp Singh has left everything is search of his father and he meets Savi accidentally who came for her destination wedding in Harsil. The story further continues in their struggle of finding Bhavar\'s father and they eventually fall in love in the journey',
//     ),
//   ];

//   Widget _sectionHeader(String title) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title.toUpperCase(),
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               Get.to(() => ViewAllScreen(title: title));
//             },
//             child: Text(
//               "View All",
//               style: TextStyle(color: AppColors.orange, fontSize: 14.sp),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _trendingSection(HomeController controller) {
//     return SizedBox(
//       height: 190.h,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.only(left: 15.w),
//         itemCount: controller.trendingList.length,
//         itemBuilder: (context, index) {
//           final item = controller.trendingList[index];
//           return GestureDetector(
//             onTap: () {
//               Get.to(
//                 () => VideoDetailScreen(
//                   videoTrailer: item['videoTrailer'] as String,
//                   videoMoives:
//                       item['videoMovies'] as String? ??
//                       item['videoTrailer'] as String,
//                   image: item['image'] as String? ?? "",
//                   subtitle: item['subtitle'] as String? ?? "",
//                   videoTitle: item['title'],
//                   dis: item['dis'], logoImage: '',
                
//                 ),
//               );
//             },
//             child: Container(
//               width: 100.w,
//               margin: EdgeInsets.only(right: 10.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(6.r),
//                         child: Image.asset(
//                           item['image'] as String,
//                           height: 170.h,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class CategorySelectorDelegate extends SliverPersistentHeaderDelegate {
//   final double height;
//   final Widget child;

//   CategorySelectorDelegate({required this.height, required this.child});

//   @override
// double get minExtent => height;

// @override
// double get maxExtent => height;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return SizedBox(height: height, child: child);
//   }

//   @override
//   bool shouldRebuild(CategorySelectorDelegate oldDelegate) {
//     return oldDelegate.height != height || oldDelegate.child != child;
//   }
// }

// Widget _top10SectionImproved(HomeController controller) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       SizedBox(
//         height: 190.h,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           physics: const BouncingScrollPhysics(),
//           padding: EdgeInsets.only(left: 40.w, right: 30.w),
//           itemCount: controller.top10List.length > 10
//               ? 10
//               : controller.top10List.length,
//           itemBuilder: (context, index) {
//             return _buildNetflixTop10Card(
//               item: controller.top10List[index],
//               rank: index + 1,
//             );
//           },
//         ),
//       ),
//     ],
//   );
// }

// Widget _buildNetflixTop10Card({
//   required Map<String, dynamic> item,
//   required int rank,
// }) {
//   return GestureDetector(
//     onTap: () {
//       Get.to(
//         () => VideoDetailScreen(
//           videoTrailer: item['videoTrailer'] as String,
//           videoMoives:
//               item['videoMovies'] as String? ?? item['videoTrailer'] as String,
//           image: item['image'] as String? ?? "",
//           subtitle: item['subtitle'] as String? ?? "",
//           videoTitle: item['title'],
//           dis: item['dis'], logoImage: '',
//         ),
//       );
//     },
//     child: Container(
//       width: 150.w,
//       margin: EdgeInsets.only(right: 50.w),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Positioned(left: -30.w, bottom: 5.h, child: _buildRankNumber(rank)),

//           Positioned(
//             left: 30,
//             top: 5.h,
//             bottom: 5.h,
//             child: Hero(
//               tag: 'top10_${item['videoTrailer']}',
//               child: Container(
//                 width: 120.w,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(6.r),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.7),
//                       blurRadius: 15,
//                       spreadRadius: 1,
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(6.r),
//                   child: Stack(
//                     children: [
//                       Image.asset(
//                         item['image'] as String,
//                         height: double.infinity,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                       Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [
//                               Colors.transparent,
//                               Colors.black.withOpacity(0.3),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
// Widget _buildRankNumber(int rank) {
//   return Stack(
//     children: [
//       Text(
//         '$rank',
//         style: TextStyle(
//           fontSize: 145.sp,
//           fontWeight: FontWeight.w900,
//           height: 0.82,
//           letterSpacing: -5,
//           fontFamily: 'Impact',
//           foreground: Paint()
//             ..style = PaintingStyle.stroke
//             ..strokeWidth = 12.w
//             ..color = Colors.black,
//         ),
//       ),

//       Text(
//         '$rank',
//         style: TextStyle(
//           fontSize: 145.sp,
//           fontWeight: FontWeight.w900,
//           height: 0.82,
//           letterSpacing: -5,
//           fontFamily: 'Impact',
//           foreground: Paint()
//             ..style = PaintingStyle.stroke
//             ..strokeWidth = 8.w
//             ..color = Colors.grey.shade900,
//         ),
//       ),
//       Text(
//         '$rank',
//         style: TextStyle(
//           fontSize: 145.sp,
//           fontWeight: FontWeight.w900,
//           color: Colors.white,
//           height: 0.82,
//           letterSpacing: -5,
//           fontFamily: 'Impact',
//           shadows: [
//             Shadow(
//               color: Colors.black.withOpacity(0.9),
//               blurRadius: 25,
//               offset: Offset(3, 3),
//             ),
//             Shadow(
//               color: Colors.black.withOpacity(0.5),
//               blurRadius: 15,
//               offset: Offset(1, 1),
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// Widget popular(HomeController controller) {
//   return SizedBox(
//     height: 250.h,
//     child: ListView.builder(
//       scrollDirection: Axis.horizontal,
//       padding: EdgeInsets.only(left: 15.w),
//       itemCount: controller.continueWatching.length,
//       itemBuilder: (context, index) {
//         final item = controller.continueWatching[index];
//         return GestureDetector(
//           onTap: () {
//             Get.to(
//               () => VideoDetailScreen(
//                 videoTrailer: item['videoTrailer'] as String,
//                 videoMoives:
//                     item['videoMovies'] as String? ??
//                     item['videoTrailer'] as String,
//                 image: item['image'] as String? ?? "",
//                 subtitle: item['subtitle'] as String? ?? "",
//                 videoTitle: item['title'],
//                 dis: item['dis'], logoImage: '',
//               ),
//             );
//           },
//           child: Container(
//             width: 140.w,
//             margin: EdgeInsets.only(right: 10.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(6.r),
//                       child: Image.asset(
//                         item['image'] as String,
//                         height: 240.h,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     ),
//   );
// }
