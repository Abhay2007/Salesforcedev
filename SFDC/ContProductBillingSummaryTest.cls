@isTest(SeeAllData=false isParallel=true)

public class ContProductBillingSummaryTest{
 
 
 @istest 
   
    static void displayProductBillingGridTest(){
       
       
        test.startTest();
        Account acc = TUtilDataSetup.createTestAccount();
        TUtilDataSetup.createProductBillForAcc(acc.id);
        PageReference pageRef = Page.VFProductBillingSummary;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acc.id);
        ApexPages.StandardController sc = new ApexPages.standardController(acc); 
        ContProductBillingSummary billingSumm = new ContProductBillingSummary(sc);
        billingSumm.displayProductBillingGrid();
        //System.assert(billingSumm.displayPage);
        Test.stopTest();
         
    } 
    
    @isTest 
    public static void test_displayProductBillingGridTest(){
        //create test Account
        Account testAccount = TUtilDataSetup.createTestAccount();
        
        PageReference pageRef = Page.VFProductBillingSummary;
        ApexPages.currentPage().getParameters().put('Id',testAccount.id);
        ApexPages.StandardController sc = new ApexPages.standardController(testAccount);
        ContProductBillingSummary billingSummCont = new ContProductBillingSummary(sc);
        Test.startTest();
        billingSummCont.displayProductBillingGrid();
        Test.stopTest();
        
        System.assert(billingSummCont.recordsFound == false);
        
    }
    
}