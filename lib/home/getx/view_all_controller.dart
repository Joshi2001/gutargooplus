import 'package:get/get.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';

class ViewAllController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  String _currentTitle = '';

  void loadSection(String title) {
    _currentTitle = title;
    _loadItems();
  }

  void _loadItems() {
  if (homeController.isLoadingSections.value) {
    isLoading.value = true;
    return;
  }

  final section = homeController.homeSections.firstWhereOrNull(
    (s) => s.title == _currentTitle,
  );

  if (section == null || section.items.isEmpty) {
    isLoading.value = false;
    items.clear();
    return;
  }

  items.assignAll(section.items.map((m) => _toMap(m)).toList());

  isLoading.value = false;
}

  Map<String, dynamic> _toMap(MovieModel m) => {
        '_id': m.id,
        'id': m.id,
        'title': m.movieTitle,
        'movieTitle': m.movieTitle,
        'tagline': m.tagline,
        'description': m.description,
        'dis': m.description,
        'fullStoryline': m.fullStoryline,
        'genres': m.genres,
        'subtitle': m.genresString,
        'tags': m.tags,
        'language': m.language,
        'duration': m.duration,
        'ageRating': m.ageRating,
        'imdbRating': m.imdbRating,
        'releaseYear': m.releaseYear,
        'budget': m.budget,
        'awardsAndNominations': m.awardsAndNominations,
        'videoQuality': m.videoQuality,
        'audioFormat': m.audioFormat,
        'videoTrailer': m.trailerUrl.isNotEmpty ? m.trailerUrl : m.playUrl,
        'videoMovies': m.playUrl,
        'customVideoUrl': m.customVideoUrl,
        'customTrailerUrl': m.customTrailerUrl,
        'image': m.verticalPosterUrl,
        'verticalPosterUrl': m.verticalPosterUrl,
        'horizontalBannerUrl': m.horizontalBannerUrl,
        'logoImage': m.logoUrl,
        'logoUrl': m.logoUrl,
        'publishStatus': m.publishStatus,
        'subscriptionRequired': m.subscriptionRequired,
        'enableAds': m.enableAds,
        'allowDownloads': m.allowDownloads,
        'featuredMovie': m.featuredMovie,
        'contentVendor': m.contentVendor,
        'viewCount': m.viewCount,
        'directorInfo': m.directorString,
        'castInfo': m.castString,
        'mp4Url': m.movieFile?.mp4Url ?? '',
        'thumbnailUrl': m.movieFile?.thumbnailUrl ?? '',
        'trailerMp4Url': m.trailer?.mp4Url ?? '',
        'trailerThumbnailUrl': m.trailer?.thumbnailUrl ?? '',
        'director': m.director
            .map((c) => {'name': c.name, 'imageUrl': c.imageUrl})
            .toList(),
        'producer': m.producer
            .map((c) => {'name': c.name, 'imageUrl': c.imageUrl})
            .toList(),
        'writer': m.writer
            .map((c) => {'name': c.name, 'imageUrl': c.imageUrl})
            .toList(),
        'musicDirector': m.musicDirector
            .map((c) => {'name': c.name, 'imageUrl': c.imageUrl})
            .toList(),
        'cinematographer': m.cinematographer
            .map((c) => {'name': c.name, 'imageUrl': c.imageUrl})
            .toList(),
        'editor': m.editor
            .map((c) => {'name': c.name, 'imageUrl': c.imageUrl})
            .toList(),
        'castMembers': m.castMembers
            .map((c) => {
                  'name': c.name,
                  'character': c.character,
                  'imageUrl': c.imageUrl,
                  'image': c.imageUrl,
                })
            .toList(),
      };

  @override
  void onInit() {
    super.onInit();

    ever(homeController.isLoadingSections, (bool loading) {
      if (!loading && _currentTitle.isNotEmpty) {
        _loadItems();
      }
    });
    ever(homeController.homeSections, (_) {
      if (_currentTitle.isNotEmpty) {
        _loadItems();
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
  }
}