class Kategori {
  int? kategoriID;
  String? kategoriBaslik;

  Kategori({
    this.kategoriBaslik, //Kategori eklerken kullan cunku ID db tarafindan olusturuluyor.
  });

  Kategori.withID({
    this.kategoriID, //Kategorileri veritabanindan okurken kullanilir.
    this.kategoriBaslik,
  });

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['kategoriID'] = kategoriID;
    map['kategoriBaslik'] = kategoriBaslik;
    return map;
  }

  Kategori.fromMap(Map<String, dynamic> map) {
    this.kategoriID = map['kategoriID'];
    this.kategoriBaslik = map['kategoriBaslik'];
  }

  @override
  String toString() =>
      'Kategori(kategoriID: $kategoriID, kategoriBaslik: $kategoriBaslik)';
}
