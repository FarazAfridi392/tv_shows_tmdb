import 'package:tv_shows_tmdb/model/tv_show_details.dart';
import 'package:tv_shows_tmdb/model/tv_show_preview.dart';
import 'package:tv_shows_tmdb/secret/themoviedb_api.dart' as secret;
import 'package:tv_shows_tmdb/utils/constants.dart';
import 'package:tv_shows_tmdb/utils/file_manager.dart';

import 'package:flutter/material.dart';
import 'package:tv_shows_tmdb/widgets/tv_show_card.dart';
import 'networking.dart';

enum MoviePageType {
  popular,
  airing_today,
  top_rated,
}

class MovieModel {
  Future _getData({required String url}) async {
    NetworkHelper networkHelper = NetworkHelper(Uri.parse(url));
    var data = await networkHelper.getData();
    return data;
  }

  Future<List<MovieCard>> getMovies({
    required MoviePageType moviesType,
    required Color themeColor,
  }) async {
    List<MovieCard> temp = [];
    String mTypString =
        moviesType.toString().substring(14, moviesType.toString().length);

    var data = await _getData(
      url: '$kThemoviedbURL/$mTypString?api_key=${secret.themoviedbApi}',
    );

    for (var item in data["results"]) {
      temp.add(
        MovieCard(
          moviePreview: TVShowPreview(
            isFavorite: await isTVShowInFavorites(tvSID: item["id"].toString()),
            year: (item["release_date"].toString().length > 4)
                ? item["release_date"].toString().substring(0, 4)
                : "",
            imageUrl: "$kThemoviedbImageURL${item["poster_path"]}",
            name: item["name"],
            id: item["id"].toString(),
            rating: item["vote_average"].toDouble(),
            overview: item["overview"],
          ),
          themeColor: themeColor,
        ),
      );
    }
    return Future.value(temp);
  }

  Future<List<MovieCard>> searchMovies({
    required String movieName,
    required Color themeColor,
  }) async {
    List<MovieCard> temp = [];

    var data = await _getData(
      url:
          '$kThemoviedbSearchURL/?api_key=${secret.themoviedbApi}&language=en-US&page=1&include_adult=false&query=$movieName',
    );

    for (var item in data["results"]) {
      try {
        temp.add(
          MovieCard(
            moviePreview: TVShowPreview(
              isFavorite:
                  await isTVShowInFavorites(tvSID: item["id"].toString()),
              year: (item["release_date"].toString().length > 4)
                  ? item["release_date"].toString().substring(0, 4)
                  : "",
              imageUrl: "https://image.tmdb.org/t/p/w500${item["poster_path"]}",
              name: item["name"],
              id: item["id"].toString(),
              rating: item["vote_average"].toDouble(),
              overview: item["overview"],
            ),
            themeColor: themeColor,
          ),
        );
      } catch (e, s) {
        print(s);
        print(item["release_date"]);
      }
    }
    return Future.value(temp);
  }

  Future<TVShowDetails> getMovieDetails({required String movieID}) async {
    var data = await _getData(
      url:
          '$kThemoviedbURL/$movieID?api_key=${secret.themoviedbApi}&language=en-US',
    );

    List<String> temp = [];
    for (var item in data["genres"]) {
      temp.add(item["name"]);
    }

    return Future.value(
      TVShowDetails(
        backgroundURL:
            "https://image.tmdb.org/t/p/w500${data["backdrop_path"]}",
        name: data["name"],
        year: (data["release_date"].toString().length > 4)
            ? data["release_date"].toString().substring(0, 4)
            : "",
        isFavorite: await isTVShowInFavorites(tvSID: data["id"].toString()),
        rating: data["vote_average"].toDouble(),
        genres: temp,
        overview: data["overview"],
      ),
    );
  }

  Future<List<MovieCard>> getFavorites(
      {required Color themeColor, required int bottomBarIndex}) async {
    List<MovieCard> temp = [];
    List<String> favoritesID = await getFavoritesID();
    for (var item in favoritesID) {
      if (item != "") {
        var data = await _getData(
          url:
              '$kThemoviedbURL/$item?api_key=${secret.themoviedbApi}&language=en-US',
        );

        temp.add(
          MovieCard(
            contentLoadedFromPage: bottomBarIndex,
            themeColor: themeColor,
            moviePreview: TVShowPreview(
              isFavorite:
                  await isTVShowInFavorites(tvSID: data["id"].toString()),
              year: (data["release_date"].toString().length > 4)
                  ? data["release_date"].toString().substring(0, 4)
                  : "",
              imageUrl: "https://image.tmdb.org/t/p/w500${data["poster_path"]}",
              name: data["name"],
              id: data["id"].toString(),
              rating: data["vote_average"].toDouble(),
              overview: data["overview"],
            ),
          ),
        );
      }
    }
    return temp;
  }
}
