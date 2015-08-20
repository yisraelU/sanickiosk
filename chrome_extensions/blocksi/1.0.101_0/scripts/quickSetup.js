"use strict";

var currentUser;

$.holdReady(!0);

var blocksi = {
    init: function() {
        var template, self = this;
        if (md5($("#passwordLogin").val()) !== currentUser.password[1] && currentUser.password[0] && "" !== currentUser.password[1]) {
            template = Handlebars.templates.login();
            $("body").append(template);
            $("#passwordContinue").on("click", function(e) {
                var pass = md5($("#passwordLogin").val());
                if (pass === currentUser.password[1]) self.init(); else $("#loginStatus").html('<div class="bg-danger">Wrong password!</div>');
                e.preventDefault();
            });
        } else {
            var template = Handlebars.templates.quickSetup();
            $("#login").hide();
            $("body").append(template);
            var browser = navigator.vendor.indexOf("Opera") > -1 ? "Opera" : "Chrome";
            document.getElementById("browser").innerHTML = browser;
            template = Handlebars.templates.password([ !0, "" ]);
            document.getElementById("QSpass").innerHTML = template;
            $(".col-lg-3").removeClass("col-lg-3");
            $(".skipWizzard").on("click", function() {
                window.location = "options.html";
            });
            this.presets();
        }
    },
    presets: function() {
        var self = this;
        $("#adult, #minor").on("click", function(e) {
            var name = $(this).val(), minor = "1110001111111111111111111111111110000000000000000000000000000000000000000000000000000", adult = "1100000000000000000000000000000000000000000000000000000000000000000000000000000000000";
            if ("adult" === name) {
                currentUser.userSettings.parent = !0;
                currentUser.userSettings.kids = !1;
                self.changeWebFilter(adult);
            } else if ("minor" === name) {
                currentUser.userSettings.parent = !1;
                currentUser.userSettings.kids = !0;
                self.changeWebFilter(minor);
            }
            chrome.storage.sync.set({
                BlocksiSettingsV2: currentUser
            });
            $(".pt-page-1").removeClass("pt-page-current");
            $(".pt-page").removeClass("pt-page-moveFromRight pt-page-moveToLeft");
            $(".pt-page-2").addClass("pt-page-moveToLeft");
            $(".pt-page-3").addClass("pt-page-moveFromRight pt-page-current");
            e.preventDefault();
        });
        $("#next-p1").on("click", function(e) {
            e.preventDefault();
            $(".pt-page-current").toggleClass("pt-page-moveToLeft");
            $(".pt-page-current").next().toggleClass("pt-page-moveFromRight pt-page-current");
        });
        $("#next-p2").on("click", function(e) {
            e.preventDefault();
            $(".pt-page-1").removeClass("pt-page-current");
            $(".pt-page").removeClass("pt-page-moveFromRight pt-page-moveToLeft");
            $(".pt-page-2").addClass("pt-page-moveToLeft");
            $(".pt-page-3").addClass("pt-page-moveFromRight pt-page-current");
        });
        $("#next-p3").on("click", function(e) {
            e.preventDefault();
            $(".pt-page-2").removeClass("pt-page-current");
            $(".pt-page").removeClass("pt-page-moveFromRight pt-page-moveToLeft");
            $(".pt-page-3").addClass("pt-page-moveToLeft");
            $(".pt-page-4").addClass("pt-page-moveFromRight pt-page-current");
        });
        $(".finish").on("click", function(e) {
            e.preventDefault();
            window.close();
        });
        this.password();
    },
    password: function() {
        $("#savePassword").on("click", function(e) {
            var passwordVal = $("#password").val(), checkVal = $("#password-check").val(), hasError = !1;
            $(".has-error, has-success").removeClass("has-error, has-success");
            if ("" === passwordVal) {
                $("#pass-info").html('<div class="bg-danger col-md-11">Please enter a password.</div>');
                $("#password").parent().addClass("has-error");
                hasError = !0;
            } else if ("" === checkVal) {
                $("#pass-info").html('<div class="bg-danger col-md-11">Please re-enter your password.</div>');
                $("#password-check").parent().addClass("has-error");
                hasError = !0;
            } else if (passwordVal !== checkVal) {
                $("#pass-info").html('<div class="bg-danger col-md-11">Passwords do not match.</div>');
                $("#password-check, #password").parent().addClass("has-error");
                hasError = !0;
            }
            if (hasError === !0) return !1; else {
                currentUser.password[0] = !0;
                currentUser.password[1] = md5($("#password").val());
                chrome.storage.sync.set({
                    BlocksiSettingsV2: currentUser
                });
                $("#pass-info").html('<div class="bg-success">Password confirmed</div>');
                $("#password-check, #password").parent().addClass("has-success");
                $(".pt-page-2").removeClass("pt-page-current");
                $(".pt-page").removeClass("pt-page-moveFromRight pt-page-moveToLeft");
                $(".pt-page-3").addClass("pt-page-moveToLeft");
                $(".pt-page-4").addClass("pt-page-moveFromRight pt-page-current");
            }
            e.preventDefault();
        });
    },
    changeWebFilter: function(str) {
        var i, len = str.length;
        if ("1100000000000000000000000000000000000000000000000000000000000000000000000000000000000" == str) currentUser.userSettings.SafeSearch = "false"; else currentUser.userSettings.SafeSearch = "true";
        for (i = 0; len > i; i++) {
            var name = Object.keys(currentUser.userSettings.webFilter)[i];
            currentUser.userSettings.webFilter[name].a = parseInt(str[i], 10);
        }
        chrome.storage.sync.set({
            BlocksiSettingsV2: currentUser
        });
        this.presets();
    }
};

chrome.storage.sync.get("BlocksiSettingsV2", function(e) {
    if (void 0 !== e.BlocksiSettingsV2) {
        currentUser = e.BlocksiSettingsV2;
        $.holdReady(!1);
        blocksi.init();
    }
});