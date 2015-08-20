"use strict";

var blocksi, currentUser;

$.holdReady(!0);

var timeControl = new Array(7);

var ATParray;

for (var i = 0; 7 > i; i++) {
    timeControl[i] = new Array(24);
    for (var j = 0; 24 > j; j++) timeControl[i][j] = 0;
}

function setHourFormat(val) {
    var ret = "";
    var temp = val.split(",");
    for (var t in temp) {
        var temp_ = temp[t].split("_");
        for (var t_ in temp_) {
            if (parseInt(temp_[t_]) < 10) temp_[t_] = "0" + temp_[t_];
            temp_[t_] += ":00";
        }
        ret += temp_[0] + "_" + temp_[1] + ",";
    }
    ret = ret.substring(0, ret.length - 1);
    return ret;
}

function getATPstring(array) {
    var daySettings = new Array(7);
    var ATPstring = "";
    for (var i = 0; 7 > i; i++) {
        daySettings[i] = "";
        var j;
        for (j = 0; 24 > j; j++) {
            if (1 == array[i][j]) {
                daySettings[i] += j.toString() + "_";
                while (1 == array[i][j]) {
                    j++;
                    if (24 == j) break;
                }
                daySettings[i] += j.toString() + ",";
            }
            if (23 == j || 24 == j) {
                if (daySettings[i].length > 0) daySettings[i] = daySettings[i].substring(0, daySettings[i].length - 1); else daySettings[i] += "x";
                daySettings[i] += ";";
            }
        }
        ATPstring += daySettings[i];
    }
    return ATPstring;
}

function changesHandler() {
    blocksi.changes = !0;
    $("#messages").slideDown(300);
    $("#main").stop().animate({
        "padding-top": 90
    }, 300);
    $(window).scroll();
}

