import java.util.Iterator;

class FoodSystem {
  PVector origin;
  ArrayList<Food> foods;

  FoodSystem() {
    foods = new ArrayList();
  }

  void draw() {
    for (Food f : foods) {
      f.draw();
    }
  }

  void addFood(float originX, float originY) {
    Food f = new Food(originX, originY);
    foods.add(f);
  }
}
