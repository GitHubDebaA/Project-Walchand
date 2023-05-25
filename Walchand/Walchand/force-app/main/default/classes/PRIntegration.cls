@RestResource(urlMapping='/B2Cpurchase/')
global class PRIntegration {
    
    @HttpPost
    global static string doPost(){
        
        RestRequest req= RestContext.request;
        string jsonData=req.requestBody.toString();
        System.debug('jsonData-->'+jsonData);
        
        
        PRWrapeer accWr = PRWrapeer.parse(jsonData);
        // system.debug('accWr.prRequest '+accWr.prRequest);
        //set<Id> uid=new set<Id>();
        set<string> uid=new set<string>();
        for(PRWrapeer.cls_pr cc:accWr.prRequest){
            if(cc.SAPPRKey!=null){
                uid.add(cc.SAPPRKey);
            }
        }
        system.debug('uid:'+uid);
        string msg;
        
        
        
        List<PR_Line_Item__c> prlii=[select id,name,SAPPRKey__c,Material_Group__c,Material_Group_Desc__c,Requisitioner__c,Plant__c,Short_Closed__c,
                                     PRDelFlag__c,ReleaseFlag__c,Delivery_Date__c,Purchasing_Group__c,Purchase_Group_Name_Buyer__c,Document_Type__c,
                                     Changed_on__c,Unit_of_Measure__c,PR_Line_Item__c,Release_Date__c,Requisition_Date__c,
                                     Quantity_Requested__c,Doc_Type_Desc__c,UOM_Description__c,PO_Quantity__c,Service_Sr_No__c,Item_Catg__c,
                                     Additional_Long_text__c,Short_Text__c,Material__c from PR_Line_Item__c where SAPPRKey__c=:uid];
        system.debug('prlii:'+prlii.size());
        
        List<PR_Line_Item__c> prli=new List<PR_Line_Item__c>();
        if(prlii.size()==0){
            for(PRWrapeer.cls_pr cc:accWr.prRequest){
                PR_Line_Item__c p=new PR_Line_Item__c();
                p.Name=cc.Name;
                p.SAPPRKey__c=cc.SAPPRKey;
                p.Material_Group__c=cc.Material_Group;
                p.Material_Group_Desc__c=cc.Material_Group_Desc;
                p.Requisitioner__c=cc.Requisitioner;
                p.Plant__c=cc.Plant;
                p.Short_Closed__c=cc.Short_Closed;
                p.PRDelFlag__c=cc.PRDelFlag;
                p.ReleaseFlag__c=cc.ReleaseFlag;
                
                p.Delivery_Date__c=Date.valueof(cc.Delivery_Date);
                p.Purchasing_Group__c=cc.Purchasing_Group;
                p.Purchase_Group_Name_Buyer__c=cc.Purchase_Group_Name_Buyer;
                p.Document_Type__c=cc.Document_Type;
                p.Changed_on__c=Date.valueof(cc.Changed_on);
                p.Unit_of_Measure__c=cc.Unit_of_Measure;
                p.PR_Line_Item__c=cc.PR_Line_Item;
                p.Release_Date__c=Date.valueof(cc.Release_Date);
                p.Requisition_Date__c=Date.valueof(cc.Requisition_Date);
                p.Quantity_Requested__c=cc.Quantity_Requested;
                
                p.Doc_Type_Desc__c=cc.Doc_Type_Desc;
                p.UOM_Description__c=cc.UOM_Description;
                p.PO_Quantity__c=cc.PO_Quantity;
                p.Service_Sr_No__c=cc.Service_Sr_No;
                p.Item_Catg__c=cc.Item_Catg;
                p.Additional_Long_text__c=cc.Additional_Long_text;
                p.Short_Text__c=cc.Short_Text;
                p.Material__c=cc.Material;
                prli.add(p);
            }
            
            try{
                insert prli;
            }
            catch(Exception e){
                system.debug('insert error:'+e.getMessage());
                system.debug('Line no:'+e.getLineNumber());
            }
            msg='Sucessfully Inserted PR!!!';
        }
        if(prlii.size()>0){
            for(PRWrapeer.cls_pr cc:accWr.prRequest){
                
                for(PR_Line_Item__c pp:prlii){
                    if(pp.SAPPRKey__c==cc.SAPPRKey){
                        PR_Line_Item__c p=new PR_Line_Item__c();
                        p.Id=pp.Id;
                        p.Name=cc.Name;
                        p.SAPPRKey__c=cc.SAPPRKey;
                        p.Material_Group__c=cc.Material_Group;
                        p.Material_Group_Desc__c=cc.Material_Group_Desc;
                        p.Requisitioner__c=cc.Requisitioner;
                        p.Plant__c=cc.Plant;
                        p.Short_Closed__c=cc.Short_Closed;
                        p.PRDelFlag__c=cc.PRDelFlag;
                        p.ReleaseFlag__c=cc.ReleaseFlag;
                        
                        p.Delivery_Date__c=Date.valueof(cc.Delivery_Date);
                        p.Purchasing_Group__c=cc.Purchasing_Group;
                        p.Purchase_Group_Name_Buyer__c=cc.Purchase_Group_Name_Buyer;
                        p.Document_Type__c=cc.Document_Type;
                        p.Changed_on__c=Date.valueof(cc.Changed_on);
                        p.Unit_of_Measure__c=cc.Unit_of_Measure;
                        p.PR_Line_Item__c=cc.PR_Line_Item;
                        p.Release_Date__c=Date.valueof(cc.Release_Date); 
                        p.Requisition_Date__c=Date.valueof(cc.Requisition_Date);
                        p.Quantity_Requested__c=cc.Quantity_Requested;
                        
                         p.Doc_Type_Desc__c=cc.Doc_Type_Desc;
                        p.UOM_Description__c=cc.UOM_Description;
                        p.PO_Quantity__c=cc.PO_Quantity;
                        p.Service_Sr_No__c=cc.Service_Sr_No;
                        p.Item_Catg__c=cc.Item_Catg;
                        p.Additional_Long_text__c=cc.Additional_Long_text;
                        p.Short_Text__c=cc.Short_Text;
                        p.Material__c=cc.Material;
                        prli.add(p);
                    }
                }
                
            }
            try{
                update prli;
            }
            catch(Exception e){
                system.debug('insert error:'+e.getMessage());
                system.debug('Line no:'+e.getLineNumber());
            }
            msg='Sucessfully Updated PR!!!';
        }
        return msg;
    }
}