var blocksi = {
    changes: !1,
    init: function() {
        var template;
        if (md5($("#passwordLogin").val()) !== currentUser.password[1] && currentUser.password[0] && "" !== currentUser.password[1]) {
            template = Handlebars.templates.login();
            document.getElementById("container").innerHTML = template;
            $("#passwordContinue").on("click", function(e) {
                var pass = md5($("#passwordLogin").val());
                if (pass === currentUser.password[1]) blocksi.init(); else $("#loginStatus").html('<div class="bg-danger">Wrong password!</div>');
                e.preventDefault();
            });
        } else if (currentUser.userName && currentUser.validationCode) {
            $("#container").html('<div id="main" class="container template manager"></div>');
            template = Handlebars.templates.manager(currentUser);
            $("#main").append(template);
            $("#main").append("<h2>" + chrome.i18n.getMessage("menu0") + '</h2><div id="webfilteraccordion"></div>' + '<div id="youtubeaccordion"></div>' + "<h2>" + chrome.i18n.getMessage("menu1") + '</h2><ul id="bwlistUl"></ul>' + "<h2>" + chrome.i18n.getMessage("menu4") + '</h2><table id="timeUl" class="table table-hover"></table>' + "<h2>" + chrome.i18n.getMessage("menu2") + '</h2><ul id="regexUl"></ul>');
            template = Handlebars.templates.webfilterlist(data);
            $("#webfilteraccordion").append(template);
            template = Handlebars.templates.youtubelist(data);
            $("#youtubeaccordion").append(template);
            template = Handlebars.templates.regexList(currentUser.userSettings);
            $("#regexUl").append(template);
            template = Handlebars.templates.bwlistTable(currentUser.userSettings);
            $("#bwlistUl").append(template);
            template = Handlebars.templates.accesstimeList(currentUser.userSettings);
            document.getElementById("timeUl").innerHTML = template;
            $(".selectpicker option:selected").each(function() {
                var txt = $(this).text();
                $(this).parent().parent().append(txt);
            });
            $("#youtubeaccordion").before("<h2>Youtube</h2>");
            $(".bwDelButton, .regexDelButton, .selectpicker, #regexUl > li.liItem.header > span:nth-child(2)").remove();
            $('input[type="radio"], button:not(#clearValidation), select').prop("disabled", !0);
            $("label.btn").addClass("disabled");
            $("#clearValidation").on("click", function() {
                if (confirm("Are you sure?")) {
                    currentUser.userName = !1;
                    currentUser.validationCode = !1;
                    currentUser.password = [ !1, "" ];
                    currentUser.companyId = "";
                    chrome.storage.sync.set({
                        BlocksiSettingsV2: currentUser
                    });
                    this.init();
                }
            });
        } else {
            template = Handlebars.templates.main();
            document.getElementById("container").innerHTML = template;
            $("#saveAll").on("click", function() {
                chrome.storage.sync.set({
                    BlocksiSettingsV2: currentUser
                });
                blocksi.changes = !1;
                $(window).scroll();
                $("#messages").slideUp(300);
                $("#main").stop().animate({
                    "padding-top": 40
                }, 300);
            });
            $(window).scroll(function() {
                var position = $("body").scrollTop();
                if (blocksi.changes && 50 >= position) $("#menu").stop().animate({
                    top: 0 - position
                }, 10); else if (blocksi.changes && position > 50) $("#menu").stop().animate({
                    top: -50
                }, 10); else $("#menu").stop().animate({
                    top: 0
                }, 300);
            });
            this.webfilter.init();
            this.bwlist.init();
            this.regex.init();
            this.youtube.init();
            this.accesstime.init();
            this.options.init();
            this.ytchannel.init();
            this.ytkeyword.init();
            this.webfilter.events();
            this.bwlist.events();
            this.regex.events();
            this.youtube.events();
            this.ytchannel.events();
            this.ytkeyword.events();
        }
    },
    ytchannel: {
        init: function() {
            var template = Handlebars.templates.ytchannel();
            document.getElementById("ytchannel").innerHTML = template;
            this.initChannel();
        },
        initChannel: function() {
            var template = Handlebars.templates.ytchannellist(currentUser.userSettings);
            document.getElementById("ytchannelUl").innerHTML = template;
        },
        events: function() {
            var self = this;
            $(".selectpicker").selectpicker();
            $("#ytChanAddButton").on("click", function(e) {
                e.preventDefault();
                var channel = $("#ytchannelInput").val(), action = $("#ytChanAction").val();
                if ("" === channel) return !1; else if (!self.updateChannel(channel, action)) {
                    currentUser.userSettings.ytChannelList.push([ channel, parseInt(action, 10) ]);
                    changesHandler();
                    self.initChannel();
                } else self.initChannel();
            });
            $("#ytchannelUl").on("click", ".ytChanDelButton", function() {
                var channel = $(this).attr("name");
                self.deleteChannel(channel);
                changesHandler();
                self.initChannel();
            });
            $("#ytchannelUl").on("change", ".selectpicker", function() {
                var channel = $(this).attr("name"), action = $(this).val();
                self.updateAction(channel, action);
            });
        },
        updateChannel: function(channel, action) {
            var updated = !1;
            var len = currentUser.userSettings.ytChannelList.length;
            for (var i = 0; len > i; i++) if (currentUser.userSettings.ytChannelList[i][0] === channel) {
                currentUser.userSettings.ytChannelList[i][1] = parseInt(action, 10);
                updated = !0;
                changesHandler();
                break;
            }
            return updated;
        },
        deleteChannel: function(channel) {
            var len = currentUser.userSettings.ytChannelList.length;
            for (var i = 0; len > i; i++) if (currentUser.userSettings.ytChannelList[i][0] === channel) {
                currentUser.userSettings.ytChannelList.splice(i, 1);
                changesHandler();
                break;
            }
        },
        updateAction: function(channel, action) {
            var len = currentUser.userSettings.ytChannelList.length;
            for (var i = 0; len > i; i++) if (currentUser.userSettings.ytChannelList[i][0] === channel) {
                currentUser.userSettings.ytChannelList[i][1] = action;
                changesHandler();
                break;
            }
        }
    },
    ytkeyword: {
        init: function() {
            var template = Handlebars.templates.ytkeyword();
            document.getElementById("ytkeyword").innerHTML = template;
            this.initYTKeywordList();
        },
        initYTKeywordList: function() {
            var template = Handlebars.templates.ytkeywordlist(currentUser.userSettings);
            document.getElementById("ytkeywordUl").innerHTML = template;
        },
        events: function() {
            var self = this;
            $("#addYtKeyword").on("click", function(e) {
                e.preventDefault();
                var keyword = $("#ytkeywordInput").val(), exists = !1, len = currentUser.userSettings.ytKeywords.length;
                $("#regex-form").removeClass("has-error has-warning");
                $("#regexErr").remove();
                if ("" === keyword) {
                    $("#regex-form").addClass("has-error");
                    $("#addYtKeyword").after('<span id="regexErr" class="help-block">' + chrome.i18n.getMessage("valEmpty") + "</span>");
                    return;
                }
                for (var i = 0; len > i; i++) if (currentUser.userSettings.ytKeywords[i] === keyword) {
                    $("#regex-form").addClass("has-warning");
                    $("#addYtKeyword").after('<span id="regexErr" class="help-block">' + chrome.i18n.getMessage("urlDupli") + "</span>");
                    exists = !0;
                    break;
                }
                if (!exists) {
                    currentUser.userSettings.ytKeywords.push(keyword);
                    changesHandler();
                    self.initYTKeywordList();
                }
            });
            $("#ytkeywordUl").on("click", ".ytkeywordDelButton", function() {
                var keyword = $(this).attr("name"), len = currentUser.userSettings.ytKeywords.length;
                for (var i = 0; len > i; i++) if (currentUser.userSettings.ytKeywords[i] === keyword) {
                    currentUser.userSettings.ytKeywords.splice(i, 1);
                    changesHandler();
                    break;
                }
                self.initYTKeywordList();
            });
        }
    },
    webfilter: {
        init: function() {
            var template = Handlebars.templates.webfilter();
            document.getElementById("webfilter").innerHTML = template;
            template = Handlebars.templates.webfilterlist(data);
            document.getElementById("webfilteraccordion").innerHTML = template;
            template = Handlebars.templates.presets(currentUser.userSettings);
            document.getElementById("presets").innerHTML = template;
            $("#menu").on("click", "#nav a", function() {
                var link = "#" + $(this).attr("href");
                $("#nav li").removeClass("active");
                $(this).parent().addClass("active");
                $("section").addClass("hidden").removeClass("fadeIn");
                $(link).toggleClass("fadeIn hidden");
                if ($(".navbar-collapse").is(".in")) $(".navbar-toggle").trigger("click");
                return !1;
            });
            if ("true" == currentUser.userSettings.SafeSearch) $("#safeSearchBox").prop("checked", !0); else $("#safeSearchBox").prop("checked", !1);
            $("#safeSearchBox").on("change", function() {
                if ($(this).prop("checked")) {
                    currentUser.userSettings.SafeSearch = "true";
                    changesHandler();
                } else {
                    currentUser.userSettings.SafeSearch = "false";
                    changesHandler();
                }
            });
            $(".quickSetup").on("click", function() {
                window.location = "quick-setup.html";
            });
            $("#webfilter .tipsy").tooltip({
                container: "body"
            });
        },
        events: function() {
            var self = this;
            $("#safeSearchBox").on("click", function() {
                if (document.getElementById("safeSearchBox").checked) currentUser.userSettings.SafeSearch = "true"; else currentUser.userSettings.SafeSearch = "false";
                changesHandler();
            });
            $("#webfilteraccordion").on("change", '[type="radio"]', function() {
                self.clearQuickSetup();
                if ($(this).prop("checked")) {
                    var cat = $(this).attr("name"), val = $(this).val();
                    currentUser.userSettings.webFilter[cat].a = parseInt(val, 10);
                    changesHandler();
                }
            });
            $(".accordionBtn input[type=radio]").on("change", function() {
                var cat = $(this).attr("data-category");
                $('[type="radio"][data-category="' + cat + "." + this.value + '"]').prop("checked", !0).trigger("change");
            });
            $("#preset .btn").on("click", function(e) {
                var name = $(this).val(), minor = "1110001111111111111111111111111110000000000000000000000000000000000000000000000000000", adult = "1000001110000000000000000000000000000000000000000000000000000000000000000000000000000";
                if ("adult" === name) {
                    currentUser.userSettings.parent = !0;
                    currentUser.userSettings.kids = !1;
                    self.changeWebFilter(adult);
                } else if ("minor" === name) {
                    currentUser.userSettings.parent = !1;
                    currentUser.userSettings.kids = !0;
                    self.changeWebFilter(minor);
                }
                e.preventDefault();
            });
            $("#checkurlCat").on("click", function(e) {
                var cUrl = $("#urlCat").val();
                if (!cUrl) return !1;
                var url = "http://service2.block.si/getRating.json?url=" + cUrl + "&api_key=" + apikey;
                $.ajax({
                    url: url,
                    success: function(res) {
                        if (res) if (void 0 === res.status) {
                            var subcat = chrome.i18n.getMessage("id" + res.Category), cat = chrome.i18n.getMessage("id" + res.Category.toString()[0]);
                            $("#urlCatRes").html('<div class="bg-primary"><span id="ucrc"></span><i class="glyphicon glyphicon-chevron-right"></i><span id="ucrs"></span></div>');
                            $("#ucrc").text(cat);
                            $("#ucrs").text(subcat);
                        }
                    },
                    dataType: "json"
                });
                e.preventDefault();
            });
        },
        changeWebFilter: function(str) {
            var i, len = str.length;
            if ("1000001110000000000000000000000000000000000000000000000000000000000000000000000000000" == str) currentUser.userSettings.SafeSearch = "false"; else currentUser.userSettings.SafeSearch = "true";
            for (i = 0; len > i; i++) {
                var name = Object.keys(currentUser.userSettings.webFilter)[i];
                currentUser.userSettings.webFilter[name].a = parseInt(str[i], 10);
            }
            changesHandler();
            this.init();
            blocksi.youtube.init();
            this.events();
            blocksi.youtube.events();
        },
        clearQuickSetup: function() {
            $("#preset button").removeClass("active");
            currentUser.userSettings.parent = !1;
            currentUser.userSettings.kids = !1;
        }
    },
    bwlist: {
        init: function() {
            var template = Handlebars.templates.bwlist();
            document.getElementById("bwlist").innerHTML = template;
            this.initBwList();
        },
        initBwList: function() {
            var template = Handlebars.templates.bwlistTable(currentUser.userSettings);
            document.getElementById("bwlistUl").innerHTML = template;
            this.events();
        },
        events: function() {
            var self = this;
            $(".selectpicker").selectpicker();
            $("#bwAddButton").on("click", function(e) {
                e.preventDefault();
                var url_ = $("#bwlistInput").val();
                if (url_.indexOf("http://") == -1 && url_.indexOf("https://") == -1) url_ = "http://" + url_;
                var url = new URL(url_).hostname, action = $("#bwAction").val();
                if ("" === url) return !1; else if (!self.updateURL(url, action)) {
                    currentUser.userSettings.bwList.push([ url, parseInt(action, 10) ]);
                    changesHandler();
                    self.initBwList();
                } else self.initBwList();
            });
            $("#bwlistUl").on("click", ".bwDelButton", function() {
                var url = $(this).attr("name");
                self.deleteURL(url);
                changesHandler();
                self.initBwList();
            });
            $("#bwlistUl").on("change", ".selectpicker", function() {
                var url = $(this).attr("name"), action = $(this).val();
                self.updateAction(url, action);
            });
        },
        updateURL: function(url, action) {
            var updated = !1;
            var len = currentUser.userSettings.bwList.length;
            for (var i = 0; len > i; i++) if (currentUser.userSettings.bwList[i][0] === url) {
                currentUser.userSettings.bwList[i][1] = parseInt(action, 10);
                updated = !0;
                changesHandler();
                break;
            }
            return updated;
        },
        deleteURL: function(url) {
            var len = currentUser.userSettings.bwList.length;
            for (var i = 0; len > i; i++) if (currentUser.userSettings.bwList[i][0] === url) {
                currentUser.userSettings.bwList.splice(i, 1);
                changesHandler();
                break;
            }
        },
        updateAction: function(url, action) {
            var len = currentUser.userSettings.bwList.length;
            for (var i = 0; len > i; i++) if (currentUser.userSettings.bwList[i][0] === url) {
                currentUser.userSettings.bwList[i][1] = action;
                changesHandler();
                break;
            }
        }
    },
    regex: {
        init: function() {
            var template = Handlebars.templates.regex();
            document.getElementById("regex").innerHTML = template;
            this.initRegexList();
        },
        initRegexList: function() {
            var template = Handlebars.templates.regexList(currentUser.userSettings);
            document.getElementById("regexUl").innerHTML = template;
        },
        events: function() {
            var self = this;
            $("#addRegex").on("click", function(e) {
                e.preventDefault();
                var regex = $("#regexInput").val(), exists = !1, len = currentUser.userSettings.regExList.length;
                $("#regex-form").removeClass("has-error has-warning");
                $("#regexErr").remove();
                if ("" === regex) {
                    $("#regex-form").addClass("has-error");
                    $("#addRegex").after('<span id="regexErr" class="help-block">' + chrome.i18n.getMessage("valEmpty") + "</span>");
                    return;
                }
                for (var i = 0; len > i; i++) if (currentUser.userSettings.regExList[i] === regex) {
                    $("#regex-form").addClass("has-warning");
                    $("#addRegex").after('<span id="regexErr" class="help-block">' + chrome.i18n.getMessage("urlDupli") + "</span>");
                    exists = !0;
                    break;
                }
                if (!exists) {
                    currentUser.userSettings.regExList.push(regex);
                    changesHandler();
                    self.initRegexList();
                }
            });
            $("#regexUl").on("click", ".regexDelButton", function() {
                var regex = $(this).attr("name"), len = currentUser.userSettings.regExList.length;
                for (var i = 0; len > i; i++) if (currentUser.userSettings.regExList[i] === regex) {
                    currentUser.userSettings.regExList.splice(i, 1);
                    changesHandler();
                    break;
                }
                self.initRegexList();
            });
        }
    },
    youtube: {
        init: function() {
            var template = Handlebars.templates.youtube();
            document.getElementById("youtube").innerHTML = template;
            template = Handlebars.templates.youtubelist(data);
            document.getElementById("youtubeaccordion").innerHTML = template;
        },
        events: function() {
            $("#youtube").on("change", '[type="radio"]', function() {
                if ($(this).prop("checked")) {
                    var cat = $(this).attr("name"), val = $(this).val();
                    currentUser.userSettings.ytFilter[cat].a = parseInt(val, 10);
                    changesHandler();
                }
            });
        }
    },
    accesstime: {
        init: function() {
            var self = this, template = Handlebars.templates.accesstime(currentUser.userSettings);
            document.getElementById("accesstime").innerHTML = template;
            template = Handlebars.templates.accesstimeList(currentUser.userSettings);
            for (var i = 0; 7 > i; i++) for (var j = 0; 24 > j; j++) $("#" + i + "_" + j).on("click", function() {
                var i_ = parseInt(this.id.split("_")[0]);
                var j_ = parseInt(this.id.split("_")[1]);
                if (1 == timeControl[i_][j_]) {
                    timeControl[i_][j_] = 0;
                    $("#" + this.id).css("background-color", "white");
                } else {
                    timeControl[i_][j_] = 1;
                    $("#" + this.id).css("background-color", "red");
                }
                var atpString = getATPstring(timeControl);
                ATParray = atpString.split(";");
                if ("x" != ATParray[i_]) ATParray[i_] = setHourFormat(ATParray[i_]);
                currentUser.userSettings.AccTimes[i_] = ATParray[i_];
                changesHandler();
            });
            for (var i = 0; 7 > i; i++) if ("x" == currentUser.userSettings.AccTimes[i]) for (var j = 0; 24 > j; j++) $("#" + i + "_" + j).css("background-color", "white"); else if ("undefined" != typeof currentUser.userSettings.AccTimes[i]) if ("string" == typeof currentUser.userSettings.AccTimes[i]) {
                var tempTimes = currentUser.userSettings.AccTimes[i].split(",");
                for (var j = 0; j < tempTimes.length; j++) {
                    var tempTime = tempTimes[j].split("_");
                    var from = parseInt(tempTime[0].split(":")[0]);
                    var to = parseInt(tempTime[1].split(":")[0]);
                    for (var k = from; to > k; k++) $("#" + i + "_" + k).css("background-color", "red");
                }
            }
            $(".selectpicker").selectpicker();
            if (currentUser.userSettings.AccTimeEnabled) $("#enableAccessTime").prop("checked", !0);
            $("#enableAccessTime").on("change", function() {
                if ($(this).prop("checked")) {
                    $("article.ac-12").toggleClass("fadeIn hidden");
                    currentUser.userSettings.AccTimeEnabled = !0;
                    changesHandler();
                } else {
                    $("article.ac-12").toggleClass("fadeIn hidden");
                    currentUser.userSettings.AccTimeEnabled = !1;
                    changesHandler();
                }
            });
            $("a.tagsinput-remove-link").on("click", function(e) {
                e.preventDefault();
                var val = $(this).attr("data-arr");
                var index = val.split(",");
                currentUser.userSettings.AccTimes[index[0]].splice(index[1], 1);
                self.init();
                changesHandler();
            });
            $("#addAccessTime").on("click", function(e) {
                e.preventDefault();
                var day = parseInt($("#dayOfWeek").val(), 10);
                $("#accessVal").html("");
                var fromH = $("#fromH").val(), fromM = $("#fromM").val(), tillH = $("#tillH").val(), tillM = $("#tillM").val();
                var now = new Date(), t1 = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0), from = new Date(t1.getFullYear(), t1.getMonth(), t1.getDate(), fromH, fromM, 0), till = new Date(t1.getFullYear(), t1.getMonth(), t1.getDate(), tillH, tillM, 0);
                if (!(fromH && fromM && tillH && tillM)) $("#accessVal").html('<div class="bg-danger">' + chrome.i18n.getMessage("allfields") + "</div>"); else if (from > till) $("#accessVal").html('<div class="bg-danger">' + chrome.i18n.getMessage("accessVal") + "</div>"); else {
                    var diff1 = from.getTime() - t1.getTime(), diff2 = till.getTime() - t1.getTime();
                    var arr = [];
                    switch (day) {
                      case 7:
                        arr = [ 0, 1, 2, 3, 4, 5, 6 ];
                        break;

                      case 8:
                        arr = [ 1, 2, 3, 4, 5 ];
                        break;

                      case 9:
                        arr = [ 0, 6 ];
                        break;

                      default:
                        arr = [ day ];
                    }
                    for (var i = 0; i < arr.length; i++) currentUser.userSettings.AccTimes[arr[i]].push([ diff1, diff2 ]);
                    self.init();
                    changesHandler();
                }
            });
        }
    },
    options: {
        init: function() {
            var template = Handlebars.templates.options(currentUser.password);
            document.getElementById("options").innerHTML = template;
            template = Handlebars.templates.password();
            document.getElementById("passwd").innerHTML = template;
            template = Handlebars.templates.manager();
            document.getElementById("manager").innerHTML = template;
            this.events();
        },
        events: function() {
            $("#savePassword").on("click", function(e) {
                var passwordVal = $("#password").val();
                var checkVal = $("#password-check").val();
                var hasError = !1;
                $(".has-error").removeClass("has-error, has-success");
                $(".del").remove();
                $("#pass-info").html("");
                if ("" === passwordVal) {
                    $("#pass-info").html('<div class="bg-danger">Please enter a password.</div>');
                    $("#password").parent().addClass("has-error");
                    $("#password").parent().append('<span class="del glyphicon glyphicon-remove form-control-feedback"></span>');
                    hasError = !0;
                } else if ("" === checkVal) {
                    $("#pass-info").html('<div class="bg-danger">Please re-enter your password.</div>');
                    $("#password-check").parent().addClass("has-error");
                    $("#password-check").parent().append('<span class="del glyphicon glyphicon-remove form-control-feedback"></span>');
                    hasError = !0;
                } else if (passwordVal !== checkVal) {
                    $("#pass-info").html('<div class="bg-danger">Passwords do not match.</div>');
                    $("#password-check, #password").parent().addClass("has-error");
                    $("#password-check").parent().append('<span class="del glyphicon glyphicon-remove form-control-feedback"></span>');
                    $("#password").parent().append('<span class="del glyphicon glyphicon-remove form-control-feedback"></span>');
                    hasError = !0;
                }
                if (hasError === !0) return !1; else {
                    currentUser.password[0] = !0;
                    currentUser.password[1] = md5($("#password").val());
                    changesHandler();
                    $("#pass-info").html('<div class="bg-success">Password confirmed</div>');
                    $("#password-check, #password").parent().addClass("has-success");
                }
                e.preventDefault();
            });
            if ("" !== currentUser.password[1]) {
                $("#password").val(currentUser.password[1]);
                $("#password").prop("disabled", !0);
                $("#passwd").css("height", 180);
                $("#passwd > form > div > div:nth-child(2)").hide();
                $("#savePassword").hide();
                $("#clearPassword").removeClass("hidden");
            }
            $("#clearPassword").on("click", function(e) {
                currentUser.password = [ !1, "" ];
                blocksi.options.init();
                changesHandler();
                e.preventDefault();
            });
            $("#enablePassword").on("change", function() {
                if ($(this).prop("checked")) {
                    $("#passwd").toggleClass("fadeIn hidden");
                    if ("" !== $("#password").val()) {
                        currentUser.password[0] = !0;
                        changesHandler();
                    }
                } else {
                    $("#passwd").toggleClass("fadeIn hidden");
                    if ("" !== $("#password").val()) {
                        currentUser.password[0] = !1;
                        changesHandler();
                    }
                }
            });
            $("#saveUser").on("click", function(e) {
                var user = $("#userName").val(), code = $("#validateCode").val(), url = "http://service.block.si/config/getSettingsByUserId/" + user + "/" + code;
                if (user.indexOf("@blocksicloud.com") > -1) url = "http://service.block.si/config/getSettingsByHomeUser/" + user + "/" + code;
                $.ajax({
                    url: url,
                    success: function(res) {
                        if (res && "true" === res.status) {
                            currentUser.userName = user;
                            currentUser.validationCode = code;
                            chrome.storage.sync.set({
                                BlocksiSettingsV2: currentUser
                            });
                            $("#status").html('<div class="bg-primary">Success! Blocksi Manager is now active</div>');
                            setTimeout(function() {
                                window.location = "options.html";
                            }, 3e3);
                        } else if ("false" === res.Status) $("#status").html('<div class="bg-danger">Error: Username or validation wrong!</div>'); else $("#status").html('<div class="bg-danger">Oops! Something went wrong. </div>');
                    },
                    dataType: "json"
                });
                e.preventDefault();
            });
            $("#defaults").on("click", function(e) {
                e.preventDefault();
                blocksi.changes = !1;
                chrome.storage.sync.clear();
                window.close();
            });
        }
    }
};

chrome.i18n.getAcceptLanguages(function(arr) {
    blocksi.lang = arr;
});

chrome.storage.sync.get("BlocksiSettingsV2", function(e) {
    if (void 0 !== e.BlocksiSettingsV2) {
        currentUser = e.BlocksiSettingsV2;
        $.holdReady(!1);
        blocksi.init();
    }
});

window.onbeforeunload = function() {
    if (blocksi.changes) return 'You have unsaved changes.\r\nPlease click "Save settings" before exiting.';
};