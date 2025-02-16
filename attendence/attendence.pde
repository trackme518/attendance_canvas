import com.cage.zxing4p3.*;
ZXING4P zxing4p;
PImage  QRCode;

BrowserInstance instance;

String weburl = "https://canvas.instructure.com/courses/10987072/external_tools/90097";

String user = null; //provide the creditianls in GUI (paste into text fields) and click save
String pass = null; //data are saved in data.json file inside data folder

boolean loaded = false;
boolean loading = false;

AsyncSSLServer server;

//get assigned from BrowserInstance when calling getStudents
ArrayList<Student> students = new ArrayList<Student>();

String serverIp = null;

HeartBeat heartBeat;

int qrCodeSize = 720;
/////////////////////////////////////////////////////

void setup() {
  size(1280, 720, P2D);
  windowTitle("Canvas Attendence"); 
  windowResizable(true);
  windowMove(60, 60);

  heartBeat = new HeartBeat();

  loadFromJson(); //load username, password and url from file

  initGUI();

  zxing4p = new ZXING4P();
  zxing4p.version(); //show version in console

  //determine OS and choose appropriate web browser executable - I have downloaded ungoogled chromium for this

  startBrowser();

  server = new AsyncSSLServer();
}
///////////////////////////////////////////////////////////
//end setup
void windowResized() {
  if (width<height) {
    qrCodeSize = width;
  } else {
    qrCodeSize = height;
  }
}

void draw() {
  background(0);
  heartBeat.pulse();

  if (instance!=null) {
    instance.execute(); //call continously - execute commands in que one by one on separate thread

    if (instance.isRunning()) {
      pushStyle();
      fill(255);
      textFont(largefont);
      textSize(36);
      text( heartBeat.getPulse(), width-height-60, 30 );
      fill(255, 0, 0);
      popStyle();
      //circle(width-720-60, 30, 30);
    }
  }

  //get server IP - my localIP
  if (serverIp!=null) {
    pushStyle();
    textSize(14);
    fill(255);
    stroke(255);
    line(30, 30, textWidth(serverIp), 30);

    text(serverIp, 30, 30);
    popStyle();
  }

  if (QRCode==null && server!=null && serverIp==null) {
    String currIp = getIPAddress();
    if (currIp!=null) {
      serverIp = "https://"+getIPAddress()+":"+server.getPort();
      generateQRCode(serverIp, 720, 720);
    }
  }

  if (QRCode!=null) {
    image(QRCode, width-qrCodeSize, 0, qrCodeSize, qrCodeSize);
  }

  if (students!=null) {
    for (int i=0; i< students.size(); i++) {
      students.get(i).render(30, 60+30*i);
    }
  }

  renderGUI();
}

void generateQRCode(String textToEncode, int w, int h) {
  if (textToEncode==null) {
    return;
  }
  QRCode = zxing4p.generateQRCode(textToEncode, w, h);
  QRCode.save(dataPath("qrcode_tmp.gif"));
  QRCode = loadImage("qrcode_tmp.gif");
}

void exit() {
  println("exiting...");
  try {
    if (instance!=null) {
      server.close();
      instance.close();
      executeCommand("killall chromedriver");
      executeCommand("killall chrome");
    }
  }
  catch(Exception e) {
    println(e);
  }
  //put code to run on exit here
  super.exit();
}

//--------------------------
void startBrowser() {
  if (user==null || pass==null || weburl==null) {
    return;
  }

  int currOS = getOS();
  String browser_build_dir = "";
  String chrome_binary_path = "";

  if (currOS==0) { //MACOS
    String arch = System.getProperty("os.arch");
    if (arch.contains("aarch64") || arch.contains("arm64")) {
      System.out.println("Running on MACOS Apple Silicon (ARM64)");
      browser_build_dir = dataPath("chromedriver"+File.separator+"macos_silicon");
    } else {
      System.out.println("Running on MACOS Intel (x86_64)");
      browser_build_dir = dataPath("chromedriver"+File.separator+"macos_intel");
    }
  } else if (currOS == 1) { //WIN
    println("Running on WINDOWS");
    browser_build_dir = dataPath("chromedriver"+File.separator+"win64");
  } else if (currOS == 2) { //Linux
    println("Running on  LINUX");
    browser_build_dir = dataPath("chromedriver"+File.separator+"linux64");
    chrome_binary_path = browser_build_dir+File.separator+"chrome.AppImage";
  }

  if(instance!=null) {
    instance.close();
  }

  String chromedriver_path = browser_build_dir+File.separator+"chromedriver";

  instance = new BrowserInstance( chromedriver_path, chrome_binary_path );
  instance.doTask(instance.LOGIN);
  instance.doTask(instance.GETSTUDENTS);
}
