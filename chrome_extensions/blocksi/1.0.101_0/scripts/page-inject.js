"use strict";

var isPrerendering = !1;

function regexCheck(regexList) {
    var txt = document.getElementsByTagName("html")[0].innerHTML, len = regexList.length, i;
    for (i = 0; len > i; i++) if (txt.search(new RegExp(regexList[i], "im")) !== -1) {
        window.location.replace("http://www.block.si/regex.php?url=" + window.location.host + "&reg=" + regexList[i]);
        break;
    }
}

function handleVisibilityChange() {
    if (!isPrerendering || location.host.indexOf("block.si") > -1) return;
    chrome.runtime.sendMessage({
        regex: !0
    }, function(response) {
        regexCheck(response.Regex);
    });
    isPrerendering = !1;
}

if ("prerender" !== document.webkitVisibilityState && location.host.indexOf("block.si") === -1) chrome.runtime.sendMessage({
    regex: !0
}, function(response) {
    regexCheck(response.Regex);
}); else {
    isPrerendering = !0;
    document.addEventListener("webkitvisibilitychange", handleVisibilityChange, !1);
}

window.addEventListener("message", function(event) {
    if (event.data.type && "FROM_PAGE" === event.data.type) {
        var urlLink = document.getElementById("url_link");
        chrome.runtime.sendMessage({
            warning: event.data.text,
            url: urlLink.innerText
        });
    }
}, !1);