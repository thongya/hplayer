main(){
  String sName = "Rahim";
  String sClass = "10";
  String sAddress = "bandarban";
  print("Name: $sName, Class: $sClass, Adress: $sAddress");

  Student student = Student();
  student.studentName = "kahim";
  student.studentClass = "11";
  student.studentAddress = "Dhaka";
  // animal
  Animal animal = Animal();
  animal.eyes = 2;
  animal.lags = 2;
  animal.sound();
  print(Animal.makeEatting);
  print("Eyes: ${animal.eyes}, Lags: ${animal.lags}, sound: ${animal.sound()}");

  print("Name: ${student.studentName}, Class: ${student.studentClass}, Address: ${student.studentAddress}");

  Car car = Car("Toyota", "Camry", 2022);
  print("Brand: ${car.brand}, Model: ${car.model}, Year: ${car.year}");

  Restaureant kfc = Restaureant("Insapf Hotel");
  kfc.order("burger");
  kfc._prepareItem("Chicken fry");
  print(kfc.name);
  print(kfc.restaurantId);
  print(kfc.setId = 25666);

  Son son = Son("Honda", "15000");
  print(son.bike);
  print(son.taka);
  Daughter daughter = Daughter("Honda", "15000", "25000");
  print(daughter.bike);
  print(daughter.taka);
  print(daughter.nijTaka);

}
class Student{
  String ? studentName;
  String ? studentClass;
  String ? studentAddress;
}
class Animal{
  int lags = 2;
  int eyes = 2;
  static String makeEatting = "Eatting";
  sound(){
    print("dogs bark");
  }
}

class Car {
  String brand;
  String model;
  int year;

  Car(this.brand, this.model, this.year);

  Human(){
    method1();
    method2();
  }

  method1(){
    print("Moving");
  }
  method2(){
    print("Moving2");
  }
}
class Restaureant{
  String name;
  int _id = 12222;

  Restaureant(this.name);

  order(String item){
    print("$item ordered");
    _prepareItem(item);
  }
  order2(String item){
    print("$item ordered2");
  }
  _prepareItem(String item){
    print("$item prepared");
  }
  shopping(String item){
    print("$item shopping");
  }

  int get restaurantId => _id;
  set setId(int id){
    _id = id;
  }
}

class Father {
  String bike ="Honda";
  String taka = "15000";

  Father(this.bike, this.taka);
}
class Son extends Father{
  Son(String bike, String taka) : super(bike, taka);
}
class Daughter extends Father{
  String nijTaka = "25000";
  Daughter(String bike, String taka, String nijTaka) : super(bike, taka);

}