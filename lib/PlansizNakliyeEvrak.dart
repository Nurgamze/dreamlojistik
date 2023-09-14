
import 'package:dreamlojistik/LocalDB/EvraklarDB.dart';
import 'package:dreamlojistik/Modeller/DreamCogsGif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import 'LocalDB/DatabaseHelper.dart';
import 'Modeller/GridListeler.dart';
import 'Modeller/GridModeller.dart';
import 'Modeller/ProviderHelper.dart';
import 'Modeller/Sabitler.dart';
import 'package:provider/provider.dart';


class PlansizNakliyeEvrak extends StatefulWidget {
  int evrakId;
  String depoAdi;
  PlansizNakliyeEvrak(this.evrakId,this.depoAdi);
  @override
  _PlansizNakliyeEvrakState createState() => _PlansizNakliyeEvrakState();
}

class _PlansizNakliyeEvrakState extends State<PlansizNakliyeEvrak> {

  TextEditingController _aramaController = TextEditingController();
  TextEditingController _rafController = TextEditingController();
  TextEditingController _miktarIlkController = TextEditingController();
  TextEditingController _miktarSonController = TextEditingController();

  final DataGridController _dataGridController = DataGridController();
  final DataGridController _sayimEvrakStoklarDtaGridController = DataGridController();

  int secilenRow = -1;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  SayimDBHelper _sayimDBHelper = SayimDBHelper();

