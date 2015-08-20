"use strict";

var getJSON = function(url, async, successHandler, errorHandler) {
    var xhr = new XMLHttpRequest();
    xhr.open("get", url, async);
    xhr.setRequestHeader("x-api-key", apikey);
    if (void 0 === async || async === !1) {
        xhr.send();
        if (200 === xhr.status) return xhr.response; else return !1;
    } else {
        xhr.responseType = "json";
        xhr.timeout = 1e3;
        xhr.onload = function() {
            var status = xhr.status;
            if (200 === status) successHandler && successHandler(xhr.response); else errorHandler && errorHandler(status);
        };
        xhr.send();
    }
};

function sendLog(PageUrl, cat, action) {
    if (s.companyId && s.userName && s.validationCode) chrome.identity.getProfileUserInfo(function(userInfo) {
        var today = new Date();
        var dd = today.getDate();
        if (10 > dd) dd = "0" + dd;
        var mm = today.getMonth() + 1;
        if (10 > mm) mm = "0" + mm;
        var yyyy = today.getFullYear();
        var date = yyyy + "-" + mm + "-" + dd;
        var h = today.getHours();
        if (10 > h) h = "0" + h;
        var min = today.getMinutes();
        if (10 > min) min = "0" + min;
        var sec = today.getSeconds();
        if (10 > sec) sec = "0" + sec;
        var time = h + ":" + min + ":" + sec;
        today.setHours(today.getHours() - today.getTimezoneOffset() / 60);
        var timestamp = today.toJSON();
        var reqUrl = "http://service.block.si/elasticsearch?date=" + date + "&time=" + time + "&Extension_Version=" + chrome.app.getDetails().version + "&timestamp=" + timestamp + "&userEmail=" + userInfo.email + "&Hostname=" + PageUrl.hostname + "&User_ID=" + s.userName + "&Company_ID=" + s.companyId + "&URL=" + PageUrl.hostname + "&Category=" + cat + "&Category_Action=" + action;
    });
}

function checkAction(PageUrl, cat, action) {
    sendLog(PageUrl, cat, action);
    if (0 === action) return {
        cancel: !1
    };
    if (1 === action) return {
        redirectUrl: "http://www.block.si/block.php?url=" + PageUrl.hostname + "&category=" + cat
    };
    if (2 === action) return {
        redirectUrl: "http://www.block.si/warning.php?url_link=" + encodeURIComponent(PageUrl.href) + "&category=" + cat
    };
}

function localIP(ipAddress) {
    var ip = ipAddress.split(".");
    if (4 === ip.length) {
        var x = [ parseInt(ip[0], 10), parseInt(ip[1], 10), parseInt(ip[2], 10), parseInt(ip[3], 10) ];
        var from = [ [ 10, 0, 0, 0 ], [ 172, 16, 0, 0 ], [ 192, 168, 0, 0 ], [ 127, 0, 0, 1 ] ];
        var to = [ [ 10, 255, 255, 255 ], [ 172, 31, 255, 255 ], [ 192, 168, 255, 255 ], [ 127, 0, 0, 1 ] ];
        if (isNaN(x[0]) || isNaN(x[1]) || isNaN(x[2]) || isNaN(x[3])) return !1;
        var i = 3;
        while (i > -1) {
            if (from[i][0] <= x[0] && to[i][0] >= x[0] && from[i][1] <= x[1] && to[i][1] >= x[1] && from[i][2] <= x[2] && to[i][2] >= x[2] && from[i][3] <= x[3] && to[i][3] >= x[3]) return !0;
            i--;
        }
    }
    return !1;
}

function checkURL(PageUrl) {
    var action;
    var lan = localIP(PageUrl.hostname);
    if (lan) return {
        cancel: !1
    };
    var data = getJSON("http://service2.block.si/getRating.json?url=" + PageUrl.hostname);
    if (data) {
        var pageInfo = JSON.parse(data);
        if (void 0 === pageInfo.status) {
            action = s.userSettings.webFilter[pageInfo.Category].a;
            return checkAction(PageUrl, pageInfo.Category, action);
        } else return {
            cancel: !1
        };
    } else return {
        cancel: !1
    };
}

