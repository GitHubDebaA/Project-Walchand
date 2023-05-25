@istest
public class PRIntegration_Test {
  
    
    @istest
    public static void testdata(){
        
        
        
        RFQ__c rfq=new RFQ__c();
        rfq.LD_clause__c='Applicable';
        rfq.Warrranty_Period_Months__c='50';
        rfq.RFQ_Type__c='Material';
        rfq.PBG__c='Applicable';
        rfq.PBG_Type__c='%';
        rfq.Transit_Insurance__c='Yes';
        rfq.Insurance_Type__c='%';
        rfq.Insurance_Cost__c=10;
        rfq.Incoterms__c='CFR – Cost and Freight';
        rfq.Currency__c='USD- U.S Doller';
        rfq.Payment_Terms__c='test';
        rfq.Vendor_type__c='import';
        // rfq.Packing__c='import';
        rfq.LD_clause_details__c='test';
        //  insert rfq;
        
        list<PR_Line_Item__c> prlist=new list<PR_Line_Item__c>();
        //PRWrapeer.JsonAccount acc = new WSCustomerEdit.JsonAccount();
        
        PR_Line_Item__c pritem=new PR_Line_Item__c();
        pritem.RFQ__c=rfq.Id;
        pritem.Document_Type__c='FO';
        pritem.Purchasing_Group__c='110';
        pritem.Changed_on__c=System.today();
        pritem.Unit_of_Measure__c='%';
        pritem.Delivery_Date__c=System.today();
        pritem.PR_Line_Item__c=10;
        pritem.Material_Group__c='001';
        pritem.Release_Date__c=date.today();
        pritem.Requisition_Date__c=System.today();
        pritem.Quantity_Requested__c=10;
        pritem.P__c = 'Open';
        pritem.ReleaseFlag__c = 'Y';
        // insert pritem;
        prlist.add(pritem);
        
        PR_Line_Item__c pritem1=new PR_Line_Item__c();
        pritem1.RFQ__c=rfq.Id;
        pritem1.Document_Type__c='FO';
        pritem1.Purchasing_Group__c='110';
        pritem1.Changed_on__c=System.today();
        pritem1.Unit_of_Measure__c='%';
        pritem1.Delivery_Date__c=System.today();
        pritem1.PR_Line_Item__c=10;
        pritem1.Material_Group__c='001';
        pritem1.Release_Date__c=date.today();
        pritem1.Requisition_Date__c=System.today();
        pritem1.Quantity_Requested__c=10;
        pritem1.P__c = 'Open';
        pritem1.ReleaseFlag__c = 'Y';
      pritem1.SAPPRKey__c = 'S9000001815000600000000060';
        prlist.add(pritem1);
        insert prlist;
   
        
         list<PRWrapeer.cls_pr> pr_list=new list<PRWrapeer.cls_pr>();
         PRWrapeer.cls_pr cl=new PRWrapeer.cls_pr();
        cl.Changed_on = string.valueof(pritem1.Changed_on__c);
        cl.Delivery_Date =  string.valueof(pritem1.Delivery_Date__c);
        cl.Document_Type = pritem1.Document_Type__c;
        CL.Material_Group =pritem1.Material_Group__c;
        CL.Material_Group_Desc = pritem1.Material_Group_Desc__c;
        CL.Name = pritem1.Name;
        CL.Plant =pritem1.Plant__c;
        CL.PR_Line_Item =pritem1.PR_Line_Item__c;
        CL.PRDelFlag  =pritem1.PRDelFlag__c;
        CL.Purchase_Group_Name_Buyer =pritem1.Purchase_Group_Name_Buyer__c;
        cl.Purchasing_Group = pritem1.Purchasing_Group__c;
        cl.Quantity_Requested = pritem1.Quantity_Requested__c;
        cl.Requisitioner = pritem1.Requisitioner__c;
        cl.SAPPRKey = 'S9000001815000600000000060';
        cl.Short_Closed  =pritem1.Short_Closed__c;
        cl.Unit_of_Measure = 'NO';
        cl.Requisition_Date = string.valueof(date.today());
        cl.Release_Date = string.valueOf(date.today());
        
        pr_list.add(cl);
        
         PRWrapeer.cls_pr cl1=new PRWrapeer.cls_pr();
        cl1.Changed_on = string.valueof(pritem1.Changed_on__c);
        cl1.Delivery_Date =  string.valueof(pritem1.Delivery_Date__c);
        cl1.Document_Type = pritem1.Document_Type__c;
        CL1.Material_Group =pritem1.Material_Group__c;
        CL1.Material_Group_Desc = pritem1.Material_Group_Desc__c;
        CL1.Name = pritem1.Name;
        CL1.Plant =pritem1.Plant__c;
        CL1.PR_Line_Item =pritem1.PR_Line_Item__c;
        CL1.PRDelFlag  =pritem1.PRDelFlag__c;
        CL1.Purchase_Group_Name_Buyer =pritem1.Purchase_Group_Name_Buyer__c;
        cl1.Purchasing_Group = pritem1.Purchasing_Group__c;
        cl1.Quantity_Requested = pritem1.Quantity_Requested__c;
        cl1.Requisitioner = pritem1.Requisitioner__c;
        cl1.SAPPRKey = 'S900000181500060000000006000';
        cl1.Short_Closed  =pritem1.Short_Closed__c;
        cl1.Unit_of_Measure = 'NO';
        cl1.Requisition_Date = string.valueof(date.today());
        cl1.Release_Date = string.valueOf(date.today());
        
        pr_list.add(cl1);
       
   Test.startTest();
        PRWrapeer prr=new PRWrapeer();
        prr.prRequest = pr_list;
 String myJSON = JSON.serialize(prr); 
        
        
        //  system.debug('myJSON : ' + myJSON);
   RestRequest req = new RestRequest(); 
   RestResponse res = new RestResponse();

    req.requestURI = 'https://walchandnagarindustrieslimited--auction.sandbox.my.salesforce.com/services/apexrest/B2Cpurchase/';  //Request URL
    req.httpMethod = 'POST';//HTTP Request Type
    req.requestBody = Blob.valueof(myJSON);
    RestContext.request = req;
    RestContext.response= res;
         PRIntegration.doPost();
        Test.stopTest();
        
    }
    
    
    @istest
    public static void testdata1(){
        
        
        
        RFQ__c rfq=new RFQ__c();
        rfq.LD_clause__c='Applicable';
        rfq.Warrranty_Period_Months__c='50';
        rfq.RFQ_Type__c='Material';
        rfq.PBG__c='Applicable';
        rfq.PBG_Type__c='%';
        rfq.Transit_Insurance__c='Yes';
        rfq.Insurance_Type__c='%';
        rfq.Insurance_Cost__c=10;
        rfq.Incoterms__c='CFR – Cost and Freight';
        rfq.Currency__c='USD- U.S Doller';
        rfq.Payment_Terms__c='test';
        rfq.Vendor_type__c='import';
        // rfq.Packing__c='import';
        rfq.LD_clause_details__c='test';
        //  insert rfq;
        
        list<PR_Line_Item__c> prlist=new list<PR_Line_Item__c>();
        //PRWrapeer.JsonAccount acc = new WSCustomerEdit.JsonAccount();
        
        PR_Line_Item__c pritem=new PR_Line_Item__c();
        pritem.RFQ__c=rfq.Id;
        pritem.Document_Type__c='FO';
        pritem.Purchasing_Group__c='110';
        pritem.Changed_on__c=System.today();
        pritem.Unit_of_Measure__c='%';
        pritem.Delivery_Date__c=System.today();
        pritem.PR_Line_Item__c=10;
        pritem.Material_Group__c='001';
        pritem.Release_Date__c=date.today();
        pritem.Requisition_Date__c=System.today();
        pritem.Quantity_Requested__c=10;
        pritem.P__c = 'Open';
        pritem.ReleaseFlag__c = 'Y';
        // insert pritem;
        prlist.add(pritem);
        
        PR_Line_Item__c pritem1=new PR_Line_Item__c();
        pritem1.RFQ__c=rfq.Id;
        pritem1.Document_Type__c='FO';
        pritem1.Purchasing_Group__c='110';
        pritem1.Changed_on__c=System.today();
        pritem1.Unit_of_Measure__c='%';
        pritem1.Delivery_Date__c=System.today();
        pritem1.PR_Line_Item__c=10;
        pritem1.Material_Group__c='001';
        pritem1.Release_Date__c=date.today();
        pritem1.Requisition_Date__c=System.today();
        pritem1.Quantity_Requested__c=10;
        pritem1.P__c = 'Open';
        pritem1.ReleaseFlag__c = 'Y';
      pritem1.SAPPRKey__c = 'S9000001815000600000000060';
        prlist.add(pritem1);
        insert prlist;
   
        
         list<PRWrapeer.cls_pr> pr_list=new list<PRWrapeer.cls_pr>();
         
        
         PRWrapeer.cls_pr cl1=new PRWrapeer.cls_pr();
        cl1.Changed_on = string.valueof(pritem1.Changed_on__c);
        cl1.Delivery_Date =  string.valueof(pritem1.Delivery_Date__c);
        cl1.Document_Type = pritem1.Document_Type__c;
        CL1.Material_Group =pritem1.Material_Group__c;
        CL1.Material_Group_Desc = pritem1.Material_Group_Desc__c;
        CL1.Name = pritem1.Name;
        CL1.Plant =pritem1.Plant__c;
        CL1.PR_Line_Item =pritem1.PR_Line_Item__c;
        CL1.PRDelFlag  =pritem1.PRDelFlag__c;
        CL1.Purchase_Group_Name_Buyer =pritem1.Purchase_Group_Name_Buyer__c;
        cl1.Purchasing_Group = pritem1.Purchasing_Group__c;
        cl1.Quantity_Requested = pritem1.Quantity_Requested__c;
        cl1.Requisitioner = pritem1.Requisitioner__c;
        cl1.SAPPRKey = 'S900000181500060000000006000';
        cl1.Short_Closed  =pritem1.Short_Closed__c;
        cl1.Unit_of_Measure = 'NO';
        cl1.Requisition_Date = string.valueof(date.today());
        cl1.Release_Date = string.valueOf(date.today());
        
        pr_list.add(cl1);
       
   Test.startTest();
        PRWrapeer prr=new PRWrapeer();
        prr.prRequest = pr_list;
 String myJSON = JSON.serialize(prr); 
        
        
        //  system.debug('myJSON : ' + myJSON);
   RestRequest req = new RestRequest(); 
   RestResponse res = new RestResponse();

    req.requestURI = 'https://walchandnagarindustrieslimited--auction.sandbox.my.salesforce.com/services/apexrest/B2Cpurchase/';  //Request URL
    req.httpMethod = 'POST';//HTTP Request Type
    req.requestBody = Blob.valueof(myJSON);
    RestContext.request = req;
    RestContext.response= res;
         PRIntegration.doPost();
        Test.stopTest();
        
    }
}