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
  List<ListItem> elencoFiltrato = [];

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _caricaElenco();
    _searchController.addListener(_filterElenco);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _caricaElenco() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      elenco = (prefs.getStringList('elenco') ?? []).map((e) {
        final elements = e.split('|');
        String elemento2 = elements[2].startsWith('W.') ? elements[2].substring(2) : elements[1];
        elemento2 = elemento2.endsWith('!@1') ? elemento2.substring(0, elemento2.length - 3) : elemento2;
        return ListItem(elements[0], elements[1], elemento2);
      }).toList();
      elencoFiltrato = elenco; // Inizialmente elencoFiltrato è uguale a elenco
    });
  }

  void _salvaElenco() async {
    final prefs = await SharedPreferences.getInstance();
    final elencoStrings = elenco.map((item) =>
    '${item.elemento1}|${item.elemento3}|W.${item.elemento2}!@1').toList();
    prefs.setStringList('elenco', elencoStrings);
  }

  void _filterElenco() {
    setState(() {
      if (_isSearching && _searchController.text.isNotEmpty) {
        elencoFiltrato = elenco
            .where((item) =>
            item.elemento1.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      } else {
        elencoFiltrato = elenco;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cerca...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black),
          ),
          style: TextStyle(color: Colors.black),
        )
            : const Text('Elenco credenziali', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(169, 255, 171, 64),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black45),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  elencoFiltrato = elenco; // Ripristina elenco completo
                }
              });
            },
          )
        ],
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
                _filterElenco(); // Aggiorna filtro elenco
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
                  if (newIndex > oldIndex) newIndex -= 1;
                  final ListItem item = elenco.removeAt(oldIndex);
                  elenco.insert(newIndex, item);
                  _salvaElenco();
                });
              },
              children: elencoFiltrato.map((item) {
                return ReorderableDelayedDragStartListener(
                  key: Key(item.elemento1),
                  index: elencoFiltrato.indexOf(item),
                  child: ListTile(
                  /*  key: Key(item.elemento1),
                    title: Text(
                      '${item.elemento1} - ${item.elemento3} - ${item.elemento2}',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),*/
                    key: Key(item.elemento1),
                    title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${item.elemento1} - ',
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                          )

                        ),
                        TextSpan(
                            text: '${item.elemento3} - ',
                            style: TextStyle(
                                color: Color.fromARGB(90, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                            )

                        ),  TextSpan(
                            text: item.elemento2,
                            style: TextStyle(
                              color: Color.fromARGB(90, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                            )

                        )
                      ]
                    ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy,
                              color: Color.fromARGB(100, 255, 171, 64)),
                          onPressed: () {
                            _selezionaTesto(item);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Color.fromARGB(100, 255, 171, 64)),
                          onPressed: () {
                            setState(() {
                              elenco.remove(item);
                              _salvaElenco();
                              _filterElenco();
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