import javax.net.ssl.*;
import java.io.*;
import java.net.*;
import java.security.*;
import java.security.cert.*;
import java.util.concurrent.*;
import java.security.KeyStore;
import java.time.Instant;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.IOException;
import java.io.File;


import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

/*
  String encodedId = "YOUR_ENCODED_ID_HERE"; // Replace with the actual encoded ID
 String decodedId = URLDecoder.decode(encodedId, StandardCharsets.UTF_8);
 System.out.println("Decoded ID: " + decodedId);
 
 
 SSL
 
 openssl genpkey -algorithm RSA -out server.key
 openssl req -new -key server.key -out server.csr
 openssl x509 -req -in server.csr -signkey server.key -out server.crt
 
 openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12 -name myalias
 keytool -importkeystore -deststorepass password -destkeystore keystore.jks -srckeystore server.p12 -srcstoretype PKCS12 -alias myalias
 */

public class AsyncSSLServer {


  private int PORT = 4430;  // Port 443 for SSL, under 1000 are privliged - ie would need sudo
  private SSLServerSocket serverSocket;
  private ExecutorService threadPool = Executors.newFixedThreadPool(10);  // Thread pool for handling requests

  private volatile boolean running = false; // Control flag for the server loop
  private String status = "";

  private String SSLPASS = "rollcall666";
  public String path_2_cert_p12 = dataPath("server.p12");
  private final Map<String, byte[]> serverFiles = new HashMap<>();

  public AsyncSSLServer() {
    restart();
  }

  public void restart() {
    boolean initiated = initServer();
    if (initiated) {
      loadFiles();
      start();
    }
  }

  public int getPort() {
    return PORT;
  }

  public void setPort(int _port) {
    if (_port == PORT) {
      return;
    }
    PORT = _port;
    if (running) {
      close();
      restart();
    }
  }

  private void loadFiles() {
    File folder = new File(dataPath(""));
    if (!folder.exists() || !folder.isDirectory()) return;
    File[] files = folder.listFiles();

    for (File file : files) {
      String fileName = file.getName();
      if (fileName.endsWith(".html") || fileName.endsWith(".js") || fileName.endsWith(".css") || fileName.endsWith(".png") || fileName.endsWith(".jpg")) {
        try {
          serverFiles.put(fileName, Files.readAllBytes( file.toPath() ));
          System.out.println("Loaded: " + fileName);
        }
        catch (IOException e) {
          System.err.println("Error loading file: " + fileName);
        }
      }
    }
  }

  public boolean initServer() {
    try {
      // Set up SSL context with the server certificate
      KeyStore keyStore = KeyStore.getInstance("PKCS12");
      char[] SSLPASS = "rollcall666".toCharArray();
      FileInputStream keyStoreStream = new FileInputStream(path_2_cert_p12); // Path to the certificate
      keyStore.load(keyStoreStream, SSLPASS);

      KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
      keyManagerFactory.init(keyStore, SSLPASS);

      SSLContext sslContext = SSLContext.getInstance("TLS");
      sslContext.init(keyManagerFactory.getKeyManagers(), null, null);

      // Create SSL Server Socket Factory and Server Socket
      SSLServerSocketFactory sslServerSocketFactory = sslContext.getServerSocketFactory();
      serverSocket = (SSLServerSocket) sslServerSocketFactory.createServerSocket(PORT);

      // Set SO_REUSEADDR to allow re-binding even if port is in use
      //serverSocket.setReuseAddress(true);
      //serverSocket.bind(new InetSocketAddress(PORT));
      System.out.println("Server initiated on port " + PORT);
      status = "Server initiated on port " + PORT;
      return true;
    }
    catch (Exception e) {
      status = e.toString();
      e.printStackTrace();
    }
    return false;
  }

  public String getState() {
    return status;
  }

  public boolean isRunning() {
    return running;
  }

  public void start() {
    System.out.println("Server started on port " + PORT);
    running = true;
    // Run server in a separate thread
    new Thread(() -> {
      while (running) {
        try {
          SSLSocket clientSocket = (SSLSocket) serverSocket.accept();
          threadPool.execute(() -> handleClient(clientSocket)); // Handle request in a separate thread
        }
        catch (IOException e) {
          if (!running) break; // Exit loop if server is stopped
          e.printStackTrace();
        }
      }
    }
    ).start();
  }

