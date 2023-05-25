({
    doinit : function(component, event, helper) {
        helper.doinitHelper(component, event, helper);
    },
    
    handleSelectVRFQ : function(component, event, helper) {
        return;
        console.log("handleSelectVRFQ trigger : " + event.currentTarget.dataset.id);
        let elementId = event.currentTarget.dataset.id;
        let keys = elementId.split("/");
        let vrfq = keys[0];
        let index = keys[1];
        let jndex = keys[2];
        
        let wrapRFQItems = component.get("v.wrapRFQItems");
        
        let RFQItems = wrapRFQItems[index];
        let lstPriority = RFQItems.lstVendorPriority;
        let VRFQItems = RFQItems.lstVRFQItems[jndex];
        
        if(VRFQItems.className.includes('tableTDSelected')) {
            VRFQItems.className = 'tableColumnPointer';
            VRFQItems.classNameSeperetor = 'tableColumnPointer seperator';
            RFQItems.maxPriority -= 1;
            VRFQItems.isSelected = false;
            
            let priority = VRFQItems.priority;
            
            for(let i=priority-1; i<lstPriority.length-1; i++) {
                lstPriority[i] = lstPriority[i+1];
            }
            lstPriority[lstPriority.length-1] = '';
            
            for(let item of RFQItems.lstVRFQItems) {
                if(item.priority != null || item.priority != undefined) {
                    if(item.isSelected) {
                        if(item.priority > priority) {
                            item.priority -= 1;
                            if(item.priority === 0) item.priority = null;
                        }
                    } else {
                        item.priority = null;
                    }
                }
            }
            
        } else {
            VRFQItems.className = 'tableColumnPointer tableTDSelected';
            VRFQItems.classNameSeperetor = 'tableColumnPointer tableTDSelected seperator';
            RFQItems.maxPriority += 1;
            if(RFQItems.maxPriority - 1 >= 0) lstPriority[RFQItems.maxPriority - 1] = VRFQItems.vrfqItems.Vendor__r.Name;
            VRFQItems.priority = RFQItems.maxPriority;
            VRFQItems.isSelected = true;
        }
        
        component.set("v.wrapRFQItems", wrapRFQItems);
    },
    
    dragStart: function(component, event, helper) {
        var tdNode = event.currentTarget.closest("td");
        var rowIndex = tdNode.parentNode.dataset.index;
        var colIndex = event.currentTarget.dataset.index;
        event.dataTransfer.setData("text", rowIndex + ":" +colIndex );
        event.dataTransfer.setData("value", event.currentTarget.dataset.value); 
        
        // set className of the dragged item to blue
        var RFQItems = component.get("v.wrapRFQItems");
        RFQItems[rowIndex].lstVendorPriority[colIndex].className = 'dragStart';
                
        component.set("v.wrapRFQItems", RFQItems);
        
    },
    
    allowDrop: function(component, event, helper) {
        event.preventDefault();
    },
    
    onClosedDrop: function(component, event, helper) {
        event.preventDefault();
        
        var dragItem = event.dataTransfer.getData("text");
        
        var dropRowIndex = event.currentTarget.dataset.indexcol;
        var dropColIndex = event.currentTarget.dataset.index;
        var dragRowIndex = dragItem.split(":")[0];
        var dragColIndex = dragItem.split(":")[1];
        
        if (dropRowIndex == dragRowIndex) {
            let RFQItems = component.get("v.wrapRFQItems");
            let vendors = RFQItems[dropRowIndex].lstVendorPriority;
            
            let sourceItem = vendors[dragColIndex];
            
            vendors.splice(dragColIndex, 1);
            vendors.splice(dropColIndex, 0, sourceItem);
            sourceItem.className = "";

            // Set className attribute of dragged item to green and all other items in the same row to red

            let vrfqItems = RFQItems[dropRowIndex].lstVRFQItems;
            console.log("vrfqItems size : " + vrfqItems.length);
            
            const priority = new Map();
            
            for(let i=0; i < vendors.length; i++) {
                console.log("vrfqItems name: " + vendors[i].vrfqItems);
                priority.set(vendors[i].vrfqItems, i+1);
            }

            console.log("map : ");
            console.log(priority);
            
            for(let item of vrfqItems) {
                console.log("vrfq item : " + item.vrfqItems.Name);
                item.vrfqItems.Priority__c = priority.get(item.vrfqItems.Name);
                console.log("item.Priority__c : " + item.Priority__c);
            }
			console.log('final check');
            component.set("v.wrapRFQItems", RFQItems);
        } else {
            let RFQItems = component.get("v.wrapRFQItems");
            let vendors = RFQItems[dropRowIndex].lstVendorPriority;
            
            let sourceItem = vendors[dragColIndex];
            let targetItem = vendors[dropColIndex];
            
            sourceItem.className = "";
            component.set("v.wrapRFQItems", RFQItems);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : "warning",
                "message": "Cannot Drag and Drop between Rows."
            });
            toastEvent.fire();
        }
    },
    
    handleUpdateClick : function(component, event, helper) {
        let rfqItems = component.get("v.wrapRFQItems");
        
        component.set("v.updateStatus", true);
        let action = component.get("c.updateVRFQItems");
        
        action.setParams({
            "data" : JSON.stringify(rfqItems)
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            component.set("v.updateStatus", false);
            if(state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "",
                    "message": "The record has been updated successfully.",
                    "type" : "success"
                });
                toastEvent.fire();
            }
            if(state === "ERROR") {
                let error = response.getError();
                let errorMessage = error[0].message;
                helper.openAlert(component, event, errorMessage, 'error', 'Error!', function() {
                    return;
                });
            }
        });
        $A.enqueueAction(action);
    }
})