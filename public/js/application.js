function getCookies() {
  var pairs = document.cookie.split(/; ?/);
  var cookies = {};
  for (var i = 0; i < pairs.length; i++) {
    var pair = pairs[i].split('=');
    cookies[(pair[0] + '').trim()] = unescape(pair.slice(1).join('='));
  }
  return cookies;
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
  var padToken = getCookies().token;
  // console.log("token = " + padToken);
  if (!padToken) return;
  url = $("#ep").data("urlToken");
  if (!url) return;
  // console.log("sending token to " + url);
  $.ajax({
    url: url,
    type: "POST",
    // contentType: "application/json",
    dataType: "json",
    data: { padToken: padToken },
    success: function() { console.log("success") }
  });
}

function requestPad(dom, data) {
  // console.log("setting pad token " + data['padToken']);
  document.cookie = 'token=' + data['padToken'];
  dom.pad(data);
  setTimeout(() => { sendPadTokenToServer(); }, 10000);
}

function loadEtherpad() {
  var dom = $('#ep');
  if (dom.data("padId")) {
    setTimeout(() => { requestPad(dom, dom.data()) }, 1000);
  }
}

document.addEventListener('turbo:load', function() {
  convertUTC();
  loadEtherpad();
});
