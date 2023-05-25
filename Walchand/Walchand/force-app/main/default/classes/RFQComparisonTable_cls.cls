public class RFQComparisonTable_cls {
    @AuraEnabled
    public static String getDetails(String recordId) {
        try {
            RFQ__c rfq = [SELECT Id, Name FROM RFQ__c WHERE Id =: recordId];
            List<RFQ_Line_Item__c> lstRFQItems = [SELECT Id, Name, Purchase_Requisitions__c, Purchase_Requisitions__r.Name, RFQ__c,
                                                  Material_Code__c, PR_additional_text__c, PR_Quantity__c, PR_UOM__c,
                                                  (SELECT Id, Name, Material_with_grade_Vendor__c, Vendor_UOM__c, Offered_Quantity2__c,
                                                   GST__c, Price_Vendor__c, Offered_cycle_time_and_location__c, Vendor__c, Vendor__r.Name,
                                                   Line_value1__c, VRFQ__c, VRFQ__r.Name, Priority__c
                                                   FROM VRFQ_Line_Items__r Order By VRFQ__r.Name ASC)
                                                  FROM RFQ_Line_Item__c WHERE RFQ__c =: recordId ORDER BY Name ASC];
            List<VRFQ__c> lstVRFQ = [SELECT Id, Name, RFQ__c, Vendor__c, Vendor__r.Name, Incoterms_Vendor__c, P_F_Value__c,
                                     Payment_Terms_Vendor__c
                                     FROM VRFQ__c WHERE RFQ__c =: recordId ORDER BY Name ASC];
            
            List<AggregateResult> VRFQItemsAggResults2 = [SELECT SUM(Price_Vendor__c) sumPrice, SUM(Line_value1__c) sumTotalPrice, SUM(GST_Amount__c) gstAmt
                                                          FROM VRFQ_Line_Item__c WHERE RFQ__c =: recordId GROUP By VRFQ__r.Name ORDER BY VRFQ__r.Name ASC];
            
            wrapMeta details = new wrapMeta();
            details.rfq = rfq;
            details.lstRFQItems = lstRFQItems;
            details.lstVRFQ = lstVRFQ;
            
            List<wrapRFQItems> wrapList = new List<wrapRFQItems> ();
            
            for(RFQ_Line_Item__c item : lstRFQItems) {
                wrapRFQItems wrap = new wrapRFQItems();
                wrap.rfqItem = item;
                wrap.maxPriority = 0;
                List<wrapVRFQItems> lstVRFQItems_w = new List<wrapVRFQItems> ();
                List<wrapVendorPriority> lstPriority = new List<wrapVendorPriority> ();
                for(VRFQ_Line_Item__c jtem : item.VRFQ_Line_Items__r) {
                    if(jtem.Price_Vendor__c != null) {
                        if(wrap.minPrice == null) wrap.minPrice = jtem.Price_Vendor__c;
                        else if(jtem.Price_Vendor__c < wrap.minPrice) wrap.minPrice = jtem.Price_Vendor__c;
                        
                        if(wrap.maxPrice == null) wrap.maxPrice = jtem.Price_Vendor__c;
                        else if(jtem.Price_Vendor__c > wrap.maxPrice) wrap.maxPrice = jtem.Price_Vendor__c;
                    }
                }
                
                for(VRFQ_Line_Item__c jtem : item.VRFQ_Line_Items__r) {
                    wrapVRFQItems wrapItem = new wrapVRFQItems();
                    wrapItem.vrfqItems = jtem;
                    if(jtem.Price_Vendor__c == wrap.minPrice) wrapItem.priceBackground = '#45c65a';
                    else if(jtem.Price_Vendor__c == wrap.maxPrice) wrapItem.priceBackground = '#fe5c4c';
                    else wrapItem.priceBackground = 'none';
                    
                    if(jtem.Offered_Quantity2__c < item.PR_Quantity__c) wrapItem.quantityBackground = '#fff03f';
                    if(jtem.Offered_Quantity2__c > item.PR_Quantity__c) wrapItem.quantityBackground = '#fe9339';
                    
                    wrapItem.className = 'tableColumnPointer';
                    wrapItem.classNameSeperetor = 'tableColumnPointer seperator';
                    wrapItem.priority = lstVRFQItems_w.size() + 1;
                    lstVRFQItems_w.add(wrapItem);
                    
                    wrapVendorPriority vendorPriority = new wrapVendorPriority();
                    vendorPriority.priority = Integer.valueOf(jtem.Priority__c);
                    vendorPriority.vrfqItems = jtem.Name;
                    vendorPriority.vendorName = jtem.Vendor__r.Name;
                    lstPriority.add(vendorPriority);
                }
                wrap.lstVRFQItems = lstVRFQItems_w;
                wrap.lstVendorPriority = lstPriority;
                wrapList.add(wrap);
            }            
            details.lstWrapRFQItems = wrapList;
            
            Decimal maxSubTotal, minSubTotal, maxTotal, minTotal;
            
            List<wrapVRFQItems> lstwrapItem1 = new List<wrapVRFQItems> ();
            for(AggregateResult result : VRFQItemsAggResults2) {
                wrapVRFQItems wrap1Items = new wrapVRFQItems();
                wrap1Items.subtotal = (Decimal) result.get('sumTotalPrice');
                
                if(wrap1Items.subtotal != null) {
                    if(maxSubTotal == null) maxSubTotal = wrap1Items.subtotal;
                    else if(wrap1Items.subtotal > maxSubTotal) maxSubTotal = wrap1Items.subtotal;
                    
                    if(minSubTotal == null) minSubTotal = wrap1Items.subtotal;
                    else if(wrap1Items.subtotal < minSubTotal) minSubTotal = wrap1Items.subtotal;
                }
                
                wrap1Items.gst = 18;
                wrap1Items.gstAmount = (Decimal) result.get('gstAmt');
                wrap1Items.transportCharges = 0;
                wrap1Items.totalValue = wrap1Items.subtotal + wrap1Items.gstAmount + wrap1Items.transportCharges;
                
                if(wrap1Items.totalValue != null) {
                    if(maxTotal == null) maxTotal = wrap1Items.totalValue;
                    else if(wrap1Items.totalValue > maxTotal) maxTotal = wrap1Items.totalValue;
                    
                    if(minTotal == null) minTotal = wrap1Items.totalValue;
                    else if(wrap1Items.totalValue < minTotal) minTotal = wrap1Items.totalValue;
                }
                
                lstwrapItem1.add(wrap1Items);
            }
            
            system.debug('min sub total : ' + minSubTotal);
            system.debug('max sub total : ' + maxSubTotal);
            for(wrapVRFQItems item : lstwrapItem1) {
                if(item.subtotal == minSubTotal) item.priceBackground = '#45c65a';
                else if(item.subtotal == maxSubTotal) item.priceBackground = '#fe5c4c';
                else item.priceBackground = 'none';
                
                if(item.totalValue == minTotal) item.totalBackground = '#45c65a';
                else if(item.totalValue == maxTotal) item.totalBackground = '#fe5c4c';
                else item.totalBackground = 'none';
            }
            
            details.wrapOtherItems = lstwrapItem1;
            
            return JSON.serialize(details);
        } catch(Exception e) {
            system.debug('RFQComparisonTable_cls.getDetails error message : ' + e.getMessage());
            system.debug('RFQComparisonTable_cls.getDetails error line number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String updateVRFQItems(String data) {
        try {
            List<wrapRFQItems> lstWrapData = (List<wrapRFQItems>) JSON.deserialize(data, List<wrapRFQItems>.class);
            List<VRFQ_Line_Item__c> lstVRFQItems = new List<VRFQ_Line_Item__c> ();
            for(wrapRFQItems item : lstWrapData) {
                for(wrapVRFQItems jtem : item.lstVRFQItems) {
                    lstVRFQItems.add(jtem.vrfqItems);
                }
            }
            
            System.debug('lstVRFQItems size : ' + lstVRFQItems.size());
            update lstVRFQItems;
            return 'success';
        } catch(Exception e) {
            System.debug('RFQComparisonTable_cls.updateVRFQItems error message : ' + e.getMessage());
            System.debug('RFQComparisonTable_cls.updateVRFQItems error line number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class wrapMeta {
        public RFQ__c rfq;
        public List<RFQ_Line_Item__c> lstRFQItems;
        public List<VRFQ__c> lstVRFQ;
        public List<wrapRFQItems> lstWrapRFQItems;
        public List<wrapVRFQItems> wrapOtherItems;
    }
    
    public class wrapRFQItems {
        public RFQ_Line_Item__c rfqItem;
       public List<wrapVRFQItems> lstVRFQItems;
       public List<wrapVendorPriority> lstVendorPriority;
        public Decimal minPrice, maxPrice, minTotalPrice, maxTotalPrice;
        public Integer maxPriority;
    }
    
    public class wrapVRFQItems {
        public VRFQ_Line_Item__c vrfqItems;
        public String priceBackground, quantityBackground, totalBackground, className, classNameSeperetor;
        public Decimal subtotal, gst, gstAmount, transportCharges, totalValue;
        public Integer priority;
        public Boolean isSelected;
    }
    
    public class wrapVendorPriority {
        public String vendorName, vrfqItems;
        public Integer priority;
    }
    
}