import 'package:flutter/material.dart';
import 'package:movies_flutter/models/movieCast.dart';
import 'package:movies_flutter/models/movieModel.dart';
import 'package:movies_flutter/models/movieDetailsModel.dart';
import 'package:movies_flutter/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:movies_flutter/models/castcrew.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class MovieDetail extends StatefulWidget {
  final Results movie;

  MovieDetail({this.movie});

  @override
  _MovieDetails createState() => new _MovieDetails();
}

class _MovieDetails extends State<MovieDetail> {
  String movieDetailUrl;
  String movieCastUrl;
  MovieDetailsModel movieDetailsModel;
  MovieCastModel movieCastModel;
  List<CastCrew> castCrew = new List<CastCrew>();
  bool isLoading;

  @override
  void initState() {
    super.initState();
    movieDetailUrl = "$baseUrl${widget.movie.id}?api_key=$apiKey";
    movieCastUrl = "$baseUrl${widget.movie.id}/credits?api_key=$apiKey";
    _fetchMovieDetailUrl();
    _fetchMovieCastUrl();
  }

  void _fetchMovieDetailUrl() async {
    var response = await http.get(movieDetailUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      movieDetailsModel = MovieDetailsModel.fromJson(decodeJson);
    });
  }

  void _fetchMovieCastUrl() async {
    setState(() {
      isLoading = true;
    });

    var response = await http.get(movieCastUrl);
    var decodeJson = jsonDecode(response.body);
    movieCastModel = MovieCastModel.fromJson(decodeJson);

    movieCastModel.cast.forEach((c) => castCrew.add(CastCrew(
        id: c.castId,
        name: c.name,
        subName: c.character,
        imagePath: c.profilePath,
        personType: "Cast")));

    movieCastModel.crew.forEach((c) => castCrew.add(CastCrew(
        id: c.id,
        name: c.name,
        subName: c.job,
        imagePath: c.profilePath,
        personType: "Crew")));

    setState(() {
      isLoading = false;
    });
  }

  String _getMovieDuration(int runtime) {
    if (runtime == null) return 'No data';
    double movieHours = runtime / 60.0;
    int movieMinutes = ((movieHours - movieHours.floor()) * 60).round();
    return "${movieHours.floor()}h ${movieMinutes}min";
  }

  Widget _buildCastCrewContent(String personType) => Container(
        height: 115.0,
        padding: EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                personType,
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400]),
              ),
            ),
            Flexible(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: isLoading
                    ? [Center(child: CircularProgressIndicator())]
                    : castCrew
                        .where((f) => f.personType == personType)
                        .map(
                          (c) => Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Container(
                                  width: 65.0,
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                          radius: 28.0,
                                          backgroundImage: c.imagePath != null
                                              ? NetworkImage(
                                                  '${baseImagesUrl}w154${c.imagePath}')
                                              : AssetImage(
                                                  'assets/nobody.jpg')),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(c.name,
                                            style: TextStyle(
                                                fontSize: 8.0,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      Text(c.subName,
                                          style: TextStyle(fontSize: 8.0),
                                          overflow: TextOverflow.ellipsis)
                                    ],
                                  ))),
                        )
                        .toList(),
              ),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final moviePoster = Container(
      height: 350.0,
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Center(
        child: Card(
          elevation: 15.0,
          child: Hero(
            tag: widget.movie.heroTag,
            child: Image.network(
                "${baseImagesUrl}w342${widget.movie.posterPath}",
                fit: BoxFit.cover),
          ),
        ),
      ),
    );

    final movieTitle = Padding(
        padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
        child: Center(
          child: Text(
            widget.movie.title,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ));

    final movieTickets = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          movieDetailsModel != null
              ? _getMovieDuration(movieDetailsModel.runtime)
              : '',
          style: TextStyle(fontSize: 11.0),
        ),
        Container(
          height: 20.0,
          width: 1.0,
          color: Colors.white70,
        ),
        Text(
          "Release Date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.movie.releaseDate))}",
          style: TextStyle(fontSize: 11.0),
        ),
        RaisedButton(
          onPressed: () {},
          shape: StadiumBorder(),
          elevation: 15.0,
          color: Colors.red[700],
          child: Text('Tickets'),
        )
      ],
    );

    final genresList = Container(
      height: 25.0,
      child: Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: movieDetailsModel == null
              ? []
              : movieDetailsModel.genres
                  .map((genre) => Padding(
                        padding: EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          backgroundColor: Colors.grey[400],
                          labelStyle: TextStyle(fontSize: 10.0),
                          label: Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              genre.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onSelected: null,
                        ),
                      ))
                  .toList(),
        ),
      ),
    );

    final middleContent = Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: Column(
        children: [
          Divider(),
          genresList,
          Divider(),
          Text(
            'SYNOPSIS',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[200]),
          ),
          SizedBox(height: 10.0),
          Center(
            child: Text(
              widget.movie.overview,
              style: TextStyle(fontSize: 11.0, color: Colors.grey[200]),
            ),
          ),
          SizedBox(height: 10.0)
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          'Movies App',
          style: TextStyle(
              color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          moviePoster,
          movieTitle,
          movieTickets,
          middleContent,
          _buildCastCrewContent("Cast"),
          _buildCastCrewContent("Crew")
        ],
      ),
    );
  }
}
