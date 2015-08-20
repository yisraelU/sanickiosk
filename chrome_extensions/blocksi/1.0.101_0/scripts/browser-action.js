"use strict";

function addToList(url, action) {
    chrome.runtime.sendMessage({
        BW: "add",
        url: url,
        action: action
    });
}

function i18n() {
    return chrome.i18n.getMessage.apply(chrome.i18n, arguments) || arguments[0];
}

function queryKey(PageUrl) {
    if (!PageUrl) return !1;
    var start = PageUrl.indexOf("url=") + 4;
    if (1 == start) return !1;
    var end = PageUrl.indexOf("&", start);
    if (end == -1) end = PageUrl.length;
    return PageUrl.substring(start, end);
}

document.getElementById("allowLabel").innerHTML = document.getElementById("allowLabel").innerHTML + i18n("allow");

document.getElementById("blockLabel").innerHTML = document.getElementById("blockLabel").innerHTML + i18n("block");

!function() {
    document.getElementById("checkPass").innerHTML = i18n("ok");
    chrome.tabs.getSelected(null, function(tab) {
        var url = new URL(tab.url);
        if (url.hostname.indexOf("block.si") > -1) {
            document.getElementById("url").innerHTML = queryKey(url.search);
            document.getElementById("allow").checked = !1;
            document.getElementById("block").checked = !0;
            document.getElementById("allowLabel").classList.remove("active");
            document.getElementById("blockLabel").classList.add("active");
        } else {
            document.getElementById("url").innerHTML = url.host;
            chrome.runtime.sendMessage({
                BW: "action",
                url: url
            }, function(response) {
                if (1 === response.action) {
                    document.getElementById("allow").checked = !1;
                    document.getElementById("block").checked = !0;
                    document.getElementById("allowLabel").classList.remove("active");
                    document.getElementById("blockLabel").classList.add("active");
                }
            });
        }
    });
}();

document.getElementById("save").onclick = function(e) {
    e.stopPropagation();
    chrome.runtime.sendMessage({
        BW: "password"
    }, function(response) {
        if (response.password === !1) {
            var url = document.getElementById("url").textContent, radios = document.action.bwlist;
            for (var i = 0, length = radios.length; length > i; i++) if (radios[i].checked) {
                addToList(url, parseInt(radios[i].value, 10));
                window.close();
                break;
            }
        } else {
            document.getElementById("save").classList.add("hidden");
            document.getElementById("container").classList.add("hidden");
            document.getElementById("password-dialog").style.display = "block";
        }
    });
};

var elems = document.action.bwlist, i;

var prev = null;

function radioClick() {
    return function() {
        if (this !== prev) prev = this;
        var active = document.getElementsByClassName("active");
        for (var i = 0; i < active.length; i++) active[i].classList.remove("active");
        this.parentNode.classList.add("active");
        var d = document.getElementById("save");
        d.classList.remove("hidden");
        d.classList.add("fadeIn");
    };
}

for (i = 0; i < elems.length; i++) elems[i].addEventListener("click", radioClick(i));

document.getElementById("checkPass").onclick = function(e) {
    e.stopPropagation();
    chrome.runtime.sendMessage({
        BW: "password"
    }, function(response) {
        var password = document.getElementById("password").value, url = document.getElementById("url").textContent;
        if (response.password === md5(password)) {
            var radios = document.action.bwlist;
            for (var i = 0, length = radios.length; length > i; i++) if (radios[i].checked) {
                addToList(url, parseInt(radios[i].value, 10));
                break;
            }
            window.close();
        } else {
            document.getElementById("message").innerHTML = i18n("wrongPass");
            document.getElementById("message").style.display = "block";
        }
    });
};