import 'dart:io';
import 'package:flutter/material.dart';
import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/pages/kategori_islemleri.dart';
import 'package:not_sepeti/utils/database_helper.dart';
import 'not_detay.dart';

class NotListesi extends StatefulWidget {
  NotListesi({Key? key}) : super(key: key);

  @override
  _NotListesiState createState() => _NotListesiState();
}

class _NotListesiState extends State<NotListesi> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'Kategori Ekle',
            tooltip: 'Kategori Ekle',
            onPressed: () {
              kategoriEkleDialog(context);
            },
            child: Icon(
              Icons.add_circle,
            ),
            mini: true,
          ),
          FloatingActionButton(
            heroTag: 'Not Ekle',
            tooltip: 'Not Ekle',
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => NotDetay(
                            baslik: 'Yeni Not',
                          )))
                  .then((value) => setState(() {}));
            },
            child: Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          'Not Sepeti',
        ),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.category),
                  title: Text('Kategoriler'),
                  onTap: () {
                    //Geri geldigimizde popup ekraninin acik olmamasi icin
                    Navigator.pop(context);
                    //Kategoriler sayfasina gitmek icin
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => Kategoriler()))
                        .then((value) {
                      setState(() {});
                    });
                  },
                ),
              ),
            ];
          }),
        ],
      ),
      body: FutureBuilder(
        future: databaseHelper.notListesiniGetir(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            sleep(Duration(milliseconds: 500));
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    leading: _oncelikIconuAta(snapshot.data![index].notOncelik),
                    title: Text(
                      snapshot.data![index].notBaslik.toString(),
                    ),
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Kategori '),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Olusturulma tarihi'),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(snapshot.data![index].kategoriBaslik
                                    .toString()),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  databaseHelper.dateFormat(
                                    DateTime.parse(
                                        snapshot.data![index].notTarih),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              snapshot.data![index].notIcerik,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      _notSil(snapshot.data![index].notID),
                                  child: Text('Sil'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                NotDetay(
                                              baslik: 'Not Guncelle',
                                              not: snapshot.data![index],
                                            ),
                                          ),
                                        )
                                        .then((value) => setState(() {}));
                                  },
                                  child: Text('Guncelle'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error\n' + snapshot.error.toString(),
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
              );
            } else {
              return Center(
                child: Text(
                  'Else',
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
              );
            }
          } else {
            return Center(
              child: Text('Yukleniyor...'),
            );
          }
        },
      ),
    );
  }

  Future<dynamic> kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String? yeniKategoriAdi;
    return showDialog(
      //Disarida bir yere tiklanildiginda kapanmasini engelliyor
      barrierDismissible: false,

      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            'Kategori Ekle',
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
                  onSaved: (value) {
                    yeniKategoriAdi = value.toString();
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
                        databaseHelper
                            .kategoriEkle(
                                Kategori(kategoriBaslik: yeniKategoriAdi))
                            .then((value) {
                          if (value > 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(seconds: 3),
                                content: Text('Kategori eklendi.'),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    child: Text('Kaydet'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // _detaySayfasinaGit(BuildContext context) {
  //   Navigator.of(context)
  //       .push(MaterialPageRoute(
  //           builder: (context) => NotDetay(
  //                 baslik: 'Yeni Not',
  //               )))
  //       .then((value) => setState(() {}));
  // }

  _oncelikIconuAta(int notOncelik) {
    switch (notOncelik) {
      case 0:
        return CircleAvatar(
          child: Text('Az'),
        );
      case 1:
        return CircleAvatar(
          backgroundColor: Colors.orange.shade400,
          child: Text(
            'Orta',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        );
      case 2:
        return CircleAvatar(
          backgroundColor: Colors.red.shade400,
          child: Text(
            'Acil',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        );
    }
  }

  _notSil(notID) {
    databaseHelper.notSil(notID).then((value) {
      if (value != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not Silindi.'),
          ),
        );
        setState(() {});
      }
    });
  }
}
