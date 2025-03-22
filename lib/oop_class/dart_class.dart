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
}