function checkBlackWhite(PageUrl) {
    var len = s.userSettings.bwList.length, data, i;
    if (0 === len) return checkURL(PageUrl);
    for (i = 0; len >= i; i++) if (i === len) return checkURL(PageUrl); else if (s.userSettings.bwList[i][0] === PageUrl.hostname.replace("www.", "") || s.userSettings.bwList[i][0] === PageUrl.hostname) {
        if (1 === s.userSettings.bwList[i][1] || "1" === s.userSettings.bwList[i][1]) if (data && void 0 === pageInfo.status) return {
            redirectUrl: "http://www.block.si/block.php?url=" + PageUrl.hostname + "&category=" + pageInfo.Category + "&bwlist=1"
        }; else return {
            redirectUrl: "http://www.block.si/block.php?url=" + PageUrl.hostname + "&category=700&bwlist=1"
        }; else return {
            cancel: !1
        };
        break;
    }
}

function extractVideoID(PageUrl) {
    if (!PageUrl) return !1;
    var start = PageUrl.indexOf("v=") + 2;
    if (1 == start) return !1;
    var end = PageUrl.indexOf("&", start);
    if (end == -1) end = PageUrl.length;
    return PageUrl.substring(start, end);
}

function checkYoutube(PageUrl) {
    var videoID = extractVideoID(PageUrl.search), url = "http://www.youtube.com/watch?v=5jVhna6IRB8", data, rating;
    if (videoID && "5jVhna6IRB8" !== videoID) {
        data = getJSON("https://www.googleapis.com/youtube/v3/videos?key=" + YTKey + "&part=snippet&fields=items(id,snippet(title,description,categoryId,channelId,channelTitle))&id=" + videoID);
        data2 = getJSON("https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=" + videoID + "&key=" + YTKey);
        if (data) {
            rating = JSON.parse(data);
            for (var i = 0; i < s.userSettings.ytChannelList.length; i++) if (rating.items[0].snippet.channelTitle == s.userSettings.ytChannelList[i][0] || rating.items[0].snippet.channelId == s.userSettings.ytChannelList[i][0]) if ("0" == s.userSettings.ytChannelList[i][1] || 0 == s.userSettings.ytChannelList[i][1]) return {
                cancel: !1
            }; else if ("1" == s.userSettings.ytChannelList[i][1] || 1 == s.userSettings.ytChannelList[i][1]) return {
                redirectUrl: url
            };
            for (var i = 0; i < s.userSettings.ytKeywords.length; i++) if (rating.items[0].snippet.title.toLowerCase().indexOf(s.userSettings.ytKeywords[i]) > -1 || rating.items[0].snippet.description.toLowerCase().indexOf(s.userSettings.ytKeywords[i]) > -1) return {
                redirectUrl: url
            };
            if (data2) {
                ageRestriction = JSON.parse(data2);
                if (ageRestriction.items[0].contentDetails.contentRating.ytRating.indexOf("ytAgeRestricted") > -1 && 1 == s.userSettings.ytAgeRestriction) return {
                    redirectUrl: url
                };
            }
            if (1 === s.userSettings.ytFilter["yt_" + rating.items[0].snippet.categoryId].a) return {
                redirectUrl: url
            }; else return {
                cancel: !1
            };
        }
    } else return checkBlackWhite(PageUrl);
}

function checkAccTimes(PageUrl) {
    var now = new Date(), then = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0), diff = now.getTime() - then.getTime(), day = now.getDay();
    if ("x" != s.userSettings.AccTimes[day]) {
        var len = s.userSettings.AccTimes[day].length, i;
        if ("undefined" != typeof s.userSettings.AccTimes[day]) if ("string" == typeof s.userSettings.AccTimes[day]) {
            var periods = s.userSettings.AccTimes[day].split(",");
            for (var i = 0; i < periods.length; i++) {
                var FromTo = periods[i].split("_");
                var from = parseInt(FromTo[0].split(":")[0]);
                var to = parseInt(FromTo[1].split(":")[0]);
                var t1_ = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0), from_ = new Date(t1_.getFullYear(), t1_.getMonth(), t1_.getDate(), from, 0, 0), till_ = new Date(t1_.getFullYear(), t1_.getMonth(), t1_.getDate(), to, 0, 0);
                var diff1 = from_.getTime() - t1_.getTime(), diff2 = till_.getTime() - t1_.getTime();
                if (i === len) break; else if (diff > diff1 && diff2 > diff) {
                    var t1 = new Date(0, 0, 0, 0, 0, 0, diff1).getHours(), t2 = new Date(0, 0, 0, 0, 0, 0, diff2).getHours();
                    if (10 > t1) t1 = "0" + t1;
                    if (10 > t2) t2 = "0" + t2;
                    t1 += ":00:00";
                    t2 += ":00:00";
                    return {
                        redirectUrl: "http://www.block.si/acctime.php?t1=" + t1 + "&t2=" + t2
                    };
                }
            }
        }
    }
    if ("www.youtube.com" === PageUrl.host) return checkYoutube(PageUrl); else return checkBlackWhite(PageUrl);
}

