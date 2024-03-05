trigger AccountTrigger on Account (after update) {
    system.debug('======>'  + trigger.new[0].TestCheckBox__c);

}