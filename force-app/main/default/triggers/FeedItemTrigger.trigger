trigger FeedItemTrigger on FeedItem (after insert, after update) {
        System.debug('=====>' + trigger.new);
    List<FeedAttachment> attachments =  [SELECT Id, Title, Type, FeedEntityId 
                                         FROM FeedAttachment 
                                         WHERE FeedEntityId IN :Trigger.new ];
    
    for (FeedAttachment attachment : attachments) {
        System.debug(attachment.Type);
    }
    
    
    for(FeedItem  f :  trigger.new){
        if(f.Type == 'TextPost'){
               List<Bundle_Submitted__e> inkEvents = new List<Bundle_Submitted__e>();
               String msg = f.Body.replace('<p>','');
               msg = msg.replace('</p>','');
                inkEvents.add(new Bundle_Submitted__e(Description__c=msg , Bundle_Id__c=f.Id));
        
                
                
                // Call method to publish events
                List<Database.SaveResult> results = EventBus.publish(inkEvents);           
        }
    }
    
    
    
      
    
    
}