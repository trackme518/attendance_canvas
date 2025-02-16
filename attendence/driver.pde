import org.openqa.selenium.*;
import org.openqa.selenium.WebDriver;
//import org.openqa.selenium.firefox.FirefoxDriver;
//comment the above line and uncomment below line to use Chrome
import org.openqa.selenium.chrome.ChromeDriver;

//ChromeDriver driver;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.WebDriverWait;


import java.time.Duration;
//download driver that is the same as your chrome version--see chrome->about to see current version
//https://chromedriver.chromium.org/
import org.openqa.selenium.chromium.ChromiumOptions;
import org.openqa.selenium.chromium.ChromiumDriver;

import java.util.*;
//wait.until(EC.title_is("title"))
//wait.until(EC.title_contains("part of title"))
//import expected_conditions as EC
//import java.util.List;

int threadCount = 0;

public class BrowserInstance implements Runnable {
  public final int START = 0;
  public final int LOGIN = 1;
  public final int GETSTUDENTS = 2;
  public final int MARKSTUDENT = 3;
  public final int LOGOUT = 4;
  public final int REFRESH = 5;

  public ChromeDriver driver;
  private Thread thread;
  private volatile boolean isRunning = false; // Flag to control the thread
  //public int task = -1; //mark what I want to achieve on separate thread inside run() method
  String path_to_driver;
  String chrome_binary_path;

  ArrayList<Task>tasks = new ArrayList<Task>();
  //@BeforeMethod

  BrowserInstance(String _path_to_driver, String _chrome_binary_path ) {
    /*
    try {
     //kill previous instances
     //executeCommand("killall chromedriver");
     //executeCommand("killall chrome");
     //macos
     executeCommand("pkill -TERM -U $(id -u) -f \"chromedriver\"");
     executeCommand("pkill -TERM -U $(id -u) -f \"chrome\"");
     //pkill -TERM -U $(id -u) -f "ProcessName"
     }
     catch (Exception e) {
     println(e);
     }
     */

    path_to_driver = _path_to_driver;
    chrome_binary_path = _chrome_binary_path;

    doTask(START);
    //start(path_to_driver);
  }

  //enable quing tasks / commands - get id to query particular task
  class Task {
    int task; //task type
    long id;
    boolean finished = false;
    boolean started = false;
    long startedTime;
    String[] args;

    Task(int _task) {
      id = generateTaskId();
      task = _task;
    }
    Task(int _task, String[] _args) {
      id = generateTaskId();
      task = _task;
      args = _args;
    }

    public long generateTaskId() {
      long timestamp = System.currentTimeMillis(); // Current time in milliseconds
      int randomInt = new Random().nextInt(1000000); // Random number between 0 and 999999
      // Combine timestamp and random number using bit shifting
      return (timestamp << 32) | (randomInt & 0xFFFFFFFFL); // Combine into a long value
    }
  }

  public long doTask(int _task, String[] _args) {
    Task currTask = new Task(_task, _args);
    tasks.add(currTask);
    println("Added task "+_task+", id: "+currTask.id+" with parameters, in que: "+tasks.size());
    return currTask.id;
  }

  public long doTask(int _task) {
    Task currTask = new Task(_task);
    tasks.add(currTask);
    println("Added task "+_task+", id: "+currTask.id+" in que: "+tasks.size());
    return currTask.id;
  }

  public void execute() {
    //execute tasks in que one by one - allows issuing commands and not blocking main thread

    if (tasks==null || tasks.size()<1) {
      return;
    }

    //garbage finished tasks
    ArrayList<Task>aliveTasks = new ArrayList<Task>();
    for (int i=0; i<tasks.size(); i++) {
      Task task = tasks.get(i);
      if (!task.finished) {
        aliveTasks.add(task);
      } else {
        println("tak "+task.task+" finsihed");
      }
    }
    tasks = aliveTasks;

    if (tasks==null || tasks.size()<1) {
      return;
    }

    Task task = tasks.get(0);
    if (task.started) {
      return;
    } else {
      if (!isRunning) {
        isRunning = true;
        thread = new Thread(this);
        thread.start();  // Start the thread
      }
    }
  }

  public boolean isRunning() {
    return isRunning;
  }

