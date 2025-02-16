// Global variables

ArrayList<Button>buttons = new ArrayList<Button>();
ArrayList<TextInputField>textInputFields = new ArrayList<TextInputField>();
PFont font;
PFont largefont;

boolean ctrlPressed = false;  // To track if CTRL is pressed
boolean vPressed = false;

void initGUI() {

  font = createFont(dataPath("Roboto-Regular.ttf"), 14);
  largefont = createFont(dataPath("Roboto-Regular.ttf"), 36);
  textFont(font);
  // Create the text input field with a label
  textInputFields.add( new TextInputField(30, height-50, 200, 30, "USERNAME", user) );

  TextInputField passwdField = new TextInputField(260, height-50, 200, 30, "PASSWORD", pass);
  passwdField.hidden = true;

  textInputFields.add( passwdField );
  textInputFields.add( new TextInputField(30, height-50-60, 200, 30, "ATTENDENCE URL", weburl) );

  // Create the button with an associated method using an anonymous function (lambda-style)
  buttons.add( new Button(260, height-50-60, 60, 30, "Save", new ButtonAction() {
    public void onClick() {
      saveToJson();
    }
  }
  ));

  buttons.add( new Button(340, height-50-60, 60, 30, "Login", new ButtonAction() {
    public void onClick() {
      startBrowser();
    }
  }
  ));
}

TextInputField getTextInputFieldByLabel(String label) {
  for (int i=0; i< textInputFields.size(); i++ ) {
    if ( textInputFields.get(i).label.equals(label) ) {
      return textInputFields.get(i);
    }
  }
  return null;
}

String getInputTextByLabel(String label) {
  TextInputField field = getTextInputFieldByLabel(label);
  if (field !=null) {
    return field.inputText;
  }
  return null;
}

void renderGUI() {
  // Display the text input field and button
  for (int i=0; i< buttons.size(); i++ ) {
    buttons.get(i).display();
  }
  for (int i=0; i< textInputFields.size(); i++ ) {
    textInputFields.get(i).display();
  }
}

// TextInputField class for the text field and label
class TextInputField {
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
      while (hiddenString.length()< inputText.length()) {
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

  String getText() {
    return inputText;
  }
}

// ButtonAction interface to define the onClick behavior
interface ButtonAction {
  void onClick();
}

// Button class for creating a button with a label and associated method
class Button {
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

//////////////////////////////////////////////////////
//user input actions

void mousePressed() {
  for (int i=0; i< buttons.size(); i++ ) {
    buttons.get(i).mousePressed();
  }

  for (int i=0; i< textInputFields.size(); i++ ) {
    textInputFields.get(i).mousePressed();
  }
  //myButton.mousePressed();  // Check if the button was clicked
}


void keyPressed() {

  if (key == CODED) {
    if (keyCode == 86 ) { //CTRL + V
      println("CTRL+V");
      String clipboard = getClipboard();
      println(clipboard);
      for (int i=0; i< textInputFields.size(); i++ ) {
        if ( textInputFields.get(i).selected) {
          textInputFields.get(i).inputText = clipboard;
        }
      }
    }
    return;
  }


  for (int i=0; i< textInputFields.size(); i++ ) {
    textInputFields.get(i).keyPressed(key);
  }
}
///////////////////////////////////////////////////////

// Function to save data to a JSON file
void saveToJson() {
  String _user = getInputTextByLabel("USERNAME");
  String _pass =  encrypter( getInputTextByLabel("PASSWORD"), cryptoPass );
  String _url = getInputTextByLabel("ATTENDENCE URL");

  if (_user==null || _pass==null || _url==null) {
    return;
  }

  // Create a JSONObject
  user = _user;
  pass = _pass;
  weburl = _url;
  JSONObject json = new JSONObject();
  json.setString("username", user);
  json.setString("password", pass);
  json.setString("weburl", weburl);
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
    pass = decrypter( json.getString("password") , cryptoPass) ;
    weburl = json.getString("weburl");
    return true;
  }
  catch (Exception e) {
    println(e);
    return false;
  }
}
