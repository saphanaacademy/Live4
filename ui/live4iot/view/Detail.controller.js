sap.ui.core.mvc.Controller.extend("live4IoT.view.Detail", {

	onInit : function() {
		this.oInitialLoadFinishedDeferred = jQuery.Deferred();

		if(sap.ui.Device.system.phone) {
			//Do not wait for the master when in mobile phone resolution
			this.oInitialLoadFinishedDeferred.resolve();
		} else {
			this.getView().setBusy(true);
			var oEventBus = this.getEventBus(); 
			oEventBus.subscribe("Component", "MetadataFailed", this.onMetadataFailed, this);
			oEventBus.subscribe("Master", "InitialLoadFinished", this.onMasterLoaded, this);
		}

		this.getRouter().attachRouteMatched(this.onRouteMatched, this);
	},

	onMasterLoaded :  function (sChannel, sEvent) {
		this.getView().setBusy(false);
		this.oInitialLoadFinishedDeferred.resolve();
	},
	
	onMetadataFailed : function(){
		this.getView().setBusy(false);
		this.oInitialLoadFinishedDeferred.resolve();
        this.showEmptyView();	    
	},

	onRouteMatched : function(oEvent) {
		var oParameters = oEvent.getParameters();

		jQuery.when(this.oInitialLoadFinishedDeferred).then(jQuery.proxy(function () {
			var oView = this.getView();

			// When navigating in the Detail page, update the binding context 
			if (oParameters.name !== "detail") { 
				return;
			}

			var sEntityPath = "/" + oParameters.arguments.entity;
			this.bindView(sEntityPath);

			var oIconTabBar = oView.byId("idIconTabBar");
			oIconTabBar.getItems().forEach(function(oItem) {
			    if(oItem.getKey() !== "selfInfo"){
    				oItem.bindElement(oItem.getKey());
			    }
			});

			// Specify the tab being focused
			var sTabKey = oParameters.arguments.tab;
			this.getEventBus().publish("Detail", "TabChanged", { sTabKey : sTabKey });

			if (oIconTabBar.getSelectedKey() !== sTabKey) {
				oIconTabBar.setSelectedKey(sTabKey);
			}
		}, this));

	},

	bindView : function (sEntityPath) {
		var oView = this.getView();
		oView.bindElement(sEntityPath); 

		//Check if the data is already on the client
		if(!oView.getModel().getData(sEntityPath)) {

			// Check that the entity specified was found.
			oView.getElementBinding().attachEventOnce("dataReceived", jQuery.proxy(function() {
				var oData = oView.getModel().getData(sEntityPath);
				if (!oData) {
					this.showEmptyView();
					this.fireDetailNotFound();
				} else {
					this.fireDetailChanged(sEntityPath);
				}
			}, this));

		} else {
			this.fireDetailChanged(sEntityPath);
		}

	},

	showEmptyView : function () {
		this.getRouter().myNavToWithoutHash({ 
			currentView : this.getView(),
			targetViewName : "live4IoT.view.NotFound",
			targetViewType : "XML"
		});
	},

	fireDetailChanged : function (sEntityPath) {
		this.getEventBus().publish("Detail", "Changed", { sEntityPath : sEntityPath });
		this.byId("sAQI").setValue(parseInt(this.byId("iAQI").getValue()));
		this.byId("sTmp").setValue(parseInt(this.byId("iTmp").getValue()));
		this.byId("sHum").setValue(parseInt(this.byId("iHum").getValue()));
	},

	fireDetailNotFound : function () {
		this.getEventBus().publish("Detail", "NotFound");
	},

	onNavBack : function() {
		// This is only relevant when running on phone devices
		this.getRouter().myNavBack("main");
	},

	onDetailSelect : function(oEvent) {
		sap.ui.core.UIComponent.getRouterFor(this).navTo("detail",{
			entity : oEvent.getSource().getBindingContext().getPath().slice(1),
			tab: oEvent.getParameter("selectedKey")
		}, true);
	},

	openActionSheet: function() {

		if (!this._oActionSheet) {
			this._oActionSheet = new sap.m.ActionSheet({
				buttons: new sap.ushell.ui.footerbar.AddBookmarkButton()
			});
			this._oActionSheet.setShowCancelButton(true);
			this._oActionSheet.setPlacement(sap.m.PlacementType.Top);
		}
		
		this._oActionSheet.openBy(this.getView().byId("actionButton"));
	},

	iAQIChange: function() {
		this.byId("sAQI").setValue(Number(this.byId("iAQI").getValue()));
	},
	
	sAQILiveChange: function() {
		this.byId("iAQI").setValue(this.byId("sAQI").getValue());
	},
	
	iTmpChange: function() {
		this.byId("sTmp").setValue(Number(this.byId("iTmp").getValue()));
	},
	
	sTmpLiveChange: function() {
		this.byId("iTmp").setValue(this.byId("sTmp").getValue());
	},
	
	iHumChange: function() {
		this.byId("sHum").setValue(Number(this.byId("iHum").getValue()));
	},
	
	sHumLiveChange: function() {
		this.byId("iHum").setValue(this.byId("sHum").getValue());
	},
	
	onAccept: function() {
        var oModel = this.getView().getModel();
 		oModel.submitChanges(function(){
                jQuery.sap.require("sap.m.MessageToast");
                sap.m.MessageToast.show("Update saved.");
        		$.ajax({
        			url: jQuery.sap.getModulePath("live4IoT") + "/destinations/live4/services.xsjs?cmd=predict",
        			type: "get",
        			error: function() {
        				console.log("Predict error.");
        			},
        			success: function() {
        				console.log("Predict finished.");
        			}
        		});                
 			},function(){
                jQuery.sap.require("sap.m.MessageBox");
 				sap.m.MessageBox.alert("Update failed.");
 			});
	},

	onReject: function() {
        var oModel = this.getView().getModel();
		oModel.resetChanges();
	},

	getEventBus : function () {
		return sap.ui.getCore().getEventBus();
	},

	getRouter : function () {
		return sap.ui.core.UIComponent.getRouterFor(this);
	},
	
	onExit : function(oEvent){
	    var oEventBus = this.getEventBus();
    	oEventBus.unsubscribe("Master", "InitialLoadFinished", this.onMasterLoaded, this);
		oEventBus.unsubscribe("Component", "MetadataFailed", this.onMetadataFailed, this);
		if (this._oActionSheet) {
			this._oActionSheet.destroy();
			this._oActionSheet = null;
		}
	}
});