  void run() {
    if (tasks==null || tasks.size()<1) {
      return;
    }

    try {
      while (isRunning) {

        Task task = tasks.get(0);
        task.startedTime = millis();
        int taskType = task.task;

        println("task started; type: "+task.task+ " id: "+task.id);

        if (taskType == LOGIN) { // login
          login();
        } else if (taskType == START) { //start browser
          start(path_to_driver, chrome_binary_path);
        } else if ( taskType == GETSTUDENTS ) {
          String[] studentNames = getStudents(); //studentNames is global var from attendence
          for (int i=0; i< studentNames.length; i++) {
            students.add(new Student(studentNames[i]) );
          }
        } else if ( taskType == MARKSTUDENT ) {
          boolean result = markStudentPresence(task.args[0], task.args[1] );
        }
        task.finished = true;
        isRunning = false;  // Assuming this is to stop the loop after login
        println("task finished");
      }
    }
    catch (Exception e) {
      // If the exception is thrown, check if isRunning is false and exit if needed
      if (!isRunning) {
        return;  // Instead of break, we return from the method to exit the loop
      }
      e.printStackTrace();
    }
  }

  public void start( String _path_to_driver, String _chrome_binary_path ) {
    int currOS = getOS();

    Map<String, Object> prefs = new HashMap<String, Object>(); //Create a map to store  preferences
    ChromeOptions options = new ChromeOptions(); //Create an instance of ChromeOptions

    if (currOS==0) { //MACOS - I am getting permission denied when trying to start from chromedriver so lets start on separate thread
      //String[] args = {"--no-sandbox", "--remote-debugging-port=9222", "--headless"};
      executeCommand( "open "+_chrome_binary_path+" --remote-debugging-port=8223 --no-sandbox");
      //executeCommand( "open "+_chrome_binary_path+" --remote-debugging-port=9222 --no-sandbox");
      options.addArguments("remote-debugging-port=8223");
      options.addArguments("headless");
    } else {
      options.setBinary(_chrome_binary_path); //path to chrome executable
      options.addArguments("headless"); //run headless
      options.addArguments("--no-sandbox");
      prefs.put("profile.default_content_setting_values.notifications", 2); //Pass the argument 1 to allow and 2 to block notifications
      options.setExperimentalOption("prefs", prefs); // set ExperimentalOption - prefs
    }
    
    System.setProperty("webdriver.chrome.driver", _path_to_driver );
    driver=new ChromeDriver(options); //use options to switch off notifications

    //driver.manage().window().setPosition(new Point(-2000, 0)); //move outside visible area
  }
  //@AfterMethod
  public void close() {
    try {
      if (driver != null) {
        driver.quit();
      }

      isRunning = false; // Signal the thread to stop
      if (thread != null) {
        thread.join(); // Wait for the thread to finish
      }
    }
    catch (InterruptedException e) {
      Thread.currentThread().interrupt();
    }
  }

  //-------------------------------------------------------------------
  //helper function to get elements on page
  void openLink(String uri) {
    driver.get(uri);
  }

  WebElement getbyXpath(String xpath) {
    WebElement ele = null;
    try {
      ele = driver.findElement( By.xpath( xpath ) );
    }
    catch(Exception e) {
      println("element not found ERROR: "+e);
      return null;
    }
    return ele;
  }

  WebElement[] getAllbyXpath(String xpath) {
    List<WebElement> ele = null;
    try {
      ele = driver.findElements( By.xpath( xpath ) );
    }
    catch(Exception e) {
      println("element not found ERROR: "+e);
      return null;
    }

    WebElement[] arr = new WebElement[ele.size()];
    for (int i = 0; i < ele.size(); i++) {
      arr[i] = ele.get(i);
    }
    return arr;
  }

  WebElement[] getAllByClassName(String name) {
    List<WebElement> ele = null;
    try {
      ele = driver.findElements( By.className( name ) );
    }
    catch(Exception e) {
      println("element not found ERROR: "+e);
      return null;
    }
    WebElement[] arr = new WebElement[ele.size()];
    for (int i = 0; i < ele.size(); i++) {
      arr[i] = ele.get(i);
    }
    return arr;
  }



