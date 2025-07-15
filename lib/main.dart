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
}

// definir los componentes: texto, botones, etc...
class MyHomePage extends StatelessWidget {
  @override
  //Cada widget define un método build() que se llama automáticamente
  //cada vez que cambian las circunstancias del widget de modo que este 
  //siempre esté actualizado.
  Widget build(BuildContext context) {
    // se realiza el seguimiento del estado actual de la app con 'watch'
    var appState = context.watch<MyAppState>();
    var pair = appState.current; // referencia SOLO al par de palabras, no al appstate completo 

    //cada metodo build debe mostrar un widget o un arbol de widgets anidado
    return Scaffold(
      body: Center(
        child: Column( // widget basico que coloca elementos de arriba a abajo
          mainAxisAlignment: MainAxisAlignment.center, // <-- centrado vertical
          children: [
            Text('This is a random word:'), //widget que muestra texto
            // en este texto se accede a la var appstate, a su vez current, y a lowercase
            // que es un metodo de WordPair, mostrandose ese texto
            BigCard(pair: pair), // referencia al pair solo
            SizedBox(height: 10), // para separar el boton y la palabra
            ElevatedButton(
            onPressed: (){
              appState.getNext();
            },
            child: Text('Next'),
          ),
          ],
        ),
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
