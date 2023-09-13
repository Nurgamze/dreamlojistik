class DataGridModel{
  String stokKodu;
  String stokAdi;
  String barKodu;
  String birim;
  String anaGrup;
  String altGrup;
  String marka;
  String reyon;
  String renk;
  String beden;
  String sezon;
  String hamMadde;
  String kategori;

  DataGridModel(this.stokKodu,this.stokAdi,this.barKodu,this.birim,this.anaGrup,this.altGrup,this.marka,this.reyon,this.renk,this.beden,this.sezon,this.hamMadde,this.kategori);
}


class SayimEvrakStoklarDataGrid{
  String? stokKodu;
  String? stokAdi;
  String? listeAdi;
  String? fiyat;
  String? birim;
  String? anaGrup;
  String? altGrup;
  String? marka;
  String? reyon;
  String? kisaIsmi;
  String? paraBirimi;
  String? miktar;

  SayimEvrakStoklarDataGrid(this.stokKodu,this.stokAdi,this.miktar,this.birim,this.anaGrup,this.altGrup,this.marka,this.reyon,this.listeAdi,this.fiyat,this.paraBirimi,this.kisaIsmi);
}

class StokMiktarPopUpGrid{
  String depoAdi;
  double miktar;

  StokMiktarPopUpGrid(this.depoAdi,this.miktar);
}

class StokFiyatPopUpGrid{
  String aciklama;
  String fiyat;

  StokFiyatPopUpGrid(this.aciklama,this.fiyat);
}

class SayimlarSayfasiDataGrid{
  int? id;
  String? evrakAdi;
  int? depoKod;
  String? depoAdi;
  String? basTarihi;
  String? sonIslemTarihi;
  int? aktarildiMi;
  String? userId;

  SayimlarSayfasiDataGrid(this.id,this.evrakAdi,this.depoKod,this.depoAdi,this.basTarihi,this.sonIslemTarihi,this.userId);
}

class SayimEvrakSayfasiDataGrid{
  int id;
  int evrakId;
  String raf;
  String miktar;
  String stokKodu;
  String stokAdi;
  String birim;

  SayimEvrakSayfasiDataGrid(this.id,this.evrakId,this.raf,this.miktar,this.stokKodu,this.stokAdi,this.birim);
}

class PlansizNakliyeDataGrid{
  int? id;
  int? cikisDepoNo;
  int? girisDepoNo;
  int? satir;
  String? seri;
  String? cikisDepoAdi;
  String? girisDepoAdi;
  String? tarih;
  String? aciklama;
  int? aktarildiMi;
  PlansizNakliyeDataGrid(this.id,this.cikisDepoNo,this.girisDepoNo,this.satir,this.seri,this.cikisDepoAdi,this.girisDepoAdi,this.tarih,this.aciklama);
}
class PlansizNakliyeEvrakDataGrid{
  int id;
  int evrakId;
  String miktar;
  String stokKodu;
  String stokAdi;
  String birim;

  PlansizNakliyeEvrakDataGrid(this.id,this.evrakId,this.miktar,this.stokKodu,this.stokAdi,this.birim);
}



class DepolarArasiSiparisFisiDataGrid{
  int? id;
  int? cikisDepoNo;
  int? girisDepoNo;
  int? satir;
  String? seri;
  String? cikisDepoAdi;
  String? girisDepoAdi;
  String? tarih;
  String? aciklama;
  int? aktarildiMi;
  DepolarArasiSiparisFisiDataGrid(this.id,this.cikisDepoNo,this.girisDepoNo,this.satir,this.seri,this.cikisDepoAdi,this.girisDepoAdi,this.tarih,this.aciklama);
}
class DepolarArasiSiparisFisiDetayDataGrid{
  int id;
  int evrakId;
  String miktar;
  String stokKodu;
  String stokAdi;
  String birim;

  DepolarArasiSiparisFisiDetayDataGrid(this.id,this.evrakId,this.miktar,this.stokKodu,this.stokAdi,this.birim);
}

class AlternatiflerGrid{
  String kodu;
  String stokAdi;
  String urunTipi;
  String ipRate;
  String marka;
  String kasaTipi;
  String tip;
  String ekOzellik;
  String sinif;
  String renk;
  String levin;
  String ledSayisi;
  String lens;
  String guc;
  String volt;
  String akim;
  String ebat;
  String kilo;
  String recete1;
  String koli;
  String yeniAlan13;
  String recete2;
  String ongoruMasraf;
  String marka2;
  String kilif;
  String kelvin;
  String vfBin;
  String renkBin;
  String lumenBin;
  String satisPotansiyeli;
  String aileKutugu;
  String garantiSuresi;
  String binKodu;

  AlternatiflerGrid(this.kodu,this.stokAdi,this.urunTipi,this.ipRate,this.marka,this.kasaTipi,this.tip,this.ekOzellik,this.sinif,this.renk,this.levin,this.ledSayisi,this.lens,this.guc,this.volt,this.akim,this.ebat,this.kilo,this.recete1,this.koli,this.yeniAlan13,this.recete2,this.ongoruMasraf,this.marka2,this.kilif,this.kelvin,this.vfBin,this.renkBin,this.lumenBin,this.satisPotansiyeli,this.aileKutugu,this.garantiSuresi,this.binKodu);
}



//VERİ TABANI MODELLERİ

class StokSatisFiyatListesiInfo{
  String? stokKodu;
  String? aciklama;
  double? satisFiyati;
  String? paraBirimi;
  StokSatisFiyatListesiInfo({this.stokKodu,this.aciklama,this.satisFiyati,this.paraBirimi});
}

class DepolarInfo{
  int? depNo;
  String? depoAdi;
  DepolarInfo({this.depNo,this.depoAdi});
}

class BarkodTanimlariInfo{
  String? barStokKodu;
  String? barKodu;
  BarkodTanimlariInfo({this.barStokKodu,this.barKodu});
}

class DeponunStoklariInfo{
  int? depNo;
  String? depoAdi;
  String? stokKodu;
  double? miktar;
  DeponunStoklariInfo({this.depNo,this.depoAdi,this.stokKodu,this.miktar});
}

class StoklarInfo{
  String? guid;
  String? stokKodu;
  String? stokAdi;
  String? birim;
  String? anaGrup;
  String? altGrup;
  String? marka;
  String? reyon;
  String? kategori;
  String? renk;
  String? beden;
  String? sezon;
  String? hamMadde;
  StoklarInfo({this.guid,this.stokKodu,this.stokAdi,this.birim,this.anaGrup,this.altGrup,this.marka,this.reyon,this.kategori,this.renk,this.beden,this.sezon,this.hamMadde});
}