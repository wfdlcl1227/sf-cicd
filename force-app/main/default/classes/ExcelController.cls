public with sharing class ExcelController {
    
    public List<Account> rows {get;set;}
    public String fileName {get;set;}
    
    public ExcelController(){
        fileName = String.valueOf(DateTime.Now());
        rows = [SELECT Id, Name, Phone FROM Account limit 11];
    }


    public static void sendEmailReport(){
        PageReference excelPage = new PageReference('/apex/ExcelPage');
        Blob content = excelPage.getContent();

        //send email
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new String[] {'zeming.dong@accenture.com'});
        message.setSubject('New Report' + String.valueOf(DateTime.Now()));
        message.setPlainTextBody('Please see report in attachement');
        //set attachement
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
        att.setFileName(String.valueOf(DateTime.Now()) + '.xls');
        att.setBody(content);
        att.setContentType('application/vnd.ms-excel');
        attachments.add(att);
        message.setFileAttachments(attachments);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
}