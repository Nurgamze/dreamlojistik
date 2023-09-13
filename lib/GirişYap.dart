import 'package:dreamlojistik/AnaEkran.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';


class GirisYap extends StatefulWidget {
  @override
  _GirisYapState createState() => _GirisYapState();
}

class _GirisYapState extends State<GirisYap> {

  TextEditingController _kullaniciAdiController = new TextEditingController();
  TextEditingController _sifreController = new TextEditingController();
  FocusNode passFocusNode = FocusNode();
  bool passwordVisible = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getShared();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 65,),
          Image(image: AssetImage('assets/images/dream_lojistik.png',),height: 200,),
          SizedBox(height: 50,),
          Container(
              height: MediaQuery.of(context).size.height/15,
              padding: EdgeInsets.symmetric(horizontal: 25,vertical: 0),
              margin: EdgeInsets.symmetric(horizontal: 30.0,),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade900,width: 2)
              ),
              child: Center(
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress ,
                  controller: _kullaniciAdiController,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: "Kullanıcı adı",
                    hintStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(passFocusNode);
                  },
                ),
              )
          ),
          SizedBox(height: 15,),
          Container(
              height: MediaQuery.of(context).size.height/15,
              padding: EdgeInsets.symmetric(horizontal: 25,vertical: 0),
              margin: EdgeInsets.symmetric(horizontal: 30.0,),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade900,width: 2)
              ),
              child: Center(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _sifreController,
                  obscureText: passwordVisible,
                  focusNode: passFocusNode,
                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Şifre',
                    hintStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey),
                    // Here is key idea
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
                          passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.blue.shade900
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                  onFieldSubmitted: (value) async {

                  },
                ),
              )
          ),
          SizedBox(height: 30,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: InkWell(
              child: Container(
                height: MediaQuery.of(context).size.height/15,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade900),
                    color: Colors.blue.shade900
                ),
                child: Center(
                  child: Text("Giriş Yap",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700),),
                ),
              ),
              onTap: () async {
                if(_kullaniciAdiController.text == "dreamwms" && _sifreController.text == "Wms12Dream"){

                  var pref = await SharedPreferences.getInstance();
                  pref.setString("name", "dreamwms");
                  pref.setString("pass", "Wms12Dream");
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AnaEkran()),
                        (Route<dynamic> route) => false,
                  );
                }else{
                  Fluttertoast.showToast(
                      msg:"Kullanıcı adı veya şifre yanlış",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      textColor: Colors.white,
                      backgroundColor: Colors.red.shade600,
                      fontSize: 16.0
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  void _getShared() async  {
    var pref = await SharedPreferences.getInstance();
    var name = pref.get("name");
    var pass = pref.get("pass");

    if(name != null){
      _kullaniciAdiController.text = name.toString();
      _sifreController.text = pass.toString();
    }
    setState(() {});
  }
}
