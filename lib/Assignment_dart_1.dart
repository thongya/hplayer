abstract class Vehicle{
  late int _speed;

  int get speed => _speed; // getter
  set speed(int speed){ // setter
    _speed = speed;
  }

  move(); // abstract method
}

class Car extends Vehicle{
   String name;
   Car(this.name);

    @override
  move() {
    print("The car is moving at $_speed km/h");
  }
}


void main(){
  Car car = Car("Toyota");
  car.speed = 80;
  print("Car name: ${car.name} and speed is ${car.speed}");
  car.move();
}