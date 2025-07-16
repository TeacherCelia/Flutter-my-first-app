import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Se le indica a flutter que ejecute la app definida en myapp
void main() {
  runApp(MyApp());
}

// Configuración de la app por completo
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) { 
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'My first flutter app', // definicion de nombre de app
        theme: ThemeData( // definicion de tema visual
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 112, 20, 161)),
        ),
        home: MyHomePage(), // definicion de widget principal (punto de partida)
      ),
    );
  }
}

// definir el estado de la APP
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  // genero un comportamiento, en el que se reasigna el elemento current a un nuevo WordPair
  // tambien llama a NotifyListener() para que se notifique a todos los watchers
  void getNext(){
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[]; // se inicializa con una lista vacia de wordpairs[]
  // Función que agrega a la lista de favoritos la palabra si no esta en ella
  void toggleFavorite() {
    if (favorites.contains(current)){
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

}

// myhomepage divide la pantalla en 2(row): SafeArea (navigationRail) y Expanded (generatorPage)
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex){
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage(); // placeholder es un widget que dibuja un cuadrado tachado para saber que hay que acabar esta pantalla
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea( // garantiza que sus elementos secundarios no se muestren oscurecidos por recorde de hardware o barra de estado
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600, // para mostrar los nombres o no junto a los iconos (constraint de 600px, solo cuando tenga ese espacio)
                  destinations: [ // destinos de navegación
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) { // qué hacer al elegir uno de los destinos
                    setState((){ //<-- hace que cuando cambia el value, se redibuja la pagina
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page, 
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

// lo que antes era MyHomePage (en extended ahora)
class GeneratorPage extends StatelessWidget {
  @override
  //Cada widget define un método build() que se llama automáticamente
  //cada vez que cambian las circunstancias del widget de modo que este x
  //siempre esté actualizado.
  Widget build(BuildContext context) {
    // se realiza el seguimiento del estado actual de la app con 'watch'
    var appState = context.watch<MyAppState>();
    var pair = appState.current; // referencia SOLO al par de palabras, no al appstate completo

    // objeto icono para el boton de favorites
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    //cada metodo build debe mostrar un widget o un arbol de widgets anidado
    return Center(
      child: Column( // widget basico que coloca elementos de arriba a abajo
        mainAxisAlignment: MainAxisAlignment.center, // <-- centrado vertical
        children: [
          Text('This is a random word:'), //widget que muestra texto
            // en este texto se accede a la var appstate, a su vez current, y a lowercase
            // que es un metodo de WordPair, mostrandose ese texto
          BigCard(pair: pair), // referencia al pair solo
          SizedBox(height: 10), // para separar el boton y la palabra
          Row( // se hace una fila para añadir dos botones juntos
            mainAxisSize: MainAxisSize.min, // para indicarle a row que no ocupe todo el espacio horizontal disponible
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// clase automatica extrayendo el widget para mostrar más guay el texto de la palabra
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // para solicitar el tema actual de la app
    // con theme.textTheme se accede al tema de la fuente de tu app
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );  
    return Card(
      color: theme.colorScheme.primary, // definimos color de la tarjeta
      child: Padding( // resultado de refactor en text
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase, 
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}", // *accesibilidad*: esto sirve para que los lectores de pantalla lean las 2 palabras correctamente
          ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // se realiza el seguimiento del estado actual de la app con 'watch'
    var appState = context.watch<MyAppState>();
    if (appState.favorites.isEmpty) { 
      return Center(
        child: Text('No favorites yet.'), // si no hay favoritos se muestra un mensaje
      );
    }
    return ListView( // widget que hace que suba y baje la pantalla con scroll
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile( // 
            leading: Icon(Icons.favorite), // icono al lado de la palabra
            title: Text(pair.asLowerCase), // palabra en favoritos
          ),
      ],
    );
  }
}