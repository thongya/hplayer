import 'dart:io';

main(){
  try{
    print("Enter age ");
    String ? age = stdin.readLineSync();
    int age1 = int.parse(age!);
    age1 > 18 ? print("You are adult") : print("You are not adult");
  }catch(error){
    print("Error");

  }
}