import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}



class HomePageState extends State<HomePage> {
  List data = [];
  bool isLoading = true;
  String NEWSAPIKey = "ADDME";

  Future<String> getData(String apiPlatform, String filter) async {
    setState(() {
      isLoading = true;
    });
    http.Response response;
    var response_data;
    switch (apiPlatform) {
      case "newsapi":
        response = await http.get(
            Uri.parse(
                'https://newsapi.org/v2/top-headlines?category='+
                    filter +
                    '&language=en&apiKey=' +
                    NEWSAPIKey),
            headers: {"Accept": "application/json"});
        response_data = jsonDecode(response.body)["articles"];
        break;
      case "google":
        response = await http.get(
            Uri.parse(
                'https://google-news.p.rapidapi.com/v1/top_headlines?lang=en&country=US'
            ),
            headers: {
              "Accept": "application/json",
              'x-rapidapi-host': 'google-news.p.rapidapi.com',
              'x-rapidapi-key': '9lGfqLvBK4mshmRTL9YtkuD1Eb26p1EzTV3jsn4BZP9CzUQxrP'
            }
        );
        response_data = jsonDecode(response.body)["articles"];
        for (var i = 0; i < response_data.length; i++) {
          var current = response_data[i];
          response_data[i] = {
            "url": current["link"],
            "title": current["title"]
          };
        }

        break;
      default:
        response = await http.get(
            Uri.parse(
                'https://newsapi.org/v2/top-headlines?category='+
                    filter +
                    '&language=en&apiKey=' +
                    NEWSAPIKey),
            headers: {"Accept": "application/json"});
        response_data = jsonDecode(response.body)["articles"];
        break;
    }

    setState(() {
      data = response_data;
      isLoading = false;
    });

    return "Success!";
  }

  @override
  void initState() {
    getData("","");
    super.initState();
  }

  _launchURLBrowser(String link) async {
    if( link == ""){
      link = "https://http.cat/404";
    }
    await launch(link);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Custom News Feed"),
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                child: Material(
                  child: Center(
                    child: Text(
                      "Custom News Feed",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                title: const Text('Technology'),
                onTap: () {
                  Navigator.pop(context);
                  getData("newsapi", "technology");
                },
              ),
              ListTile(
                title: const Text('Business'),
                onTap: () {
                  Navigator.pop(context);
                  getData("newsapi","business");
                },
              ),
              ListTile(
                title: const Text('Google'),
                onTap: () {
                  Navigator.pop(context);
                  getData("google","");
                },
              ),
            ],
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          child: isLoading
              ? const SpinKitSpinningLines(
                color: Colors.blue,
                size: 50.0,
              )
              : ListView.builder(
                  itemCount: max(0, data.length),
                  itemBuilder: (BuildContext context, int index) {
                    String title = data[index]["title"] ?? "No Title";
                    String description = data[index]["description"] ?? "No Description";
                    String link = data[index]["url"] ?? "";
                    return Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.white70,
                            width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:Container(
                        height:  200,
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child:Container(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        title: Text(title),
                                        subtitle: Text(description),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(Icons.arrow_forward),
                                            label: Text('link'),
                                            onPressed: (){
                                              _launchURLBrowser(link);
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              flex:8 ,
                            ),
                          ],
                        ),
                      ),
                      elevation: 8,
                      margin: EdgeInsets.all(10),
                    );
                  },
                ),
        ));
  }
}
