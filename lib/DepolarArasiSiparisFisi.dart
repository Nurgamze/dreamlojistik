/*

import 'dart:convert';

import 'package:dream_lojistik/DepolarArasiSiparisFisiDetay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'LocalDB/DatabaseHelper.dart';
import 'LocalDB/EvraklarDB.dart';
import 'Modeller/Foksiyonlar.dart';
import 'Modeller/GridListeler.dart';
import 'Modeller/GridModeller.dart';
import 'Modeller/ProviderHelper.dart';
import 'Modeller/Sabitler.dart';
import 'PlansizNakliyeEvrak.dart';

class DepolarArasiSiparisFisi extends StatefulWidget {
  @override
  _DepolarArasiSiparisFisiState createState() => _DepolarArasiSiparisFisiState();
}

final DepolarArasiSiparisFisiDataGridSource _depolarArasiSiparisFisiDataGridSource = DepolarArasiSiparisFisiDataGridSource();

class _DepolarArasiSiparisFisiState extends State<DepolarArasiSiparisFisi> {

  TextEditingController _aramaController = TextEditingController();
  TextEditingController _evrakAciklamaController = TextEditingController();
  final DataGridController _dataGridController = DataGridController();
  List gidenVeriler = [];
  var uuid = Uuid();
  List file = [];
  String directory = "";
  int secilenRow = -1;
  bool loading = true;
  bool stokBulunamadi = false;
  bool aktarildiGostersinMi = false;
  String depoSecinizTitle = "DEPO SEÇİNİZ";
  DatabaseHelper _databaseHelper = DatabaseHelper();
  SayimDBHelper _sayimDBHelper = SayimDBHelper();
  var depolar = [];
  FocusNode textFocus = new FocusNode();
  FocusNode aciklamaFocus = new FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeSayimDB();
    _depolarArasiSiparisFisiGetir(false);
  }

  @override
  Widget build(BuildContext context) {
    double sWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("DEPOLAR ARASI SİPARİŞ FİŞİ"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(right: 5, left: 5,top: 5,bottom: 5),
                            decoration: Sabitler.dreamBoxDecoration,
                            padding: EdgeInsets.only(left: 10),
                            height: 60,
                            width: MediaQuery.of(context).size.width-80,
                            child: Center(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText:
                                    'Evrak ara',
                                    border: InputBorder.none,
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.cancel,color: Colors.blue.shade900,),
                                      onPressed: () {
                                        //_dataGridController.selectedRow = null;
                                        _aramaController.text = "";
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      },
                                    )),
                                controller: _aramaController,
                                textInputAction: TextInputAction.search,
                                focusNode: textFocus,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                },
                              ),
                            )
                        ),
                        InkWell(
                          child: Container(
                              height: 60,
                              width: 60,
                              margin: EdgeInsets.only(left: 3,right: 5,top: 2,bottom: 2),
                              decoration: Sabitler.dreamBoxDecoration,
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.search,
                                  color: Colors.blue.shade900,
                                  size: 18,
                                ),
                              )),
                          onTap: () async {
                            setState(() {
                              _plansizNakliyeEvrakAra(_aramaController.text);
                            });
                          },
                        ),
                      ],
                    ),
                    Container(
                      height: 45,
                      color: Colors.white,
                      child: Row(
                        children: [
                          Container(
                              height: 50,
                              margin: EdgeInsets.only(left: 10),
                              child: Center(child: Text("Gönderilenler ?"),)
                          ),
                          Container(
                            height: 50,
                            child: CupertinoSwitch(
                                value: aktarildiGostersinMi,
                                onChanged: (value) {
                                  print(value);
                                  setState(() {
                                    aktarildiGostersinMi = value;
                                    _dataGridController.selectedRows= [];
                                    secilenRow = -1;
                                    _depolarArasiSiparisFisiGetir(aktarildiGostersinMi);
                                  });
                                }),
                            margin: EdgeInsets.only(left: 20),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 14,
                        child: !loading ? Container(child: Center(child: CircularProgressIndicator(),)) :
                        Column(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                                  color: Colors.blue[900],
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 1),
                                height: 30,
                                width: MediaQuery.of(context).size.width,
                                child: Center(child: Text("EVRAKLAR",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                                child: SfDataGridTheme(
                                  data: SfDataGridThemeData(
                                      selectionStyle: DataGridCellStyle(
                                          backgroundColor: Colors.blue,
                                          textStyle: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          )
                                      ),
                                      headerStyle: DataGridHeaderCellStyle(
                                          sortIconColor: Colors.white,
                                          textStyle:
                                          TextStyle(color: Colors.white,fontSize: 12),
                                          backgroundColor: Color.fromRGBO(235, 90, 12, 1))),
                                  child: SfDataGrid(
                                    selectionMode: SelectionMode.multiple,
                                    onCellTap: (value) {
                                      Future.delayed(Duration(milliseconds: 50), (){
                                        FocusScope.of(context).requestFocus(new FocusNode());
                                        secilenRow = value.rowColumnIndex.rowIndex;
                                      });

                                    },
                                    source: _depolarArasiSiparisFisiDataGridSource,
                                    columns: <GridColumn> [
                                      GridTextColumn(mappingName: 'id',headerText : "ID",padding : EdgeInsets.only(left:10,right: 10),columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding: EdgeInsets.only(left:10,right: 10),),
                                      GridTextColumn(mappingName: 'girisDepoAdi',headerText : "GİRİŞ DEPO",padding : EdgeInsets.only(left:10,right: 10),columnWidthMode : ColumnWidthMode.lastColumnFill,minimumWidth : 120,headerPadding: EdgeInsets.only(left:10,right: 10),),
                                      GridTextColumn(mappingName: 'cikisDepoAdi',headerText : "ÇIKIŞ DEPO",padding : EdgeInsets.only(left:10,right: 10),columnWidthMode : ColumnWidthMode.lastColumnFill,minimumWidth : 140,headerPadding: EdgeInsets.only(left:10,right: 10),),
                                      GridTextColumn(mappingName: 'tarih',headerText : "TARİH",padding : EdgeInsets.only(left:10,right: 10),columnWidthMode : ColumnWidthMode.lastColumnFill,minimumWidth : 140,headerPadding: EdgeInsets.only(left:10,right: 10),),
                                    ],
                                    gridLinesVisibility: GridLinesVisibility.vertical,
                                    headerGridLinesVisibility: GridLinesVisibility.vertical,
                                    headerRowHeight: 30,
                                    rowHeight: 30,
                                    controller: this._dataGridController,
                                    onQueryRowStyle: (QueryRowStyleArgs args) {
                                      if (args.rowIndex % 2 == 0) {
                                        return DataGridCellStyle(backgroundColor: Colors.white,textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                                      }
                                      return DataGridCellStyle(backgroundColor: Colors.grey[300],textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                    )
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: Container(
                            height: 60,
                            width: sWidth/2-10,
                            margin: EdgeInsets.only(left: 5),
                            decoration: Sabitler.dreamBoxDecoration,
                            child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(FontAwesomeIcons.plus,color: Colors.blue.shade900,),
                                    SizedBox(width: 10,),
                                    Text("YENİ",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.bold),),
                                  ],
                                )
                            )
                        ),
                        onTap: () async{
                          context.read<StateHelper>().setPlansizCikis("Depo Seçiniz");
                          context.read<StateHelper>().setPlansizGiris("Depo Seçiniz");
                          _evrakAciklamaController.clear();
                          List<dynamic> depoList = [];
                          String depolarData = "";
                          depolar = await _databaseHelper.depolarGetir();
                          for(var depo in depolar){
                            depolarData += '''"${depo["depoAdi"]}",''';
                          }
                          if ((depolarData != null) && (depolarData.length > 0)) {
                            depolarData = depolarData.substring(0, depolarData.length - 1);
                          }
                          depoList = [[depolarData]];
                          showDialog(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.5),
                              builder: (context) => _yeniNakliye(context,depoList)
                          );
                        },
                      ),
                      InkWell(
                        child: Container(
                          height: 60,
                          width: sWidth/2-10,
                          margin: EdgeInsets.only(right: 5),
                          decoration: Sabitler.dreamBoxDecoration,
                          child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(FontAwesomeIcons.boxOpen,color: Colors.blue.shade900,),
                                  SizedBox(width: 10,),
                                  Text("AÇ",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.bold),),
                                ],
                              )
                          ),
                        ),
                        onTap: () {
                          if(aktarildiGostersinMi){
                            Toast.show(
                                "Gönderilen evraklar üzerinde işlem yapamazsınız.",
                                context,
                                duration: 1,
                                gravity: 3,
                                backgroundColor: Colors.red.shade600,
                                textColor: Colors.white,
                                backgroundRadius: 5
                            );
                            return ;
                          }
                          if(_dataGridController.selectedIndex<0){
                            Toast.show(
                                "Tablodan açmak istediğiniz evrağı seçiniz.",
                                context,
                                duration: 1,
                                gravity: 3,
                                backgroundColor: Colors.red.shade600,
                                textColor: Colors.white,
                                backgroundRadius: 5
                            );
                          }else{
                            int evrakIndex = _dataGridController.selectedIndex;
                            setState(() {
                              _dataGridController.selectedRows= [];
                            });
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DepolarArasiSiparisFisiDetay(depolarArasiSiparisFisiGridList[evrakIndex].id,depolarArasiSiparisFisiGridList[evrakIndex].girisDepoAdi)));
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: Container(
                            height: 60,
                            width: sWidth/2-10,
                            margin: EdgeInsets.only(left: 5),
                            decoration: Sabitler.dreamBoxDecoration,
                            child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(FontAwesomeIcons.trash,color: Colors.blue.shade900,),
                                    SizedBox(width: 10,),
                                    Text("SİL",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.bold),),
                                  ],
                                )
                            )
                        ),
                        onTap: () {
                          if(aktarildiGostersinMi){
                            Toast.show(
                                "Gönderilen evraklar üzerinde işlem yapamazsınız.",
                                context,
                                duration: 2,
                                gravity: 3,
                                backgroundColor: Colors.red.shade600,
                                textColor: Colors.white,
                                backgroundRadius: 5
                            );
                            return ;
                          }
                          if(_dataGridController.selectedIndex<0){
                            Toast.show(
                                "Tablodan silmek istediğiniz evrağı seçiniz.",
                                context,
                                duration: 1,
                                gravity: 3,
                                backgroundColor: Colors.red.shade600,
                                textColor: Colors.white,
                                backgroundRadius: 5
                            );
                          }else{
                            setState(() {
                              showDialog(context: context,builder: (context) => _silOnayDialog());
                            });
                          }
                        },
                      ),
                      InkWell(
                        child: Container(
                          height: 60,
                          width: sWidth/2-10,
                          margin: EdgeInsets.only(right: 5),
                          decoration: Sabitler.dreamBoxDecoration,
                          child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(FontAwesomeIcons.solidPaperPlane,color: Colors.blue.shade900,),
                                  SizedBox(width: 10,),
                                  Text("GÖNDER",style: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.bold),),
                                ],
                              )
                          ),
                        ),
                        onTap: () async {
                          if(aktarildiGostersinMi){
                            Toast.show(
                                "Gönderilen evrakları tekrar gönderemezsiniz. Gönderilmeyen evraklardan seçip işleme öyle devam ediniz.",
                                context,
                                duration: 2,
                                gravity: 3,
                                backgroundColor: Colors.red.shade600,
                                textColor: Colors.white,
                                backgroundRadius: 5
                            );
                            return ;
                          }
                          if(_dataGridController.selectedRows.length == 0) {
                            Toast.show(
                                "Tablodan göndermek istediğiniz evrakları seçiniz",
                                context,
                                duration: 1,
                                gravity: 3,
                                backgroundColor: Colors.red.shade600,
                                textColor: Colors.white,
                                backgroundRadius: 5
                            );
                            return;
                          }
                          showDialog(context: context,builder: (context) => _gonderOnayDialog());
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _gonderOnayDialog() {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/10),
          child: Container(
            height: 180,
            child: Column(
              children: [
                Container(
                    height: 120,
                    child: Text("Seçtiğiniz evraklar gönderilecek artık işlem yapamayacaksınız, sayımı bitirdiyseniz gönderin.\nGöndermek istediğinize emin misiniz?",style: TextStyle(color: Colors.black,fontSize: 17),maxLines: 4,textAlign: TextAlign.center,),
                    margin: EdgeInsets.only(top: 2,bottom: 5),
                    padding: EdgeInsets.only(left: 5,top: 20,bottom: 10,right: 5)
                ),
                Container(
                  padding: EdgeInsets.only(right: 10,left: 10),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: FlatButton(
                        height: 45,
                        child: Text("İptal Et",style: TextStyle(color: Colors.grey.shade200),),
                        color: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: Colors.red,)
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(child: FlatButton(
                        height: 45,
                        child: Text("Gönder",style: TextStyle(color: Colors.grey.shade200),),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: Colors.green)
                        ),
                        color: Colors.green,
                        onPressed: () async {
                          bool intVarMi = await Foksiyonlar.internetDurumu(context);
                          if(!intVarMi) return;
                          Navigator.pop(context);
                          _evrakGonder();
                        },
                      ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  _silOnayDialog() {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/10),
          child: Container(
            height: 140,
            child: Column(
              children: [
                Container(
                    height: 80,
                    child: Text("${depolarArasiSiparisFisiGridList[_dataGridController.selectedIndex].id} adlı evrağı silmek üzeresiniz!\nSilmek istediğinize emin misiniz?",style: TextStyle(color: Colors.black,fontSize: 17),maxLines: 4,textAlign: TextAlign.center,),
                    margin: EdgeInsets.only(top: 2,bottom: 5),
                    padding: EdgeInsets.only(left: 5,top: 20,bottom: 10,right: 5)
                ),
                Container(
                  padding: EdgeInsets.only(right: 10,left: 10),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: FlatButton(
                        height: 45,
                        child: Text("İptal Et",style: TextStyle(color: Colors.grey.shade200),),
                        color: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: Colors.red,)
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(child: FlatButton(
                        height: 45,
                        child: Text("Sil",style: TextStyle(color: Colors.grey.shade200),),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: Colors.green)
                        ),
                        color: Colors.green,
                        onPressed: () async {
                          var result = await _sayimDBHelper.depolarArasiSiparisFisiSil(depolarArasiSiparisFisiGridList[_dataGridController.selectedIndex ].id);
                          if(result > 0){
                            setState(() {
                              depolarArasiSiparisFisiGridList.removeAt(_dataGridController.selectedIndex );
                            });
                            Navigator.pop(context);
                          }
                        },
                      ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }


  _evrakGonder() async {
    List<int> aktarilacakEvrakIds = [];
    gidenVeriler = [];
    for(var evrak in _dataGridController.selectedRows){
      DepolarArasiSiparisFisiDataGrid eklenecekEvrak = evrak;
      var v4 = uuid.v4();
      if(eklenecekEvrak.aktarildiMi == 1) continue;
      var detaylar = await _sayimDBHelper.depolarArasiSiparisFisiDetayGetir(eklenecekEvrak.id);
      print(detaylar.length);
      if(detaylar.length == 0) {
        Toast.show(
            "${eklenecekEvrak.id} no'lu evrağın satırı bulunmamaktadır seçimden çıkarınız yada satır ekleyiniz.",
            context,
            duration: 2,
            gravity: 3,
            backgroundColor: Colors.red.shade600,
            textColor: Colors.white,
            backgroundRadius: 5
        );
        return;
      }
      aktarilacakEvrakIds.add(eklenecekEvrak.id!);   //Aktarılacak id leri api işlemi başarılı olursa aktarıldı işaretlicez.
      int i = 0;
      for(var detay in detaylar){
        DASPGonderilecekVeriModel gonderilecekVeri = DASPGonderilecekVeriModel(eklenecekEvrak.id.toString(),eklenecekEvrak.tarih,detay["stokKodu"],detay["miktar"],eklenecekEvrak.girisDepoNo.toString(),eklenecekEvrak.cikisDepoNo.toString(),eklenecekEvrak.aciklama);
        Map<String, dynamic> map = {
          'evrakId': gonderilecekVeri.evrakId,
          'tarih': gonderilecekVeri.tarih,
          'stokKodu': gonderilecekVeri.stokKodu,
          'girDepoNo': gonderilecekVeri.girDepoNo,
          'cikDepoNo': gonderilecekVeri.cikDepoNo,
          'miktar': gonderilecekVeri.miktar,
          'aciklama': gonderilecekVeri.aciklama,
          'satirNo' : "$i",
          'subeNo'  : "1",
          'evrakUid' : v4,
          'mikroUserKod' : '94'
        };
        i++;
        String rawJson = jsonEncode(map);
        gidenVeriler.add(rawJson);
      }
    }
    print(gidenVeriler.toString());
    var body = jsonEncode({
      "data": gidenVeriler.toString(),
    });
    if(gidenVeriler.isEmpty) return;
    var response = await http.post("${Sabitler.url}/api/DepolarArasiSFAktar",
        headers: {
          "apiKey": Sabitler.apiKey,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);
    print(response.statusCode);
    print(response.body);
    if(response.statusCode == 200) {
      for(var id in aktarilacakEvrakIds) {
        await _sayimDBHelper.depolarArasiSiparisFisiAktarGuncelle(id);
        await _depolarArasiSiparisFisiGetir(true);
        setState(() {
          aktarildiGostersinMi = true;
        });
      }

    }
    Toast.show(
        "Gönderme işlemi başarıyla tamamlandı.",
        context,
        duration: 1,
        gravity: 3,
        backgroundColor: Colors.green.shade600,
        textColor: Colors.white,
        backgroundRadius: 5
    );
    _dataGridController.selectedRows= [];
  }

  _depolarArasiSiparisFisiGetir(bool aktrilanlarMi) async {
    depolarArasiSiparisFisiGridList.clear();
    var result = await _sayimDBHelper.depolarArasiSiparisFisiGetir();
    print(result.length);
    for(var evrak in result){
      String tempDate = DateFormat("dd-MM-yyyy hh:mm:ss").format(DateTime.parse(evrak["tarih"]));
      if(aktrilanlarMi){
        if(evrak["aktarildiMi"] == 1){
          setState(() {
            depolarArasiSiparisFisiGridList.add(DepolarArasiSiparisFisiDataGrid(evrak["id"],evrak["cikisDepoNo"], evrak["girisDepoNo"], evrak["satir"], evrak["sira"], evrak["cikisDepoAdi"],evrak["girisDepoAdi"],tempDate,evrak["aciklama"]));
          });
        }
      }else{
        if(evrak["aktarildiMi"] == 0){
          setState(() {
            depolarArasiSiparisFisiGridList.add(DepolarArasiSiparisFisiDataGrid(evrak["id"],evrak["cikisDepoNo"], evrak["girisDepoNo"], evrak["satir"], evrak["seri"], evrak["cikisDepoAdi"],evrak["girisDepoAdi"],tempDate,evrak["aciklama"]));
          });
        }
      }
    }
  }
  _plansizNakliyeEvrakAra(String aranacakKelime) async {
    depolarArasiSiparisFisiGridList.clear();
    var result = await _sayimDBHelper.sayimEvrakAra(aranacakKelime);
    for(var evrak in result){
      if(aktarildiGostersinMi){
        if(evrak["aktarildiMi"] == 1){
          setState(() {
            depolarArasiSiparisFisiGridList.add(DepolarArasiSiparisFisiDataGrid(evrak["id"],evrak["cikisDepoNo"], evrak["girisDepoNo"], evrak["satir"], evrak["seri"], evrak["cikisDepoAdi"],evrak["girisDepoAdi"],evrak["tarih"],evrak["aciklama"]));
          });
        }
      }else{
        if(evrak["aktarildiMi"] == 0){
          setState(() {
            depolarArasiSiparisFisiGridList.add(DepolarArasiSiparisFisiDataGrid(evrak["id"],evrak["cikisDepoNo"], evrak["girisDepoNo"], evrak["satir"], evrak["seri"], evrak["cikisDepoAdi"],evrak["girisDepoAdi"],evrak["tarih"],evrak["aciklama"]));
          });
        }
      }
    }
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "İptal", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if(barcodeScanRes != "-1"){
        _aramaController.text = barcodeScanRes;
      }
    });
  }
  int cikisDepoNo;
  int girisDepoNo;
  Widget _yeniNakliye(BuildContext context,List<dynamic> depoList){
    String cikisDepo = context.watch<StateHelper>().plansizCikis;
    String girisDepo = context.watch<StateHelper>().plansizGiris;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
          height: 405,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(17),
          ),
          child: ListView(
            children: [
              Container(
                child: Center(
                  child: Text("SİPARİŞ FİŞİ OLUŞTUR",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                ),
                margin: EdgeInsets.only(top: 10),
              ),
              Container(
                height: 365,
                padding: EdgeInsets.only(top: 10,bottom: 10,right: 25,left: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width/1.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Çıkış Depo",style: TextStyle(color: Colors.black),),
                            SizedBox(height: 4,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.indigo.shade800),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              width: MediaQuery.of(context).size.width/1.1,
                              child: FlatButton(
                                child: Text(context.watch<StateHelper>().plansizCikis),
                                onPressed: () {
                                  Picker(
                                      adapter: PickerDataAdapter<String>(
                                        pickerdata: JsonDecoder().convert(depoList.toString()),
                                        isArray: true,
                                      ),
                                      hideHeader: true,
                                      height: 220,
                                      title: Text("Depo Seçiniz"),
                                      textAlign: TextAlign.center,
                                      confirmText: "Tamam",
                                      selectedTextStyle: TextStyle(color: Colors.indigo.shade800),
                                      cancel: FlatButton(onPressed: () {
                                        Navigator.pop(context);
                                      }, child: Text("İptal")),
                                      onConfirm: (Picker picker, List value) {
                                        context.read<StateHelper>().setPlansizCikis(picker.getSelectedValues().first);
                                        cikisDepo = picker.getSelectedValues().first;
                                        print(depolar[picker.selecteds[0]]);
                                        cikisDepoNo = depolar[picker.selecteds[0]]["depNo"];
                                      }
                                  ).showDialog(context);
                                },
                              ),
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 10,),
                    Container(
                        width: MediaQuery.of(context).size.width/1.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Giriş Depo",style: TextStyle(color: Colors.black),),
                            SizedBox(height: 4,),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.indigo.shade800),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              width: MediaQuery.of(context).size.width/1.1,
                              child: FlatButton(
                                child: Text(context.watch<StateHelper>().plansizGiris),
                                onPressed: () {
                                  Picker(
                                      adapter: PickerDataAdapter<String>(
                                        pickerdata: JsonDecoder().convert(depoList.toString()),
                                        isArray: true,
                                      ),
                                      hideHeader: true,
                                      height: 220,
                                      title: Text("Depo Seçiniz"),
                                      textAlign: TextAlign.center,
                                      confirmText: "Tamam",
                                      selectedTextStyle: TextStyle(color: Colors.indigo.shade800),
                                      cancel: FlatButton(onPressed: () {
                                        Navigator.pop(context);
                                      }, child: Text("İptal")),
                                      onConfirm: (Picker picker, List value) {
                                        context.read<StateHelper>().setPlansizGiris(picker.getSelectedValues().first);
                                        girisDepo = picker.getSelectedValues().first;
                                        print(depolar[picker.selecteds[0]]);
                                        girisDepoNo = depolar[picker.selecteds[0]]["depNo"];
                                      }
                                  ).showDialog(context);
                                },
                              ),
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 10,),
                    InkWell(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Açıklama",style: TextStyle(color: Colors.black),),
                            SizedBox(height: 4,),
                            Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.indigo.shade800),
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                padding: EdgeInsets.only(left: 10),
                                height: 100,
                                width: MediaQuery.of(context).size.width/1.1,
                                child: Center(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText:
                                      'Açıklama',
                                      border: InputBorder.none,
                                    ),
                                    maxLength: 250,
                                    maxLines: 3,
                                    controller: _evrakAciklamaController,
                                    textInputAction: TextInputAction.search,
                                    focusNode: aciklamaFocus,
                                    onFieldSubmitted: (value) {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                    },
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                      onTap: () => FocusScope.of(context).requestFocus(aciklamaFocus),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(child: FlatButton(
                          height: 45,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side: BorderSide(color: Colors.red)
                          ),
                          color: Colors.red,
                          child: Text("İptal",style: TextStyle(color: Colors.white),),
                          onPressed: () => Navigator.pop(context),
                        ),),
                        SizedBox(width: 2),
                        Expanded(child: FlatButton(
                          height: 45,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side: BorderSide(color: Colors.green)
                          ),
                          color: Colors.green,
                          child: Text("Oluştur",style: TextStyle(color: Colors.white),),
                          onPressed: () async {
                            if(cikisDepo == "Depo Seçiniz"  || girisDepo == "Depo Seçiniz"){
                              Toast.show(
                                  "Evrak oluşturabilmek için çıkış ve giriş depolarını seçmeniz gerekmektedir",
                                  context,
                                  duration: 1,
                                  gravity: 3,
                                  backgroundColor: Colors.red.shade600,
                                  textColor: Colors.white,
                                  backgroundRadius: 5
                              );
                            }else{
                              DateTime now = DateTime.now();
                              String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
                              int result = await _sayimDBHelper.depolarArasiSiparisFisiEkle(cikisDepoNo, girisDepoNo, cikisDepo,girisDepo ,_evrakAciklamaController.text);
                              if(result > 0) {
                                setState(() {
                                  _depolarArasiSiparisFisiGetir(aktarildiGostersinMi);
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => DepolarArasiSiparisFisiDetay(result,cikisDepo)));
                                });
                              }else if(result == -1){
                                Toast.show(
                                    "Seçtiğiniz depoda bu evrak zaten var tablodan evrağı açıp işleme devam edebilirsiniz.",
                                    context,
                                    duration: 2,
                                    gravity: 3,
                                    backgroundColor: Colors.red.shade600,
                                    textColor: Colors.white,
                                    backgroundRadius: 5
                                );
                              }else{
                                Toast.show(
                                    "Evrak oluşturulamadı.",
                                    context,
                                    duration: 1,
                                    gravity: 3,
                                    backgroundColor: Colors.red.shade600,
                                    textColor: Colors.white,
                                    backgroundRadius: 5
                                );
                              }
                            }
                          },
                        ),)
                      ],
                    )
                  ],
                ),
              ),

            ],
          )
      ),
    );
  }

  _initializeSayimDB() async {
    _sayimDBHelper.initializeDatabase().then((value) {
    });
  }
}
class DepolarArasiSiparisFisiDataGridSource extends DataGridSource<DepolarArasiSiparisFisiDataGrid> {

  DepolarArasiSiparisFisiDataGridSource();

  @override
  List<DepolarArasiSiparisFisiDataGrid> get dataSource => depolarArasiSiparisFisiGridList;

  @override
  getValue(DepolarArasiSiparisFisiDataGrid DepolarArasiSiparisFisiDataGrid, String columnName) {
    switch (columnName) {
      case 'id':
        return  DepolarArasiSiparisFisiDataGrid.id;
        break;
      case 'girisDepoAdi':
        return  DepolarArasiSiparisFisiDataGrid.girisDepoAdi;
        break;
      case 'cikisDepoAdi':
        return  DepolarArasiSiparisFisiDataGrid.cikisDepoAdi;
        break;
      case 'tarih':
        return  DepolarArasiSiparisFisiDataGrid.tarih;
        break;
      default:
        return ' ';
        break;
    }
  }
  void updateDataGridSource() {
    notifyListeners();
  }
}

class DASPGonderilecekVeriModel{
  String evrakId;
  String tarih;
  String girDepoNo;
  String cikDepoNo;
  String stokKodu;
  String miktar;
  String aciklama;

  DASPGonderilecekVeriModel(this.evrakId,this.tarih,this.stokKodu,this.miktar,this.girDepoNo,this.cikDepoNo,this.aciklama);
}

 */