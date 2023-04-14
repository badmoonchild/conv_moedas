import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeConver extends StatefulWidget {
  const HomeConver({Key? key}) : super(key: key);

  @override
  State<HomeConver> createState() => _HomeConverState();
}

class _HomeConverState extends State<HomeConver> {
  final realControl = TextEditingController();
  final dolarControl = TextEditingController();
  final euroControl = TextEditingController();
  final yuanControl = TextEditingController(); // moeda chinesa
  final wonControl = TextEditingController(); // moeda coreana

  double dolar = 0;
  double euro = 0;
  double yuan = 0; // nova moeda chinesa
  double won = 0; // nova moeda coreana

  @override
  void dispose() {
    realControl.dispose();
    dolarControl.dispose();
    euroControl.dispose();
    yuanControl.dispose(); // adap nova moeda
    wonControl.dispose(); //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Conversor de Moedas'),
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            if (!snapshot.hasError) {
              if (snapshot.connectionState == ConnectionState.done) {
                dolar = double.parse(snapshot.data!['USDBRL']['bid']);
                euro = double.parse(snapshot.data!['EURBRL']['bid']);
                yuan = double.parse(snapshot.data!['CNYBRL']['bid']); // adap
                won = double.parse(snapshot.data!['KRWBRL']['bid']); //adap
                // dolar = snapshot.data!['USD']['buy'];
                // euro = snapshot.data!['EUR']['buy'];
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.monetization_on_outlined,
                        size: 120,
                      ),
                      const SizedBox(height: 20),
                      currencyTextField(
                          'reais ', 'R\$ ', realControl, _convertReal),
                      const SizedBox(height: 20),
                      currencyTextField(
                          'Dolares', 'US\$ ', dolarControl, _convertDolar),
                      const SizedBox(height: 20),
                      currencyTextField(
                          'Euros', '€ ', euroControl, _convertEuro),
                      const SizedBox(height: 20), // mudando aqui
                      currencyTextField('Yuan', '¥', yuanControl, _convertYuan),
                      const SizedBox(height: 20), // mudando aqui
                      currencyTextField('Won', '₩', wonControl, _convertWon),
                    ],
                  ),
                );
              } else {
                return waitingIndicator();
              }
            } else {
              return waitingIndicator();
            }
          },
        ));
  }

  TextField currencyTextField(String label, String prefixText,
      TextEditingController controller, Function f) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixText: prefixText,
      ),
      onChanged: (value) => f(value),
      keyboardType: TextInputType.number,
    );
  }

  Center waitingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void _convertReal(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double real = double.parse(text);
    dolarControl.text = (real / dolar).toStringAsFixed(2);
    euroControl.text = (real / euro).toStringAsFixed(2);
    yuanControl.text = (real / yuan).toStringAsFixed(2); // nova moedinha chinesa p ajudar o governo
    wonControl.text = (real / won).toStringAsFixed(2);  // nova moedinha kpop 
  }

  void _convertDolar(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double dolar = double.parse(text);
    realControl.text = (this.dolar * dolar).toStringAsFixed(2);
    euroControl.text = ((this.dolar * dolar) / euro).toStringAsFixed(2);
    yuanControl.text = ((this.dolar * dolar) / yuan).toStringAsFixed(2); // novo
    wonControl.text = ((this.dolar * dolar) / won).toStringAsFixed(2); // novo 
  }

  void _convertEuro(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double euro = double.parse(text);
    realControl.text = (this.euro * euro).toStringAsFixed(2);
    dolarControl.text = ((this.euro * euro) / dolar).toStringAsFixed(2);
    yuanControl.text = ((this.euro * euro) / yuan).toStringAsFixed(2); // novo 
    wonControl.text = ((this.euro * euro) / won).toStringAsFixed(2); // novo 
  }

  void _convertYuan(String text) { // funçao moedinha Chinesa
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double yuan= double.parse(text);
    realControl.text = (this.yuan * yuan).toStringAsFixed(2);
    euroControl.text = ((this.yuan * yuan) / euro).toStringAsFixed(2);
    dolarControl.text = ((this.yuan * yuan) / dolar).toStringAsFixed(2); // novo 
    wonControl.text = ((this.yuan * yuan) / won).toStringAsFixed(2); // novo 
  }

  void _convertWon(String text) { // funçao moedinha coreana
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double won= double.parse(text);
    realControl.text = (this.won * won).toStringAsFixed(2);
    euroControl.text = ((this.won * won) / euro).toStringAsFixed(2);
    dolarControl.text = ((this.won * won) / dolar).toStringAsFixed(2); // novo 
    yuanControl.text = ((this.won * won) / yuan).toStringAsFixed(2); // novo 
  }


  void _clearFields() {
    realControl.clear();
    dolarControl.clear();
    euroControl.clear();
  }
}

Future<Map> getData() async {
  //* ENDEREÇO DA API NOVA
  //* https://docs.awesomeapi.com.br/api-de-moedas

  const requestApi =
      "https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL,CNY-BRL,KRW-BRL ";
  var response = await http.get(Uri.parse(requestApi));
  return jsonDecode(response.body);

  //* json manual para teste em caso de
  //* problema com a conexão http
/*   var response = {
    "USDBRL": {
      "code": "USD",
      "codein": "BRL",
      "name": "Dólar Americano/Real Brasileiro",
      "high": "5.3388",
      "low": "5.2976",
      "varBid": "0.0382",
      "pctChange": "0.72",
      "bid": "5.3348",
      "ask": "5.3363",
      "timestamp": "1679660987",
      "create_date": "2023-03-24 09:29:47"
    },
    "EURBRL": {
      "code": "EUR",
      "codein": "BRL",
      "name": "Euro/Real Brasileiro",
      "high": "5.7429",
      "low": "5.6772",
      "varBid": "-0.0095",
      "pctChange": "-0.17",
      "bid": "5.7256",
      "ask": "5.7293",
      "timestamp": "1679660999",
      "create_date": "2023-03-24 09:29:59"
    }
  };

  return jsonDecode(jsonEncode(response));

  <BRL-CNY>Real Brasileiro/Yuan Chinês</BRL-CNY>
  <BRL-KRW>Real Brasileiro/Won Sul-Coreano</BRL-KRW>
 */
}
