public with sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList() {
        return [select id, name, phone,title,Picture__c,Company__c from contact order by createddate limit 3] ;
    }

    @AuraEnabled(cacheable=true)
    public static Account getSingleAccount() {
        return [
            SELECT Id, Name, Phone, Type
            FROM Account
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }
}