  WebElement findElementByText(String findText) {
    try {
      WebElement e = driver.findElement(By.xpath("//*[text()='"+findText+"']"));
      System.out.println("Element with text(): " + e.getText() );
      return e;
    }
    catch(Exception error) {
      println("could not find element by text: "+ error);
      return null;
    }
  }

  void switchFocusToFrame(WebElement e) {
    instance.driver.switchTo().frame(e);
  }

  void scrollDown(int px, int py, int cycles) throws InterruptedException {
    for (int i = 0; i < cycles; i++) { //repeat behaviour
      if ( px >1 ) { //randomize scroll amount
        px = int( random( (float(px)-float(px)/10), (float(px)+float(px)/10) ) );
      }
      JavascriptExecutor js = (JavascriptExecutor) driver;
      String cmd = "window.scrollBy("+px+","+py+")";
      js.executeScript( cmd ); //window.scrollBy(x-pixels,y-pixels)
      Thread.sleep( int(random(510, 1110)));
    }
  }

  void sleepNow(int sleepFor) {
    try {
      Thread.sleep(sleepFor);
    }
    catch (InterruptedException e) {
      println(e);
      return; // Exit loop
    }
  }

  void sleepNow(int min, int max) {
    int sleepFor = int(random(min, max));
    try {
      Thread.sleep(sleepFor);
    }
    catch (InterruptedException e) {
      println(e);
      return; // Exit loop
    }
  }
  //-----------------------------------------------------------------------
  private void login() {
    try {
      sleepNow(500);
      instance.openLink(weburl);
      sleepNow(1000);
      WebElement username = instance.getbyXpath( "//div[label[contains(., 'mail')]]/input" );
      username.sendKeys( user );
      sleepNow(600, 1000);
      WebElement password = instance.getbyXpath( "//div[label[contains(., 'assword')]]/input" );
      password.sendKeys( pass );
      sleepNow(600, 1000);
      WebElement submit = instance.getbyXpath( "//input[@type='submit']" );
      submit.click();
      sleepNow(2000, 2500);
      //the Roll Call is external application that loads itself inside iframe - we need to switch focus there so we can search inside it
      instance.switchFocusToFrame(instance.getbyXpath("//iframe[@class='tool_launch']"));
    }
    catch(Exception e) {
      //catch(InterruptedException e) {
      println(e);
      instance.close();
    }
  }

  private boolean markStudentPresence(String name, String present) {
    try {
      //a[@aria-label='Click to view more information about "+name+"']
      String xpath = "//a[@aria-label='Click to view more information about "+name+"']";
      WebElement seeMore = instance.getbyXpath(xpath);
      seeMore.click();
      sleepNow(200, 250);
      if (present.equals("present")) { //PRESENT
        xpath = "//a[@aria-label='Mark as present']";
      } else if (present.equals("absent")) {//ABSENT
        xpath = "//a[@aria-label='Mark as absent']";
      } else if ( present.equals("late")) {//LATE
        xpath = "//a[@aria-label='Mark as late']";
      } else if ( present.equals("unmark")) { //RESET
        xpath = "//a[@aria-label='Unmark student']";
      } else {
        println("unsupported parameter");
        return false;
      }
      WebElement button = instance.getbyXpath(xpath);
      button.click();
      sleepNow(200, 250);
      seeMore.click(); //close the see more section
      sleepNow(100, 150);
      return true;
    }
    catch (Exception e) {
      println(e);
      return false;
    }
  }

  private String[] getStudents() {
    WebElement[] _students = instance.getAllbyXpath( "//div[contains(@class,'student-name')]" );
    if (students == null ) {
      println("students null");
      return null;
    }
    println("Found " + _students.length + " students");
    String names[] = new String[_students.length];

    for (int s=0; s<_students.length; s++) {
      names[s] = _students[s].getText();
    }
    return names;
  }

  /*
  private void markPresent(String name) {
   String xpath = "//a[@class='student-toggle'][.//div[contains(normalize-space(.), '"+name+"')]]";
   WebElement presentToggle = instance.getbyXpath(xpath);
   if (presentToggle!=null) {
   presentToggle.click();
   }
   }
   */
  //---------------------------------------------------------------------------
}
