// Global variables


PFont font;
PFont largefont;

//GuiGroup loginTab;
Gui gui;

boolean settingsVisible = true;

int lastKey = -1;

void initGUI() {
  gui = new Gui();

  font = createFont(dataPath("Roboto-Regular.ttf"), 14);
  largefont = createFont(dataPath("Roboto-Regular.ttf"), 36);
  textFont(font);

  GuiGroup loginTab = gui.addGroup("login");

  if (userdataloaded) { //valid user data were loaded
    loginTab.hide();
    settingsVisible = false;
  }

  // Create the text input field with a label
  TextInputField usernameField = new TextInputField(30, 100, 200, 30, "USERNAME", user);
  loginTab.add( usernameField );

  TextInputField passwdField = new TextInputField(260, 100, 200, 30, "PASSWORD", pass);
  passwdField.hidden = true;
  loginTab.add( passwdField );

  TextInputField urlField = new TextInputField(30, 160, 200, 30, "ATTENDENCE URL", weburl);
  loginTab.add( urlField );

  // Create the button with an associated method using an anonymous function (lambda-style)
  Button saveButton  = new Button(260, 160, 60, 30, "Save", new ButtonAction() {
    public void onClick() {
      saveToJson();
    }
  }
  );
  loginTab.add( saveButton);

  Button loginButton  =  new Button(340, 160, 60, 30, "Login", new ButtonAction() {
    public void onClick() {
      startBrowser();
    }
  }
  );
  loginTab.add( loginButton);


  Button toggleGuiButton  =  new Button(30, 30, 60, 30, "Settings", new ButtonAction() {
    public void onClick() {
      loginTab.toggle();
      settingsVisible = !settingsVisible; //assign to global var as well
    }
  }
  );
  gui.add( toggleGuiButton );
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// GUI MAIN CLASS
public class Gui {
  ArrayList<GuiGroup> guiGroups = new ArrayList<GuiGroup>();

  Gui() {
    GuiGroup defaultGroup = new GuiGroup("default");
    guiGroups.add(defaultGroup);
  }

  void render() {
    // Display the text input field and button
    for (int i=0; i< guiGroups.size(); i++ ) {
      guiGroups.get(i).render();
    }
  }

  void mousePressed() {
    for (int i=0; i< guiGroups.size(); i++ ) {
      guiGroups.get(i).mousePressed();
    }
  }

  void keyPressed(char key) {
    for (int i=0; i< guiGroups.size(); i++ ) {
      guiGroups.get(i).keyPressed(key);
    }
  }

  GuiGroup addGroup(String name) {
    GuiGroup group = new GuiGroup(name);
    guiGroups.add(group);
    return group;
  }

  void add(GuiGroup group) {
    guiGroups.add(group);
  }

  void add(Button button) {
    getGroup("default").add(button);
  }

  void add(TextInputField field) {
    getGroup("default").add(field);
  }

  TextInputField getTextInputFieldByLabel(String label) {
    for (int i=0; i< guiGroups.size(); i++ ) {
      TextInputField currField = guiGroups.get(i).getTextInputFieldByLabel(label);
      if ( currField != null ) {
        return currField;
      }
    }
    return null;
  }

  String getInputTextByLabel(String label) {
    TextInputField field = getTextInputFieldByLabel(label);
    if (field !=null) {
      return field.getText();
    }
    return null;
  }

  GuiGroup getGroup(String name) {
    for (int i=0; i< guiGroups.size(); i++ ) {
      if (guiGroups.get(i).name.equals(name)) {
        return guiGroups.get(i);
      }
    }
    return null;
  }

  TextInputField getSelectedTextField() {
    for (int i=0; i< guiGroups.size(); i++ ) {
      TextInputField field = guiGroups.get(i).getSelectedTextField();
      if (field!=null) {
        return field;
      }
    }
    return null;
  }
}

//---------------------------------------------------------------------------
public class GuiGroup {
  String name;
  boolean visible = true;

  ArrayList<Button>buttons = new ArrayList<Button>();
  ArrayList<TextInputField>textInputFields = new ArrayList<TextInputField>();

  GuiGroup(String name) {
    this.name = name;
  }

  void render() {
    if (visible) {
      for (int i=0; i< buttons.size(); i++ ) {
        buttons.get(i).display();
      }
      for (int i=0; i< textInputFields.size(); i++ ) {
        textInputFields.get(i).display();
      }
    }
  }

  void mousePressed() {
    if (visible) {
      for (int i=0; i< buttons.size(); i++ ) {
        buttons.get(i).mousePressed();
      }
      for (int i=0; i< textInputFields.size(); i++ ) {
        textInputFields.get(i).mousePressed();
      }
    }
  }

  void keyPressed(char key) {
    if (visible) {
      for (int i=0; i< textInputFields.size(); i++ ) {
        textInputFields.get(i).keyPressed(key);
      }
    }
  }

  TextInputField getTextInputFieldByLabel(String label) {
    for (int i=0; i< textInputFields.size(); i++ ) {
      if ( textInputFields.get(i).label.equals(label) ) {
        return textInputFields.get(i);
      }
    }
    return null;
  }

  Button getButtonByLabel(String label) {
    for (int i=0; i< buttons.size(); i++ ) {
      if ( buttons.get(i).label.equals(label) ) {
        return buttons.get(i);
      }
    }
    return null;
  }

  TextInputField getSelectedTextField() {
    for (int i=0; i< textInputFields.size(); i++ ) {
      if ( textInputFields.get(i).selected ) {
        return textInputFields.get(i);
      }
    }
    return null;
  }

  void show() {
    visible = true;
  }

  void hide() {
    visible = false;
  }

  boolean isVisible() {
    return visible;
  }

  void toggle() {
    visible = !visible;
  }

  void add(TextInputField field) {
    textInputFields.add(field);
  }

  void add(Button button) {
    buttons.add(button);
  }
}

//------------------------------------------------------------------------------------------
// TextInputField class for the text field and label
public class TextInputField {
  float x, y, width, height;
  String label;
  String inputText = "";
  boolean selected = false;
  boolean hidden = false; //for password

  TextInputField(float x, float y, float width, float height, String label, String value) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.label = label;
    if (value!=null) {
      this.inputText = value;
    }
  }

  TextInputField(float x, float y, float width, float height, String label) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.label = label;
  }

  String getText() {
    return inputText;
  }

  void setText(String text) {
    inputText = text;
  }

  void display() {
    pushStyle();
    textSize(14);

    textAlign(LEFT);
    // Draw label
    fill(255);
    text(label, x, y - 10);

    // Draw the input box
    if (selected) {
      fill(255, 253, 138);
    } else {
      fill(100);
    }
    rect(x, y, width, height);

    // Display text inside the input box
    if (selected) {
      fill(0);
    } else {
      fill(255);
    }

    if (!hidden) {
      text(inputText, x + 5, y+7, width-5, height);
    } else {
      //password - display asterisk instead of the original text
      String hiddenString = "";
      for (int i=0; i<inputText.length(); i++) {
        hiddenString += "*";
      }
      text(hiddenString, x + 5, y+7, width-5, height);
    }
    popStyle();
  }

  void mousePressed() {
    if (mouseX > x && mouseX < x + width && mouseY > y && mouseY < y + height) {
      selected = true;  // Call the associated method when the button is pressed
    } else {
      selected = false;
    }
  }

  void keyPressed(char key) {
    if (!selected) {
      return;
    }
    // Add the typed character to the input text when a key is pressed
    if (key != BACKSPACE && key != ENTER) {
      inputText += key;
    }
    // Handle backspace to delete text
    else if (key == BACKSPACE && inputText.length() > 0) {
      inputText = inputText.substring(0, inputText.length() - 1);
    }
  }
}
//------------------------------------------------------------------------------------------
// Button class for creating a button with a label and associated method
public class Button {
  float x, y, width, height;
  String label;
  ButtonAction action;  // ButtonAction interface to store the action
  long clicked = 0; //last time it was clicked

