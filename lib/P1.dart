class Animal{
  late String name;
  void makeSound(){
    print("$name is bark");
  }
}

class Person{
  late String _name;
  late int _age;
  void setName(String name, int age){
    _name = name;
    _age = age;
  }
  void getName(){
    print("Name: $_name, Age: $_age");
  }
}

// Inheritance
class cow extends Animal{
  void ambaa(){
    print("$name is ambadaa");
  }
}

class elephant extends Animal{
  @override
  void ambaa(){
    print("$name is ambadaa hello");
  }
}

void main(){
  var dog = Animal();  // Polymorphism class
  var ccow = cow();  // Inheritance
  ccow.name = "Cow";
  dog.name = "Dog";
  dog.makeSound();
  ccow.ambaa();
  var ele = elephant();  // override
  ele.name = "Elephant";
  ele.ambaa();
  var person = Person(); // Encapsulation
  person.setName("Thong", 20);
  person.getName();
}