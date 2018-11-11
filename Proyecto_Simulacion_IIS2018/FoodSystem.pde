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

  void addFood(float originX, float originY, String type) {
    Food f = new Food(originX, originY, type);
    foods.add(f);
  }
}