  Button(float x, float y, float width, float height, String label, ButtonAction action) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.label = label;
    this.action = action;
  }

  void display() {
    pushStyle();
    textSize(14);

    if (millis()-clicked<333) {
      fill(255, 253, 138);
    } else {
      fill(100);
    }
    rect(x, y, width, height);

    if (millis()-clicked<333) {
      fill(0);
    } else {
      fill(255);
    }
    textAlign(CENTER, CENTER);
    text(label, x + width / 2, y + height / 2);
    popStyle();
  }

  void mousePressed() {
    if (mouseX > x && mouseX < x + width && mouseY > y && mouseY < y + height) {
      clicked = millis();
      action.onClick();  // Call the associated method when the button is pressed
    }
  }
}
//--------------------------------------------------------------------------------------------



// ButtonAction interface to define the onClick behavior
interface ButtonAction {
  void onClick();
}


//////////////////////////////////////////////////////
//user input actions

void mousePressed() {
  if (gui!=null) {
    gui.mousePressed();
  }
}

void pasteToField() {
  String clipboard = getClipboard();
  //println(clipboard);
  TextInputField selectedField = gui.getSelectedTextField();
  if (selectedField!=null) {
    selectedField.setText(clipboard);
  }
}

void keyPressed() {
  //println("code: " + (int)key);

  int currOS = getOS();

  if (currOS==0) { //MACOS
    if (lastKey==(int)65535) {
      if (key==118) {
        pasteToField();
        return;
      }
    }
  } else if (currOS==2 || currOS==1) { //LINUX OR WIN
    if (key == CODED) {
      if (keyCode == 86 ) { //CTRL + V
        println("coded: " + (int)keyCode);
        println("CTRL+V detected");
        pasteToField();
        return;
      }
    }
  }

  lastKey = key;

  if (key ==CODED) {
    return;
  }

  if (gui!=null) {
    gui.keyPressed(key);
  }
}
///////////////////////////////////////////////////////

