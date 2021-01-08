import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_masked_text/flutter_masked_text.dart';
// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

const request = "https://api.hgbrasil.com/finance?format=json&key=f2049c83";

void main() async {
  //print(json.decode(response.body)["results"]["currencies"]["USD"]);

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MoneyMaskedTextController realController =
      MoneyMaskedTextController(decimalSeparator: ',');
  MoneyMaskedTextController dolarController =
      MoneyMaskedTextController(decimalSeparator: ',');
  MoneyMaskedTextController euroController =
      MoneyMaskedTextController(decimalSeparator: ',');

  //final real2Controler = MaskTextInputFormatter

  double dolar;
  double euro;

  double _removePTBRFormat(String value) {
    String retorno = value.replaceAll(",", "").replaceAll(".", "");

    return double.parse(retorno) / 100;
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = _removePTBRFormat(text);

    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double d = _removePTBRFormat(text);

    realController.text = (d * this.dolar).toStringAsFixed(2);
    euroController.text = ((d * this.dolar) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double e = _removePTBRFormat(text);

    realController.text = (e * this.euro).toStringAsFixed(2);
    dolarController.text = ((e * this.euro) / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(" \$ Conversor \$"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return getWidgetStatus("Carregando Dados...");
              break;
            default:
              if (snapshot.hasError) {
                return getWidgetStatus("Erro ao Carregar Dados :(");
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 150.0, color: Colors.amber),
                      Divider(),
                      Text(
                        "dolar: R\$: $dolar | euro: R\$: $euro"
                            .replaceAll(".", ","),
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 15.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Divider(),
                      buildTextField(
                          "Reais", "R\$ ", realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dólares", "US\$ ", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField(
                          "Euro", "€ ", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
        future: getData(),
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

Center getWidgetStatus(String mensagem) {
  return Center(
      child: Text(
    mensagem,
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
    textAlign: TextAlign.center,
  ));
}

Widget buildTextField(String label, String prefix,
    MoneyMaskedTextController edcontroller, Function f) {
  return TextField(
    controller: edcontroller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    // inputFormatters: [
    //   MaskTextInputFormatter(
    //       mask: '###.###,##', filter: {"#": RegExp(r'[0-9]')})
    // ],
  );
}
