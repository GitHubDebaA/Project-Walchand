({
    doinitHelper : function(component, event, helper) {
        console.log("doinit helper is running");
        let action = component.get("c.getDetails");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                let rval = JSON.parse(response.getReturnValue());
                component.set("v.RFQ", rval.rfq);
                component.set("v.RFQItems", rval.lstRFQItems);
                component.set("v.VRFQ", rval.lstVRFQ);
                component.set("v.wrapRFQItems", helper.sortPriorityTable(component, event, helper, rval.lstWrapRFQItems));
                component.set("v.wrapOtherItems", rval.wrapOtherItems);
            }
            if(state === "ERROR") {
                let error = response.getError();
                let errorMessage = error[0].message;
                helper.openAlert(component, event, errorMessage, 'error', 'Error!', function() {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/" + component.get("v.recordId")
                    });
                    urlEvent.fire();
                });
            }
        });
        
        $A.enqueueAction(action);
    },
    
    openAlert : function(component, event, message, theme, label, ff) {
        this.LightningAlert.open({
            message: message,
            theme: theme,
            label: label,
        }).then(function() {
            console.log('alert is closed');
            ff();
        });
    },
    
    sortPriorityTable : function(component, event, helper, data) {
        for(let item of data) {
            item.lstVendorPriority.sort(function(a, b){return a.priority - b.priority});
        }
        return data;
    },
})