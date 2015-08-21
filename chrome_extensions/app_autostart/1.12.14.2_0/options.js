
var OptionsPage = {
    OPENAS: '<select appid="%%appid%%"><option value="regular">Regular</option>' +
            '<option value="pinned">Pinned</option>' +
            '<option value="window" selected>Window</option>' +
            '<option value="full">Full Screen</option>',

    htmlEncode: function(value) {
        //create a in-memory div, set it's inner text(which jQuery automatically encodes)
        //then grab the encoded contents back out.  The div never exists on the page.
        return $('<div/>').text(value).html();
    },

    htmlDecode: function(value) {
        return $('<div/>').html(value).text();
    },

    addApp: function(info, appSettings) {
        var openAs = appSettings[info.id];
        var row = '<tr appid="%%appid%%">';
        row += '<td class="col-app-name" appid="%%appid%%"></td>';
        row += '<td class="col-auto-start"><input type="checkbox" appid="%%appid%%"></input></td>';
        row += '<td class="col-open-as">' + this.OPENAS + '</td>';
        row += '</tr>';
        row = row.replace(/%%appid%%/g, info.id);

        // Append the row
        $('#app-table').append(row);

        // Selector for the row
        var trAppId = 'tr[appid="' + info.id + '"]';
        $(trAppId + ' .col-app-name').text(info.name);
        // Set the checked attribute and the open-as values
        if (openAs) {
            $(trAppId + ' .col-auto-start input').prop('checked', true);
            $(trAppId + ' .col-open-as option[value="' + openAs + '"]').attr('selected', 'selected');
        } else {
            $(trAppId + ' select').attr('disabled', 'disabled');
        }
    },

    updateApp: function(id) {
        var trAppId = 'tr[appid="' + id + '"]';
        var checked = $(trAppId + ' .col-auto-start input').is(':checked');
        var openAs =  $(trAppId + ' .col-open-as select').val();
        var appSettings = Utils.getStorage('appSettings') || {};
        if (checked) {
            appSettings[id] = openAs;
            $(trAppId + ' select').removeAttr('disabled');
        } else {
            $(trAppId + ' select').attr('disabled', 'disabled');
            delete appSettings[id];
        }
        Utils.setStorage('appSettings', appSettings);
    },

    init2: function() {
        var self = this;
        // Add the check handlers
        $('.col-auto-start input:checkbox').click(function() {
            self.updateApp($(this).attr('appid'));
        });
        // Add the 'open as' handlers
        $('.col-open-as select').change(function() {
            self.updateApp($(this).attr('appid'));
        });
        $('#close-main').prop('checked', !!Utils.getStorage('closeOthers'));
        $('#close-main').click(function() {
            Utils.setStorage('closeOthers', $('#close-main').is(':checked'));
        });
    },

    init: function() {
        var appSettings = Utils.getStorage('appSettings') || {};
        var self = this;

        chrome.management.getAll(function(apps) {
            for (var i=0; i<apps.length; i++) {
                var info = apps[i];
                if (!info.isApp)
                    continue;
                self.addApp(info, appSettings);
            }
            // Follow-up initialization after the table has been built
            self.init2();
        });
    }
}

$(window).load(function() {
    OptionsPage.init();
});
