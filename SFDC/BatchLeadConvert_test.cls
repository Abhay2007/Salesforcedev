@isTest
public class TestLeadConversion {
    static testMethod void LeadConvertedTest()
    {
        Lead lead1 = new Lead(LastName='Test',FirstName='Tester',Status='Known',Company='test');
        insert lead1;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead1.id);
        lc.setConvertedStatus('Closed - Converted');

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess()); 
    }
}