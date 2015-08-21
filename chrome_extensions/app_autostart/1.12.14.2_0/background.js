var launches = Utils.getStorage('launches') || 0;
launches++;
Utils.setStorage('launches', launches);
console.log('AAS background: ' + launches);

var AppAutoStart = {
    isLaunching: false,

    // Closes all windows not in the keepOpen set
    closeOthers: function(keepOpen) {
        chrome.windows.getAll(function(all) {
            var toRemove = [];
            for (var i=0; i<all.length; i++) {
                if (!keepOpen[all[i].id]) {
                    toRemove.push(all[i].id);
                }
            }
            // Do not respect the "close others" option if no windows will remain open.
            // That could be disastrous.
            if (toRemove.length == all.length) {
                console.log("Error:  All windows would be removed.  That's not good!");
                return;
            }
            for (var i=0; i<toRemove.length; i++) {
                chrome.windows.remove(toRemove[i]);
            }
        });
    },

    launchApps: function() {
        var appSettings = Utils.getStorage('appSettings') || {};
        var closeOthers = Utils.getStorage('closeOthers');
        var self = this;
        var ourWindows = {};
        var waiting = {};
        this.isLaunching = true;

        function doneWaiting() {
            var done = true;
            for(var id in waiting) { done = false; break; }
            return done;
        }

        var fnFinished = function(id) {
            delete waiting[id];
            if (doneWaiting()) {
                self.isLaunching = false;
                if (closeOthers) {
                    self.closeOthers(ourWindows);
                }
            }
        }

        for (var id in appSettings) {
            waiting[id] = true;
            chrome.management.get(id, function(info) {
                console.log("launching " + id);
                switch(appSettings[id]) {
                    case 'regular':
                        chrome.tabs.create({ url: info.appLaunchUrl }, function(tab) {
                            fnFinished(id);
                        });
                        break;
                    case 'pinned':
                        chrome.tabs.create({ url: info.appLaunchUrl, pinned: true }, function(tab) {
                            fnFinished(id);
                        });
                        break;
                    case 'window':
                        chrome.windows.create({ url: info.appLaunchUrl, type: 'popup' }, function(window) {
                            ourWindows[window.id] = true;
                            fnFinished(id);
                        });
                        break;
                    case 'full':
                        chrome.windows.create({ url: info.appLaunchUrl }, function(window) {
                            chrome.windows.update(window.id, { state: 'fullscreen' });
                            ourWindows[window.id] = true;
                            fnFinished(id);
                        });
                        break;
                }
            });
        }
        if (doneWaiting())
            this.isLaunching = false;
    },

    init: function() {
        var self = this;
        var hasRun = Utils.getStorage("hasRun");
        Utils.setStorage("hasRun", true);

        if(!hasRun) {
            var url = chrome.extension.getURL("options.html");
            chrome.tabs.create({  url: url });
        }

        chrome.browserAction.onClicked.addListener(function() {
            chrome.tabs.create({ url: 'options.html' });
        });

        // TODO:  Actually, we should be careful to NOT run this just when the browser is reloaded, e.g. by auto-update!
        this.launchApps();

        // TODO:  Report this as a bug
        // HACK:  When using multiple user accounts, Chrome does not shut down the extension when the last window for a
        //        user is closed if there are other user accounts with Chrome open.  So if you re-launch the user account,
        //        the extension doesn't get re-loaded and launchApps doesn't happen.
        chrome.windows.onCreated.addListener(function(newWindow) {
            console.log("onCreated: " + newWindow.id);
            // If we are launching apps now, then we're fine
            if (self.isLaunching) {
                return;
            }
            // If there is only one window and it was newly created, then launch our apps again
            chrome.windows.getAll(function(allWindows) {
                console.log("JUST LAUNCHED.  Windows count = " + allWindows.length);
                if ( (allWindows.length == 1) && (allWindows[0].id == newWindow.id) ) {
                    self.launchApps();
                }
            });
        });
    }
}

window.addEventListener("load", function() {
    AppAutoStart.init();
}, false);
