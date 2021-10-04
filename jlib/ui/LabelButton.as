#include "../../../lib/ui/Button.cpp"
#include "../../../lib/ui/label.cpp"
class LabelButton : ButtonClickHandler, callback_base {
  private float BUTTON_HEIGHT = 34;
  private float SIZE = 10;
  //Button
  UI@ ui;
  scene@ g;
  Button@ button;
  Mouse@ mouse;
  Rect border;
  string callback;

  LabelButton(UI@ ui, float X1, float Y1, string callback_name, string labelText) {
    @g = get_scene();
    @this.ui = ui;
    @this.mouse = ui.mouse;
    border = Rect(X1, Y1, X1 + SIZE, Y1 + SIZE);
    const float height = BUTTON_HEIGHT - ui.padding * 2;
    @button = Button(ui, Label(ui, labelText));
    button.fit_to_height(height);
    @button.click_listener = this;
    callback = callback_name;
  }

  void draw() {
    const float PADDING = ui.padding;
    Rect rect = border;
    rect.set(
      rect.x1 - PADDING - button.width, rect.y1,
      rect.x1 - PADDING, rect.y2);
    button.draw(g, rect);
  }

  void on_button_click(Button@ button) {
    message@ msg = create_message();
    msg.set_string(callback, "true");
    broadcast_message(callback, msg); 
  }
}