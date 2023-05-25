public class PRWrapeer {
    
    public cls_pr[] prRequest;
    
    public class cls_pr {
        public string Name;
        public string SAPPRKey;
        public string Material_Group;
        public string Material_Group_Desc;
        public string Requisitioner;
        public string Plant;
        public string Short_Closed;
        public string PRDelFlag;
        public string ReleaseFlag;
        
        public string Delivery_Date;
        public string Purchasing_Group;
        public string Purchase_Group_Name_Buyer;
        public string Document_Type;
        public string Changed_on;
        public string Unit_of_Measure;
        public decimal PR_Line_Item;
        // public string Material_Group;
        public string Release_Date;
        // public string Requisitioner;
        public string Requisition_Date;
        public decimal Quantity_Requested;
        
        public string Doc_Type_Desc;
        public string UOM_Description;
        public decimal PO_Quantity;
        public string Service_Sr_No;
        public string Item_Catg;
        public string Additional_Long_text;
        public string Short_Text;
        public string Material;
        
    }
    public static PRWrapeer parse(String json){
        return (PRWrapeer) System.JSON.deserialize(json, PRWrapeer.class);
    }
}