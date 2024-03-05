public with sharing class NEO_Lookup_LC_Ctrl {

    @AuraEnabled
    public static Map<String, Object> search(String inputKeyword,
                                             String objectType,
                                             String filterFieldsString,
                                             String queryString,
                                             String displayFieldsString,
                                             String displaySubFieldsString,
                                             String masterObjID) {
        List<MySelectOption> selectOptions = new List<MySelectOption>();
        // Get selected field
        Set<String> selectedFieldsSet = new Set<String> { 'Id', 'Name' };

        Set<String> includeFieldsSet = new Set<String> {};
        Set<String> excludeFieldsSet = new Set<String> {};
        for (String strField : NEO_Rules_Utils.getSelectedFieldsList(objectType, includeFieldsSet, excludeFieldsSet, true)) {
            // selectedFieldsSet.add(strField);
        }
        if (String.isNotBlank(displayFieldsString)) {
            for (String sf : displayFieldsString.split(',')) {
                selectedFieldsSet.add(sf.trim());
            }
        }
        if (String.isNotBlank(displaySubFieldsString)) {
            for (String sf : displaySubFieldsString.split(',')) {
                selectedFieldsSet.add(sf.trim());
            }
        }

        // Keyword filter
        String strLike = '%' + inputKeyword + '%';
        Set<String> filtersSet = new Set<String>();
        if (String.isNotBlank(filterFieldsString)) {
            for (String sf : filterFieldsString.split(',')) {
                sf = sf.trim();
                filtersSet.add(sf + ' LIKE :strLike');
                selectedFieldsSet.add(sf);
            }
        }

        // Add master filter
        String strMasterFilter = '';
        Map<String, NEO_Rules_Constants.ObjectWrapper> objectWrapperMap = NEO_Rules_Constants.objectWrapperMap;
        if (String.isNotBlank(masterObjID) && objectWrapperMap.containsKey(objectType)) {
            NEO_Rules_Constants.ObjectWrapper objectWrapperObj = objectWrapperMap.get(objectType);
            if (String.isNotBlank(objectWrapperObj.strMasterFieldName)) {
                strMasterFilter = objectWrapperObj.strMasterFieldName + ' = :masterObjID';
            }
        }
        
        List<String> args = new List<String>();
        args.add(String.join(new List<String>(selectedFieldsSet), ', '));
        args.add(objectType);

        String strSOQL = 'SELECT ' + String.join(new List<String>(selectedFieldsSet), ', ') + ' FROM ' + objectType;

        String strWhere = '';
        if (String.isNotBlank(strMasterFilter)) {
            if (String.isBlank(strWhere)) {
                strWhere += ' WHERE ';
            } else {
                strWhere += ' AND ';
            }
            strWhere += strMasterFilter;
        }

        if (filtersSet.size() > 0) {
        	if (String.isBlank(strWhere)) {
        		strWhere += ' WHERE ';
        	} else {
        		strWhere += ' AND ';
        	}
        	strWhere += '(' + String.join(new List<String>(filtersSet), ' OR ') + ')';
        }

        if (String.isNotBlank(queryString)) {
        	if (String.isBlank(strWhere)) {
        		strWhere += ' WHERE ';
        	} else {
        		strWhere += ' AND ';
        	}
            strWhere += '(' + queryString + ')';
        }

        if (String.isNotBlank(strWhere)) {
        	strSOQL += strWhere;
        }

        strSOQL += ' LIMIT 6';
        System.debug(LoggingLevel.DEBUG, '-------->strSOQL: ' + strSOQL);
        List<SObject> sObjectList = Database.query(strSOQL);

        Set<String> displayNameFilterSet = new Set<String>();

        for (SObject sObj : sObjectList) {
            MySelectOption optionObj = new MySelectOption();
            optionObj.recordId = String.valueOf(sObj.get('Id'));

            List<String> displayValuesList = new List<String>();
            if (String.isNotBlank(displayFieldsString)) {
            	for (String sf : displayFieldsString.split(',')) {
	                sf = sf.trim();
	                displayValuesList.add(String.valueOf(sObj.get(sf)));
	            }
            }
            if (displayValuesList.size() > 0) {
            	optionObj.displayName = String.join(displayValuesList, ', ');
            } else {
            	optionObj.displayName = '';
            }

            List<String> displaySubValuesList = new List<String>();
            if (String.isNotBlank(displaySubFieldsString)) {
            	for (String sf : displaySubFieldsString.split(',')) {
	                sf = sf.trim();
	                displaySubValuesList.add(String.isBlank(String.valueOf(sObj.get(sf))) ? '-' : String.valueOf(sObj.get(sf)));
	            }
            }
            if (displaySubValuesList.size() > 0) {
            	optionObj.subDisplayName = String.join(displaySubValuesList, ', ');
            } else {
            	optionObj.subDisplayName = '';
            }

            if (!displayNameFilterSet.contains(optionObj.displayName + optionObj.subDisplayName)) {
                displayNameFilterSet.add(optionObj.displayName + optionObj.subDisplayName);
                selectOptions.add(optionObj);
            }
        }

    	Map<String, Object> returnMaps = new Map<String, Object> {
    		'selectOptions' => selectOptions,
            'sObjectList' => sObjectList,
            'strSOQL' => strSOQL,
            'strLike' => strLike,
            'objectType' => objectType,
            'objectWrapperMap.get(objectType)' => objectWrapperMap.get(objectType),
            'masterObjID' => masterObjID,
            'filtersSet' => filtersSet
    	};

        return returnMaps;
    }

    class MySelectOption {
        @AuraEnabled
        public String recordId { get; set; }
        @AuraEnabled
        public String displayName { get; set; }
        @AuraEnabled
        public String subDisplayName { get; set; }

        public MySelectOption() {

        }

        public MySelectOption(String displayName, String subDisplayName) {
            this.displayName = displayName;
            this.subDisplayName = subDisplayName;
        }
    }
}