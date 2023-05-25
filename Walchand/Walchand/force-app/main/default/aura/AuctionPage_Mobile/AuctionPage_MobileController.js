({
    doinit: function (component, event, helper) {
    
        window.clearInterval(component.get("v.upcoming_intervalId"));
        window.clearInterval(component.get("v.ongoing_intervalId"));
        window.clearInterval(component.get("v.currentslab_intervalId"));
        window.clearTimeout(component.get("v.upcoming_timeoutId"));
        window.clearTimeout(component.get("v.ongoing_timeoutId"));
        window.clearInterval(component.get("v.ongoing_PositionIntervalId"));

        helper.doinit_helper01(component, event, helper);
    },
    
    closePOPreview : function(component, event, helper){
        component.set("v.showaccesptprisepoup",false);
    } ,
    
    acceptCurrentBid : function(component, event, helper) {
        let dauc = component.get("v.dauction");
        let vendorPTc = component.get("v.vendorPT");
        let vendorDTc = component.get("v.vendorDT");
        
        if(vendorPTc == null || vendorPTc == undefined || vendorPTc.trim().length == 0) {
            alert("Please Give Vendor Payment Terms");
            return;
        }
        
        if(vendorDTc == null || vendorDTc == undefined || vendorDTc.trim().length == 0) {
            alert("Please Give Vendor Delivery Terms");
            return;
        }

        
        let message = "Are you sure you want to bid for " + dauc.Current_Bid_Price__c + ". Please Review Payment Terms & Delivery Terms.";
        let theme = "warning";
        let label = "Please Confirm";
        helper.openConfirm(component, event, helper, message, theme, label, function() {
			helper.acceptCurrentBid_helper(component, event, helper);
        });
    },
    
    participate: function (component, event, helper) {
        var action = component.get("c.participateAuction");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var type, title, msg;
            
            if(state === "SUCCESS") {
                type = "success";
                msg = "Congratulations !! You Have Participated Now !!!";
                title = "Auction Response!!!";
                
                let redoinit = component.get("c.doinit");
                $A.enqueueAction(redoinit);
            }
            if(state === "ERROR") {
                let error = response.getError();
                type = "error";
                msg = error[0].message;
                title = "Error!!!";
            }
            
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
    
    handleChangeTNC : function(component, event, helper) {
        console.log("value : " + event.getSource().get("v.checked"));
        console.log("name : " + event.getSource().get("v.name"))

        let name = event.getSource().get("v.name");
        let value = event.getSource().get("v.checked");
        let dauc = component.get("v.dauction");

        
        if(name === "acceptCustomerPT" && value) {
            component.set("v.vendorPT", dauc.Payment_Terms__c);
        } 
        if(name === "acceptCustomerDT" && value) {
            component.set("v.vendorDT", dauc.Delivery_Terms__c);
        }
    },
    handleClick : function(component,event){
        window.open('https://www.youtube.com/watch?v=2exB6irHw4c&t=6s');
        $A.get('e.force:closeQuickAction').fire();
    }
})