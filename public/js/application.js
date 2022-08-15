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

function loadEtherpad() {
  var dom = $('#ep');
  if (!dom.data("padId")) return;
  dom.pad(dom.data());
}

document.addEventListener('turbo:load', function() {
  convertUTC();
  loadEtherpad();
});
