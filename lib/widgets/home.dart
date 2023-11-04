import 'package:flutter/material.dart';
import 'package:news_app/clases/new.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<New>> newsFuture;

  @override
  void initState() {
    super.initState();
    newsFuture = getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("News"),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.search)),
          IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData) {
              final news = snapshot.data as List<New>;
              return buildNews(news);
            } else {
              return const Text("No data available");
            }
          },
        ),
      ),
    );
  }

  Future<List<New>> getNews() async {
    var apiKey =
        '7f1df14418f6460cb1cc649da7d1004b'; // Reemplaza con tu clave de API
    var url =
        Uri.parse('https://newsapi.org/v2/everything?q=keyword&apiKey=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> articles = data['articles'];

      return articles.map((article) => New.fromJson(article)).toList();
    } else {
      throw Exception('Fallo al cargar las noticias');
    }
  }

  Widget buildNews(List<New> news) {
    return ListView.separated(
      itemCount: news.length,
      itemBuilder: (BuildContext context, int index) {
        final newsItem = news[index];

        return ListTile(
          title: Text(newsItem.title ?? 'Sin título'),
          isThreeLine: true,
          contentPadding: const EdgeInsets.all(8.0),
          dense: true,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(newsItem.urlToImage ?? ''),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fuente: ${newsItem.source?.name ?? 'Desconocida'}'),
              Text('Autor: ${newsItem.author ?? 'Desconocido'}'),
              Text(
                  'Fecha de publicación: ${newsItem.publishedAt?.toString() ?? 'Desconocida'}'),
              Text('URL: ${newsItem.url ?? 'Desconocida'}'),
              Text('Contenido: ${newsItem.content ?? 'Sin contenido'}'),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Puedes agregar acciones al hacer clic en un elemento si es necesario.
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          thickness: 2,
        );
      },
    );
  }
}
