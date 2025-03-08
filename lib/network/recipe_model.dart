import 'package:json_annotation/json_annotation.dart';

part 'recipe_model.g.dart';

@JsonSerializable()
class APIReccipeQuery {
  factory APIReccipeQuery.fromJson(Map<String, dynamic> json) =>
  _$APIReccipeQueryFromJson(json);

  Map<String, dynamic> toJson() => _$APIReccipeQueryToJson(this);
  @JsonKey(name: 'q')
  String query;
  int from;
  int to;
  bool more;
  int count;
  List<APIHits> hits;

  APIReccipeQuery({
    required this.query,
    required this.from,
    required this.to,
    required this.more,
    required this.count,
    required this.hits,
  });
}

@JsonSerializable()
class APIHits {
  APIReccipe reccipe;

  APIHits({
    required this.reccipe,
  });

  factory APIHits.fromJson(Map<String, dynamic> json) =>
  _$APIHitsFromJson(json);
  Map<String, dynamic> toJson() => _$APIHitsToJson(this);
}

@JsonSerializable()
class APIReccipe {
  String label;
  String image;
  String url;
  List<APIIngredients> ingredients;
  double calories;
  double totalWeight;
  double totalTime;

  APIReccipe({
    required this.label,
    required this.image,
    required this.url,
    required this.ingredients,
    required this.calories,
    required this.totalWeight,
    required this.totalTime,
  });

  factory APIReccipe.fromJson(Map<String, dynamic> json) =>
  _$APIReccipeFromJson(json);
  Map<String, dynamic> toJson() => _$APIReccipeToJson(this);
}

@JsonSerializable()
class APIIngredients {
  @JsonKey(name: 'text')
  String name;
  double weight;

  APIIngredients({
    required this.name, 
    required this.weight, 
  });

  factory APIIngredients.fromJson(Map<String, dynamic> json) =>
  _$APIIngredientsFromJson(json);
  Map<String, dynamic> toJson() => _$APIIngredientsToJson(this);
}

String getCalories(double? calories) {
  if (calories == null) {
    return '0 KCAL';
  }
  return '${calories.floor()} KCAL';
}

String getWeight(double? calories) {
  if (calories == null) {
    return '0g';
  }
  return '${calories.floor()}g';
}

