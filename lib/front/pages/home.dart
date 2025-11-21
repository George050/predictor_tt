import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tt_predictor/front/pages/addPetPage.dart';
import 'package:tt_predictor/required/enumeration.dart';
import 'package:tt_predictor/front/pages/editPetPage.dart';
import 'package:http/http.dart' as http;
import 'package:platform_detector/platform_detector.dart';


class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {

  List pets = [];
  List<Widget> petCards = [];
  int pageIndex = 0;
  String text = "";
  StateLabel petsStatus = StateLabel.available;
  int textFieldPetId = 0;
  List petsIndexForDelete = [];

  @override
  void initState() {
    super.initState();
    setPets();
  }

  @override
  Widget build(BuildContext context){
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Padding (
            padding: EdgeInsets.only(right: kIsWeb && width > height ?
            (width - height) / 2 :
              0),
            ),
            Text("Список питомцев"),
            IconButton(onPressed: () {
              setState(() {
                pageIndex = 0;
              });
              setPets();
            }, icon: Icon(Icons.refresh))
          ],
        )
      ),
      body: Padding (
        padding: EdgeInsets.symmetric(horizontal: kIsWeb && width > height ?
        (width - height) / 2 :
        0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: TextField(
                  keyboardType: TextInputType.number, //
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly //
                  ],
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Введите ID искомого питомца"
                  ),
                  onSubmitted: (String value) {
                    setState(() {
                      textFieldPetId = int.parse(value);
                      petsStatus = StateLabel.empty;
                      setPetById();
                    });
                  }
              )
            ),
            Row(
              children: [
                Padding(padding: EdgeInsets.only(top: 8, left: 10, right: 10),
                    child: OutlinedButton(onPressed: () {
                      showDialog(context: context,
                          builder: (BuildContext context) => AddPetPage()
                      );
                    },
                        child: const Text("Добавить питомца")
                    )
                ),
                Padding(padding: EdgeInsets.only(top: 8),
                child: OutlinedButton(onPressed: petsIndexForDelete.isEmpty ?
                null : () {
                  deletePetsById();
                },
                    child: const Text("Удалить питомцев")
                ),)
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 8, left: 10, right: 10),
              child:SegmentedButton<StateLabel>(
                segments: const <ButtonSegment<StateLabel>>[
                  ButtonSegment<StateLabel>(
                      value: StateLabel.available,
                      label: Text("Доступные")
                  ),
                  ButtonSegment<StateLabel>(
                      value: StateLabel.pending,
                      label: Text("В ожидании")
                  ),
                  ButtonSegment<StateLabel>(
                      value: StateLabel.sold,
                      label: Text("Проданы")
                  )
                ],
                selected: <StateLabel>{petsStatus},
                onSelectionChanged: (Set<StateLabel> newSelection) {
                  setState(() {
                    petsStatus = newSelection.first;
                    pageIndex = 0;
                    setPets();
                  });
                },
                showSelectedIcon: false,
              )
            ),

            Expanded(
              flex: 10,
              child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.indigo.shade100,
                        width: 1,
                      )
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  margin: EdgeInsets.all(8.0),
                  child: GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 3,
                    childAspectRatio: 0.7,
                    children: petCards
                )
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(onPressed: pageIndex > 0 ? () {
                  pageIndex -= 1;
                  setPets();
                } : null,
                  child: Icon(Icons.arrow_back),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text("Страница ${pageIndex + 1} из ${pets.length ~/ 30 + (pets.length % 30 > 0 ? 1 : 0)}", style: TextStyle(
                  fontSize: 15
                  ),)
                ),

                OutlinedButton(onPressed: (pageIndex + 1) * 30 < pets.length ? () {
                  pageIndex += 1;
                  setPets();
                } : null,
                    child: Icon(Icons.arrow_forward)
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: 10))
          ],
        )
      ),
    );
  }

  void deletePetsById() async {
    print(petsIndexForDelete);
     while (petsIndexForDelete.isNotEmpty) {
      var url = Uri.https("petstore.swagger.io", "v2/pet/${pets[petsIndexForDelete[0]]["id"]}");
      var response = await http.delete(url);
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: response.statusCode == 200 ? Text('Питомец с id ${jsonDecode(response.body)["message"]} был удален!') : Text("Питомец с id ${pets[petsIndexForDelete[0]]["id"]} не найден!"),
          duration: const Duration(milliseconds: 1500),
          width: 280.0, // Width of the SnackBar.
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 4.0
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      );
      petsIndexForDelete.removeAt(0);
    }
    setPets();
  }

  void setPetById() async {
    petsIndexForDelete = [];
    var url = Uri.https('petstore.swagger.io', 'v2/pet/$textFieldPetId');
    var response = await http.get(url);
    setState(() {
      pets = [];
      petCards = [];
      if (response.statusCode == 200) {
        var curPet = jsonDecode(response.body);
        bool _isChecked = false;
        pets.add(curPet);
        var petImage = curPet["photoUrls"] != null &&
            curPet["photoUrls"].isNotEmpty && curPet["photoUrls"][0] != null?
        Image.network(curPet["photoUrls"][0],
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return Icon(Icons.photo, size: 100,);
            }) :
        Icon(Icons.photo, size: 100,);
        petCards.add(Card(
            child: Column(
                children: [
                  Expanded(child: Row(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 5)),
                      Expanded(child: petImage),
                      Padding(padding: EdgeInsets.only(right: 5))
                    ],
                  )
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          flex: 4,
                          child: TextButton(
                          onPressed: () {
                            showDialog(context: context,
                                builder: (BuildContext dialogContext) => PetPage(petId: curPet["id"],
                                  name: curPet["name"] == null || curPet["name"].replaceAll(' ', '') == "" ? "noname pet" : curPet["name"],
                                  photoUrls: curPet["photoUrls"] ?? [],
                                  status: curPet["status"],
                                  petCardIndex: 0,
                                  pets: pets,
                                  homeState: this,
                                )
                            );
                          },
                          child: Text(
                              curPet["name"] ?? "noname pet",
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 13
                              ),
                              maxLines: 2
                          )
                        )
                      ),
                        Flexible(
                            flex: 1,
                            child: Checkbox(
                          checkColor: Colors.white,
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                            _isChecked = value!;
                            if (_isChecked) {
                              petsIndexForDelete.add(0);
                            } else {
                              petsIndexForDelete.remove(0);
                            }
                          });
                          },
                        )
                        )
                    ],
                  )
                ])
          )
        );
      } else {
        petCards.add(Text(jsonDecode(response.body)["message"]));
      }
    });
  }

  void setPets() async {
    petsIndexForDelete = [];
    if (petsStatus == StateLabel.empty) {
      petsStatus = StateLabel.available;
    }
    var response;
    try {
      var url = Uri.https(
          'petstore.swagger.io', 'v2/pet/findByStatus',
          {'status': petsStatus.state});
      response = await http.get(url);
    }
    catch (e) {
      showDialog(context: context, builder:
      (BuildContext context) => Dialog(
        child: Padding(padding: EdgeInsets.all(6.0),
        child:  Text(e.toString()),
        )
      ));

      return;
    }
    setState(() {
      pets = [];
      petCards = [];
      json.decode(response.body).forEach((pet) => pets.add(pet));
      petCards = List.generate(
        (30 * (pageIndex + 1)) > pets.length ? pets.length % 30 : 30, (index) {
        var curPet = pets[index + pageIndex * 30];
        bool _isChecked = false;
        var petImage = curPet["photoUrls"] != null &&
            curPet["photoUrls"].isNotEmpty && curPet["photoUrls"][0] != null ?
            Image.network(curPet["photoUrls"][0],
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Icon(Icons.photo, size: 100,);
              }) :
            Icon(Icons.photo, size: 100,);
        return Card(
          child: Column(
            children: [
              Expanded(child: Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: 5)),
                    Expanded(child: petImage),
                    Padding(padding: EdgeInsets.only(right: 5))
                  ],
              )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      flex: 4,
                      child: TextButton(
                      onPressed: () {
                        showDialog(context: context,
                            builder: (BuildContext dialogContext) => PetPage(petId: curPet["id"],
                              name: curPet["name"] == null || curPet["name"].replaceAll(' ', '') == "" ? "noname pet" : curPet["name"],
                              photoUrls: curPet["photoUrls"] ?? [],
                              status: curPet["status"],
                              petCardIndex: index,
                              pets: pets,
                              homeState: this,
                            )
                        );
                      },
                      child: Text(
                          curPet["name"] ?? "noname pet",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 13
                          ),
                          maxLines: 2
                      )
                    )
                  ),
                  Flexible(
                      flex: 1,
                      child: Checkbox(
                    checkColor: Colors.white,
                    tristate: false,
                    value: _isChecked,
                    onChanged: (bool? valueIn) {
                      setState(() {
                        _isChecked = !_isChecked;
                        if (_isChecked) {
                          petsIndexForDelete.add(index + pageIndex * 30);
                        } else {
                          petsIndexForDelete.remove(index + pageIndex * 30);
                        }
                      });
                    },
                  )
                  )
                ],
              )
            ])
          );
      });
      if (petCards.isEmpty) {
        petCards.add(Text("Питомцы не найдены"));
      }
      print(pets.length);
    });
  }
}