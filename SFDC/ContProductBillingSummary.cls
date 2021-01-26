public class ContProductBillingSummary{

    Public List<Product_Billing__c> productBillingRecs {get;set;}
    Public Account acc {get;set;}
    Public List<SelectOption> yearsLst {get;set;}
    Public String selectedYear {get;set;}
    Public Boolean recordsFound {get;set;}
    Public Boolean havePageAccess {get;set;}
    Public Boolean showNorecordsMsg {get;set;}
    Public Boolean displayPage {get;set;}
    Public Boolean displayAccSpendData {get;set;}
    Public Boolean displayYearSel {get;set;}
    Public String currentYear ; 
    Public String accId ;
    Public List<Product_Billing__c> productBillingRecsNoTotal ;
    Public ServProductBilling service = new ServProductBillingIM();
    Public ServAccount accServ = new ServAccountIm();
    public List<tableHearderWrapper> tableHearderWrapperList {get; set;}
    
    public ContProductBillingSummary(){

        accId = ApexPages.currentPage().getParameters().get('Id');
    }
    
    public ContProductBillingSummary(ApexPages.StandardController controller) {

        accId = ApexPages.currentPage().getParameters().get('Id');
        currentYear  = String.valueOf(System.now().year());
        selectedYear = currentYear ;
        recordsFound = true;
        havePageAccess = true;
        showNorecordsMsg = false;
        displayPage = true;
        displayAccSpendData = true;
        displayYearSel = false;
        acc = accServ.getAccountById(accId);
        tableHearderWrapperList = null;
    }
    
    public void displayProductBillingGrid() {

        yearsLst = new List<SelectOption>();
        List<String> years = new  List<String>();
        Set<String> yearsSet = new  Set<String>();
        Map<Integer, Decimal> monthlyTotalMap = new Map<Integer, Decimal>();
        productBillingRecsNoTotal = new List<Product_Billing__c>();
        List<Product_Billing__c> prvYearProductBillingRecs = new List<Product_Billing__c>();
        Map<String, List<Product_Billing__c>>  yearProductBillingRecsMap = new Map<String, List<Product_Billing__c>>();
        //Map Created for mapping the column Headers of VF Page table containing the data
        Map<Integer,String> monthMap = new Map<Integer,String>(); 
        monthMap.put(1,'Jan ');
        monthMap.put(2,'Feb ');
        monthMap.put(3,'Mar ');
        monthMap.put(4,'Apr ');
        monthMap.put(5,'May ');
        monthMap.put(6,'Jun ');
        monthMap.put(7,'Jul ');
        monthMap.put(8,'Aug ');
        monthMap.put(9,'Sep ');
        monthMap.put(10,'Oct ');
        monthMap.put(11,'Nov ');
        monthMap.put(12,'Dec ');
        date currentDate = Date.today();
        
        
        yearProductBillingRecsMap = service.getProductBillingRecords(accId);

        if(yearProductBillingRecsMap != null && yearProductBillingRecsMap.Size() > 0){

            yearsSet = yearProductBillingRecsMap.keySet();
            years.addAll(yearsSet);
            years.sort();
            
            yearsLst.add(new SelectOption(String.valueOf(System.now().year()),'Current Year'));
            yearsLst.add(new SelectOption(String.valueOf(System.now().year()-1),'Previous Year'));
            yearsLst.add(new SelectOption('Rolling 12 Months','Rolling 12 Months'));
            if(yearProductBillingRecsMap.containsKey(selectedYear)){
                
                productBillingRecs = new List<Product_Billing__c>();
                productBillingRecs = yearProductBillingRecsMap.get(selectedYear);
                productBillingRecs = service.addVtotal(productBillingRecs);
                
                if(productBillingRecs != null && productBillingRecs.size() >=0){
                    recordsFound = true;
                }
                else{
                    recordsFound = false;
                }
            }else if(selectedYear.equalsIgnoreCase('Rolling 12 Months')){
                
                productBillingRecs  = service.mapDataForRolling12Months(yearProductBillingRecsMap);
                productBillingRecs = service.addVtotal(productBillingRecs); 
                if(productBillingRecs != null && productBillingRecs.size() >=0){
                    recordsFound = true;
                }else{
                    
                    recordsFound = false;
                    
                }
            }else{
                productBillingRecs = new List<Product_Billing__c>();
                productBillingRecs = service.addVtotal(productBillingRecs);
                if(productBillingRecs != null && productBillingRecs.size() >=0){
                    recordsFound = true;
                }else{
                    recordsFound = false;
                }
            }
        }else{

            recordsFound = false;

        }
        
        if(!yearProductBillingRecsMap.containsKey(String.valueOf(System.now().year())) && !yearProductBillingRecsMap.containsKey(String.valueOf(System.now().year()-1))){
            recordsFound = false;
        }
        
        String year = (String.valueOf(currentDate.year())).substring(2);
        if(selectedYear == 'Rolling 12 Months'){
            tableHearderWrapperList = new List<tableHearderWrapper>();
            tableHearderWrapper header = new tableHearderWrapper ();
            for(Integer month : monthMap.keySet()){
                if(currentDate.month() - month >= 0){
                    header.put(String.valueOf('column'+ (monthMap.size()-month+1)) ,monthMap.get(currentDate.month() - month + 1) + year ); 
                    
                }
                else{
                    year = String.valueOf((Date.today().addYears(-1)).year()).substring(2);
                    Integer prevMonth = month-currentDate.month();
                    header.put(String.valueOf('column'+ (monthMap.size()-month+1)) ,monthMap.get(monthMap.size()-prevMonth+1) + year );
                    
                }
            }
            tableHearderWrapperList.add(header);
            
        }
        else{
            year = String.valueOf(selectedYear).substring(2);
            tableHearderWrapperList = new List<tableHearderWrapper>();
            tableHearderWrapper header = new tableHearderWrapper();
            for(Integer month : monthMap.keySet()){
                header.put(String.valueOf('column'+month),monthMap.get(month) + year);
            } 
            tableHearderWrapperList.add(header);   
        }
        
        havePageAccess = service.checkAccessToPage();           
        displayPage = havePageAccess && recordsFound;
        showNorecordsMsg = !recordsFound && havePageAccess; 
        displayAccSpendData = service.checkAccessToPage(); //show this section for those who have access to group.//service.checkAccessToAccSpendBlock() && recordsFound;      
        displayYearSel =  !displayAccSpendData && displayPage;
        
    }  
     /*
    ** wrapper class that dynamically assigns column headers for the VF Page table which displays all the Product Billing Data,
    */
    public class tableHearderWrapper {
        public String column1{get; set;}
        public String column2{get; set;}
        public String column3{get; set;}
        public String column4{get; set;}
        public String column5{get; set;}
        public String column6{get; set;}
        public String column7{get; set;}
        public String column8{get; set;}
        public String column9{get; set;}
        public String column10{get; set;}
        public String column11{get; set;}
        public String column12{get; set;}
        
        public tableHearderWrapper() {
            column1 = 'Jan';    
            column2 = 'Feb';
            column3 = 'Mar';
            column4 = 'Apr';
            column5 = 'May';
            column6 = 'Jun';
            column7 = 'Jul';
            column8 = 'Aug';
            column9 = 'Sep';
            column10 = 'Oct';
            column11 = 'Nov';
            column12 = 'Dec';
        }
        public void put(String columnName , String value){
            if(columnName == 'column1'){
                column1 = value;
            }
            if(columnName == 'column2'){
                column2 = value;
            }
            if(columnName == 'column3'){
                column3 = value;
            }
            if(columnName == 'column4'){
                column4 = value;
            }
            if(columnName == 'column5'){
                column5 = value;
            }
            if(columnName == 'column6'){
                column6 = value;
            }
            if(columnName == 'column7'){
                column7 = value;
            }
            if(columnName == 'column8'){
                column8 = value;
            }
            if(columnName == 'column9'){
                column9 = value;
            }
            if(columnName == 'column10'){
                column10 = value;
            }
            if(columnName == 'column11'){
                column11 = value;
            }
            if(columnName == 'column12'){
                column12 = value;
            }
        }
    }  
    
}