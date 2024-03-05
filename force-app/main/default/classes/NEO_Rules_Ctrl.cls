public class NEO_Rules_Ctrl {
    public String recordId { get; set; }
    public String strMasterObjectName { get; set; }

    public NEO_Rules_Ctrl(ApexPages.StandardController stdCtrl) {
        this.recordId = stdCtrl.getId();
        this.strMasterObjectName = ApexPages.currentPage().getParameters().get('strMasterObjectName');
    }
}