import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import '../Modeller/GridModeller.dart';


class DatabaseHelper {

  static Database? _database;
  static DatabaseHelper? _databaseHelper;

  DatabaseHelper._createInstance();
  factory DatabaseHelper() {
    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }
  Future<Database> initializeDatabase() async {
    var dir = await getApplicationDocumentsDirectory();

    var path  = join(dir.path,"flutter.db");
    var database = await openDatabase(
        path,
        version: 3,
    );
    Sqflite.setLockWarningInfo(duration: Duration(seconds: 25),callback: (){});
    return database;
  }
  
  Future<List> aramaYap(String arananKelime) async {
    arananKelime = arananKelime.replaceAll("'", "''").replaceAll("*", "%").toLowerCase();
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT 
    stokKodu, 
    stokAdi,
    BarkodTanimlari.barKodu, 
    birim, 
    anaGrup, 
    altGrup, 
    marka,                         
    reyon, 
    renk, 
    beden, 
    sezon, 
    hamMadde, 
    kategori
    FROM Stoklar 
	LEFT OUTER JOIN
	   BarkodTanimlari On BarkodTanimlari.barStokKodu = Stoklar.stokKodu
			where Stoklar.arama like '%$arananKelime%' OR barKodu = '$arananKelime'
    ''');

    return data;
  }

  Future<List> sayimKalemiStoklariGetir(String arananKelime,String depoAdi) async {
    Sqflite.setLockWarningInfo(duration: Duration(milliseconds: 1),callback: (){print("dsa");});
    arananKelime = arananKelime.replaceAll("'", "''").replaceAll("*", "%").toLowerCase();
    var db = await this.database;
    var data = await db.rawQuery('''
   SELECT distinct
    Stoklar.stokKodu, 
    stokAdi,
    birim, 
    anaGrup, 
    altGrup,
    marka,                         
    reyon,
    miktar
    FROM Stoklar 
    LEFT OUTER JOIN
       DeponunStoklari ON Stoklar.stokKodu = DeponunStoklari.stokKodu AND DeponunStoklari.depoAdi = '$depoAdi'
	LEFT OUTER JOIN
	   BarkodTanimlari On BarkodTanimlari.barStokKodu = Stoklar.stokKodu
			where Stoklar.arama like '%$arananKelime%' OR barKodu = '$arananKelime'
    ''',);
  print(arananKelime);
    return data;
  }

  Future<List<AlternatiflerGrid>> alternatifleriGetir(String stokKodu) async {
    var db = await this.database;
    List<AlternatiflerGrid> alternatiflerGridList = [];
    var data = await db.rawQuery('''
    SELECT 
    guid,
    alternatifKod
    FROM StokAlternatifleri Where stokKodu = '$stokKodu'
    ''');
    if(data.isEmpty){
      print("data empty");
      return [];
    }else{
      for(Map guid in data){
        var alternatifStoklarGuid = await db.rawQuery('''
      SELECT guid 
       From Stoklar Where stokKodu = '${guid["alternatifKod"]}'
      ''');

        if(alternatifStoklarGuid.length ==0){
          alternatiflerGridList.add(AlternatiflerGrid(guid["alternatifKod"],"TANIMSIZ","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",));
        }else{
          var alternatifList = await db.rawQuery('''
      SELECT 
      (select stokAdi from Stoklar WHERE stokKodu =  '${guid["alternatifKod"]}') stokAdi, *
       From StoklarUser Where guid = '${alternatifStoklarGuid[0]["guid"]}'
      ''') as Map;
          alternatiflerGridList.add(AlternatiflerGrid(guid["alternatifKod"],alternatifList[0]["stokAdi"],alternatifList[0]["urunTipi"],alternatifList[0]["ipRate"],alternatifList[0]["marka"],alternatifList[0]["kasaTipi"],
              alternatifList[0]["tip"],alternatifList[0]["ekOzellik"],alternatifList[0]["sinif"],alternatifList[0]["renk"],alternatifList[0]["levin"],alternatifList[0]["ledSayisi"],
              alternatifList[0]["lens"],alternatifList[0]["guc"],alternatifList[0]["volt"],alternatifList[0]["akim"],alternatifList[0]["ebat"],alternatifList[0]["kilo"],alternatifList[0]["recete1"],
              alternatifList[0]["koli"],alternatifList[0]["yeniAlan13"],alternatifList[0]["recete2"],alternatifList[0]["ongoruMasraf"] != null ? alternatifList[0]["ongoruMasraf"].toString() : "TANIMSIZ",alternatifList[0]["marka2"],alternatifList[0]["kilif"],alternatifList[0]["kelvin"],
              alternatifList[0]["vfBin"],alternatifList[0]["renkBin"],alternatifList[0]["lumenBin"],alternatifList[0]["satisPotansiyeli"],alternatifList[0]["aileKutugu"],alternatifList[0]["garantiSuresi"],alternatifList[0]["binKodu"]));
        }
      }

      return alternatiflerGridList;
    }
  }

  Future<List> stokDetayAra(String stokKodu) async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT 
    depoAdi,
    miktar
    FROM DeponunStoklari Where stokKodu = '$stokKodu'
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }
  Future<List> satisFiyatiAra(String stokKodu) async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT 
    aciklama,
    satisFiyati,
    paraBirimi
    FROM StokSatisFiyatListesi Where stokKodu = '$stokKodu'
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }

  Future<List> depolarGetir() async {
    var db = await this.database;
    var data = await db.rawQuery('''
    SELECT 
    depNo,
    depoAdi
    FROM Depolar order by depoAdi
    ''');
    if(data.isEmpty){
      return [];
    }else{
      return data;
    }
  }

}
