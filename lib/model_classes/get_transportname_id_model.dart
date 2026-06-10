/// id : 259
/// name : "ABCT TRANSPORT LTD COR"

class GetTransportnameIdModel {
  GetTransportnameIdModel({
      num? id, 
      String? name,}){
    _id = id;
    _name = name;
}

  GetTransportnameIdModel.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
  }
  num? _id;
  String? _name;
GetTransportnameIdModel copyWith({  num? id,
  String? name,
}) => GetTransportnameIdModel(  id: id ?? _id,
  name: name ?? _name,
);
  num? get id => _id;
  String? get name => _name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    return map;
  }

}