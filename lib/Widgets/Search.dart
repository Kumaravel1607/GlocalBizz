import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:glocal_bizz/Controller/constand.dart';

class SearchCategory extends StatefulWidget {
  const SearchCategory({Key key}) : super(key: key);

  @override
  _SearchCategoryState createState() => _SearchCategoryState();
}

class _SearchCategoryState extends State<SearchCategory> {
  final TextEditingController _searchData = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.0),
          height: MediaQuery.of(context).size.height,
          color: white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CloseButton(),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 45,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.grey[200],
                    blurRadius: 5.0,
                    spreadRadius: 3.0,
                  ),
                ]),
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                      autofocus: true,
                      controller: _searchData,
                      decoration: textDecoration2("Search category..")),
                  suggestionsCallback: (pattern) async {
                    // return await get_locationData(pattern);
                  },
                  itemBuilder: (context, item) {
                    return list();
                  },
                  onSuggestionSelected: (item) async {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget list() {
    return SingleChildScrollView(
      child: ListTile(
        title: Text("Car"),
        // subtitle: Text(location.id),
      ),
    );
  }
}
