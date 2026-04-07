import 'package:gutrgoopro/home/model/movie_model.dart';

class HomeSectionModel {
  final String id;
  final String title;
  final String sectionType;
  final String displayStyle;
  final int displayOrder;
  final bool isActive;
  final List<String> movieIds;
  final List<String> visibleTabs;
  final String? categoryId;
  List<MovieModel> items;

  HomeSectionModel({
    required this.id,
    required this.title,
    required this.sectionType,
    required this.displayStyle,
    required this.displayOrder,
    required this.isActive,
    required this.movieIds,
    required this.visibleTabs,
    this.categoryId,
    List<MovieModel>? items,
  }) : items = items ?? [];

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    final sectionData = json['sectionData'] as Map<String, dynamic>?;
    final rawMovieIds = (sectionData?['movies'] ?? []) as List<dynamic>;
    final movieIds = rawMovieIds.map((e) => e.toString()).toList();

    final rawItems =
        (json['items'] ?? json['populatedMovies'] ?? []) as List<dynamic>;

    final visibleTabs =
        ((json['visibleTabs'] ?? []) as List<dynamic>)
            .map((e) => e.toString())
            .toList();

    return HomeSectionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      sectionType: (json['sectionType'] ?? json['type'] ?? 'default').toString(),
      displayStyle: (json['displayStyle'] ?? 'default').toString(),
      displayOrder: _parseInt(json['displayOrder'] ?? json['order'] ?? 0),
      isActive: json['isActive'] == true || json['active'] == true,
      movieIds: movieIds,
      visibleTabs: visibleTabs,
      categoryId: json['categoryId']?.toString(),
      items: rawItems
          .map((e) {
            try {
              return MovieModel.fromJson(e as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<MovieModel>()
          .toList(),
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  HomeSectionModel copyWith({List<MovieModel>? items}) {
    return HomeSectionModel(
      id: id,
      title: title,
      sectionType: sectionType,
      displayStyle: displayStyle,
      displayOrder: displayOrder,
      isActive: isActive,
      movieIds: movieIds,
      visibleTabs: visibleTabs,
      categoryId: categoryId,
      items: items ?? this.items,
    );
  }
}