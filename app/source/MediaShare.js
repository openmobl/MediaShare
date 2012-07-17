/* Copyright 2011 OpenMobl Systems. All rights reserved. */
enyo.kind({
	name: "MediaShare",
	kind: "Pane",
	components: [
		{kind: "ApplicationEvents",
			onUnload: "cleanup"
		},
        {kind: "VFlexBox", name: "instructions", className:"enyo-bg", components: [
            {kind:"Toolbar", className:"enyo-toolbar-dark mediashare-header", pack:"center", components: [
                {kind: "Control", className: "title", content: $L("Share")}
            ]},
            {className: "accounts-header-shadow"},
            {kind: enyo.Hybrid, name: "usharePlugin", width: 0, height: 0, executable: "ushare", takeKeyboardFocus: false,
                cachePlugin: true,
                onPluginReady: "handlePluginReady",
                onPluginDisconnected: "handlePluginDisconnect"
            },
            {kind: "PalmService", name: "openPort", service: "palm://com.palm.firewall", method: "control",
                onSuccess: "openPortSuccess", onFailure: "openPortFailure", subscribe: true
            },
            {kind: "PalmService", name: "openPortCommand", service: "palm://com.palm.firewall", method: "control",
                onSuccess: "openPortCommandSuccess", onFailure: "openPortCommandFailure", subscribe: true
            },
            {layoutKind: "VFlexLayout", flex: 1, components: [
                {kind: "HFlexBox", name: "loading", className:"box-center", flex:1, pack:"center", align:"center", components: [
                    {kind:"Spinner", name: "pluginSpinner"},
                    {content: $L("Loading Service...")}
                ]},
                {kind: "HFlexBox", name: "icon", className:"box-center", flex:1, pack:"center", align:"center", components: [
                    {kind: "Image", name: "icon-image", visible: false, src: "images/share-icon.png"}
                ]},
            ]},
            {kind: "Toolbar", name: "commands", pack:"center", align:"center", components: [
                /*{kind: "ToolButton", name: "share", className: "tool-button", icon: "images/button-media-share.png", onclick: "startSharing"},
                {kind: "ToolButton", name: "add", className: "tool-button", icon: "images/button-folder-new.png", onclick: "addFolder"}*/
                
                {layoutKind: "HFlexLayout", components: [
                    {kind: "Button", name: "stop", flex: 1, caption: "Stop Sharing", className: "enyo-button-negative", onclick: "stopSharing"},
                    {kind: "Button", name: "start", flex: 1, caption: "Start Sharing", className: "enyo-button-affirmative", onclick: "startSharing"}
                ]}
            ]}
        ]}
    ],
	pluginLoaded: false,
    isSharing: false,
    
	constructor: function() {
		this.inherited(arguments);
		
	},
	create: function() {
		this.inherited(arguments);
		enyo.keyboard.setResizesWindow(false);
        
		this.log(enyo.json.stringify(enyo.windowParams));
	},
    cleanup: function() {
        this.stopSharing();
    },
	applicationRelaunchHandler: function(inSender) {
		var c = enyo.windows.getActiveWindow();
		var params = enyo.windowParams;
		
        enyo.windows.openWindow("index.html", null, params);
        return true;
	},
	rendered: function() {
		this.inherited(arguments);
		this.log();
		var p = enyo.windowParams;
        
        enyo.setAllowedOrientation("up");
        
        this.$.stop.hide();
        this.$.icon.hide();
		this.$.pluginSpinner.show();
	},
    handlePluginReady: function(inSender) {
        this.log("Plugin has notified ready");
        this.pluginLoaded = true;
        
		this.$.pluginSpinner.hide();
		this.$.loading.hide();
        this.$.icon.show();
        
        //this.$.usharePlugin.addCallback("openPort", enyo.bind(this, this.openPort), false);
    },
    handlePluginDisconnect: function(inSender) {
        this.log("ERROR: Plugin quit on us!");
        this.isSharing = false;
        this.$.stop.hide();
        this.$.start.show();
    },
    startSharing: function() {
        this.log("Starting to share");
        if (this.pluginLoaded) {
            this.$.openPort.call({ "subscribe": true, "rules": [
                    {"protocol":"TCP","destinationPort":1900},
                    {"protocol":"UDP","destinationPort":1900},
                    
                    {"protocol":"TCP","destinationPort":8080}
                ]});
        }
    },
    stopSharing: function() {
        this.log("Stopping share");
        if (this.pluginLoaded) {
            try {
                this.$.usharePlugin.callPluginMethodDeferred(null, "stop");
                this.log("No longer sharing");
            } catch (e) {
                this.log("EXCEPTION: " + e);
            }
            this.isSharing = false;
            this.$.stop.hide();
            this.$.start.show();
        }
    },
    reloadSharing: function() {
        this.log("Reloading share");
        if (this.pluginLoaded) {
            try {
                this.$.usharePlugin.callPluginMethodDeferred(null, "reload");
            } catch (e) {
                this.log("EXCEPTION: " + e);
            }
        }
    },
    addFolder: function() {
    
    },
    sharingStarted: function() {
        this.isSharing = true;
        this.$.stop.show();
        this.$.start.hide();
        this.log("Sharing started!");
    },
    
    /* Initial Open Port API */
    openPortSuccess: function(inSender, inResponse) {
        this.log("Open port success, results=" + enyo.json.stringify(inResponse));
        
        if (this.pluginLoaded) {
            try {
                this.$.usharePlugin.callPluginMethodDeferred(null, "start",
                    "--name=\"HP PRE3\"",
                    "--content=/media/internal/Music/",
                    "--content=/media/internal/Videos/",
                    "--content=/media/internal/Movies/",
                    "--no-telnet",
                    "--port=8080");
            } catch (e) {
                this.log("EXCEPTION: " + e);
            }
            this.log("Sharing");
            this.sharingStarted(); /* TODO: Make this a callback above */
        }
    },          
    // Log errors to the console for debugging
    openPortFailure: function(inSender, inError, inRequest) {
        this.log(enyo.json.stringify(inError));
    }


});