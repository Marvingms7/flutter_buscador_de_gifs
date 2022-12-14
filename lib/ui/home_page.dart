import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _buscar;

  int _offSet = 26;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_buscar == '') {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=aaVClH3IDxPutSQeutFyZrw8OXYS1wHA&limit=25&rating=g'));
    } else {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=aaVClH3IDxPutSQeutFyZrw8OXYS1wHA&q=$_buscar&limit=25&offset=$_offSet&rating=g&lang=pt'));
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  labelText: 'Pesquise aqui!',
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder()),
              style: const TextStyle(color: Colors.white, fontSize: 17.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _buscar = text;
                  _offSet = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        return Container();
                      } else {
                        return _criarTabelaGif(context, snapshot);
                      }
                  }
                }),
          ),
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_buscar == '') {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _criarTabelaGif(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: (context, index) {
        if (_buscar == '' || index < snapshot.data('data').length) {
          return GestureDetector(
            child: Image.network(
              snapshot.data['data'][index]['images']['fixed_height']['url'],
              height: 300.0,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 70.0,
                ),
                Text(
                  'Carregar mais...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}
