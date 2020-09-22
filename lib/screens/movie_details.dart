import 'package:flutter/material.dart';
import 'package:movies_flutter/models/movieModel.dart';
import 'package:movies_flutter/models/movieDetailsModel.dart';
import 'package:movies_flutter/constants/constants.dart';
import 'package:http/http.dart' as http;
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
  MovieDetailsModel movieDetailsModel;

  @override
  void initState() {
    super.initState();
    movieDetailUrl = "$baseUrl${widget.movie.id}?api_key=$apiKey";
    _fetchMovieDetailUrl();
  }

  void _fetchMovieDetailUrl() async {
    var response = await http.get(movieDetailUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      movieDetailsModel = MovieDetailsModel.fromJson(decodeJson);
    });
  }

  String _getMovieDuration(int runtime) {
    if (runtime == null) return 'No data';
    double movieHours = runtime / 60.0;
    int movieMinutes = ((movieHours - movieHours.floor()) * 60).round();
    return "${movieHours.floor()}h ${movieMinutes}min";
  }

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

    final midleContent = Container(
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
        children: [moviePoster, movieTitle, movieTickets, midleContent],
      ),
    );
  }
}