function pageCheck(url) {
    var PageUrl = new URL(url);
    var whitelist = [ "accounts.google.com", "blocksimanager.appspot.com", "www.block.si", "www.google.com", "service2.block.si", "service.block.si" ];
    var i = 5;
    if ("true" == s.userSettings.SafeSearch) if (PageUrl.hostname.indexOf("www.google") > -1 && PageUrl.href.indexOf("safe=active") < 0) if (PageUrl.search.length > 0) return {
        redirectUrl: PageUrl.href + "&safe=active"
    }; else return {
        redirectUrl: PageUrl.href + "?safe=active"
    }; else if (PageUrl.hostname.indexOf("www.bing") > -1 && PageUrl.href.indexOf("adlt=strict") < 0) return {
        redirectUrl: PageUrl.href + "&adlt=strict"
    }; else if (PageUrl.hostname.indexOf("search.yahoo") > -1 && PageUrl.href.indexOf("vm=r") < 0) return {
        redirectUrl: PageUrl.href + "&vm=r"
    };
    while (i > -1) {
        if (whitelist[i] === PageUrl.hostname) return {
            cancel: !1
        };
        i--;
    }
    while (i > -1) {
        if (whitelist[i] === PageUrl.hostname) return {
            cancel: !1
        };
        i--;
    }
    if ("http:" === PageUrl.protocol || "https:" === PageUrl.protocol) if (s.userSettings.AccTimeEnabled) return checkAccTimes(PageUrl); else if ("www.youtube.com" === PageUrl.host) return checkYoutube(PageUrl); else return checkBlackWhite(PageUrl); else return {
        cancel: !1
    };
}

var s;

chrome.storage.local.clear();

function updateChromeSettings() {
    chrome.storage.sync.set({
        BlocksiSettingsV2: s
    });
}

chrome.runtime.onInstalled.addListener(function() {});

function getManagerSettings(userName, validationCode) {
    var i, len, name, reqUrl = "http://service.block.si/config/getSettingsByHomeUser/" + userName + "/" + validationCode;
    getJSON(reqUrl, !0, function(data) {
        var reqSettings;
        if ("string" == typeof data) reqSettings = JSON.parse(data); else reqSettings = data;
        if ("true" === reqSettings.status) {
            s = new UserData(userName, validationCode);
            s.companyId = reqSettings.CompanyId;
            if ("true" === reqSettings.PassStatus) s.password = [ !0, reqSettings.Password ]; else s.password = [ !0, "" ];
            if (null != reqSettings.SafeSearch && void 0 != reqSettings.SafeSearch) s.userSettings.SafeSearch = reqSettings.SafeSearch;
            var fix = [ 49, 38, 32, 17, 8, 5 ];
            var arr = reqSettings.FilterSettings.split("");
            len = fix.length;
            for (i = 0; len > i; i++) {
                var p = arr.splice(fix[i], 1)[0];
                arr.reverse().push(p);
                arr.reverse();
            }
            len = Object.keys(s.userSettings.webFilter).length;
            for (i = 0; len > i; i++) {
                name = Object.keys(s.userSettings.webFilter)[i];
                s.userSettings.webFilter[name].a = parseInt(arr[i], 10);
            }
            if (null !== reqSettings.YTFilter) if (reqSettings.YTFilter.length > 0) {
                len = Object.keys(s.userSettings.ytFilter).length;
                for (i = 0; len > i; i++) {
                    name = Object.keys(s.userSettings.ytFilter)[i];
                    s.userSettings.ytFilter[name].a = parseInt(reqSettings.YTFilter[0].Settings.charAt(i), 10);
                }
                if (reqSettings.YTFilter[0].Settings.length > 33) if ("1" == reqSettings.YTFilter[0].Settings.charAt(33)) s.userSettings.ytAgeRestriction = !0; else s.userSettings.ytAgeRestriction = !1; else s.userSettings.ytAgeRestriction = !0;
            }
            len = reqSettings.List.length;
            for (i = 0; len > i; i++) {
                var a = new Array();
                a[0] = reqSettings.List[i].Url;
                a[1] = reqSettings.List[i].Action;
                s.userSettings.bwList.push(a);
            }
            if (reqSettings.RegEx) {
                len = reqSettings.RegEx.length;
                for (i = 0; len > i; i++) s.userSettings.regExList.push(reqSettings.RegEx[i].RegEx);
            }
            if (null !== reqSettings.ATProfile) {
                s.userSettings.AccTimeEnabled = !0;
                s.userSettings.AccTimes = [ "x", "x", "x", "x", "x", "x", "x" ];
                len = reqSettings.ATProfile.length;
                for (i = 0; len > i; i++) if ("x" !== reqSettings.ATProfile[i]) s.userSettings.AccTimes[i] = reqSettings.ATProfile[i];
            }
            updateChromeSettings();
        }
    });
}

