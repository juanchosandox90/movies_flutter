import 'package:flutter/material.dart';
import 'package:movies_flutter/models/movieModel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const baseUrl = "https://api.themoviedb.org/3/movie/";
const baseImagesUrl = "https://image.tmdb.org/t/p/";
const apiKey = "61c7b9e7d9da1b81cab16a772cd27284";
const nowPlayingUrl = "${baseUrl}now_playing?api_key=$apiKey";

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie App',
      theme: ThemeData.dark(),
      home: MyMovieApp(),
    ));

class MyMovieApp extends StatefulWidget {
  @override
  _MyMovieApp createState() => new _MyMovieApp();
}

class _MyMovieApp extends State<MyMovieApp> {
  Movie nowPlayingMovies;

  @override
  void initState() {
    super.initState();
    _fetchNowPlayingMovies();
  }

  void _fetchNowPlayingMovies() async {
    var response = await http.get(nowPlayingUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      nowPlayingMovies = Movie.fromJson(decodeJson);
      print(decodeJson);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          'Movies App',
          style: TextStyle(
              color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
      ),
    );
  }
}
