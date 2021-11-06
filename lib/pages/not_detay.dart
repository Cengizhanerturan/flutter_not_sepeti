import 'package:flutter/material.dart';
import 'package:not_sepeti/models/kategori.dart';
import 'package:not_sepeti/models/notlar.dart';
import 'package:not_sepeti/utils/database_helper.dart';

// ignore: must_be_immutable
class NotDetay extends StatefulWidget {
  String? baslik;
  Not? not;
  NotDetay({this.baslik, this.not, Key? key}) : super(key: key);

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  int? kategoriID;
  static var _oncelik = ['Dusuk', 'Orta', 'Yuksek'];
  int? secilenOncelik;
  var formKey = GlobalKey<FormState>();
  List<Kategori>? tumKategoriler;
  DatabaseHelper? databaseHelper;
  String? notBaslik;
  String? notIcerik;

  @override
  void initState() {
    super.initState();
    tumKategoriler = [];
    databaseHelper = DatabaseHelper();
    databaseHelper!.kategorileriGetir().then((value) {
      for (Map i in value) {
        tumKategoriler!.add(Kategori.fromMap(i as Map<String, dynamic>));
      }
      setState(() {});
    });
    if (widget.not != null) {
      kategoriID = widget.not!.kategoriID;
      secilenOncelik = widget.not!.notOncelik;
    } else {
      kategoriID = tumKategoriler!.first.kategoriID;
      secilenOncelik = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leadingWidth: 48,
        titleSpacing: 0,
        title: Text(
          widget.baslik.toString(),
        ),
      ),
      body: tumKategoriler!.length <= 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Kategori',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              items: kategoriItemleriOlustur(),
                              value: kategoriID,
                              onChanged: (secilenKategoriID) {
                                setState(() {
                                  kategoriID = secilenKategoriID as int;
                                });
                              },
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                          margin: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue:
                            widget.not != null ? widget.not!.notBaslik : '',
                        validator: (value) {
                          if (value!.length <= 3) {
                            return 'En az 4 karakter giriniz.';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          notBaslik = value;
                        },
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'Not basligini giriniz.',
                          labelText: 'Baslik',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue:
                            widget.not != null ? widget.not!.notIcerik : '',
                        onSaved: (value) {
                          notIcerik = value;
                        },
                        autofocus: false,
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Not icerigini giriniz.',
                          labelText: 'Icerik',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Oncelik',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              items: _oncelik.map((e) {
                                return DropdownMenuItem(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  value: _oncelik.indexOf(e),
                                );
                              }).toList(),
                              value: secilenOncelik,
                              onChanged: (value) {
                                setState(() {
                                  secilenOncelik = value as int;
                                });
                              },
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                          margin: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Vazgec',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              var suan = DateTime.now();
                              if (widget.not == null) {
                                databaseHelper!
                                    .notEkle(
                                  Not(
                                    kategoriID,
                                    notBaslik,
                                    notIcerik,
                                    suan.toString(),
                                    secilenOncelik,
                                  ),
                                )
                                    .then((value) {
                                  if (value != 0) {
                                    Navigator.pop(context);
                                  }
                                });
                              } else {
                                databaseHelper!
                                    .notGuncelle(
                                  Not.withID(
                                    widget.not!.notID,
                                    kategoriID,
                                    notBaslik,
                                    notIcerik,
                                    suan.toString(),
                                    secilenOncelik,
                                  ),
                                )
                                    .then((value) {
                                  if (value != 0) {
                                    Navigator.pop(context);
                                  }
                                });
                              }
                            }
                          },
                          child: Text(
                            'Kaydet',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<DropdownMenuItem<int>> kategoriItemleriOlustur() {
    return tumKategoriler!
        .map(
          (e) => DropdownMenuItem(
            value: e.kategoriID,
            child: Text(
              e.kategoriBaslik.toString(),
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        )
        .toList();
  }
}

/* Form(
        key: formKey,
        child: Column(
          children: [
            Center(
              child: Container(
                child: tumKategoriler!.length <= 0
                    ? CircularProgressIndicator()
                    : DropdownButton<int>(
                        underline: Container(),
                        iconSize: 30,
                        iconDisabledColor: Theme.of(context).primaryColorLight,
                        iconEnabledColor: Theme.of(context).primaryColorLight,
                        value: kategoriID,
                        items: kategoriItemleriOlustur(),
                        onChanged: (secilenKategoriID) {
                          setState(() {
                            kategoriID = secilenKategoriID as int;
                          });
                        },
                      ),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ), */