function updateLocalSettings() {
    chrome.storage.sync.get("BlocksiSettingsV2", function(data) {
        if (data.BlocksiSettingsV2) {
            s = data.BlocksiSettingsV2;
            chrome.browserAction.enable();
            chrome.browserAction.setTitle({
                title: "Add to black/white list"
            });
            chrome.browserAction.setBadgeText({
                text: ""
            });
            if (s.userName && s.validationCode) {
                getManagerSettings(s.userName, s.validationCode);
                chrome.browserAction.disable();
                chrome.browserAction.setTitle({
                    title: "Manager is used"
                });
                chrome.browserAction.setBadgeText({
                    text: "M"
                });
            }
        } else {
            s = new UserData(!1, !1);
            updateChromeSettings();
            chrome.tabs.create({
                url: "quick-setup.html"
            });
        }
    });
}

updateLocalSettings();

function addURLtoBW(url, action) {
    var len = s.userSettings.bwList.length;
    if (0 === len) {
        s.userSettings.bwList.push([ url, action ]);
        updateChromeSettings();
        return;
    }
    for (var i = 0; len > i; i++) {
        if (s.userSettings.bwList[i][0] === url || s.userSettings.bwList[i][0].indexOf(url) !== -1) {
            s.userSettings.bwList[i][1] = action;
            updateChromeSettings();
            break;
        }
        if (i === len - 1) {
            s.userSettings.bwList.push([ url, action ]);
            updateChromeSettings();
        }
    }
}

function getBWaction(url) {
    var len = s.userSettings.bwList.length;
    if (0 === len) return 0;
    for (var i = 0; len > i; i++) {
        if (s.userSettings.bwList[i][0] === url) return s.userSettings.bwList[i][1];
        if (i === len - 1) return 0;
    }
}

chrome.storage.onChanged.addListener(function(changes, areaName) {
    updateLocalSettings();
});

chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
    if (void 0 !== request.regex) sendResponse({
        Regex: s.userSettings.regExList
    }); else if (void 0 !== request.warning) if ("Allow" === request.warning) {
        var url = new URL(decodeURIComponent(request.url));
        addURLtoBW(url.hostname, 0);
        chrome.tabs.update(sender.tab.id, {
            url: url.href
        });
    } else chrome.tabs.remove(sender.tab.id); else if (void 0 !== request.BW) if ("add" === request.BW) addURLtoBW(request.url, parseInt(request.action, 10)); else if ("action" === request.BW) sendResponse({
        action: getBWaction(request.url)
    }); else if ("password" === request.BW) if (s.password[0]) sendResponse({
        password: s.password[1]
    }); else sendResponse({
        password: !1
    });
});

chrome.webRequest.onBeforeRequest.addListener(function(details) {
    return pageCheck(details.url);
}, {
    urls: [ "<all_urls>" ],
    types: [ "main_frame" ]
}, [ "blocking" ]);

chrome.webNavigation.onHistoryStateUpdated.addListener(function(details) {
    var blockData = pageCheck(details.url);
    if (void 0 !== blockData && "redirectUrl" in blockData) chrome.tabs.update(details.tabId, {
        url: blockData.redirectUrl
    });
});