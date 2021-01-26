global class HibuBatchObjectUpdate extends HibuBatchObjectUtil implements Database.Batchable<sObject>, Database.Stateful {
    
    public List<String> sfids;
    public List<String> successes;
    public List<String> errors;
    public Batch_Process__c batchProcess;
    public String fieldType;
    public HibuDaoBatchProcess dao;
    public HibuDaoAttachment attachDao;
    
    global HibuBatchObjectUpdate(){
        // Batch Constructor
    }
    
    global HibuBatchObjectUpdate(Batch_Process__c batchP){
        
        batchProcess = batchP;
        sfids = new List<String>();
        successes = new List<String>();
        errors = new List<String>();
        dao = new HibuDaoBatchProcessIm();
        attachDao = new HibuDaoAttachmentIm();
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){

        //System.debug('batch job id '+bc.getJobId());
        //batchProcess = dao.getBatchProcessById(batchProcessId); //[SELECT id, object_list__c, field_list__c, new_value__c,description__c, status__c, ownerId FROM Batch_Process__c WHERE  id =: batchProcessId LIMIT 1];
        //System.debug('batchProcess'+batchProcess);

        if (batchProcess!=null){
            fieldType = Schema.getGlobalDescribe().get(batchProcess.object_list__c).getDescribe().fields.getMap().get(batchProcess.field_list__c).getDescribe().getType().Name();

            List<Attachment> attachments = attachDao.getAttachmentsByParentId(batchProcess.id);//[SELECT id, ownerid,body, parentId FROM Attachment WHERE parentId =: batchProcess.id ];
			System.debug('attachments size '+attachments.size());            
            
            if( attachments.size()>0){
                Attachment inputCsv = attachments.get(0);
                
                if (inputCsv!= null){
                    batchProcess.Status__c='In-Progress';
                    update batchProcess;
                    
                    sfids = getIdsFromAttachment(inputCsv); 
                    System.debug('sfids '+sfids);
                }
            }
            else
            {
                 batchProcess.Status__c='Missing Input File';
                 update batchProcess;
            }
        }
        
        String dbQuery = 'SELECT iD, '+batchProcess.field_list__c +' FROM '+ batchProcess.object_list__c+' WHERE ID in: sfids';
        System.debug('dbQuery '+dbQuery);
        return Database.getQueryLocator(dbQuery);
        
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<SObject> objs){
        try{

                //we are updatiing alignments
                System.debug('Founds '+objs.size()+' objects needing an update');
                
                for(SObject ob : objs){
                    
                    //System.debug('updating '+ ob);
                    ob.put(batchProcess.field_List__c,getValue());
                }
                
                //update objs;
                Database.SaveResult[] lsr = Database.update(objs,false);
                
                for(Database.SaveResult result: lsr){
                    
                    if (result.isSuccess()) {
                        
                        // Operation was successful, so get the ID of the record that was processed
                        
                        //System.debug('Successfully updated Obj ID: ' + result.getId());
                        successes.add(result.getId()+', success');
                        //result.getId() contains a value for successful updates
                    }
                    else {
                        
                        // Operation failed, so get all errors               
                        
                        for(Database.Error err : result.getErrors()) {
                            
                            System.debug('The following error has occurred.');                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Fields that affected this error: ' + err.getFields());
                            errors.add(result.getId()+', Status: '+err.getStatusCode()+', Message: '+err.getMessage()+ ', Fields: '+err.getFields());
                            //result.getId() DOES NOT contain a value for errored records
                        }
                    }
                }
            
        }
        catch(Exception e){
            //Exception will only be caught if using Database.SaveResult[] lsr = Database.update(objs,TRUE); 
            //or Database.SaveResult[] lsr = Database.update(objs);
            //any failure in any batch will result in complete Batch failure, and exception will be thrown.
            //When using Database.SaveResult[] lsr = Database.update(objs,FALSE);
            //Errors are passed back in the result.getErrors() array.
            
            //update the parentId Status to Error
            //System.debug('Error: '+e.getMessage());
            ///currentJob.Status__c='Error';
            //update currentJob;
	    HibuUtilRuntimeLog.logApex('HibuBatchObjectUpdate',e);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :BC.getJobId() LIMIT 1]; 
        
        System.debug('Job Id '+a.Id);
        System.debug('Job Status '+a.Status);
        System.debug('Job NumberOfErrors '+a.NumberOfErrors);
        System.debug('Job JobItemsProcessed '+a.JobItemsProcessed);
        System.debug('Job TotalJobItems '+a.TotalJobItems);
        System.debug('Job ExtendedStatus '+a.ExtendedStatus);
        
        if (errors.size()>0){
            batchProcess.Status__c='Error';
            update batchProcess;
        }
        else if (batchProcess.Status__c=='In-Progress'){
             batchProcess.Status__c='Success';
            update batchProcess;
        }
        
    } 
    
    private Object getValue(){
        //System.debug('fieldType: '+fieldType);
        if (fieldType.equals(Schema.DisplayType.STRING)){
            return batchProcess.New_Value__c;
        } 

        else if(fieldType.equals(Schema.DisplayType.REFERENCE)){
            return batchProcess.New_Value__c;
        }
        else{
            return batchProcess.New_Value__c;
        }
        
        //else if(fieldType.equals(Schema.DisplayType.INTEGER)){
        //    return Integer.valueOf(batchProcess.New_Value__c);
        //} 
        //else if(fieldType.equals(Schema.DisplayType.BOOLEAN)){
        //    return Boolean.valueOf(batchProcess.New_Value__c);
        //}
        //return null;	
    }
    
    
    //private String outputFile(List<String> content){
        
    //    System.debug('content '+content.size());
//        String output='';
    //    for(String line: content){
     //       output = output+line +' \n ';
     //   }
    //    System.debug('output '+output);
    //    return output;
    //}
    //
    
    
    
}