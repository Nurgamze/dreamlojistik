/*

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:toast/toast.dart';
import 'DepolarArasiSiparisFisi.dart';
import 'LocalDB/DatabaseHelper.dart';
import 'Modeller/GridListeler.dart';
import 'Modeller/GridModeller.dart';
import 'Modeller/Sabitler.dart';
import 'Sayim/SayimModuluSayfasi.dart';



class AnaEkranYdk extends StatefulWidget {
  @override
  _AnaEkranYdkState createState() => _AnaEkranYdkState();
}

final _StoklarDataGridSource _stoklarDataGridSource = _StoklarDataGridSource();
final StokDetayPopUpDataSource _stokDetayPopUpDataSource = StokDetayPopUpDataSource();
final StokFiyatPopUpDataSource _stokFiyatPopUpDataSource = StokFiyatPopUpDataSource();
final AlternatiflerDataGridSoruce _alternatiflerDataGridSoruce = AlternatiflerDataGridSoruce();

class _AnaEkranYdkState extends State<AnaEkranYdk> {

  TextEditingController _aramaController = TextEditingController();
  final DataGridController _dataGridController = DataGridController();
  final DataGridController _stokFiyatGridController = DataGridController();
  final DataGridController _stokMiktarGridConroller = DataGridController();
  final DataGridController _alternatiflerGridController = DataGridController();

  int secilenRow = -1;
  bool loading = true;
  bool stokBulunamadi = false;
  DataGridModel stok;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  FocusNode textFocus = new FocusNode();


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Container(
          child: Image(image: AssetImage("assets/images/appbar_title.png"),width: 120),
        ),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        padding: EdgeInsets.only(left: 5),
                        height: 60,
                        width: screenWidth - 70,
                        decoration: Sabitler.dreamBoxDecoration,
                        child: Center(
                          child: TextFormField(
                            decoration: InputDecoration(
                                hintText:
                                'Stok arayın',
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
                              _aramaYap(_aramaController.text);
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                          ),
                        )
                    ),
                    InkWell(
                      child: Container(
                          height: 60,
                          width : 60,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          decoration: Sabitler.dreamBoxDecoration,
                          padding: EdgeInsets.all(5),
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.camera,
                              color: Colors.blue.shade900,
                              size: 18,
                            ),
                          )),
                      onTap: () async {
                        scanBarcodeNormal();
                      },
                    ),
                  ],
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
                            child: Center(child: Text("STOKLAR",style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold))),)
                        ),
                        Expanded(
                          child: stokBulunamadi ? Container(
                            child: Center(
                              child: Text("Aradığınız ürün stoklarda bulunamadı."),
                            ),
                          ):
                          Container(
                            padding: EdgeInsets.only(bottom: 1,left: 1,right: 1),
                            child: SfDataGridTheme(
                              data: SfDataGridThemeData(
                                  selectionStyle: DataGridCellStyle(
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
                                      backgroundColor: Color.fromRGBO(235, 90, 12, 1))),
                              child: SfDataGrid(
                                selectionMode: SelectionMode.single,
                                frozenColumnsCount: 1,
                                columnWidthMode: ColumnWidthMode.lastColumnFill,
                                allowSorting: true,
                                allowTriStateSorting: true,
                                onCellTap: (value) {
                                  Future.delayed(Duration(milliseconds: 50), (){
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                    secilenRow = value.rowColumnIndex.rowIndex;
                                    stok = _dataGridController.selectedRow;
                                  }
                                  );
                                },
                                source: _stoklarDataGridSource,
                                columns: <GridColumn> [
                                  GridTextColumn(mappingName: 'stokKodu', headerText : "STOK KODU", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding : EdgeInsets.only(left:10,right: 10)),
                                  GridTextColumn(mappingName: 'stokAdi', headerText : "STOK ADI", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill, minimumWidth:250,headerPadding : EdgeInsets.only(left:10,right: 10)),
                                  GridTextColumn(mappingName: 'barKodu', headerText : "BARKODU", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding : EdgeInsets.only(left:10,right: 10)),
                                  GridTextColumn(mappingName: 'birim', headerText : "BİRİM", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding : EdgeInsets.only(left:10,right: 10)),
                                  GridTextColumn(mappingName: 'anaGrup', headerText : "ANA GRUP", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding : EdgeInsets.only(left:10,right: 10)),
                                  GridTextColumn(mappingName: 'altGrup', headerText : "ALT GRUP", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding : EdgeInsets.only(left:10,right: 10)),
                                  GridTextColumn(mappingName: 'marka', headerText : "MARKA", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding : EdgeInsets.only(left:10,right: 10)),
                                  GridTextColumn(mappingName: 'reyon', headerText : "REYON", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding : EdgeInsets.only(left:10,right: 10)),
                                  GridTextColumn(mappingName: 'renk', headerText : "RENK", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding : EdgeInsets.only(left:10,right: 10)),
                                  GridTextColumn(mappingName: 'beden', headerText : "BEDEN", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding : EdgeInsets.only(left:10,right: 10)),
                                  GridTextColumn(mappingName: 'sezon', headerText : "SEZON", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding : EdgeInsets.only(left:10,right: 10)),
                                  GridTextColumn(mappingName: 'hamMadde', headerText : "HAMMADDE", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding : EdgeInsets.only(left:10,right: 10)),
                                  GridTextColumn(mappingName: 'kategori', headerText : "KATEGORİ", padding : EdgeInsets.only(left:10,right: 10), columnWidthMode : ColumnWidthMode.lastColumnFill,headerPadding : EdgeInsets.only(left:10,right: 10)),
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
                                  return DataGridCellStyle(backgroundColor: Colors.grey.shade300,textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ),
                Container(color: Colors.blue.shade900,height: 2,),
                SizedBox(height: 3,)
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 2),
            color: Colors.white,
            height: 55,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Container(
                          height: 50,
                          width: screenWidth/2-4,
                          decoration: Sabitler.dreamBoxDecoration,
                          child: Center(
                            child: Text("STOK DETAYI",style: TextStyle(color: Colors.green.shade900,fontWeight: FontWeight.bold),),
                          )
                      ),
                      onTap: () async{
                        if(secilenRow > 0){
                          popUpMiktarGridList.clear();
                          popUpFiyatGridList.clear();
                          _databaseHelper.initializeDatabase().then((value) {
                            print(value);
                          });
                          var dataList = await _databaseHelper.stokDetayAra(stok.stokKodu);
                          var stokFiyatList = await _databaseHelper.satisFiyatiAra(stok.stokKodu);
                          for(var data in dataList){
                            popUpMiktarGridList.add(StokMiktarPopUpGrid(data["depoAdi"], data["miktar"]));
                          }
                          for(var data in stokFiyatList){
                            popUpFiyatGridList.add(StokFiyatPopUpGrid(data["aciklama"], data["satisFiyati"].toString() + " " + data["paraBirimi"]));
                          }
                          showDialog(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.5),
                              builder: (context) => stokDetayDialog()
                          );
                        }else{
                          Toast.show(
                              "Detayını görmek istediğiniz stoğu tablodan seçmeniz gerekmektedir.",
                              context,
                              duration: 2,
                              gravity: 3,
                              backgroundColor: Colors.red.shade600,
                              textColor: Colors.white,
                              backgroundRadius: 5
                          );
                        }

                      },
                    ),
                    SizedBox(width: 3,),
                    InkWell(
                      child: Container(
                        height: 50,
                        width: screenWidth/2-4,
                        decoration: Sabitler.dreamBoxDecoration,
                        child: Center(
                          child: Text("ALTERNATİF STOKLAR",style: TextStyle(color: Colors.green.shade900,fontWeight: FontWeight.bold),),
                        ),
                      ),
                      onTap: () {
                        if(secilenRow > 0){
                          _alternatifStoklarGetir(stok.stokKodu);
                        }else{
                          Toast.show(
                              "Alternatiflerini görmek istediğiniz stoğu tablodan seçmeniz gerekmektedir.",
                              context,
                              duration: 2,
                              gravity: 3,
                              backgroundColor: Colors.red.shade600,
                              textColor: Colors.white,
                              backgroundRadius: 5
                          );
                        }
                      },
                    )
                  ],
                ),
                SizedBox(height: 5,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget stokDetayDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: EdgeInsets.symmetric(vertical: 24,horizontal: 5),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(17),
        ),
        child: DefaultTabController(
          length: 2,
          initialIndex: 0,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey))
                ),
                child: TabBar(tabs: [
                  Tab(
                    child: Text("Miktar",style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Tab(
                    child: Text("Fiyat",style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],labelColor: Colors.blue.shade900,unselectedLabelColor: Colors.grey,
                ),
              ),
              Expanded(child: Container(
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        Container(height: 20,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Center(
                              child: Column(
                                children: [
                                  Text(stok.stokAdi,style: GoogleFonts.roboto(fontWeight: FontWeight.bold),maxLines: 2,textAlign: TextAlign.center,),
                                  Text("(${stok.stokKodu})",style: TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              )
                          ),
                        ),
                        SizedBox(height: 10,),
                        Divider(thickness: 2,),
                        Expanded(child: Container(
                          height: 245,
                          child: SfDataGridTheme(
                            data: SfDataGridThemeData(
                                selectionStyle: DataGridCellStyle(
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
                                    backgroundColor: Color.fromRGBO(235, 90, 12, 1))),
                            child: SfDataGrid(
                              selectionMode: SelectionMode.none,
                              columnWidthMode: ColumnWidthMode.lastColumnFill,
                              source: _stokDetayPopUpDataSource,
                              columns: <GridColumn> [
                                GridTextColumn(mappingName: 'depoAdi', headerText : "DEPO ADI", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                                GridNumericColumn(mappingName: 'miktar', headerText : "MİKTAR", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                              ],
                              gridLinesVisibility: GridLinesVisibility.vertical,
                              headerGridLinesVisibility: GridLinesVisibility.vertical,
                              headerRowHeight: 30,
                              rowHeight: 30,
                              controller: this._stokMiktarGridConroller,
                              onQueryRowStyle: (QueryRowStyleArgs args) {
                                if (args.rowIndex % 2 == 0) {
                                  return DataGridCellStyle(backgroundColor: Colors.grey[300],textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                                }
                                return DataGridCellStyle(backgroundColor: Colors.white,textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                              },
                              onCellTap: (value) {
                                Future.delayed(Duration(milliseconds: 50), (){
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                }
                                );
                              },
                            ),
                          ),
                        ),),
                        SizedBox(height: 10,),
                      ],
                    ),
                    Column(
                      children: [
                        Container(height: 20,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Center(
                              child: Column(
                                children: [
                                  Text(stok.stokAdi,style: GoogleFonts.roboto(fontWeight: FontWeight.bold),maxLines: 2,textAlign: TextAlign.center,),
                                  Text("(${stok.stokKodu})",style: TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              )
                          ),
                        ),
                        SizedBox(height: 10,),
                        Divider(thickness: 1,),
                        Expanded(child: Container(
                          height: 245,
                          child: SfDataGridTheme(
                            data: SfDataGridThemeData(
                                selectionStyle: DataGridCellStyle(
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
                                    backgroundColor: Color.fromRGBO(235, 90, 12, 1))),
                            child: SfDataGrid(
                              selectionMode: SelectionMode.none,
                              columnWidthMode: ColumnWidthMode.lastColumnFill,
                              source: _stokFiyatPopUpDataSource,
                              columns: <GridColumn> [
                                GridTextColumn(mappingName: 'aciklama', headerText : "AÇIKLAMA", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                                GridNumericColumn(mappingName: 'fiyat', headerText : "SATIŞ FİYATI", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                              ],
                              gridLinesVisibility: GridLinesVisibility.vertical,
                              headerGridLinesVisibility: GridLinesVisibility.vertical,
                              headerRowHeight: 30,
                              rowHeight: 30,
                              controller: this._stokFiyatGridController,
                              onQueryRowStyle: (QueryRowStyleArgs args) {
                                if (args.rowIndex % 2 == 0) {
                                  return DataGridCellStyle(backgroundColor: Colors.grey[300],textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                                }
                                return DataGridCellStyle(backgroundColor: Colors.white,textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                              },
                              onCellTap: (value) {
                                Future.delayed(Duration(milliseconds: 50), (){
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                }
                                );
                              },
                            ),
                          ),
                        ),)
                      ],
                    ),
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
  Widget alternetiflerDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: EdgeInsets.symmetric(vertical: 24,horizontal: 5),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          children: [
            Container(height: 20,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                  child: Column(
                    children: [
                      Text(stok.stokAdi,style: GoogleFonts.roboto(fontWeight: FontWeight.bold),maxLines: 2,textAlign: TextAlign.center,),
                      Text("Alternatifler(${stok.stokKodu})",style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  )
              ),
            ),
            SizedBox(height: 10,),
            Divider(thickness: 2,),
            Expanded(child: Container(
              height: 245,
              child: SfDataGridTheme(
                data: SfDataGridThemeData(
                    selectionStyle: DataGridCellStyle(
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
                        backgroundColor: Color.fromRGBO(235, 90, 12, 1))),
                child: SfDataGrid(
                  selectionMode: SelectionMode.none,
                  columnWidthMode: ColumnWidthMode.lastColumnFill,
                  allowSorting: true,
                  source: _alternatiflerDataGridSoruce,
                  columns: <GridColumn> [
                    GridTextColumn(mappingName: 'stokKodu', headerText : "STOK KODU", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'stokAdi', headerText : "STOK ADI", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'urunTipi', headerText : "ÜRÜN TİPİ", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'ipRate', headerText : "IP Rate", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'marka', headerText : "MARKA", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'kasaTipi', headerText : "KASA TİPİ", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'tip', headerText : "TİP", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'ekOzellik', headerText : "EK ÖZELLİK", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'sinif', headerText : "SINIFI", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'renk', headerText : "RENK", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'ledSayisi', headerText : "LED SAYISI", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'volt', headerText : "VOLT", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'guc', headerText : "GÜÇ", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'kelvin', headerText : "KELVİN", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'akim', headerText : "AKIM", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'lens', headerText : "LENS", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'garantiSuresi', headerText : "GARANTİ SÜRESİ", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'satisPotansiyeli', headerText : "SATIŞ POTANSİYELİ", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),
                    GridTextColumn(mappingName: 'aileKutugu', headerText : "AİLE KÜTÜĞÜ", padding : EdgeInsets.only(left:10,right: 10), headerPadding : EdgeInsets.only(left:10,right: 10)),

                  ],
                  gridLinesVisibility: GridLinesVisibility.vertical,
                  headerGridLinesVisibility: GridLinesVisibility.vertical,
                  headerRowHeight: 30,
                  rowHeight: 30,
                  controller: this._alternatiflerGridController,
                  onQueryRowStyle: (QueryRowStyleArgs args) {
                    if (args.rowIndex % 2 == 0) {
                      return DataGridCellStyle(backgroundColor: Colors.grey[300],textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                    }
                    return DataGridCellStyle(backgroundColor: Colors.white,textStyle: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w500));
                  },
                  onCellTap: (value) {
                    Future.delayed(Duration(milliseconds: 50), (){
                      FocusScope.of(context).requestFocus(new FocusNode());
                    }
                    );
                  },
                ),
              ),
            ),),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }

  _aramaYap(String aranacakKelime) async {
    aranacakKelime = aranacakKelime.trimRight();
    _databaseHelper.initializeDatabase().then((value) {
      print(value);

    });
    dataGridList.clear();
    var result = await _databaseHelper.aramaYap(aranacakKelime);
    print("arama result lennt :  ${result.length}");
    for(var data in result){
      dataGridList.add(DataGridModel(data["stokKodu"], data["stokAdi"], data["barKodu"], data["birim"], data["anaGrup"],
          data["altGrup"], data["marka"], data["reyon"], data["renk"], data["beden"], data["sezon"], data["hamMadde"], data["kategori"]));
    }
    if(dataGridList.length <= 0){
      setState(() {
        stokBulunamadi = true;
      });
    }else{
      stokBulunamadi = false;
    }
    setState(() {
      _stoklarDataGridSource.updateDataGridSource();
    });

  }
  _alternatifStoklarGetir(String aranacakKelime) async {

    _databaseHelper.initializeDatabase().then((value) {
      print(value);

    });
    alternatiflerPopUpGridList.clear();
    alternatiflerPopUpGridList = await _databaseHelper.alternatifleriGetir(aranacakKelime);
    if(alternatiflerPopUpGridList.length <= 0){
      Toast.show(
          "Bu stoğun alternatifi bulunmamaktadır.",
          context,
          duration: 1,
          gravity: 3,
          backgroundColor: Colors.red.shade600,
          textColor: Colors.white,
          backgroundRadius: 5
      );
    }else{
      showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => alternetiflerDialog()
      );
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
        _aramaYap(_aramaController.text);
      }
    });
  }



}

class _StoklarDataGridSource extends DataGridSource<DataGridModel> {

  _StoklarDataGridSource();

  @override
  List<DataGridModel> get dataSource => dataGridList;
  @override
  Object getValue(DataGridModel _dataGridModel, String columnName) {
    switch (columnName) {
      case 'stokKodu':
        return  _dataGridModel.stokKodu;
        break;
      case 'stokAdi':
        return  _dataGridModel.stokAdi;
        break;
      case 'barKodu':
        return  _dataGridModel.barKodu;
        break;
      case 'birim':
        return  _dataGridModel.birim;
        break;
      case 'anaGrup':
        return  _dataGridModel.anaGrup;
        break;
      case 'altGrup':
        return  _dataGridModel.altGrup;
        break;
      case 'marka':
        return  _dataGridModel.marka;
        break;
      case 'reyon':
        return  _dataGridModel.reyon;
        break;
      case 'renk':
        return  _dataGridModel.renk;
        break;
      case 'beden':
        return  _dataGridModel.beden;
        break;
      case 'sezon':
        return  _dataGridModel.sezon;
        break;
      case 'hamMadde':
        return  _dataGridModel.hamMadde;
        break;
      case 'kategori':
        return  _dataGridModel.kategori;
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

class AlternatiflerDataGridSoruce extends DataGridSource {

  @override
  List<AlternatiflerGrid> get dataSource => alternatiflerPopUpGridList;

  @override
  getCellValue(int rowIndex, String columnName) {
    switch (columnName) {
      case 'stokKodu':
        return  alternatiflerPopUpGridList[rowIndex].kodu;
        break;
      case 'stokAdi':
        return  alternatiflerPopUpGridList[rowIndex].stokAdi;
        break;
      case 'urunTipi':
        return  alternatiflerPopUpGridList[rowIndex].urunTipi;
        break;
      case 'ipRate':
        return  alternatiflerPopUpGridList[rowIndex].ipRate;
        break;
      case 'marka':
        return  alternatiflerPopUpGridList[rowIndex].marka;
        break;
      case 'kasaTipi':
        return  alternatiflerPopUpGridList[rowIndex].kasaTipi;
        break;
      case 'tip':
        return  alternatiflerPopUpGridList[rowIndex].tip;
        break;
      case 'ekOzellik':
        return  alternatiflerPopUpGridList[rowIndex].ekOzellik;
        break;
      case 'sinif':
        return  alternatiflerPopUpGridList[rowIndex].sinif;
        break;
      case 'renk':
        return  alternatiflerPopUpGridList[rowIndex].renk;
        break;
      case 'ledSayisi':
        return  alternatiflerPopUpGridList[rowIndex].ledSayisi;
        break;
      case 'volt':
        return  alternatiflerPopUpGridList[rowIndex].volt;
        break;
      case 'guc':
        return  alternatiflerPopUpGridList[rowIndex].guc;
        break;
      case 'kelvin':
        return  alternatiflerPopUpGridList[rowIndex].kelvin;
        break;
      case 'akim':
        return  alternatiflerPopUpGridList[rowIndex].akim;
        break;
      case 'lens':
        return  alternatiflerPopUpGridList[rowIndex].lens;
        break;
      case 'garantiSuresi':
        return  alternatiflerPopUpGridList[rowIndex].garantiSuresi;
        break;
      case 'satisPotansiyeli':
        return  alternatiflerPopUpGridList[rowIndex].satisPotansiyeli;
        break;
      case 'aileKutugu':
        return  alternatiflerPopUpGridList[rowIndex].aileKutugu;
        break;
      default:
        return ' ';
        break;
    }
  }
}


class StokDetayPopUpDataSource extends DataGridSource {
  @override
  List<StokMiktarPopUpGrid> get dataSource => popUpMiktarGridList;

  @override
  getCellValue(int rowIndex, String columnName) {
    switch (columnName) {
      case 'depoAdi':
        return  popUpMiktarGridList[rowIndex].depoAdi;
        break;
      case 'miktar':
        return  popUpMiktarGridList[rowIndex].miktar;
        break;
      default:
        return ' ';
        break;
    }
  }
}
class StokFiyatPopUpDataSource extends DataGridSource {
  @override
  List<StokFiyatPopUpGrid> get dataSource => popUpFiyatGridList;

  @override
  getCellValue(int rowIndex, String columnName) {
    switch (columnName) {
      case 'aciklama':
        return  popUpFiyatGridList[rowIndex].aciklama;
        break;
      case 'fiyat':
        return  popUpFiyatGridList[rowIndex].fiyat;
        break;
      default:
        return ' ';
        break;
    }
  }
}

 */