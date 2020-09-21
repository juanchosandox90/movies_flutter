import 'package:flutter/material.dart';
import 'package:movies_flutter/models/movieModel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:movies_flutter/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
  Movie upcomingMovies;
  Movie topratedMovies;
  Movie popularMovies;

  int heroTag = 0;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchNowPlayingMovies();
    _fetchPopularPlayingMovies();
    _fetchTopRatedPlayingMovies();
    _fetchUpcomingPlayingMovies();
  }

  void _fetchNowPlayingMovies() async {
    var response = await http.get(nowPlayingUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      nowPlayingMovies = Movie.fromJson(decodeJson);
    });
  }

  void _fetchPopularPlayingMovies() async {
    var response = await http.get(popularUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      popularMovies = Movie.fromJson(decodeJson);
    });
  }

  void _fetchTopRatedPlayingMovies() async {
    var response = await http.get(topRatedUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      topratedMovies = Movie.fromJson(decodeJson);
    });
  }

  void _fetchUpcomingPlayingMovies() async {
    var response = await http.get(upComingUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      upcomingMovies = Movie.fromJson(decodeJson);
    });
  }

  Widget _buildCarouselSlider() => CarouselSlider(
      items: nowPlayingMovies == null
          ? [Center(child: CircularProgressIndicator())]
          : nowPlayingMovies.results
              .map((movieItem) => _buildMovieItem(movieItem))
              .toList(),
      options: CarouselOptions(
        autoPlay: false,
        height: 240.0,
        viewportFraction: 0.5,
      ));

  Widget _buildMovieItem(Results movieItem) {
    heroTag += 1;
    return Material(
      elevation: 15.0,
      child: InkWell(
        onTap: () {},
        child: Hero(
          tag: movieItem.id,
          child: Image.network("${baseImagesUrl}w342${movieItem.posterPath}",
              fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildMovieListItem(Results movieItem) => Material(
        child: Container(
          width: 128.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.all(6.0),
                  child: _buildMovieItem(movieItem)),
              Padding(
                padding: EdgeInsets.only(left: 6.0, top: 2.0),
                child: Text(
                  movieItem.title,
                  style: TextStyle(fontSize: 8.0),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 6.0, top: 2.0),
                child: Text(
                  DateFormat('yyyy')
                      .format(DateTime.parse(movieItem.releaseDate)),
                  style: TextStyle(fontSize: 8.0),
                ),
              )
            ],
          ),
        ),
      );

  Widget _buildMoviesListView(Movie movie, String movieListTitle) => Container(
        height: 258.0,
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 7.0, bottom: 7.0),
              child: Text(
                movieListTitle,
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400]),
              ),
            ),
            Flexible(
                child: ListView(
              scrollDirection: Axis.horizontal,
              children: movie == null
                  ? [Center(child: CircularProgressIndicator())]
                  : movie.results
                      .map((movieItem) => Padding(
                            padding: EdgeInsets.only(left: 6.0, right: 2.0),
                            child: _buildMovieListItem(movieItem),
                          ))
                      .toList(),
            ))
          ],
        ),
      );

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
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "NOW PLAYING",
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.00,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              expandedHeight: 290.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Container(
                      child: Image.network(
                        "${baseImagesUrl}w500/TnOeov4w0sTtV2gqICqIxVi74V.jpg",
                        fit: BoxFit.cover,
                        width: 1000.0,
                        colorBlendMode: BlendMode.dstATop,
                        color: Colors.blue.withOpacity(0.5),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 35.0),
                        child: _buildCarouselSlider())
                  ],
                ),
              ),
            ),
          ];
        },
        body: ListView(
          children: [
            _buildMoviesListView(upcomingMovies, 'COMING SOON'),
            _buildMoviesListView(popularMovies, 'POPULAR MOVIES'),
            _buildMoviesListView(topratedMovies, 'TOP RATED MOVIE'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        fixedColor: Colors.lightBlue,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_movies),
            label: 'All Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tag_faces),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
