trigger OppTrigger on Opportunity (before delete) {

    ContentDocumentLink le = [Select c.ContentDocumentId, c.Id, c.IsDeleted, c.LinkedEntityId, c.ShareType, c.SystemModstamp, c.Visibility from ContentDocumentLink c  where LinkedEntityId = :Trigger.Old[0].Id];

    //delete [Select Id, Title, FileExtension, CreatedDate,Owner.name From ContentDocument  where Id= :le.ContentDocumentId];
}