/*
    * Created By Debasis Das, 20 May 2023
    * Description: Create a RestResource to capture Purchase Order and PO Line Items. We are taking list PO Line Item in the body.
    After that we are checking with the SAP Key, 
    If a PO Line Item exist in the SFDC, then we update that PO Line Item and  
    IF it is not available then we are creating a new PO Line Item,
    
    Last Modified Date          Last Modified By            Description
    22/05/2022                  Debasis Das                 Creating the RestResource as per description
*/

@RestResource(urlMapping='/B2CPurchaseOrder/')
global class RestResource_POIntegration {

    @HttpPost
    global static string POSTConstructor() {
        RestRequest req = RestContext.request;
        string jsonData = req.requestBody.toString();
        System.debug('[jsonData] ' + jsonData);
        
        Map<String, Object> mapRequestBody = (Map<String, Object>) JSON.deserializeUntyped(jsonData);

        List<Object> PORequest = (List<Object>) mapRequestBody.get('lstPOItems');

        // for loop in PORequest
        // setSAPKEY = sapKey / 5 key we will get 

        // SOQL In PO Line Item, we will get the existing PO Line Item // we will get 2 po line item 

        // FOR loop in Above SOQL Instance 
        // Map the items, mapPOItems Key = Item.SAPKEy, value = PO Line Item/Id

        // Insert List
        // Update List
        // for loop in PORequest / item
        // IF(mapPOItems.containsKey(item.sapKey)) 
        //      POItem = item;
        //      poitem.Id = id;
        //      add in Update list
        // else 
        //      POItem = item;
        //      add in Insert List    

        // Update Update List
        // Insert Insert List





        return '';
    }
}