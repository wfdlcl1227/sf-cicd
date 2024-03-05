public with sharing class NEO_Edit_Variable_Override_Ctrl {
    public String recordId { get; set; }

    public NEO_Edit_Variable_Override_Ctrl(ApexPages.StandardController stdCtrl) {
        this.recordId = stdCtrl.getId();
    }
}