import java.net.Socket;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.net.InetAddress;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;

//for clipboard
import java.awt.datatransfer.*;
import java.awt.Toolkit;


boolean ping(String host) {
  //throws IOException, InterruptedException
  try {
    boolean isWindows = System.getProperty("os.name").toLowerCase().contains("win");

    ProcessBuilder processBuilder = new ProcessBuilder("ping", isWindows? "-n" : "-c", "1", host);
    Process proc = processBuilder.start();

    proc.waitFor();
    if (proc.exitValue() == 0) {
      return true;
    } else {
      return false;
    }
  }
  catch(Exception e) {
    println(e);
    return false;
  }
}

int getOS() {
  String osname = System.getProperty("os.name");
  if (osname.indexOf("Mac") != -1) {
    return 0; //MAC
  } else if (osname.indexOf("Windows") != -1) {
    return 1; //WIN
  } else if (osname.equals("Linux")) {  // true for the ibm vm
    return 2; //Linux
  } else {
    return -1;
  }
}

//----------------------
String getIPAddress() {
  int os = getOS();
  String command;

  // Choose the correct command based on OS
  switch (os) {
  case 0:  // macOS
    command = "ipconfig getifaddr en0"; //ipconfig getifaddr en1 for wifi en0 for wired, but if no wired then just en0...for wifi ok
    break;
  case 2:  // Linux
    command = "ip route get 8.8.8.8";
    break;
  case 1:  // Windows
    command = "powershell -Command \"((Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch 'Loopback' }).IPAddress)[0]\"";
    break;
  default:
    return null;
  }
  String output = executeCommand(command);
  return parseIPAddress(output);
}


String executeCommand(String command) {
  if (command==null) {
    return null;
  }
  int os = getOS();
  try {
    ProcessBuilder builder;
    if (os == 1) { // Windows requires PowerShell execution
      builder = new ProcessBuilder("cmd.exe", "/c", command);
    } else if (os == 0) { // macOS
      //builder = new ProcessBuilder(command);
      builder = new ProcessBuilder("/bin/bash", "-c", command);
    } else {
      builder = new ProcessBuilder("sh", "-c", command);
    }

    Process process = builder.start();
    process.waitFor();
    BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
    StringBuilder output = new StringBuilder();
    String line;

    while ((line = reader.readLine()) != null) {
      output.append(line).append("\n");
    }
    reader.close();
    //println(output.toString());
    return output.toString().trim();
  }
  catch (Exception e) {
    println(e);
    return null;
  }
}

String parseIPAddress(String output) {
  int os = getOS();
  if (output == null || output.isEmpty()) {
    return null;
  }

  if (os == 2) { // Linux: Extract "src" IP
    String[] words = output.split("\\s+");
    for (int i = 0; i < words.length - 1; i++) {
      if (words[i].equals("src")) {
        return words[i + 1]; // Return the IP after "src"
      }
    }
  } else if (os == 1) { // Windows: First non-loopback IPv4
    String[] lines = output.split("\n");
    for (String line : lines) {
      if (line.matches("\\d+\\.\\d+\\.\\d+\\.\\d+")) {
        return line;
      }
    }
  } else if (os == 0) {
    return output;
  }
  return null;
}
//------------------------------------------------
String getClipboard() {
  try {
    // Access the system clipboard
    Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
    Transferable content = clipboard.getContents(null);

    if (content != null && content.isDataFlavorSupported(DataFlavor.stringFlavor)) {
      String pastedText = (String) content.getTransferData(DataFlavor.stringFlavor);
      return pastedText;
    }
  }
  catch (Exception e) {
    println("Error pasting clipboard content: " + e);
  }
  return null;
}
//------------------------------------------------------
class HeartBeat {
  int dots = 0;
  long tick = 0;
  boolean addDots = true;
  String indicator = "";

  HeartBeat() {
  }

  String getPulse() {
    return indicator;
  }

  void pulse() {
    if (millis()-tick>1000) {
      tick = millis();
      if (addDots) {
        dots++;
      } else {
        dots--;
      }
      if (dots>2) {
        addDots = false;
      }
      if (dots<1) {
        addDots = true;
      }

      indicator = "";
      for (int i=0; i<dots; i++) {
        indicator += ".";
      }
    }
  }
}
