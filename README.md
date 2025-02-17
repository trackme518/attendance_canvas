# QR Code Attendance Automation for Canvas Roll Call

This project automates the attendance tracking system for the Canvas educational framework using a QR code-based method. 

## Problem Background
Canvas uses the Roll Call plugin to track attendance, but unfortunately, this plugin does not have an API. To overcome this, this Java application utilizes **Selenium** and **Ungoogled Chromium** in headless mode to interact with Canvas's Roll Call Attendance system. It interacts with the website as you would normally did (ie clicks on web elements identified via Xpath). 

## Overview of the Solution
This Java application runs on your PC and serves an asynchronous HTTPS server using a **self-signed certificate**. The server runs on port **4430**.

Once the server is running, the application generates a **QR code** that points to the local server. Students can scan the QR code to mark themselves as present. 

### Requirements
- **Canvas teacher credentials**: You will need your Canvas username and password.
- **Canvas Attendance URL**: The URL of the page with the Roll Call attendance feature for your class.

### Installation ###
[Download latest release](https://github.com/trackme518/attendence_canvas/releases/latest). Unzip it with 7zip( you can install 7zip from [source](https://www.7-zip.org/download.html), or on Ubuntu: `sudo apt install p7zip-full p7zip-rar` ), the App is packaged with all binaries so no further installation is needed, all dependencies are included.

**Linux**
- Enable 4430 port in your firewall. In terminal run `sudo ufw allow 4430/tcp`
- Mark executable `chrome.AppImage` and `chromedriver` in `attendence/data/chromedriver/linux64/` - on Ubuntu you can right-click->Properties->Executable as Program or in terminal `chmod a+x chrome.AppImage`
- On Ubuntu, to use the .AppImage you may need to install `sudo apt install libfuse2` (can coexist with libfuse3)

**MacOS**
- Allow the app in Privacy & Security one by one as needed. To allow all programs from Everywhere (and get rid of this problem for good), follow the [tutorial](https://macpaw.com/how-to/allow-apps-anywhere).
- You might need to run command `xattr -r -d com.apple.quarantine attendence` on the attendence directory to remove quarantine flag (downloaded from internet).

**Windows**
- Enable port 4430 in firewall 

### Screenshot of Canvas Attendance Page

![Screenshot of the Canvas Roll Call Page](./images/canvas.jpg)

### Screenshot of App Settings

![Screenshot of the Java App](./images/app_screenshot.jpg)

## How to Use

### 1. Set Up the Application
After launching the app, you will need to provide the following:
- **Canvas URL**: The URL of the Canvas attendance page.
- **Canvas Username**: Your Canvas login username.
- **Canvas Password**: Your Canvas login password.
- **Connect to school WiFi**: You need to be connected to local WiFi that students have acces to - students connect locally to your PC.

These can be entered directly into the app as shown in the screenshot above. Then let the app load and show your students the QR code - they can scan it with their phone. 

### 2. Save the Credentials
Once you have entered the necessary information (URL, username, and password), click **Save**. The app will remember these settings for the future. 

- **Note**: You will need to log in only once. The next time you start the app, it will automatically load the credentials and log you in.

### 3. Login and Load Attendance
When you start the app, it will try to log in, which may take up to 10 seconds. Let the app complete this process. 

While the app is working in the background, you will see three animated dots at the top of the screen, indicating that it is running.

### 4. Loading Students
Once logged in, the app will fetch all student names from the Canvas attendance page. The names will be displayed next to grey circles.

### 5. QR Code Generation
The app will generate a QR code that points to a **local web address** on your PC. This web page is served by the local server running on port **4430**. 

Students can scan the QR code using their mobile phones. The web page will allow them to enter their name (their  name will be saved persistently in their browser).

### 6. Marking Attendance
Once the students have entered their name, they can scan the QR code again, and the app will automatically mark them as present - the grey circle next to their name will turn green. 
If the they scan QR code 15+ minutes later after the app was started it will mark them as late, later than 60+ minutes as absent.  

### 7. Progressive Web App (PWA)
Students can save the web page as a Progressive Web App (PWA) to their phone's homepage for easier access. This way, they can quickly mark themselves present every time.
The **name provided need to match the Canvas name**! So if instead of name, someone has a number the number needs to be submitted. To save the website to phone's homepage click options in browser and select **Add to Home screen**. 
See screenshot below:

![Screenshot_20250215-231819(2)](./images/pwa_add_to_homescreen.jpg)

The succesful presence noted:

![Screenshot_20250215-231822(1)](./images/pwa_screenshot_succes.jpg)


## Conclusion
This solution automates the attendance process for Canvas using QR codes, making it easier and faster for students to mark their attendance. It also eliminates the need for manual entry by teachers.

## Cheating
To prevent cheating I am **tracking request IP address**. Each time the student mark themself present it will note their IP - if the IP is same as the other student, the **other student will be unmarked!**. 
To further discourage cheating I am also tracking unique videoinput device id (ie phone's camera) and use it same way as IP - any IP / videoinput id can not be the same as other student's. 

## Architecture
I am using [Java Processing](https://processing.org/) - uses Java 17, [Selenium](https://www.selenium.dev/downloads/) and [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium). 
In particular I am using Selenium 4.28.1 for Java, January 23, 2025 - that is version 133 and Ungoogled Chromium 133 (instead of Chrome for Testing - it is just easier to package thanks to AppImage on linux). If you update the chromium it likely breaks as the Selenium expects certain version of the driver to go along with it.   

## Download
Download the latest build from Releases.  

## Like it?
Please star the repo :-).

## Warning
Your Canvas password and username is saved inside the App - it is assumed it is running on your PC only. Take care of securing your PC to prevent leak. 

## Licence
You can download the release for non-commercial, personal use. If you want to deploy in your ogranization please contact me for licencing. 

 <p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/trackme518/attendence_canvas"> QR Code Attendance Automation for Canvas Roll Call</a> by <span property="cc:attributionName">Vojtech Leischner</span> is licensed under <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-ND 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nd.svg?ref=chooser-v1" alt=""></a></p> 

