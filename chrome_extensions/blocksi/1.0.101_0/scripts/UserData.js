'use strict';
function UserSettings(){
    this.parent = false;
    this.kids = true;
    this.webFilter = {
        1:{a:1},100:{a:1},101:{a:1},102:{a:1},
        2:{a:1},200:{a:1},201:{a:1},202:{a:1},203:{a:1},204:{a:1},205:{a:1},206:{a:1},207:{a:1},208:{a:1},
        3:{a:1},300:{a:1},301:{a:1},302:{a:1},303:{a:1},304:{a:1},305:{a:1},306:{a:1},307:{a:1},308:{a:1},309:{a:1},310:{a:1},311:{a:1},312:{a:1},313:{a:1},314:{a:1},
        4:{a:0},400:{a:0},401:{a:0},402:{a:0},403:{a:0},404:{a:0},405:{a:0},
        5:{a:0},500:{a:0},501:{a:0},502:{a:0},503:{a:0},504:{a:0},505:{a:0},506:{a:0},507:{a:0},508:{a:0},509:{a:0},510:{a:0},
        6:{a:0},600:{a:0},601:{a:0},602:{a:0},603:{a:0},604:{a:0},605:{a:0},606:{a:0},607:{a:0},608:{a:0},609:{a:0},610:{a:0},611:{a:0},612:{a:0},613:{a:0},614:{a:0},615:{a:0},616:{a:0},617:{a:0},618:{a:0},619:{a:0},620:{a:0},621:{a:0},622:{a:0},623:{a:0},624:{a:0},625:{a:0},626:{a:0},627:{a:0},628:{a:0},629:{a:0},630:{a:0},631:{a:0},632:{a:0},633:{a:0},
        700:{a:0}
    };
    this.ytFilter = {
        'youtube':{'a':0},
        'yt_1':{'a':0},
        'yt_2':{'a':0},
        'yt_10':{'a':0},
        'yt_15':{'a':0},
        'yt_17':{'a':0},
        'yt_18':{'a':0},
        'yt_19':{'a':0},
        'yt_20':{'a':0},
        'yt_21':{'a':0},
        'yt_22':{'a':0},
        'yt_23':{'a':0},
        'yt_24':{'a':0},
        'yt_25':{'a':0},
        'yt_26':{'a':0},
        'yt_27':{'a':0},
        'yt_28':{'a':0},
        'yt_29':{'a':0},
        'yt_30':{'a':0},
        'yt_31':{'a':0},
        'yt_32':{'a':0},
        'yt_33':{'a':0},
        'yt_34':{'a':0},
        'yt_35':{'a':0},
        'yt_36':{'a':0},
        'yt_37':{'a':0},
        'yt_38':{'a':0},
        'yt_39':{'a':0},
        'yt_40':{'a':0},
        'yt_41':{'a':0},
        'yt_42':{'a':0},
        'yt_43':{'a':0},
        'yt_44':{'a':0}
    };
    this.ytAgeRestriction=true;
    this.ytChannelList=[];
    this.ytKeywords=[];
    this.bwList = [];
    this.regExList = [];
    this.AccTimeEnabled = false;
    this.AccTimes=['x','x','x','x','x','x','x'];
    this.SafeSearch='true';
    //this.AccTimes=[[],[],[],[],[],[],[]];
}
function UserData(userName, validationCode){
    this.userName = userName;
    this.validationCode = validationCode;
    this.password = [false, ''];
    this.companyId = '';
    this.userSettings = new UserSettings();
}