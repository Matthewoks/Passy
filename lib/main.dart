import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyList(),
    );
  }
}

class ListItem {
  String elemento1;
  String elemento3;
  String elemento2;

  ListItem(this.elemento1, this.elemento3, this.elemento2);
}

class MyList extends StatefulWidget {
  const MyList({super.key});

  @override
  _MyListState createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  List<ListItem> elenco = [];

  bool _isSearching=false;
  final TextEditingController _searchController = TextEditingController();
  TextEditingController controller1 = TextEditingController();

  TextEditingController controller3 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  @override
  void initState() {
    super.initState();
    _caricaElenco();
  }

  void _caricaElenco() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      elenco = (prefs.getStringList('elenco') ?? []).map((e) {
        final elements = e.split('|');
        // Rimuovi 'W.' iniziale da elements[2] se presente
        String elemento2 = elements[2].startsWith('W.') ? elements[2].substring(2) : elements[1];
        // Rimuovi '!@1' finale da elements[2] se presente
        elemento2 = elemento2.endsWith('!@1') ? elemento2.substring(0, elemento2.length - 3) : elemento2;
        return ListItem(elements[0], elements[1], elemento2);
      }).toList();
    });
  }

  void _salvaElenco() async {
    final prefs = await SharedPreferences.getInstance();
    final elencoStrings = elenco.map((item) =>
    '${item.elemento1}|${item.elemento3}|W.${item.elemento2}!@1').toList();
    prefs.setStringList('elenco', elencoStrings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
       appBar: AppBar(
        title: _isSearching ? TextField(
          controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cerca..',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.black54),
            ),
          style: TextStyle(color: Colors.black),
        ) : const Text('Elenco credenziali', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(169, 255, 171, 64),
        actions: [IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black),
          onPressed: () {setState(() {
            _isSearching =! _isSearching;
            if(!_isSearching){
              _searchController.clear();
            }
          });}, )]
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller1,
                  decoration: const InputDecoration(
                    labelText: 'Piattaforma',
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                    hintStyle: TextStyle(color: Colors.orangeAccent),
                  ),
                  style: const TextStyle(color: Colors.orangeAccent),
                  onEditingComplete: () {
                    FocusScope.of(context).nextFocus();
                  },
                ),
              ),

              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller3,
                  decoration: const InputDecoration(
                    labelText: 'Mail',
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                    hintStyle: TextStyle(color: Colors.orangeAccent),
                  ),
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller2,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                    hintStyle: TextStyle(color: Colors.orangeAccent),
                  ),
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              if (controller1.text.isNotEmpty &&
                  controller3.text.isNotEmpty &&
                  controller2.text.isNotEmpty) {
                setState(() {
                  elenco.add(
                    ListItem(
                      controller1.text.toUpperCase(),

                      controller3.text,
                      controller2.text,
                    ),
                  );
                  controller1.clear();
                  controller2.clear();
                  controller3.clear();
                });
                _salvaElenco();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(169, 255, 171, 64),
            ),
            child: const Text(
              'Aggiungi',
              style: TextStyle(color: Colors.black),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final ListItem item = elenco.removeAt(oldIndex);
                  elenco.insert(newIndex, item);
                  _salvaElenco();
                });
              },
              children: elenco.map((item) {
                return ReorderableDelayedDragStartListener(
                  key: Key(item.elemento1),
                  index: elenco.indexOf(item),
                  child: ListTile(
                    key: Key(item.elemento1),
                    title: Text(
                      '${item.elemento1} - ${item.elemento3} - ${item.elemento2}',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy,
                              color: Color.fromARGB(105, 255, 171, 64)),
                          onPressed: () {
                            _selezionaTesto(item);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Color.fromARGB(105, 255, 171, 64)),
                          onPressed: () {
                            setState(() {
                              elenco.remove(item);
                              _salvaElenco();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _selezionaTesto(ListItem item) {
    String testoSelezionato = item.elemento2;
    Clipboard.setData(ClipboardData(text: testoSelezionato));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ho copiato: $testoSelezionato'),
    ));
  }
}
