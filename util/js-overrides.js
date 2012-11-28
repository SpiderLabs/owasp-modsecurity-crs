XSSTripwire = new Object();

XSSTripwire.report = function() {
  // Notify server
  var notify = XSSTripwire.newXHR();
          
  // Create a results string to send back
  var results;
  results = "HTML=" + encodeURIComponent(document.body.outerHTML);
  notify.open("POST", XSSTripwire.ReportURL, true);
  notify.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
  notify.send(results);
}

XSSTripwire.newXHR = function() {
  var xmlreq = false;
  if (window.XMLHttpRequest) {
    xmlreq = new XMLHttpRequest();
  } else if (window.ActiveXObject) {
    // Try ActiveX
    try { 
      xmlreq = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e1) { 
      // first method failed 
      try {
        xmlreq = new ActiveXObject("Microsoft.XMLHTTP");
      } catch (e2) {
        // both methods failed 
      } 
    }
  }
  return xmlreq;
};

(function() {
  var proxiedAlert = window.alert;
  window.alert = function() {
    // URL of the page to notify, in the event of a detected XSS event:
    XSSTripwire.ReportURL = "xss-tripwire-report?function=window.alert";
    XSSTripwire.report();
    // Comment out the following line if you want to prevent the original
    // function from executing.
    return proxiedAlert.apply(this, arguments);
};
})();

(function() {
  var proxiedConfirm = window.confirm;
  window.confirm = function() {
    // URL of the page to notify, in the event of a detected XSS event:
    XSSTripwire.ReportURL = "xss-tripwire-report?function=window.confirm";
    XSSTripwire.report();
    // Comment out the following line if you want to prevent the original 
    // function from executing.
    return proxiedConfirm.apply(this, arguments);
};
})();

(function() {
  var proxiedPrompt = window.prompt;
  window.prompt = function() {
    // URL of the page to notify, in the event of a detected XSS event:
    XSSTripwire.ReportURL = "xss-tripwire-report?function=window.prompt";
    XSSTripwire.report();
    // Comment out the following line if you want to prevent the original 
    // function from executing.
    return proxiedPrompt.apply(this, arguments);
};
})();

(function() {
  var proxiedUnescape = unescape;
  unescape = function() {
    // URL of the page to notify, in the event of a detected XSS event:
    XSSTripwire.ReportURL = "xss-tripwire-report?function=unescape";
    XSSTripwire.report();
    // Comment out the following line if you want to prevent the original 
    // function from executing.
    return proxiedUnescape.apply(this, arguments);
  };
})();

(function() {
  var proxiedWrite = document.write;
  document.write = function() {
    // URL of the page to notify, in the event of a detected XSS event:
    XSSTripwire.ReportURL = "xss-tripwire-report?function=document.write";
    XSSTripwire.report();
    // Comment out the following line if you want to prevent the original 
    // function from executing.
    return proxiedWrite.apply(this, arguments);
  };
})();

(function() {
  var proxiedFromCharCode = String.fromCharCode;
  String.fromCharCode = function() {
    // URL of the page to notify, in the event of a detected XSS event:
    XSSTripwire.ReportURL = "xss-tripwire-report?function=String.fromCharCode";
    XSSTripwire.report();
    // Comment out the following line if you want to prevent the original 
    // function from executing.
    return proxiedFromCharCode.apply(this, arguments);
  };
})();
