import 'package:flutter/material.dart';
import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/utils/database_helper.dart';

class Kategoriler extends StatefulWidget {
  const Kategoriler({Key? key}) : super(key: key);

  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {
  List? tumKategoriler;
  DatabaseHelper? databaseHelper;

  @override
  void initState() {
    super.initState();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    if (tumKategoriler == null) {
      tumKategoriler = [];
      databaseHelper!.kategoriListesiniGetir().then((value) {
        setState(() {
          tumKategoriler = value;
          debugPrint(tumKategoriler.toString());
        });
      });
    }
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 48,
        titleSpacing: 0,
        title: Text('Kategoriler'),
      ),
      body: ListView.builder(
        itemCount: tumKategoriler!.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              kategoriGuncelleDialog(context, tumKategoriler![index], index);
            },
            title: Text(
              tumKategoriler![index].kategoriBaslik.toString(),
            ),
            trailing: IconButton(
              onPressed: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Kategoriyi Sil'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                'Kategoriyi sildiginizde bu kategoriyle ilgili tum notlarda silinecektir. Emin Misiniz?'),
                            ButtonBar(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Vazgec'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    databaseHelper!
                                        .kategoriSil(
                                            tumKategoriler![index].kategoriID)
                                        .then((value) {
                                      if (value != 0) {
                                        setState(() {});
                                        tumKategoriler!.removeAt(index);
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            duration: Duration(seconds: 2),
                                            content: Text('Kategori silindi!'),
                                          ),
                                        );
                                      }
                                    });
                                  },
                                  child: Text('Sil'),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    });
              },
              icon: Icon(Icons.delete),
            ),
            leading: Icon(Icons.category),
          );
        },
      ),
    );
  }

  Future<dynamic> kategoriGuncelleDialog(
      BuildContext context, Kategori guncellencekKategori, index) {
    var formKey = GlobalKey<FormState>();
    String? guncellenenKategoriAdi;
    return showDialog(
      //Disarida bir yere tiklanildiginda kapanmasini engelliyor
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            'Kategori Guncelle',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          children: [
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  initialValue: guncellencekKategori.kategoriBaslik,
                  onSaved: (value) {
                    guncellenenKategoriAdi = value.toString();
                  },
                  decoration: InputDecoration(
                    labelText: 'Kategori Adi',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.length < 3) {
                      return 'En az 3 karakter giriniz';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Vazgec'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        databaseHelper!
                            .kategoriGuncelle(
                          Kategori.withID(
                              kategoriBaslik: guncellenenKategoriAdi,
                              kategoriID: guncellencekKategori.kategoriID),
                        )
                            .then((value) {
                          if (value != 0) {
                            debugPrint('statement');
                            Navigator.of(context).pop();
                            tumKategoriler![index].kategoriBaslik =
                                guncellenenKategoriAdi;
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 2),
                                content: Text('Kategori guncellendi!'),
                              ),
                            );
                          }
                        });
                      }
                    },
                    child: Text('Guncelle'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