  // Function to stop the server
  public void close() {
    running = false; // Stop accepting new connections
    try {
      if (serverSocket != null && !serverSocket.isClosed()) {
        serverSocket.close(); // Close server socket
      }
      threadPool.shutdown(); // Shutdown the thread pool
      System.out.println("Server stopped.");
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }

  private void handleClient(SSLSocket clientSocket) {
    try (BufferedReader reader = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
    OutputStream outputStream = clientSocket.getOutputStream()) {

      InetAddress clientAddress = clientSocket.getInetAddress();
      String clientIp = clientAddress.getHostAddress();

      String input = reader.readLine();
      if (input == null) return;

      String[] urlSplit = input.split(" ");
      if (urlSplit.length < 1) {
        outputStream.write(getHttpResponse(400, "text/html", "Bad Request"));
        return;
      }

      String url = urlSplit[1].substring(1);
      if (url.isEmpty()) url = "index.html"; //default

      if (url.startsWith("api")) {
        handleApiRequest(url, outputStream, clientIp);
      } else if (serverFiles.containsKey(url)) {
        serveFile(url, outputStream);
      } else {
        outputStream.write(getHttpResponse(404, "text/html", "Not Found"));
      }
    }
    catch (IOException e) {
      e.printStackTrace();
    }
    finally {
      try {
        clientSocket.close();
      }
      catch (IOException ignored) {
      }
    }
  }

  private void handleApiRequest(String url, OutputStream outputStream, String clientIp) throws IOException {
    Map<String, String> queryParams = getQueryParams(url);
    String idValue = queryParams.get("id");
    String nameValue = queryParams.get("name");

    if (idValue == null || nameValue == null ) {
      outputStream.write(getHttpResponse(400, "application/json", "{\"status\":400,\"message\":\"Missing parameters id and name\"}"));
    } else {
      
      long unixTimestamp = Instant.now().getEpochSecond();
      
      String decodedId = URLDecoder.decode( idValue, StandardCharsets.UTF_8 );
      String decodedName = URLDecoder.decode( nameValue, StandardCharsets.UTF_8 );
      //-------------------------------------------------------
      //perform action isnide Selenium engine - see driver tab
      println("client request from "+clientIp+" name: "+decodedName);
      
      Student student = getStudent(decodedName, clientIp, decodedId);
      if (student!=null) {
        student.markStudent();
        outputStream.write(getHttpResponse(200, "application/json", "{\"status\":200,\"message\":\"OK\", \"timestamp\":" + unixTimestamp + "}"));
      } else {
        outputStream.write(getHttpResponse(400, "application/json", "{\"status\":400,\"message\":\"Name does not match!\", \"timestamp\":" + unixTimestamp + "}"));
        println("student does not exist! Wrong name");
      }
      //--------------------------------------------------------
    }
  }

  private void serveFile(String url, OutputStream outputStream) throws IOException {
    String contentType = getContentType(url);
    outputStream.write(("HTTP/1.0 200 OK\r\nContent-Type: " + contentType + "\r\n\r\n").getBytes());
    outputStream.write(serverFiles.get(url));
  }

  private Map<String, String> getQueryParams(String url) {
    Map<String, String> queryParams = new HashMap<>();
    if (url.contains("?")) {
      String[] parts = url.split("\\?");
      if (parts.length > 1) {
        String queryString = parts[1];
        for (String param : queryString.split("&")) {
          String[] keyValue = param.split("=");
          if (keyValue.length == 2) {
            queryParams.put(keyValue[0], URLDecoder.decode(keyValue[1], StandardCharsets.UTF_8));
            //queryParams.put(keyValue[0], URLDecoder.decode(keyValue[1], StandardCharsets.UTF_8));
          }
        }
      }
    }
    return queryParams;
  }

  private byte[] getHttpResponse(int status, String type, String message) {

    String response = "HTTP/1.0 " + status + "\r\nContent-Type: "+type+"\r\n\r\n" + message;
    return response.getBytes();
  }

  private String getContentType(String url) {
    if (url.endsWith(".html")) return "text/html";
    if (url.endsWith(".js")) return "application/javascript";
    if (url.endsWith(".css")) return "text/css";
    if (url.endsWith(".png")) return "image/png";
    if (url.endsWith(".jpg")) return "image/jpeg";
    if (url.endsWith(".json")) return "application/json";
    return "application/octet-stream";
  }
}
