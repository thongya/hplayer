abstract class Student {
  assignment(); // jodi body na thake tahole abstract method hobe.

  attenClass(){
    print("Joined class");
  }
  examSubmit(){

  }

}
class Person extends Student{
  String name;
  Person(this.name);

  @override
  assignment() {
    print("Assignment submitted");
  }
}
class Person1 extends Student{
  @override
  assignment() {
    // TODO: implement assignment
    throw UnimplementedError();
  }

}

class Businessman implements Student{
  String name;
  String title;
  Businessman(this.name, this.title);

  @override
  assignment() {
    print("Assignment submitted");
  }
  @override
  examSubmit() {
    print("Exam submitted");
  }
  @override
  attenClass() {
    print("Joined class");
  }
}

main(){
  Person person = Person("Rafi");
  person.attenClass();
  person.assignment();
  person.examSubmit();

  Businessman businessman = Businessman("Rafi", "CEO");
  businessman.attenClass();
  businessman.assignment();
  businessman.examSubmit();

  // polymorphism
  Student student = Businessman("Rafi", "CEO");
  Student student1 = Person("Rafi");
  student.attenClass();
  student.assignment();
  student.examSubmit();
  student1.attenClass();
  student1.assignment();
  student1.examSubmit();

  // runtime type
  print(student.runtimeType);
  print(student1.runtimeType);
  print(student.runtimeType == student1.runtimeType);
  print(student is Businessman);
  print(student1 is Person);

}