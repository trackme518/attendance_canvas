var uniqueId = null;
var htmlscanner;

var debounceTimer = null;

function domReady(fn) {
  if (
    document.readyState === "complete" ||
    document.readyState === "interactive"
  ) {
    setTimeout(fn, 5000);
  } else {
    document.addEventListener("DOMContentLoaded", fn);
  }
}

// Make getId asynchronous
async function getId() {
  if (!navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) {
    console.log("enumerateDevices() not supported.");
    return null;
  }

  try {
    let devices = await navigator.mediaDevices.enumerateDevices();
    let videoDevice = devices.find((device) => device.kind === "videoinput");

    if (videoDevice && videoDevice.deviceId) {
      return videoDevice.deviceId; // Return the first camera device ID found
    }
  } catch (err) {
    console.error(`${err.name}: ${err.message}`);
  }

  return null;
}

async function markAttendance(decodeText) {

  if (debounceTimer) {
    var labelResult = document.getElementById("result");
    labelResult.textContent = "Wait 5 sec & try again";

    console.log("debounced");
    return; // Prevents calling again within 1 second - if set block
  }
  debounceTimer = setTimeout(() => {
    debounceTimer = null; // Reset timer after 1 second to null again - enable requests
  }, 1000);


  var uniqueId = await getId(); // Wait for deviceId to be retrieved
  var nameInput = document.getElementById("name").value.trim(); // Get the name input value

  // Store name in localStorage so it persists
  if (nameInput) {
    localStorage.setItem("savedName", nameInput);
  }


  if (uniqueId && nameInput) {
    var encodedId = encodeURIComponent(uniqueId);
    var encodedName = encodeURIComponent(nameInput); // URL encode the name

    var xhr = new XMLHttpRequest();
    xhr.open('GET', decodeText+'/api?id='+encodedId+'&name='+encodedName, true); // Include name in request
    //xhr.setRequestHeader("Authorization", uniqueId);
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4 ) { //xhr.status === 200
        const obj = JSON.parse(xhr.responseText);
        
        if(obj !=null ){
          console.log(obj);

          if("message" in obj){
            var labelResult = document.getElementById("result");
            labelResult.textContent = obj.message;

            if(obj.message == 'OK' && xhr.status === 200){
              htmlscanner.clear();  
              document.getElementById("my-qr-reader").style.display = "none";

            }
          }
        }
        //console.log(xhr.responseText);
      }
    };
    xhr.send();
  }
}

domReady(function () {
  // If found you qr code
  function onScanSuccess(decodeText, decodeResult) {
    //alert("You Qr is : " + decodeText, decodeResult);
    markAttendance(decodeText);
  }

  htmlscanner = new Html5QrcodeScanner(
    "my-qr-reader",
    { fps: 10, qrbos: 250 }
  );
  htmlscanner.render(onScanSuccess);
});


// Restore the saved name on page load
document.addEventListener("DOMContentLoaded", function () {
  var savedName = localStorage.getItem("savedName");
  if (savedName) {
    document.getElementById("name").value = savedName;
  }
});