public virtual class NEO_Rules_Handler implements NEO_Rules_Constants.RuleHandler {

    public void handleRealtime(List<SObject> objList, String objectType, String triggerType) {
        /*
        if (NEO_Constants.NEO_IS_INTEGRATION_USER) {
            return;
        }*/
        
    	Map<String,List<NEO_Rule__c>> realTimeTriggeredRulesList = NEO_Rules_Utils.rulesRealtimeCheck(objList, objectType, triggerType);
        
        // zh_CN / en_US
        String strUserLanguage = UserInfo.getLanguage();

    	String tempKey = '';
    	Integer rowIndex = 0;

    	for (SOBject sobjectRow : objList) {
    		Object tempObjectId = sobjectRow.get('Id');
    		if (tempObjectId == null) {
				tempKey = String.valueOf(rowIndex);
    		} else {
    			tempKey = String.valueOf(tempObjectId);
    		}
    		++rowIndex;

    		if (!realTimeTriggeredRulesList.containsKey(tempKey)) {
    			continue;
    		}

            Set<String> hardStopMsgSet = new Set<String>();
			for (NEO_Rule__c tempRuleRow : realTimeTriggeredRulesList.get(tempKey)) {
				if (tempRuleRow.Hard_Stop_Warning__c == NEO_Rules_Constants.NEO_STRING_HARD_STOP) {
                    String strAlertMessage = tempRuleRow.Alert_Message__c;
                    String strAlertMessageEN = tempRuleRow.NEO_Alert_Message_EN__c;
                    if (strUserLanguage == 'en_US' && String.isNotBlank(strAlertMessageEN)) {
                        strAlertMessage = strAlertMessageEN;
                    }

					// Stop
                    hardStopMsgSet.add(strAlertMessage);
				}
			}

			if (hardStopMsgSet.size() > 0) {
				sobjectRow.addError(String.join(new List<String>(hardStopMsgSet), '<br />'), false);
			}
    	}
    }
}