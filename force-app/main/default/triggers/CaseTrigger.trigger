trigger CaseTrigger on Case (after update) {


       
    // Iterate through each notification.
    for (case c: Trigger.New) {


        List<Bundle_Submitted__e> inkEvents = new List<Bundle_Submitted__e>();
        inkEvents.add(new Bundle_Submitted__e(Description__c='You case #'+ c.CaseNumber+ ' has been rejected due to reason:' + c.Reject_Reason__c+ '.', Bundle_Id__c=c.Id));

        
        
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(inkEvents);
        
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
        


    }
    

}