  FocusNode textFocus = new FocusNode();
  FocusNode rafFocus = new FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _plansizNakliyeEvraklariniGetir(widget.evrakId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Column(
        children: [
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width-75,
                  decoration: Sabitler.dreamBoxDecoration,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: SafeArea(
                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 0),
                        hintText:
                        'Stok arayın',
                        border: InputBorder.none,
                      ),
                      controller: _aramaController,
                      textInputAction: TextInputAction.search,
                      focusNode: textFocus,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(new FocusNode());
                        _stokAra(context);
                      },
                    ),
                  )
              ),
              SizedBox(width: 2,),
              InkWell(
                child: Container(
                    margin: EdgeInsets.symmetric(vertical: 2,horizontal: 2),
                    decoration: Sabitler.dreamBoxDecoration,
                    width: 60,
                    height: 60,
                    padding: EdgeInsets.all(5),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.camera,
                        color: Colors.blue.shade900,
                        size: 18,
                      ),
                    )),
                onTap: () {
                  scanBarcodeNormal();
                },
              ),
            ],
          ),
          SizedBox(height: 5),
          Expanded(
              flex: 10,
              child: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5)),
                        color: Colors.blue[900],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 1),
                      height: 30,
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: Text("SAYIM KALEMLERİ",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                      child: SfDataGridTheme(
                        data: SfDataGridThemeData(
                          selectionColor: Colors.yellow,
                          headerColor: Color.fromRGBO(235, 90, 12, 1),
                         /*   selectionStyle: DataGridCellStyle(
                                backgroundColor: Colors.blue,
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                )
                            ),
                            headerStyle: DataGridHeaderCellStyle(
                                sortIconColor: Colors.white,
                                textStyle:
                                TextStyle(color: Colors.white,fontSize: 12),
                                backgroundColor: Color.fromRGBO(235, 90, 12, 1))*/
                        ),
                        child: SfDataGrid(
                          selectionMode: SelectionMode.single,
                          onCellTap: (value) {
                            Future.delayed(Duration(milliseconds: 50), (){
                              FocusScope.of(context).requestFocus(new FocusNode());
                              if(value.rowColumnIndex.rowIndex >0){
                                PlansizNakliyeEvrakDataGrid evrak = _dataGridController.selectedRow as PlansizNakliyeEvrakDataGrid;
                                showDialog(
                                    context: context,
                                    barrierColor: Colors.black.withOpacity(0.5),
                                    builder: (context) => SingleChildScrollView(child: plansizNakliyeEvrakDetayDialog(evrak.stokKodu, evrak.stokAdi, evrak.birim,true,miktar: evrak.miktar,id: evrak.id)))
                                ;
                                this._dataGridController.selectedIndex = -1;
                              }
                            });
                          },
                          source: _sayimEvrakDataSource,
                          columns: <GridColumn> [
                            GridColumn(columnName: 'stokKodu',label : Container(child: Text("STOK KODU"),padding : EdgeInsets.only(left:10,right: 10), alignment : Alignment.centerLeft ,),),
                            GridColumn(columnName: 'stokAdi',label : Container(child: Text("STOK ADI"),padding : EdgeInsets.only(left:10,right: 10), alignment : Alignment.centerLeft ,),),
                            GridColumn(columnName: 'miktar',label : Container(child: Text("MİKTAR"),padding : EdgeInsets.only(left:10,right: 10), alignment : Alignment.centerLeft ,),),
                            GridColumn(columnName: 'birim',label : Container(child: Text("BİRİM"),padding : EdgeInsets.only(left:10,right: 10), alignment : Alignment.centerLeft ,),),
                          ],
                          gridLinesVisibility: GridLinesVisibility.vertical,
                          headerGridLinesVisibility: GridLinesVisibility.vertical,
                          headerRowHeight: 30,
                          allowSorting: true,
                          allowTriStateSorting: true,
                          rowHeight: 30,
                          controller: this._dataGridController,
                          /*
                          onQueryRowStyle: (QueryRowStyleArgs args) {
                            if (args.rowIndex % 2 == 0) {
                              return DataGridCellStyle(backgroundColor: Colors.white,textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                            }
                            return DataGridCellStyle(backgroundColor: Colors.grey[300],textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                          },*/
                        ),
                      ),
                    ),
                  ),
                ],
              )
          )
        ],
      ),
    );
  }

  _stokAra(BuildContext context) async {
    //kalem varsa popup göster yoksa stok seç
    String aranacakKelime = _aramaController.text.trimRight();
    var result = await _sayimDBHelper.plansizNakliyeEvrakDetayVarMi(aranacakKelime);
    print(result);
    if(result != -1){
      var stok = await _sayimDBHelper.plansizNakliyeEvrakDetayBul(result);
      showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => SingleChildScrollView(child: plansizNakliyeEvrakDetayDialog(stok[0]["stokKodu"], stok[0]["stokAdi"], stok[0]["birim"],true,miktar: stok[0]["miktar"],id: stok[0]["id"]))
      );
    }else{
      context.read<StateHelper>().setLoading(true);
      showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => plansizNakliyeEvrakStoklarDialog(aranacakKelime,context)
      );

      print("test");

      setState(() {
        _aramaController.clear();
      });
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
        _stokAra(context);
      }
    });
  }
  _stoklariGetir(String aranan,BuildContext context) async {
    var stoklarList = await _databaseHelper.sayimKalemiStoklariGetir(aranan,widget.depoAdi);
    sayimEvrakStoklarGridList.clear();
    for(var stok in stoklarList){
      sayimEvrakStoklarGridList.add(SayimEvrakStoklarDataGrid(stok["stokKodu"],stok["stokAdi"],
          stok["miktar"].toString(),stok["birim"],stok["anaGrup"],stok["altGrup"],stok["marka"],stok["reyon"],stok["aciklama"],stok["satisFiyati"].toString(),stok["paraBirimi"],stok["kisaIsmi"]));
    }
    context.read<StateHelper>().setLoading(false);
  }
  Widget plansizNakliyeEvrakStoklarDialog(String aranan,BuildContext context){
    _stoklariGetir(aranan,context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: 450,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(17),
        ),
        child: context.watch<StateHelper>().kalemPopUpLoading ? Center(child: DreamCogs(),): Column(
          children: [
            Container(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                  child: Column(
                    children: [
                      Text("STOK SEÇİNİZ",style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
              ),
            ),
            Divider(thickness: 2,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                  child: Column(
                    children: [
                      Text("Aranan stok : $aranan",style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  )
              ),
            ),
            Divider(thickness: 2,),
            Expanded(child: Container(
              child: SfDataGridTheme(
                data: SfDataGridThemeData(
                  selectionColor: Colors.yellow,
                  headerColor: Color.fromRGBO(235, 90, 12, 1),
                 /*   selectionStyle: DataGridCellStyle(
                        backgroundColor: Colors.blue,
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )
                    ),*/
                   /* headerStyle: DataGridHeaderCellStyle(
                        sortIconColor: Colors.white,
                        textStyle:
                        TextStyle(color: Colors.white,fontSize: 12),
                        backgroundColor: Color.fromRGBO(235, 90, 12, 1))*/
                ),
                child: SfDataGrid(
                  selectionMode: SelectionMode.single,
                  columnWidthMode: ColumnWidthMode.lastColumnFill,
                  allowSorting: true,
                  allowTriStateSorting: true,
                  onCellTap: (value) {
                    Future.delayed(Duration(milliseconds: 50), (){
                      FocusScope.of(context).requestFocus(new FocusNode());
                      if(value.rowColumnIndex.rowIndex >0){
                        SayimEvrakStoklarDataGrid stok = _sayimEvrakStoklarDtaGridController.selectedRow as SayimEvrakStoklarDataGrid;
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            barrierColor: Colors.black.withOpacity(0.5),
                            builder: (context) => SingleChildScrollView(child: plansizNakliyeEvrakDetayDialog(stok.stokKodu.toString(), stok.stokAdi.toString(), stok.birim.toString(),false))
                        );
                        this._sayimEvrakStoklarDtaGridController.selectedIndex = -1;
                      }
                    });
                  },
                  frozenColumnsCount: 1,
                  source: _sayimEvrakStoklarDataGridSource,
                  columns: <GridColumn> [

                    GridColumn(columnName: 'stokKodu',label : Container( child: Text("STOK KODU"), padding : EdgeInsets.only(left:10,right: 10), alignment : Alignment.centerLeft ,),),
                    GridColumn(columnName: 'stokAdi',label : Container( child: Text("STOK ADI"), padding : EdgeInsets.only(left:10,right: 10), alignment : Alignment.centerLeft ,),),
                    GridColumn(columnName: 'miktar',label : Container( child: Text("DEPODAKİ MİKTAR"), padding : EdgeInsets.only(left:10,right: 10), alignment : Alignment.centerLeft ,),),
                    GridColumn(columnName: 'marka',label : Container( child: Text("MARKA"), padding : EdgeInsets.only(left:10,right: 10), alignment : Alignment.centerLeft ,),),
                    GridColumn(columnName: 'reyon',label : Container( child: Text("REYON"), padding : EdgeInsets.only(left:10,right: 10), alignment : Alignment.centerLeft ,),),
                    GridColumn(columnName: 'birim',label : Container( child: Text("BİRİM"), padding : EdgeInsets.only(left:10,right: 10), alignment : Alignment.centerLeft ,),),
                    GridColumn(columnName: 'anaGrup',label : Container( child: Text("ANA GRUP"), padding : EdgeInsets.only(left:10,right: 10), alignment : Alignment.centerLeft ,),),
                    GridColumn(columnName: 'altGrup',label : Container( child: Text("ALT GRUP"), padding : EdgeInsets.only(left:10,right: 10), alignment : Alignment.centerLeft ,),),
                  ],
                  gridLinesVisibility: GridLinesVisibility.vertical,
                  headerGridLinesVisibility: GridLinesVisibility.vertical,
                  headerRowHeight: 30,
                  rowHeight: 30,
                  controller: this._sayimEvrakStoklarDtaGridController,
                       /*
                  onQueryRowStyle: (QueryRowStyleArgs args) {
                    if (args.rowIndex % 2 == 0) {
                      return DataGridCellStyle(backgroundColor: Colors.grey[300],textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                    }
                    return DataGridCellStyle(backgroundColor: Colors.white,textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                  },*/
                ),
              ),
            )),
            Container(height: 15,),
          ],
        ),
      ),
    );
  }

  _plansizNakliyeEvraklariniGetir(int evrakId) async {
    plansizNakliyeEvrakGridList.clear();
    var result = await _sayimDBHelper.plansizNakliyeEvrakDetayGetir(evrakId);
    for(var evrak in result){
      setState(() {
        plansizNakliyeEvrakGridList.add(PlansizNakliyeEvrakDataGrid(evrak["id"],evrak["evrakId"], evrak["miktar"], evrak["stokKodu"], evrak["stokAdi"], evrak["birim"]));
      });
    }

  }

  Widget plansizNakliyeEvrakDetayDialog(String stokKodu,String stokAdi,String birim,bool duzenleMi,{String miktar = "-1",int? id}) {
    _miktarSonController.clear();
    _miktarIlkController.clear();
    birim = birim == null ? birim = "" : birim;
    if(miktar != "-1"){
      int dot = miktar.indexOf(".");
      _miktarIlkController.text = miktar.substring(0,dot);
      _miktarSonController.text = miktar.substring(dot+1,miktar.length);
    }
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: 330,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(17),
        ),
        child: ListView(
          children: [
            Container(height: 20,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                  child: Column(
                    children: [
                      Text("Sayım Kalemi",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue.shade900)),
                    ],
                  )
              ),
            ),
            SizedBox(height: 10,),
            Divider(thickness: 2,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                  child: Row(
                    children: [
                      Expanded(child: Text("Stok Kodu",style: TextStyle(fontWeight: FontWeight.w600),textAlign: TextAlign.center,),),
                      Container(height: 20,width: 2,color: Colors.grey,),
                      Expanded(flex: 2,child: Text(stokKodu,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,),),
                    ],
                  )
              ),
            ),
            Divider(thickness: 2,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: Text("Stok Adı",style: TextStyle(fontWeight: FontWeight.w600),textAlign: TextAlign.center,),),
                      Container(height: 20,width: 2,color: Colors.grey,),
                      Expanded(flex: 2,child: Text(stokAdi,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,),),
                    ],
                  )
              ),
            ),
            Divider(thickness: 2,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                  child: Row(
                    children: [
                      Expanded(child: Text("Birim",style: TextStyle(fontWeight: FontWeight.w600),textAlign: TextAlign.center,),),
                      Container(height: 20,width: 2,color: Colors.grey,),
                      Expanded(flex: 2,child: Text(birim,style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center,),),
                    ],
                  )
              ),
            ),
            Divider(thickness: 2,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                  child: Row(
                    children: [
                      Expanded(child: Text("Miktar",style: TextStyle(fontWeight: FontWeight.w600),textAlign: TextAlign.center,),),
                      Container(height: 20,width: 2,color: Colors.grey,),
                      Expanded(flex: 2,child: Center(
                        child: Container(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                    margin: EdgeInsets.only(right: 2, left: 10,top: 0),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                    child: SafeArea(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 0),
                                          hintText:
                                          "0",
                                          hintStyle: TextStyle(color: Colors.black),
                                          border: InputBorder.none,
                                        ),
                                        controller: _miktarIlkController,
                                        textAlign: TextAlign.right,
                                        autofocus: true,
                                        keyboardType: TextInputType.number,
                                        onFieldSubmitted: (value) {
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                        },
                                      ),
                                    )
                                ),
                              ),
                              Container(child: Text(".",style: TextStyle(fontWeight: FontWeight.bold)),alignment: Alignment.bottomCenter,margin: EdgeInsets.only(top: 10),),
                              Expanded(
                                flex: 2,
                                child: Container(
                                    margin: EdgeInsets.only(right: 5, left: 0,top: 0),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)
                                    ),
                                    child: SafeArea(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 0),
                                          hintText:
                                          "00",
                                          hintStyle: TextStyle(color: Colors.black),
                                          border: InputBorder.none,
                                        ),
                                        controller: _miktarSonController,
                                        keyboardType: TextInputType.number,
                                        onFieldSubmitted: (value) {
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                        },
                                      ),
                                    )
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                    ],
                  )
              ),
            ),
            Divider(thickness: 2,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.blue.shade800)
                    ), ),

                    child: Text("İptal",style: TextStyle(color: Colors.white),),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Visibility(
                  visible: duzenleMi,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side: BorderSide(color: Colors.red)
                          ),
                        ),
                        child: Text("Sil",style: TextStyle(color: Colors.white),),
                        onPressed: () async {
                          DateTime now = DateTime.now();
                          String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
                          var result = await _sayimDBHelper.plansizNakliyeEvrakDetaySil(id!);
                          if(result == 1){
                            setState(() {
                              _plansizNakliyeEvraklariniGetir(widget.evrakId);
                            });
                          }
                          await _sayimDBHelper.sayimEvrakTarihGuncelle(formattedDate,widget.evrakId);
                          Navigator.pop(context);
                        }
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor:  Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.green)
                    ),),
                    child: Text("Kaydet",style: TextStyle(color: Colors.white),),
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
                      var raf = _rafController.text == null ? "" :  _rafController.text;
                      var miktarIlk = _miktarIlkController.text == "" ? 0 : int.parse(_miktarIlkController.text);
                      var miktarSon = _miktarSonController.text == "" ? 0 : int.parse(_miktarSonController.text);
                      if(miktarIlk == 0 && miktarSon <= 0){
                        Fluttertoast.showToast(
                            msg: 'Miktarı doğru girdinizden emim olup tekrar deneyin...',
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.red.shade600,
                            textColor: Colors.white,
                        );
                      }else{
                        if(duzenleMi){
                          var result = await _sayimDBHelper.plansizNakliyeEvrakDetayUpdate(id!, "$miktarIlk.$miktarSon");
                          if(result > 0){
                            Navigator.pop(context);
                            setState(() {
                              _plansizNakliyeEvraklariniGetir(widget.evrakId);
                            });
                          }else{
                            Fluttertoast.showToast(
                                msg: 'Kalem kaydedilirken sorun oluştu',
                                gravity:ToastGravity.CENTER,
                                backgroundColor: Colors.red.shade600,
                                textColor: Colors.white,
                            );
                          }
                        }else{
                          var result = await _sayimDBHelper.plansizNakliyeEvrakDetayEkle(stokKodu, stokAdi, widget.evrakId, "$miktarIlk.$miktarSon", birim);
                          print(result);
                          if(result > 0){
                            Navigator.pop(context);
                            setState(() {
                              _plansizNakliyeEvraklariniGetir(widget.evrakId);
                            });
                          }else{
                             Fluttertoast.showToast(
                                msg: 'Kalem kaydedilirken sorun oluştu',
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.red.shade600,
                                textColor: Colors.white,

                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

final PlansizNakliyeEvrakDataSource _sayimEvrakDataSource = PlansizNakliyeEvrakDataSource();

class PlansizNakliyeEvrakDataSource extends DataGridSource {

  PlansizNakliyeEvrakDataSource();

  @override
  List<PlansizNakliyeEvrakDataGrid> get dataSource => plansizNakliyeEvrakGridList;

  @override
  getValue(PlansizNakliyeEvrakDataGrid sayfasiDataGrid, String columnName) {
    switch (columnName) {
      case 'miktar':
        return  sayfasiDataGrid.miktar;
        break;
      case 'stokKodu':
        return  sayfasiDataGrid.stokKodu;
        break;
      case 'stokAdi':
        return  sayfasiDataGrid.stokAdi;
        break;
      case 'birim':
        return  sayfasiDataGrid.birim;
        break;
      default:
        return ' ';
        break;
    }
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    // TODO: implement buildRow
    throw UnimplementedError();
  }
}

final _SayimEvrakStoklarDataGridSource _sayimEvrakStoklarDataGridSource = _SayimEvrakStoklarDataGridSource();
class _SayimEvrakStoklarDataGridSource extends DataGridSource {

  _SayimEvrakStoklarDataGridSource();

  @override
  List<SayimEvrakStoklarDataGrid> get dataSource => sayimEvrakStoklarGridList;
  @override
  String? getValue(SayimEvrakStoklarDataGrid _sayimEvrakStoklarDataGrid, String columnName) {
    switch (columnName) {
      case 'stokKodu':
        return  _sayimEvrakStoklarDataGrid.stokKodu;
        break;
      case 'stokAdi':
        return  _sayimEvrakStoklarDataGrid.stokAdi;
        break;
      case 'fiyat':
        return  _sayimEvrakStoklarDataGrid.fiyat;
        break;
      case 'birim':
        return  _sayimEvrakStoklarDataGrid.birim;
        break;
      case 'listeAdi':
        return  _sayimEvrakStoklarDataGrid.listeAdi;
        break;
      case 'anaGrup':
        return  _sayimEvrakStoklarDataGrid.anaGrup;
        break;
      case 'altGrup':
        return  _sayimEvrakStoklarDataGrid.altGrup;
        break;
      case 'marka':
        return  _sayimEvrakStoklarDataGrid.marka;
        break;
      case 'reyon':
        return  _sayimEvrakStoklarDataGrid.reyon;
        break;
      case 'kisaIsmi':
        return  _sayimEvrakStoklarDataGrid.kisaIsmi;
        break;
      case 'paraBirimi':
        return  _sayimEvrakStoklarDataGrid.paraBirimi;
        break;
      case 'miktar':
        return  _sayimEvrakStoklarDataGrid.miktar;
        break;
      default:
        return ' ';
        break;
    }
  }
  void updateDataGridSource() {
    notifyListeners();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    // TODO: implement buildRow
    throw UnimplementedError();
  }
}

