@isTest
public class HibuBatchObjectUpdateTest {

    @isTest
    public static void testBatchObjectAccountUpdateSuccess(){
        
        //Create user
        User testUser = HibuTUtilDataSetup.createUser();
        SYstem.debug('testUserId '+testUser.id);
        
        //create an account
        Account testAccount = HibuTUtilDataSetup.createTestAccount();
        testAccount.OwnerId=testUser.Id;
        update testAccount;
        SYstem.debug('testAccountId '+testAccount.id);
        
        //create a batch job
        Batch_Process__c batchProcess = new Batch_Process__c();
        batchProcess.Description__c='Alignment Update';
        batchProcess.Object_List__c='Account';
        batchProcess.Field_List__c='TAV4__Primary_Alignment__c';
        batchProcess.New_Value__c='new alignment';
        batchProcess.Status__c='Pending';
        batchProcess.OwnerId=testUser.id;
        //batchProcess.RecordTypeId = [select id from recordType where name= 'Alignment Update' ].id;
        
        insert batchProcess;
        SYstem.debug('batchProcessId '+batchProcess.id);
        
        //create an attachment for the input csv against the batch process
        Attachment inputCsv = new Attachment();
        inputCsv.Body = Blob.valueOf('Account Id \n '+testAccount.Id);
        inputCsv.ParentId = batchProcess.id; //tie this pdf to the batch object
        inputCsv.OwnerId = batchProcess.OwnerId;
        inputCsv.name = 'input.csv';
        inputCsv.ContentType = 'text/csv';
        insert inputCsv;
        SYstem.debug('AttachmentId '+inputCsv.Id);
        
        Test.startTest();
        HibuBatchObjectUpdate b = new HibuBatchObjectUpdate(batchProcess);
		Database.executeBatch(b,200);
		Test.stopTest();
        
        //assert some stuff
        //Task tsk = [SELECT id FROM Task WHERE whatid =: batchProcess.Id LIMIT 1];
   		//System.debug('tsk '+tsk);
        
        Batch_Process__c batchProcessResult = [SELECT id, object_list__c, field_list__c, new_value__c,description__c, status__c, ownerId FROM Batch_Process__c WHERE  id =: batchProcess.Id LIMIT 1];  
        System.debug('batchProcessResult.Status__c '+batchProcessResult.Status__c);
       	System.assert(batchProcessResult.Status__c.equals('Success')); 
    }
    
    @isTest
    public static void testBatchObjectAccountUpdateMissingInputFile(){
        
        //Create user
        User testUser = HibuTUtilDataSetup.createUser();
        SYstem.debug('testUserId '+testUser.id);
        
        //create an account
        Account testAccount = HibuTUtilDataSetup.createTestAccount();
        testAccount.OwnerId=testUser.Id;
        update testAccount;
        SYstem.debug('testAccountId '+testAccount.id);
        
        //create a batch job
        Batch_Process__c batchProcess = new Batch_Process__c();
        batchProcess.Description__c='Alignment Update';
        batchProcess.Object_List__c='Account';
        batchProcess.Field_List__c='TAV4__Primary_Alignment__c';
        batchProcess.New_Value__c='new alignment';
        batchProcess.Status__c='Pending';
        batchProcess.OwnerId=testUser.id;
        //batchProcess.RecordTypeId = [select id from recordType where name= 'Alignment Update' ].id;
        
        insert batchProcess;
        SYstem.debug('batchProcessId '+batchProcess.id);
        
        //create an attachment for the input csv against the batch process
        //Attachment inputCsv = new Attachment();
        //inputCsv.Body = Blob.valueOf('Account Id \n '+testAccount.Id);
        //inputCsv.ParentId = batchProcess.id; //tie this pdf to the batch object
        //inputCsv.OwnerId = batchProcess.OwnerId;
        //inputCsv.name = 'input.csv';
        //inputCsv.ContentType = 'text/csv';
        //insert inputCsv;
        //SYstem.debug('AttachmentId '+inputCsv.Id);
        
        Test.startTest();
        HibuBatchObjectUpdate b = new HibuBatchObjectUpdate(batchProcess);
		Database.executeBatch(b,200);
		Test.stopTest();
        
        //assert some stuff
        //Task tsk = [SELECT id FROM Task WHERE whatid =: batchProcess.Id LIMIT 1];
   		//System.debug('tsk '+tsk);

		Batch_Process__c batchProcessResult = [SELECT id, object_list__c, field_list__c, new_value__c,description__c, status__c, ownerId FROM Batch_Process__c WHERE  id =: batchProcess.Id LIMIT 1];     
        System.debug('batchProcessResult.Status__c '+batchProcessResult.Status__c);
        System.assert(batchProcessResult.Status__c.equals('Missing Input File'));
        
        
    }
    
    
}