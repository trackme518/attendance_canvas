//-----------------------------------------------------
Student getStudent(String name, String ip, String videoinput) {
  if (students!=null) {
    for (int i=0; i< students.size(); i++) {
      Student currStudent = students.get(i);
      if (currStudent.name.equals(name)) {

        for (int s=0; s< students.size(); s++) {
          Student otherStudent = students.get(s);

          if (otherStudent.videoinput!=null &&  otherStudent.videoinput.equals(videoinput) ) {
            println("Same videoinput already used! Unmark previous name presence.");
            otherStudent.markStudent("unmark"); //reset state of student with that videoinput device id
          }

          if (otherStudent.ip!=null &&  otherStudent.ip.equals(ip) ) {
            println("Same IP already used! Unmark previous name presence.");
            otherStudent.markStudent("unmark"); //reset state of student with that ip
          }
        }

        //when called for first time assign ip to student
        if ( currStudent.ip == null ) {
          currStudent.ip = ip;
        }

        if ( currStudent.videoinput == null ) {
          currStudent.videoinput = videoinput;
        }

        return students.get(i);
      }
    }
  }
  return null;
}

class Student {
  Student(String _name) {
    name = _name;
  }

  String ip;
  String name;
  String videoinput; //unique ID until cookies reset
  String present = "unmark";//0=present, 1=absent,2=late,3=unmarked

  long debounceMark = 0;

  void render(int x, int y) {
    pushStyle();
    ellipseMode(CENTER);

    if (present.equals("unmark")) {
      fill(127);
    } else if (present.equals("present")) {
      fill(0, 255, 0);
    } else if (present.equals("absent")) {
      fill(255, 0, 0);
    } else if (present.equals("late")) {
      fill(255, 165, 0);
    }

    circle(x, y-3, 15);

    textSize(14);
    fill(255);
    text(name, x+30, y);
    popStyle();
  }

  void markStudent(String state) {
    //avoid multiple triggers
    if (millis()-debounceMark<1000) {
      return;
    }
    debounceMark = millis();

    present = state;
    //perform action isnide Selenium engine - see driver tab
    if (instance!=null) {
      String[] args = {name, present};
      instance.doTask(instance.MARKSTUDENT, args);
    }
  }

  void markStudent() {
    String state = "present";

    if (millis()>1000*60*15) {
      state = "late";
    }

    if (millis()>1000*60*60) {
      state = "absent";
    }

    present = state;

    //perform action isnide Selenium engine - see driver tab
    if (instance!=null) {
      String[] args = {name, state};
      instance.doTask(instance.MARKSTUDENT, args);
    }
  }
}
