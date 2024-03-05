public class LambdaCallout {
    @AuraEnabled
    public static String callLambda() {
        
        
        List<Account> accounts = [SELECT Id, Name, Text10__c, Text1__c, Text2__c, Text3__c, Text4__c, Text5__c, Text6__c, Text7__c, Text8__c, Text9__c FROM Account WHERE Text1__c != NULL LIMIT 10];
		
        
        List<AccountWrapper> wrappedAccounts = new List<AccountWrapper>();
        for (Account account : accounts) {
            wrappedAccounts.add(new AccountWrapper(account));
        }

        
        
        String payload = JSON.serialize(wrappedAccounts);
        //String requestBody = '{"body": ' + payload + '}';

		system.debug(payload);
        
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://y4ib7okcs2.execute-api.us-west-1.amazonaws.com/complete/');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-api-key', 'Jo6tyig3mE9MPV98BB26eAYpuDKl3succRpSNyh0'); // Add this line
        request.setBody(payload);
        
        HttpResponse response = http.send(request);
        
        
        
        if (response.getStatusCode() == 200) {
            system.debug(response.getBody());
            return response.getBody();
        } else {
            return 'Error: ' + response.getStatus();
        }
    }
    
    
public class AccountWrapper {
    public String Id;
    public String Name;
    public String Text1;
    public String Text2;
    public String Text3;
    public String Text4;
    public String Text5;
    public String Text6;
    public String Text7;
    public String Text8;
    public String Text9;
    public String Text10;

    public AccountWrapper(Account account) {
        this.Id = account.Id;
        this.Name = account.Name;
        this.Text1 = account.Text1__c;
        this.Text1 = account.Text2__c;
        this.Text1 = account.Text3__c;
        this.Text1 = account.Text4__c;
        this.Text1 = account.Text5__c;
        this.Text1 = account.Text6__c;
        this.Text1 = account.Text7__c;
        this.Text1 = account.Text8__c;
        this.Text1 = account.Text9__c;
        this.Text10 = account.Text10__c;
    }
}
    
    
}