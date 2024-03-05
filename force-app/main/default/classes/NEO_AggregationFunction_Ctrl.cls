public with sharing class NEO_AggregationFunction_Ctrl {

	public String recordId { get; set; }

    public NEO_AggregationFunction_Ctrl(ApexPages.StandardController stdCtrl) {
        this.recordId = stdCtrl.getId();
    }
}