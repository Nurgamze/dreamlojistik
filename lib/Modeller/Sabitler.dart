import 'package:flutter/material.dart';

class Sabitler {
  static String url = "http://api.sds.com.tr";
  static String apiKey =
      "l75pq03ejewq1qdkap1e19u9jwdk2qdm5dAsd321CnsfWWlosmCs123y";

  static BoxDecoration dreamBoxDecoration =BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade500.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 3,
          offset: Offset(0, 0.5),
        ),
      ],
      color: Colors.white
  );
}
