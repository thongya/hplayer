void main(){
  double length = 0.75;
  double width = 0.58;
  double area = length * width;
  print("Area = $area");
  print(calculateArea(10, 20));
  print(calArea_(10, 30));
  print(calArea_with_optional_parameter(25, 36, 2.5));
}

double calculateArea(double length, double width){
  return length * width;

}
var calArea_ = (double length, double width) => length * width;
var calArea_with_optional_parameter = (double length, double width, [double? height]) {
  double area = length * width;
  if (height != null) {
    area *= height;
  }else{
    print("Height is null");
  }
  return area;
};

double default_value({double length = 2.5, double width = 2.8}){
  double area = length * width;
  return area;
}