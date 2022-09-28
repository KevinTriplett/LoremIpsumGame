function getCookie(name) {
  var value = `; ${document.cookie}`;
  var parts = value.split(`; ${name}=`);
  if (parts.length === 2) return parts.pop().split(';').shift();
}

function setCookie(name, value) {
<<<<<<< HEAD
  if (!value || value === "undefined") return;
  console.log(`setting cookie ${name}=${value}`);
=======
  // console.log("setting pad token " + data['padToken']);
  if (value === "undefined") return;
>>>>>>> 1837e2522decae6af3f9f746e6dee09cdeb5934f
  var date = new Date();
  date.setTime(date.getTime() + (7 * 24 * 60 * 60 * 1000)); // one week
  document.cookie = [
    `${ name }=${ value }`,
    `expires=${ date.toUTCString() }`,
    "path=/"
  ].join("; ");
}

function optShortDateAtTime(tzString) {
  return {
    timeZone: tzString,
    weekday: "short",
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "numeric"
  };
}

function optShortDate(tzString) {
  return {
    timeZone: tzString,
    weekday: "short",
    month: "short",
    day: "numeric"
  };
}

function optTimeAndDay(tzString) {
  return {
    timeZone: tzString,
    weekday: "short",
    hour: "numeric",
    minute: "numeric"
  };
}

function getFormat(className, tzString) {
  switch(className) {
  case "game-start":
  case "game-end":
    // return optShortDateAtTime(tzString)
    return optShortDate(tzString)
  case "turn-start":
  case "turn-end":
    return optTimeAndDay(tzString)
  }
  return {
    timeZone: tzString,
    dateStyle: "full",
    timeStyle: "short"
  }
}

function convertTZ(datetime, className, tzString) {
  date = new Date((typeof datetime == "string" ? new Date(datetime) : datetime));
  return date.toLocaleString("en-US", getFormat(className, tzString));   
}

function convertUTC() {
  var timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
  $(".utc-time").each( function(i, dom){
    dom = $(dom);
    datetime = dom.text();
    className = dom.attr("class").split(" ")[1];
    datetime = convertTZ(datetime, className, timezone);
    if (datetime === "Invalid Date") return;
    dom.text(datetime);
  })
};

function sendPadTokenToServer() {
  var url = $("#ep").data("urlToken");
<<<<<<< HEAD
  console.log(`url = ${url}`);
  if (!url) return;
  var padToken = getCookie("token");
  if (padToken) {
    console.log(`sending token = ${padToken} to ${url}`);
    $.ajax({
      url: url,
      type: "POST",
      dataType: "json",
      data: { padToken: padToken },
      success: function() { console.log("success") },
      error: function() { console.log("error") }
    });
  } else {
    setTimeout(sendPadTokenToServer, 1000);
=======
  var padToken = getCookie("token");
  // console.log("token = " + padToken + " and url = " + url);
  if (!url || !padToken || padToken === "undefined") return;
  // console.log("sending token to " + url);
  $.ajax({
    url: url,
    type: "POST",
    // contentType: "application/json", rails didn't like this in early development
    dataType: "json",
    data: { padToken: padToken },
    success: function() { console.log("success") },
    error: function() { console.log("error") }
  });
}

function requestPad(dom, data) {
  setCookie('token', data['padToken']);
  dom.pad(data);
  setTimeout(() => { sendPadTokenToServer(); }, 10000);
}

function loadEtherpad() {
  var dom = $('#ep');
  if (dom.data("padId")) {
    setTimeout(() => { requestPad(dom, dom.data()) }, 1000);
>>>>>>> 1837e2522decae6af3f9f746e6dee09cdeb5934f
  }
}

function loadEtherPad() {
  var dom = $("#ep");
  if (!dom.data("padId")) return;
  var padToken = dom.data("padToken");
  setCookie("token", padToken);
  dom.pad(dom.data());
  setTimeout(sendPadTokenToServer, 10000);
}

document.addEventListener('turbo:load', function() {
  console.log(`cookies = ${document.cookie}`);
  convertUTC();
  setTimeout(loadEtherPad, 1000);
});
