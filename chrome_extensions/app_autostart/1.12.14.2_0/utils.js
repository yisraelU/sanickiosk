
var Utils = {
    htmlEncode: function(value) {
        //create a in-memory div, set it's inner text(which jQuery automatically encodes)
        //then grab the encoded contents back out.  The div never exists on the page.
        return $('<div/>').text(value).html();
    },

    htmlDecode: function(value) {
        return $('<div/>').html(value).text();
    },

    getStorage: function(key) {
        var value = localStorage[key];
        if(!value)
            return null;
        return JSON.parse(value);
    },

    setStorage: function(key, value) {
        if(value === null) {
            delete localStorage[key];
        } else {
            localStorage[key] = JSON.stringify(value);
        }
    }
}