boolean setUserData() {
  String _user = gui.getInputTextByLabel("USERNAME");
  String _pass =  gui.getInputTextByLabel("PASSWORD");
  String _url = gui.getInputTextByLabel("ATTENDENCE URL");
  if (_user==null || _pass==null || _url==null) {
    println("input fields are null - returning");
    return false;
  }
  if (_user.isEmpty() || _pass.isEmpty() || _url.isEmpty()) {
    println("input fields are empty - returning");
    return false;
  }
  user = _user;
  pass = _pass;
  weburl = _url;
  return true;
}

// Function to save data to a JSON file
void saveToJson() {

  if ( !setUserData() ) {
    return;
  }

  JSONObject json = new JSONObject();
  json.setString("username", user);
  json.setString("password", encrypter( pass, cryptoPass ) );
  json.setString("weburl", weburl);

  json.setInt("timeoutForAttendance", timeoutForAttendance); //save in minutes
  json.setInt("timeoutForLateAttendance", timeoutForLateAttendance); //save in minutes


  // Save the JSONObject as a file
  saveJSONObject(json, dataPath("data.json") );
  println("Data saved to " + dataPath("data.json"));
}

// Function to load data from a JSON file
boolean loadFromJson() {
  File f = new File(dataPath("data.json"));

  if ( !f.isFile() ) {
    println("data.json not found");
    return false;
  }

  try {
    // Load the JSON file
    JSONObject json = loadJSONObject(dataPath("data.json"));
    user = json.getString("username");
    pass = decrypter( json.getString("password"), cryptoPass) ;
    weburl = json.getString("weburl");

    timeoutForAttendance = json.getInt("timeoutForAttendance"); 
    timeoutForLateAttendance = json.getInt("timeoutForLateAttendance");

    return true;
  }
  catch (Exception e) {
    println(e);
    return false;
  }
}
