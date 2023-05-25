({
    doinit_helper01: function(component, event, helper) {
        let self = this;
        
        let action = component.get("c.initDraftAuction");

        action.setParams({
            "recordId" : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log("state : " + state);
            if(state === "SUCCESS") {
                console.log("Return Value : ");
                console.log(response.getReturnValue());
                let rval = JSON.parse(response.getReturnValue());
                component.set("v.dauction", rval.dact);
                component.set("v.wrapMeta", rval);
                component.set("v.upcoming_remainingTime", rval.upcoming_rt);
                component.set("v.ongoing_remainingTime", rval.ongoing_rt);
                component.set("v.currentslab_remainingTime", rval.currentslab_rt);
                component.set("v.vendorPlusProfile", rval.vendorPlusProfile);
                component.set("v.participatedOrNot", rval.participateorNot);

                if(rval.upcomingAuction) {
                    let timeoutId =  window.setTimeout(
                        $A.getCallback(function() {
                            var reinit = component.get("c.doinit");
                            $A.enqueueAction(reinit);
                        }), rval.upcoming_rt
                    );
					component.set("v.upcoming_timeoutId", timeoutId);
                    self.formatTimeHelper(component, event, helper, "upcoming");
                }

                if(rval.ongoingAuction) {
                    let timeoutId =  window.setTimeout(
                        $A.getCallback(function() {
                            var reinit = component.get("c.doinit");
                            $A.enqueueAction(reinit);
                        }), rval.ongoing_rt
                    );
                    
					component.set("v.ongoing_timeoutId", timeoutId);
                    self.formatTimeHelper(component, event, helper, "ongoing");
                    self.formatTimeHelper(component, event, helper, "slab");
                    self.updateVendorPosition_helper(component, event, helper);
                }
                if(rval.finishedAuction) {
                    self.updatePosition_helper(component, event, helper);
                }
            }
            if(state === "ERROR") {
                let error = response.getError();
                let errorMessage = error[0].message;
                console.log("error message : " + errorMessage);
            }
        });
        $A.enqueueAction(action);
    },

    formatTimeHelper: function(component, event, helper, type) {
        let timeoutId =  window.setInterval(
            $A.getCallback(function() {
                helper.formatTime(component, event, helper, type);
                if(type === "ongoing") {
                    helper.liveBeeper(component, event, helper);
                }
            }), 1000
        );
        
        if(type === "upcoming") {
            component.set("v.upcoming_intervalId", timeoutId);
        }
        
        if(type === "ongoing") {
            component.set("v.ongoing_intervalId", timeoutId);
        }

        if(type ===  "slab") {
            component.set("v.currentslab_intervalId", timeoutId);
        }
    },

    liveBeeper : function(component, event, helper) {
        let label = 'live gif';
        let section = component.find(label);
        $A.util.toggleClass(section, "live-gif-annimation");
    },
    
    formatTime: function (component, event, helper, type) {
        let rtime = 0;
        if(type === 'upcoming') rtime = component.get("v.upcoming_remainingTime");
        if(type === 'ongoing') rtime = component.get("v.ongoing_remainingTime");
        if(type === 'slab') rtime = component.get("v.currentslab_remainingTime");

       // console.log("formatTime rtime : " + rtime);
        let ntime = rtime - 1000;

        let secondc = Number.parseInt(ntime / 1000);
        let minutec = Number.parseInt(secondc / 60);
        secondc = secondc % 60;

        let hourc = Number.parseInt(minutec / 60);
        minutec = minutec % 60;

        let daysc = Number.parseInt(hourc / 24);
        hourc = hourc % 24;
        let rtimeS = '';
        
        if(type === 'slab' || type === 'ongoing') {
            rtimeS = this.pad(hourc) + ":" + this.pad(minutec) + ":" + this.pad(secondc);
        } else {
            rtimeS = this.pad(daysc) + " Days " + this.pad(hourc) + ":" + this.pad(minutec) + ":" + this.pad(secondc);
        }


        if(type === "upcoming") {
            component.set("v.upcoming_formattedRTime", rtimeS);
            component.set("v.upcoming_remainingTime", ntime);
            if(ntime <= 0) {
                window.clearInterval(component.get("v.upcoming_intervalId"));
            }
        }
        if(type === "ongoing") {
            component.set("v.ongoing_formattedRTime", rtimeS);
            component.set("v.ongoing_remainingTime", ntime);
        }
        if(type === "slab") {
            component.set("v.currentslab_formattedRTime", rtimeS);
            component.set("v.currentslab_remainingTime", ntime);
            if(ntime <= 0) {
                window.clearInterval(component.get("v.currentslab_intervalId"));
                let action = component.get("c.doinit");
                $A.enqueueAction(action);
            }
        }
    },

    pad : function(d) {
        return (d < 10) ? '0' + d.toString() : d.toString();
    },
    
    openConfirm: function(component, event, helper, message, theme, label, ff) {
        this.LightningConfirm.open({
            message: message,
            theme: theme,
            label: label,
        }).then(function(result) {
            // result is true if clicked "OK"
            // result is false if clicked "Cancel"
            console.log('confirm result is', result);
            
            if(result) ff();
        });
    },
    
    acceptCurrentBid_helper: function (component, event, helper) {
        console.log("acceptCurrentBid_helper is running...");
        var action = component.get("c.captureAcceptPrice");
        action.setParams({
            "dauc": JSON.stringify(component.get("v.dauction")),
            "paymentTerms" : component.get("v.vendorPT"),
            "deliveryTerms" : component.get("v.vendorDT"),
            "bidRemarks" : component.get("v.bidRemarks"),
            "recordId": component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            var status = response.getState();
            console.log("response state : " + status);
            var type, msg, title;

            if(status === "SUCCESS") {
                type = "success";
                msg = 'Congratulations !! You Have Made a Bid !!!';
                title = "Auction Response!!!";
            }
            if(status === "ERROR") {
                let err = response.getError();
                console.log(JSON.stringify(err));
                title = 'Error';
                type = 'error';
                msg = err[0].message;
                console.log("error message : " + msg);
            }
            
            let reinit = component.get("c.doinit");
            $A.enqueueAction(reinit);

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": msg
            });
            toastEvent.fire();
        });
        $A.enqueueAction(action);
    },
    
    updateVendorPosition_helper : function(component, event, helper) {
        let self = this;
        let timeoutId =  setInterval( () => {
            self.updateVendorPosition(component, event, helper);
        }, 10000);
        component.set("v.ongoing_PositionIntervalId", timeoutId);
    },
    
    updateVendorPosition : function(component, event, helper) {
        let meta = component.get("v.wrapMeta");
        
        let action = component.get("c.getVendorPosition");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
        	let state = response.getState();
            console.log("state : " + state);
            if(state === "SUCCESS") {
                let rval = response.getReturnValue();
                console.log("rval : " + rval);
                if(rval === "error") {
                    meta.position = 'N/A';
                    meta.l1Price = 'N/A';
                    meta.l1Count = 'N/A';
                    meta.bidPrice = 'N/A';
                } else {
                    let parsedRval = JSON.parse(rval);
                    meta.position = parsedRval.Position === -1 ? 'N/A' : parsedRval.Position;
                    meta.l1Price = parsedRval.L1 === null || parsedRval.L1 === undefined ? 'N/A' : parsedRval.L1;
                    meta.l1Count = parsedRval.L1Count;
                    meta.bidPrice = parsedRval.VendorBidPrice == null || parsedRval.VendorBidPrice == undefined ? 'N/A' : parsedRval.VendorBidPrice;
                }
                
                component.set("v.wrapMeta", meta);
            } 
            if(state === "ERROR") {
                console.log("error in get position");
            }
        });
        
        $A.enqueueAction(action);
    },
    
    updatePosition_helper : function(component, event, helper) {
        console.log("updatePosition_helper is running");
        let action = component.get("c.UpdateVendorPosition");
        
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log("state : " + state);
            
            if(state === "SUCCESS") {
                console.log("Vendor position capture successfully.");
            }
            if(state === "ERROR") {
                let error = response.getError();
                let errorMessage = error[0].message;
                console.log("error : " + errorMessage);
            }
        });
        
        $A.enqueueAction(action);
    }
})