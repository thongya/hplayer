abstract class Animal{
  String name;
  static var test = "This is animal class";
  Animal(this.name);

  eat(){
    print("$name is eating");
  }
  speak(){
    print("$name is speaking");
  }
}

class Dog extends Animal{
  Dog(String name) : super(name);

  bark(){
    print("$name is barking");
  }
}

class Cat extends Animal{
  Cat(String name) : super(name);
  meow(){
    print("$name is meowing");
  }
}

void main() {
  var dog = Dog("Tommy");
  dog.eat();
  dog.speak();
  dog.bark();

  // Animal animal = Animal("Cow");
  // animal.eat();
  // animal.speak();

  Cat cat = Cat("Tom");
  cat.eat();
  cat.speak();
  cat.meow();

}