/*
* Created By : Debasis Das
* Debasis has created this class 
* Date  :  25-04-2023
 Last Modified By : Sougata Paul
 Last Modified Date : 02-05-2023 Depending on record Type Description is shown --> Reverse Auction, Forward Auction and Generic Auction
 Last Modified Date : 03-05-2023 symbols added as per position, watch demo button added
*/
public without sharing class draftAuctionPageV2_cls {
    @AuraEnabled
    public static string initDraftAuction(String recordId){
        try {
            Draft_Auction__c dauction = [SELECT Id, Name, Auction_End_Time__c, Auction_Start_Date_Time__c, Current_Bid_Price__c, Payment_Terms__c, Delivery_Terms__c,
                                         CurrencyIsoCode, Last_Slab_Price1__c, Next_Slab_Price__c, OwnerId, Product__c, Quantity__c, RecordTypeId, Running_Time__c,
                                         Base_Price__c, Step_Reduction__c, Time_Interval_in_minutes__c, UOM__c, Product__r.Name, Product__r.ProductCode,
                                         Product__r.Description, Auction_Is_Yet_To_Start__c, Auction_Finished__c, ISAuction_ON__c, RecordType.Name
                                         FROM Draft_Auction__c WHERE Id =: recordId];
            
            if(Datetime.now() >= dauction.Auction_Start_Date_Time__c && Datetime.now() <= dauction.Auction_End_Time__c) {
                Datetime now = Datetime.now();
                
                Long passedTime = now.getTime() - dauction.Auction_Start_Date_Time__c.getTime();
                Decimal minutec = passedTime / 60000;
                Integer interval = (Integer) Math.floor(minutec / dauction.Time_Interval_in_minutes__c);
                
                if(dauction.RecordType.Name == 'Reverse Auction') dauction.Current_Bid_Price__c = dauction.Base_Price__c - (interval * dauction.Step_Reduction__c);
                if(dauction.RecordType.Name == 'Forward Auction') dauction.Current_Bid_Price__c = dauction.Base_Price__c + (interval * dauction.Step_Reduction__c);
            
                update dauction;
            }
            
            wrapMetaData meta = new wrapMetaData(dauction);
            return JSON.serialize(meta);
        } catch (Exception e) {
            System.debug('error message : ' + e.getMessage());
            System.debug('error line number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class wrapMetaData {
        public Draft_Auction__c dact;
        public Boolean ongoingAuction, finishedAuction, upcomingAuction, vendorPlusProfile, participateorNot, acceptCustomerPT, acceptCustomerDT, genericBidStatus;
        public Long upcoming_rt, ongoing_rt, currentslab_rt;
        public Decimal nextSlabPrice, currentL1Price, lastBidPrice, lastSlabPrice, nextSlabPrice_Upcoming,nextnextSlabPrice;
        public String position, l1Price, l1Count, bidPrice, vendorPT, vendorDT, recordType;
        public integer postitioncheck;

        public wrapMetaData(Draft_Auction__c param1) {
            dact = param1;
            ongoingAuction = false;
            finishedAuction = false;
            upcomingAuction = false;
            nextnextSlabPrice = 0;
            recordType = param1.RecordType.Name;
            if(param1.RecordType.Name == 'Reverse Auction') {
                nextSlabPrice = param1.Current_Bid_Price__c - param1.Step_Reduction__c;
                lastSlabPrice = param1.Current_Bid_Price__c + param1.Step_Reduction__c;
                if(lastSlabPrice > param1.Base_Price__c) lastSlabPrice = param1.Base_Price__c;
                nextSlabPrice_Upcoming = param1.Base_Price__c - param1.Step_Reduction__c;
                nextnextSlabPrice = nextSlabPrice_Upcoming - param1.Step_Reduction__c;
            }
            if(param1.RecordType.Name == 'Forward Auction') {
                nextSlabPrice = param1.Current_Bid_Price__c + param1.Step_Reduction__c;
                lastSlabPrice = param1.Current_Bid_Price__c - param1.Step_Reduction__c;
                if(lastSlabPrice < param1.Base_Price__c) lastSlabPrice = param1.Base_Price__c;
                nextSlabPrice_Upcoming = param1.Base_Price__c + param1.Step_Reduction__c;
                nextnextSlabPrice = nextSlabPrice_Upcoming + param1.Step_Reduction__c;
            } 
            if(Datetime.now() < param1.Auction_Start_Date_Time__c) upcomingAuction = true;
            if(Datetime.now() >= param1.Auction_Start_Date_Time__c && Datetime.now() <= param1.Auction_End_Time__c) ongoingAuction = true;
            if(Datetime.now() > param1.Auction_End_Time__c) finishedAuction =  true;
            
            upcoming_rt = param1.Auction_Start_Date_Time__c.getTime() - Datetime.now().getTime();
            ongoing_rt = param1.Auction_End_Time__c.getTime() - Datetime.now().getTime();
            
            Datetime now = Datetime.now();
            
            Long passedTime = now.getTime() - param1.Auction_Start_Date_Time__c.getTime();
            Decimal minutec = passedTime / 60000;
            Integer interval = (Integer) Math.floor(minutec / param1.Time_Interval_in_minutes__c);
            Integer intervalTime = (Integer) param1.Time_Interval_in_minutes__c * interval;
            
            Datetime currentendtime = param1.Auction_Start_Date_Time__c.addMinutes(intervalTime + (Integer) param1.Time_Interval_in_minutes__c);
            
            Long endtimeMS1 = currentendtime.getTime();
            Long endtimeMS2 = param1.Auction_End_Time__c.getTime();
            
            currentslab_rt = endtimeMS1 > endtimeMS2 ? endtimeMS2 - now.getTime() : endtimeMS1 - now.getTime();
            
            System.debug('upcoming rt : ' + upcoming_rt);
            System.debug('ongoing rt : ' + ongoing_rt);
            
            user cuser = [SELECT Id, Name, Profile.Name, ContactId FROM USER WHERE Id =: userinfo.getUserId()];
            
            vendorPlusProfile = cuser.Profile.Name == 'Vendor Plus' ? true : false;
            participateorNot = vendorParticipateorNot(param1.Id);
            
            list<Auction_Response__c> lstAResponse = [SELECT Id, Name, Bid_Price__c, Vendor__c, Draft_Auction__c, Product__c 
                                                      FROM Auction_Response__c
                                                      WHERE Draft_Auction__c =: param1.Id AND Bid_Price__c != NULL ORDER BY Bid_Price__c ASC];
            
            if(lstAResponse.size() == 0) currentL1Price = param1.Current_Bid_Price__c;
            else currentL1Price = lstAResponse[0].Bid_Price__c;
            
            lastBidPrice = getlastBidPrice(param1.Id);
            String rval = getVendorPosition(param1.Id);
            if(rval == 'error') {
                position = 'N/A';
                l1Price = 'N/A';
                l1Count = 'N/A';
            } else {
                Map<String, Object> mapRval = (Map<String, Object>) JSON.deserializeUntyped(rval);
                
                Integer positiont = (Integer) mapRval.get('Position');
                Integer l1countt = (Integer) mapRval.get('L1Count');
                Decimal l1Pricet = (Decimal) mapRval.get('L1');
                Decimal cuBidPrice = (Decimal) mapRval.get('VendorBidPrice');
                
                position = positiont == -1 ? 'N/A' : String.valueOf(positiont); 
                l1Price = l1Pricet == null ? 'N/A' : l1Pricet.format();
                bidPrice = cuBidPrice == null ? 'N/A' : cuBidPrice.format();
                l1Count = String.valueOf(l1countt);
                if(positiont == 1){
                    postitioncheck = 1;
                }
                else if(positiont == 2){
                    postitioncheck = 2;
                }
                else if(positiont == 3){
                    postitioncheck = 3;
                }
                else{
                    postitioncheck = 4;
                }
            }
        }
    }
    
    /*This is to check whether vendor has participated or not in auction*/
    public static boolean vendorParticipateorNot(String recordId){
        try{
            user u=[select id , Name , contactid from user where id =: userinfo.getUserId()];
            
            Contact   con =[select id,Name, Accountid from contact where id=:u.ContactId limit 1];
            
            Account acc= [select id , Name from Account where id =: con.AccountId limit 1];
            
            list<Auction_Participants__c> aplist = [SELECT Id, Name FROM Auction_Participants__c 
                                                    where Draft_Auction__c =: recordId AND Vendor__c =: acc.Id];
            if(aplist.size() != 0) return true;
            else return false;
        }
        catch(Exception e){
            return false;
        }
    }
    
    public static Decimal getlastBidPrice(String recordId) {
        try {
            user cuser = [SELECT Id, Name, Profile.Name, ContactId FROM USER WHERE Id =: userinfo.getUserId()];
            
            Contact con =[SELECT Id, Name, Accountid FROM Contact WHERE Id =: cuser.ContactId LIMIT 1];
            
            Account acc = [SELECT Id, Name FROM Account WHERE Id =: con.Accountid LIMIT 1];
            
            Auction_Response__c ar = new Auction_Response__c();
            ar = [SELECT Id, Name, Bid_Price__c, Vendor__c, Draft_Auction__c, Product__c 
                  FROM Auction_Response__c
                  WHERE Draft_Auction__c =: recordId AND Bid_Price__c != NULL AND Vendor__c =: acc.Id LIMIT 1];
            
            return ar.Bid_Price__c;   
        } catch(exception e) {
            return 0;
        }
    }
    
    @AuraEnabled
    public static String captureAcceptPrice(String dauc, String paymentTerms, String deliveryTerms, String bidRemarks, String recordId) {
        
        Draft_Auction__c dauction = (Draft_Auction__c) JSON.deserialize(dauc, Draft_Auction__c.class);
        
        user u = [SELECT Id, Name, Contactid FROM user WHERE Id =: userinfo.getUserId()];
        
        Contact con =[select id,Name, Accountid from contact where id=:u.ContactId limit 1];
        
        Account acc= [select id , Name from Account where id =:con.Accountid limit 1];
        
        try{
            Auction_Response__c response = [SELECT Id, Name, Bid_Price__c, Vendor__c, Draft_Auction__c, Product__c 
                                            FROM Auction_Response__c
                                            WHERE Draft_Auction__c =: recordId and Vendor__c =: acc.Id limit 1];
            response.Bid_Price__c = dauction.Current_Bid_Price__c;
            response.Payment_Terms__c = paymentTerms;
            response.Delivery_Terms__c = deliveryTerms;
            response.Bid_Remarks__c = bidRemarks;
            update response;
        }
        catch(Exception e){
            Auction_Response__c response = new Auction_Response__c();
            response.Draft_Auction__c = dauction.Id;
            response.Bid_Price__c = dauction.Current_Bid_Price__c;
            response.First_Bid_Price__c = dauction.Current_Bid_Price__c;
            response.Product__c	= dauction.Product__c;
            response.Participated__c = true;
            response.Participated_Date_Time__c = system.today();
            response.Vendor__c = acc.id;
            response.Payment_Terms__c = paymentTerms;
            response.Delivery_Terms__c = deliveryTerms;
            response.Bid_Remarks__c = bidRemarks;
            response.CurrencyIsoCode = dauction.CurrencyIsoCode;
            
            insert response;
        }
        
        return recordId;
    }
    
    @AuraEnabled
    public static String participateAuction(String recordId) {
        user cuser = [SELECT Id, Name, Contactid FROM user WHERE id =: userinfo.getUserId()];
        
        Contact ccontact = [SELECT Id, Name, Accountid FROM Contact WHERE Id =: cuser.ContactId LIMIT 1];
        
        Account acc = [select id , Name from Account where id =: ccontact.AccountId LIMIT 1];
        
        try{
            system.debug('Inside participate Class');
            Auction_Participants__c ap = [SELECT Id, Name, Vendor__c, Draft_Auction__c 
                                          FROM Auction_Participants__c
                                          WHERE Draft_Auction__c =: recordId and Vendor__c =: acc.Id LIMIT 1];
            return 'Already Participate.';
        }
        catch(Exception e){
            system.debug('Inside Get_Position Class--CATCH');
            Auction_Participants__c ap1 = new Auction_Participants__c();
            ap1.Name = acc.Name;
            ap1.Vendor__c = acc.Id;
            ap1.Draft_Auction__c = recordId;
            insert ap1;
            return 'Participate successfully.';
        }   
    }
    
    @AuraEnabled
    public static String getVendorPosition(String recordId) {
        System.debug('getVendorPosition is running');
        try {
            List<Auction_Response__c> lstAResponse = [SELECT Id, Name, Draft_Auction__c, Vendor__c, Vendor__r.Name, Bid_Price__c, Position__c, 
                                                      FROM Auction_Response__c 
                                                      WHERE Draft_Auction__c =: recordId
                                                      ORDER BY Bid_Price__c ASC];
            
            
            AggregateResult  aresult = [SELECT Min(Bid_Price__c) min FROM Auction_Response__c WHERE Draft_Auction__c =: recordId ];
            
            User cuser = [SELECT Id, Name, Profile.Name, ContactId FROM User where id =:  userinfo.getUserId()];
            
            Contact con = new Contact ();
            if(cuser.ContactId != null) {
                con = [SELECT Id, Name, Accountid FROM Contact WHERE Id =: cuser.ContactId];
            }
            
            Decimal minimumBid = (Decimal) aresult.get('min');
            Integer count = 0;
            Set<Decimal> setPosition = new Set<Decimal> ();
            Decimal cuBidPrice = null; 
            for(Auction_Response__c ar : lstAResponse) {
                if(ar.Bid_Price__c == minimumBid) count += 1;
                
                if(cuser.ContactId != null) {
                    if(ar.Vendor__c == con.Accountid) cuBidPrice = ar.Bid_Price__c;   
                }
                
                if(ar.Bid_Price__c != null) setPosition.add(ar.Bid_Price__c);
            }
            
            List<Decimal> lstBidPrice = new List<Decimal>(setPosition);
            lstBidPrice.sort();
            Integer vendorPosition = -1;
            if(cuBidPrice != null) {
                for(Integer i=0; i<lstBidPrice.size(); i++) {
                    if(lstBidPrice[i] == cuBidPrice) vendorPosition = i+1;
                }
            }
			Map<String, Object> mapBidData = new Map<String, Object> ();
            mapBidData.put('L1', minimumBid);
            mapBidData.put('L1Count', count);
            mapBidData.put('Position', vendorPosition);
            mapBidData.put('VendorBidPrice', cuBidPrice);
            
            return JSON.serialize(mapBidData);
        } catch(Exception e) {
            return 'error';
        }
    }
    
    @AuraEnabled
    public static String UpdateVendorPosition(String recordId) {
        System.debug('UpdateVendorPosition is running');
        try {
            List<Auction_Response__c> lstAResponse = [SELECT Id, Name, Draft_Auction__c, Vendor__c, Vendor__r.Name, Bid_Price__c, Position__c 
                                                      FROM Auction_Response__c 
                                                      WHERE Draft_Auction__c =: recordId AND Bid_Price__c != null
                                                      ORDER BY Bid_Price__c ASC];

            Set<Decimal> setBidPrice = new Set<Decimal>();
            for(Auction_Response__c ar : lstAResponse) {
                setBidPrice.add(ar.Bid_Price__c);
            }
            List<Decimal> lstBidPrice = new List<Decimal>(setBidPrice);
            lstBidPrice.sort();
            
            Map<Decimal, Integer> mapPosition = new Map<Decimal, Integer> ();
            for(Integer i=0; i<lstBidPrice.size(); i++) {
                mapPosition.put(lstBidPrice[i], i+1);
            }
            
            for(Auction_Response__c ar : lstAResponse) {
                if(mapPosition.containsKey(ar.Bid_Price__c)) {
                    ar.Position__c = String.valueOf(mapPosition.get(ar.Bid_Price__c));
                }
            }
            
            update lstAResponse;
            return 'success';
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
}