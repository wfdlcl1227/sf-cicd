public with sharing class NEO_Rules_LC_Ctrl {

    @AuraEnabled
	public static Map<String, Object> initialize(String recordId, String strMasterObjectName) {
		Map<String, NEO_Variable__c> NEOVariableMaps = NEO_Rules_Constants.NEOVariableMaps;

		String strSOQL = '';
		Set<String> selectFieldsSet = new Set<String>();

		// Get record type maps
		Map<String, String> rtMaps = new Map<String, String>();
		Schema.DescribeSObjectResult d = Schema.SObjectType.NEO_Variable__c;
        for (Schema.RecordTypeInfo rtInfoRow : d.getRecordTypeInfosByDeveloperName().values()) {
        	String strRecordTypeId = rtInfoRow.getRecordTypeId();
        	String strRecordTypeName = rtInfoRow.getName();
        	String strRecordTypeDeveloperName = rtInfoRow.getDeveloperName();

            rtMaps.put(strRecordTypeDeveloperName, strRecordTypeId);
            rtMaps.put(strRecordTypeId, strRecordTypeName);
        }

        // Get rule record type
        List<NEO_Rules_Constants.MySelectOption> ruleRtOptions = new List<NEO_Rules_Constants.MySelectOption>();
        Map<String, String> ruleRtMaps = new Map<String, String>();
        d = Schema.SObjectType.NEO_Rule__c;
        for (Schema.RecordTypeInfo rtInfoRow : d.getRecordTypeInfosByDeveloperName().values()) {
        	String strRecordTypeId = rtInfoRow.getRecordTypeId();
        	String strRecordTypeName = rtInfoRow.getName();
        	String strRecordTypeDeveloperName = rtInfoRow.getDeveloperName();

        	if (!strRecordTypeDeveloperName.startsWith('NEO_')) {
        		continue;
        	}

        	ruleRtOptions.add(new NEO_Rules_Constants.MySelectOption(strRecordTypeId, strRecordTypeName));
        	ruleRtMaps.put(strRecordTypeDeveloperName, strRecordTypeId);
            ruleRtMaps.put(strRecordTypeId, strRecordTypeName);
        }

        String strObjectRecordTypeId = rtMaps.get('NEO_Object_Variable');
        String strMasterObjectId = '';

		// Master Object Options
		List<NEO_Rules_Constants.MySelectOption> masterObjects = new List<NEO_Rules_Constants.MySelectOption>();
		strSOQL = 'SELECT Id, Variable_Label__c, Variable_API_Name__c FROM NEO_Variable__c WHERE RecordTypeId = :strObjectRecordTypeId AND Is_Master_Object__c = true ORDER BY Variable_Label__c';
		for (NEO_Variable__c tempVariableRow : Database.query(strSOQL)) {
			masterObjects.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Variable_Label__c));

			if (strMasterObjectName == tempVariableRow.Variable_API_Name__c) {
				strMasterObjectId = tempVariableRow.Id;
			}
		}

		// Layout list
		List<NEO_Layout__c> layoutList = new List<NEO_Layout__c>();

		// NEO_Rule__c
		NEO_Rule__c ruleObj = null;
		if (String.isNotBlank(recordId)) {
			// Sub Query Clause
			Set<String> subQuerySelectFieldsSet = new Set<String> {
				'Id', 'Name', 'NEO_Aggregation__c', 'NEO_Rule__c', 'NEO_Operator_Text__c', 'NEO_Resource_Text__c', 'Row_Serial_No__c', 'NEO_Value_Text__c', 'NEO_Resource_Operator__c', 'NEO_Resource_Value__c',
				'NEO_Value_Date__c', 'NEO_Value_Datetime__c', 'NEO_Value_Time__c'
			};
			String subQuerySelectClause = String.join(new List<String>(subQuerySelectFieldsSet), ',');

			// Select fields
			selectFieldsSet = new Set<String> { 
				'Id', 'Name', 'NEO_Rule_Name__c', 'Real_Time_Trigger__c', 'NEO_Active__c', 'Description__c', 'Hard_Stop_Warning__c', 'Comment_Needed__c','NEO_Insert_Triggered__c', 'NEO_Update_Triggered__c', 'NEO_Delete_Triggered__c',
				'Approval_Level__c', 'Master_Object__c', 'Alert_Message__c', 'NEO_Alert_Message_EN__c', 'Custom_Logic__c', 'NEO_Day_ID__c', 'NEO_Layout__c', 'RecordTypeId', 'NEO_Enable_Approve__c', 'NEO_Enable_Delete__c', 'NEO_Enable_Edit__c',
				'NEO_Enable_FACE_Cover__c', 'NEO_Enable_New__c', 'NEO_Enable_QR_Code__c', 'NEO_Readonly_Mode__c',
				'(SELECT ' + subQuerySelectClause + ' FROM NEO_Criterias__r ORDER BY Row_Serial_No__c)'
			};
			// Query NEO_Rule__c
			strSOQL = 'SELECT ' + String.join(new List<String>(selectFieldsSet), ',') + ' FROM NEO_Rule__c WHERE Id = :recordId';
			List<NEO_Rule__c> ruleList = Database.query(strSOQL);
			if (ruleList.size() > 0) {
				ruleObj = ruleList.get(0);
			}

			// Get layout list
			NEO_Variable__c masterObjectObj = NEOVariableMaps.get(ruleObj.Master_Object__c);
			String strObjectType = masterObjectObj.Variable_API_Name__c;
			strSOQL = 'SELECT Id, NEO_Layout_Name__c FROM NEO_Layout__c WHERE NEO_Object_Type__c = :strObjectType';
			layoutList = Database.query(strSOQL);

		} else {
			ruleObj = new NEO_Rule__c(Real_Time_Trigger__c = false, RecordTypeId = ruleRtMaps.get('NEO_Validation_Rule'));
			if (String.isNotBlank(strMasterObjectId)) {
				ruleObj.Master_Object__c = strMasterObjectId;
			}
		}

		// NEO_Criteria__c
		CriteriaWrapper tempCriteriaWrapperRow = null;
		List<CriteriaWrapper> criteriaWrapperList = new List<CriteriaWrapper>();

		if (ruleObj.NEO_Criterias__r <> null) {
			for (NEO_Criteria__c tempCriteriaRow : ruleObj.NEO_Criterias__r) {
				tempCriteriaWrapperRow = new CriteriaWrapper(tempCriteriaRow);
				updateCriteriaWrapperRow(ruleObj, tempCriteriaWrapperRow, null);
				criteriaWrapperList.add(tempCriteriaWrapperRow);
			}
		}

		Map<String, List<NEO_Variable__c>> parentVariableMaps = NEO_Rules_Constants.parentVariableMaps;
		// Create day ID picklist options
		List<NEO_Rules_Constants.MySelectOption> dayIDOptions = new List<NEO_Rules_Constants.MySelectOption>();
		if (ruleObj <> null && 
			String.isNotBlank(ruleObj.Master_Object__c) && 
			parentVariableMaps.containsKey(ruleObj.Master_Object__c)) {
			for (NEO_Variable__c tempVariableRow : parentVariableMaps.get(ruleObj.Master_Object__c)) {

				if (tempVariableRow.NEO_Variable_Data_Type__c <> NEO_Rules_Constants.NEO_DATA_TYPE_DATE &&
					tempVariableRow.NEO_Variable_Data_Type__c <> NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME) {
					continue;
				}

				dayIDOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Variable_Label__c));
			}
		}

		// Return back
		Map<String, Object> returnMaps = new Map<String, Object> {
			'masterObjects' => masterObjects,
			'hardStopWarningOptions' => NEO_Rules_Utils.getPicklistOptionsByObjectName('NEO_Rule__c', 'Hard_Stop_Warning__c'),
			'approvalLevelOptions' => NEO_Rules_Utils.getPicklistOptionsByObjectName('NEO_Rule__c', 'Approval_Level__c'),
			'criteriaWrapperList' => criteriaWrapperList,
			'keyPrefix' => NEO_Rule__c.SObjectType.getDescribe().getKeyPrefix(),
			'ruleObj' => ruleObj,
			'fieldsMap' => NEO_Rules_Utils.getFieldsMapByObjectName(new Set<String> { 'NEO_Event__c' }),
			'dayIDOptions' => dayIDOptions,
			'labelMaps' => NEO_Rules_Utils.getFieldLabelMapByObjectName('NEO_Rule__c'),
			'criteriaLabelMaps' => NEO_Rules_Utils.getFieldLabelMapByObjectName('NEO_Criteria__c'),
			'ruleRtOptions' => ruleRtOptions,
			'ruleRtMaps' => ruleRtMaps,
			'layoutList' => layoutList
		};
		return returnMaps;
	}

	@AuraEnabled
	public static Map<String, Object> changeMasterObject(NEO_Rule__c ruleObj) {
		String strSOQL = '';

		Map<String, List<NEO_Variable__c>> parentVariableMaps = NEO_Rules_Constants.parentVariableMaps;
		Map<String, NEO_Variable__c> NEOVariableMaps = NEO_Rules_Constants.NEOVariableMaps;

		// Create day ID picklist options
		List<NEO_Rules_Constants.MySelectOption> dayIDOptions = new List<NEO_Rules_Constants.MySelectOption>();
		if (ruleObj <> null && 
			String.isNotBlank(ruleObj.Master_Object__c) && 
			parentVariableMaps.containsKey(ruleObj.Master_Object__c)) {
			for (NEO_Variable__c tempVariableRow : parentVariableMaps.get(ruleObj.Master_Object__c)) {

				if (tempVariableRow.NEO_Variable_Data_Type__c <> NEO_Rules_Constants.NEO_DATA_TYPE_DATE &&
					tempVariableRow.NEO_Variable_Data_Type__c <> NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME) {
					continue;
				}

				dayIDOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Variable_Label__c));
			}
		}

		// Get layout list
		NEO_Variable__c masterObjectObj = NEOVariableMaps.get(ruleObj.Master_Object__c);
		String strObjectType = masterObjectObj.Variable_API_Name__c;
		strSOQL = 'SELECT Id, NEO_Layout_Name__c FROM NEO_Layout__c WHERE NEO_Object_Type__c = :strObjectType';
		List<NEO_Layout__c> layoutList = Database.query(strSOQL);

		Map<String, Object> returnMaps = new Map<String, Object> {
			'ruleObj' => ruleObj,
			'dayIDOptions' => dayIDOptions,
			'layoutList' => layoutList,
			'strObjectType' => strObjectType
		};
		return returnMaps;
	}

	@AuraEnabled
	public static Map<String, Object> addCriteriaRow(NEO_Rule__c ruleObj, String jsonString) {

		Map<String, List<NEO_Variable__c>> parentVariableMaps = NEO_Rules_Constants.parentVariableMaps;
		Map<String, NEO_Operator__c> NEOOperatorMaps = NEO_Rules_Constants.NEOOperatorMaps;
		Map<String, List<NEO_Aggregation__c>> masterObjectAggregationMaps = NEO_Rules_Constants.masterObjectAggregationMaps;

		// Resource Options
		List<NEO_Rules_Constants.MySelectOption> tempResourceOptions = new List<NEO_Rules_Constants.MySelectOption>();
		if (String.isNotBlank(ruleObj.Master_Object__c) && parentVariableMaps.containsKey(ruleObj.Master_Object__c)) {
			for (NEO_Variable__c tempVariableRow : parentVariableMaps.get(ruleObj.Master_Object__c)) {
				tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_Label__c));
			}
		}
		// Aggregation Options
		if (String.isNotBlank(ruleObj.Master_Object__c) && masterObjectAggregationMaps.containsKey(ruleObj.Master_Object__c)) {
			for (NEO_Aggregation__c tempAggregationRow : masterObjectAggregationMaps.get(ruleObj.Master_Object__c)) {
				tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption(tempAggregationRow.Id, 'Aggregation: ' + tempAggregationRow.Aggregation_Name__c));
			}
		}

		// $User Options
		if (String.isNotBlank(ruleObj.Master_Object__c)) {
			String strUserVarialeId = NEO_Rules_Constants.USER_VARIABLE_ID;
			if (String.isNotBlank(strUserVarialeId) && parentVariableMaps.containsKey(strUserVarialeId)) {
				for (NEO_Variable__c tempVariableRow : parentVariableMaps.get(strUserVarialeId)) {
					tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption('$User.' + tempVariableRow.Id, '$User: ' + tempVariableRow.Variable_Label__c));
				}
			}
		}

		// Add new row
		List<CriteriaWrapper> criteriaWrapperList = null;
		if (String.isNotBlank(jsonString)) {
			criteriaWrapperList = (List<CriteriaWrapper>)JSON.deserialize(jsonString, List<CriteriaWrapper>.class);
		} else {
			criteriaWrapperList = new List<CriteriaWrapper>();
		}
		NEO_Criteria__c tempCriteriaRow = new NEO_Criteria__c(
			Row_Serial_No__c = criteriaWrapperList.size() + 1
		);
		CriteriaWrapper tempCriteriaWrapperRow = new CriteriaWrapper(tempCriteriaRow);
		updateCriteriaWrapperRow(ruleObj, tempCriteriaWrapperRow, null);
		criteriaWrapperList.add(tempCriteriaWrapperRow);

		// Custom Logic
		String strCustomLogic = String.isBlank(ruleObj.Custom_Logic__c) ? '' : ruleObj.Custom_Logic__c;
		if (String.isNotBlank(strCustomLogic)) {
			strCustomLogic += ' AND ';
		}
		strCustomLogic += tempCriteriaWrapperRow.criteriaObj.Row_Serial_No__c;
		ruleObj.Custom_Logic__c = strCustomLogic;

		Map<String, Object> returnMaps = new Map<String, Object> {
			'ruleObj' => ruleObj,
			'criteriaWrapperList' => criteriaWrapperList
		};

		return returnMaps;
	}

	@AuraEnabled
	public static List<CriteriaWrapper> changeCriteriaRowValue(String rowIndex, NEO_Rule__c ruleObj, String changeType, String jsonString) {
		List<CriteriaWrapper> criteriaWrapperList = null;
		if (String.isNotBlank(jsonString)) {
			criteriaWrapperList = (List<CriteriaWrapper>)JSON.deserialize(jsonString, List<CriteriaWrapper>.class);
		} else {
			criteriaWrapperList = new List<CriteriaWrapper>();
		}

		// CriteriaWrapper currentCriteriaWrapperSource = null;
		for (CriteriaWrapper tempCriteriaWrapperRow : criteriaWrapperList) {
			if (String.isBlank(rowIndex)) {
				updateCriteriaWrapperRow(ruleObj, tempCriteriaWrapperRow, changeType);

			} else if (tempCriteriaWrapperRow.criteriaObj.Row_Serial_No__c == Decimal.valueOf(rowIndex)) {
				updateCriteriaWrapperRow(ruleObj, tempCriteriaWrapperRow, changeType);
				break;
			}
		}

		/*
		if (currentCriteriaWrapperSource <> null) {
			updateCriteriaWrapperRow(ruleObj, currentCriteriaWrapperSource, changeType);
		}
		*/
		return criteriaWrapperList;
	}

	private static void updateCriteriaWrapperRow(NEO_Rule__c ruleObj, CriteriaWrapper criteriaWrapperSource, String changeType) {
		// Get rule constants
		Map<String, List<NEO_Variable__c>> parentVariableMaps = NEO_Rules_Constants.parentVariableMaps;
		Map<String, NEO_Variable__c> NEOVariableMaps = NEO_Rules_Constants.NEOVariableMaps;
		Map<String, NEO_Operator__c> NEOOperatorMaps = NEO_Rules_Constants.NEOOperatorMaps;
		Map<String, NEO_Aggregation__c> aggregationMaps = NEO_Rules_Constants.aggregationMaps;
		Map<String, NEO_Variable__c> currentUserFieldsMaps = NEO_Rules_Constants.currentUserFieldsMaps;
		Map<String, List<NEO_Aggregation__c>> masterObjectAggregationMaps = NEO_Rules_Constants.masterObjectAggregationMaps;
		Map<String, List<NEO_Operator__c>> NEODataTypeOperatorMaps = NEO_Rules_Constants.NEODataTypeOperatorMaps;
		Map<String, List<NEO_Operator__c>> NEODataTypeResourceOperatorMaps = NEO_Rules_Constants.NEODataTypeResourceOperatorMaps;

		// Resource Options
		List<NEO_Rules_Constants.MySelectOption> tempResourceOptions = new List<NEO_Rules_Constants.MySelectOption>();
		List<NEO_Rules_Constants.MySelectOption> tempResourceOperatorOptions = new List<NEO_Rules_Constants.MySelectOption>();
		List<NEO_Rules_Constants.MySelectOption> tempResourceValueOptions = new List<NEO_Rules_Constants.MySelectOption>();

		List<NEO_Rules_Constants.MySelectOption> tempOperatorOptions = new List<NEO_Rules_Constants.MySelectOption>();
		List<NEO_Rules_Constants.MySelectOption> tempValueOptions = new List<NEO_Rules_Constants.MySelectOption>();
		String strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TEXT;
		String strResourceValueDisplayType = '';

		// Decimal Set
		Set<String> tempDecimalDataTypeSet = new Set<String> {
			NEO_Rules_Constants.NEO_DATA_TYPE_CURRENCY,
			NEO_Rules_Constants.NEO_DATA_TYPE_NUMBER,
			NEO_Rules_Constants.NEO_DATA_TYPE_DECIMAL,
			NEO_Rules_Constants.NEO_DATA_TYPE_PERCENT
		};

		// Resource Start
		// Resource Options + Aggregation Options + $User Options
		List<NEO_Variable__c> tempResourceVariableList = new List<NEO_Variable__c>();
		List<NEO_Aggregation__c> tempResourceAggregationList = new List<NEO_Aggregation__c>();
		List<NEO_Variable__c> tempResourceUserVariableList = new List<NEO_Variable__c>();

		if (String.isNotBlank(ruleObj.Master_Object__c) && parentVariableMaps.containsKey(ruleObj.Master_Object__c)) {
			tempResourceVariableList = parentVariableMaps.get(ruleObj.Master_Object__c);
			for (NEO_Variable__c tempVariableRow : tempResourceVariableList) {
				String tempResourceDataType = tempVariableRow.NEO_Variable_Data_Type__c;

				if (ruleObj.NEO_Update_Triggered__c) {
					tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_OLD_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_OLD_LABEL + ')'));
					if (tempResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE ||
						tempResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME) {
						tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_OLD_LABEL + '_' + NEO_Rules_Constants.NEO_FY_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_OLD_LABEL + ', ' + NEO_Rules_Constants.NEO_FY_LABEL + ')'));
						tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_OLD_LABEL + '_' + NEO_Rules_Constants.NEO_FQ_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_OLD_LABEL + ', ' + NEO_Rules_Constants.NEO_FQ_LABEL + ')'));
						tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_OLD_LABEL + '_' + NEO_Rules_Constants.NEO_FM_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_OLD_LABEL + ', ' + NEO_Rules_Constants.NEO_FM_LABEL + ')'));
					}
				}

				tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c));
				if (tempResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE ||
					tempResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME) {
					tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_FY_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_FY_LABEL + ')'));
					tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_FQ_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_FQ_LABEL + ')'));
					tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_FM_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_FM_LABEL + ')'));
				}
			}
		}

		// Aggregation Options
		if (String.isNotBlank(ruleObj.Master_Object__c) && masterObjectAggregationMaps.containsKey(ruleObj.Master_Object__c)) {
			tempResourceAggregationList = masterObjectAggregationMaps.get(ruleObj.Master_Object__c);
			for (NEO_Aggregation__c aggregationRow : tempResourceAggregationList) {
				tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption(aggregationRow.Id, 'Aggregation: ' + aggregationRow.Aggregation_Name__c));
			}
		}

		// $User Options
		if (String.isNotBlank(ruleObj.Master_Object__c)) {
			String strUserVarialeId = NEO_Rules_Constants.USER_VARIABLE_ID;
			if (String.isNotBlank(strUserVarialeId) && parentVariableMaps.containsKey(strUserVarialeId)) {
				tempResourceUserVariableList = parentVariableMaps.get(strUserVarialeId);
				for (NEO_Variable__c tempVariableRow : tempResourceUserVariableList) {
					tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption('$User.' + tempVariableRow.Id, '$User: ' + tempVariableRow.Variable_API_Name__c));
				}
			}
		}

		String tempResource = criteriaWrapperSource.criteriaObj.NEO_Resource_Text__c;
		if (String.isNotBlank(tempResource)) {
			Boolean oldResource = false, fyResource = false, fqResource = false, fmResource = false;
			if (tempResource.endsWithIgnoreCase(NEO_Rules_Constants.NEO_FY_LABEL)) {
				fyResource = true;
				tempResource = tempResource.replaceAll('_' + NEO_Rules_Constants.NEO_FY_LABEL, '');

			} else if (tempResource.endsWithIgnoreCase(NEO_Rules_Constants.NEO_FQ_LABEL)) {
				fqResource = true;
				tempResource = tempResource.replaceAll('_' + NEO_Rules_Constants.NEO_FQ_LABEL, '');

			} else if (tempResource.endsWithIgnoreCase(NEO_Rules_Constants.NEO_FM_LABEL)) {
				fmResource = true;
				tempResource = tempResource.replaceAll('_' + NEO_Rules_Constants.NEO_FM_LABEL, '');
			}

			if (tempResource.endsWithIgnoreCase(NEO_Rules_Constants.NEO_OLD_LABEL)) {
				oldResource = true;
				tempResource = tempResource.replaceAll('_' + NEO_Rules_Constants.NEO_OLD_LABEL, '');
			}

			// Resource variable information
			NEO_Variable__c tempVariableSource = null;
			NEO_Aggregation__c tempAggregationRow = null;
			String tempVariableAPIName = '';
			String tempParentVariableAPIName = '';
			String tempVariableDataType = '';
			Boolean tempVariableOrNot = true;

			if (NEOVariableMaps.containsKey(tempResource)) {
				// Variable
				tempVariableSource = NEOVariableMaps.get(tempResource);
				tempVariableDataType = tempVariableSource.NEO_Variable_Data_Type__c;
				tempParentVariableAPIName = tempVariableSource.Parent_Variable__r.Variable_API_Name__c;
				tempVariableAPIName = tempVariableSource.Variable_API_Name__c;
				tempVariableOrNot = true;

			} else if (aggregationMaps.containsKey(tempResource)) {
				// Aggregation
				tempAggregationRow = aggregationMaps.get(tempResource);
				tempVariableDataType = NEO_Rules_Constants.NEO_DATA_TYPE_AGGREGATION;
				tempVariableOrNot = false;

			} else if (currentUserFieldsMaps.containsKey(tempResource)) {
				tempVariableSource = currentUserFieldsMaps.get(tempResource);
				tempVariableDataType = tempVariableSource.NEO_Variable_Data_Type__c;
				tempParentVariableAPIName = tempVariableSource.Parent_Variable__r.Variable_API_Name__c;
				tempVariableAPIName = tempVariableSource.Variable_API_Name__c;
				tempVariableOrNot = true;
			}

			String tempVariableDataTypeKey = tempVariableDataType;
			if (String.isNotBlank(tempVariableDataTypeKey) && tempVariableDataTypeKey.contains(NEO_Rules_Constants.NEO_DATA_TYPE_LOOKUP)) {
				tempVariableDataTypeKey = NEO_Rules_Constants.NEO_DATA_TYPE_LOOKUP;
				// tempVariableDataType = tempVariableDataType.toLowerCase().capitalize();
			}

			// Resource value options and value options
			// Variable
			for (NEO_Variable__c tempVariableRow : tempResourceVariableList) {
				String tempDataType = tempVariableRow.NEO_Variable_Data_Type__c;

				// Resource value options
				if (tempDecimalDataTypeSet.contains(tempDataType) && String.valueOf(tempVariableRow.Id) <> tempResource) {
					tempResourceValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c));
				}

				// Value options
				if ((String.valueOf(tempVariableRow.Id) <> tempResource || (oldResource && String.valueOf(tempVariableRow.Id) == tempResource)) && tempVariableDataType == tempDataType) {
					if (tempDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE ||
						tempDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME) {
						if (fyResource) {
							tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_FY_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_FY_LABEL + ')'));
						
						} else if (fqResource) {
							tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_FQ_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_FQ_LABEL + ')'));
						
						} else if (fmResource) {
							tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_FM_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_FM_LABEL + ')'));
						
						} else {
							tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c));
						}
					} else {
						tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c));
					}
				} else if (String.valueOf(tempVariableRow.Id) == tempResource && !oldResource && tempVariableDataType == tempDataType && ruleObj.NEO_Update_Triggered__c) {
					if (tempDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE ||
						tempDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME) {
						if (fyResource) {
							tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_OLD_LABEL + '_' + NEO_Rules_Constants.NEO_FY_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_OLD_LABEL + ', ' + NEO_Rules_Constants.NEO_FY_LABEL + ')'));
						
						} else if (fqResource) {
							tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_OLD_LABEL + '_' + NEO_Rules_Constants.NEO_FQ_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_OLD_LABEL + ', ' + NEO_Rules_Constants.NEO_FQ_LABEL + ')'));
						
						} else if (fmResource) {
							tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_OLD_LABEL + '_' + NEO_Rules_Constants.NEO_FM_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_OLD_LABEL + ', ' + NEO_Rules_Constants.NEO_FM_LABEL + ')'));
						
						} else {
							tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_OLD_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_OLD_LABEL + ')'));
						}
					} else {
						tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id + '_' + NEO_Rules_Constants.NEO_OLD_LABEL, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c + '(' + NEO_Rules_Constants.NEO_OLD_LABEL + ')'));
					}
				}

				if (tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_AGGREGATION && tempDecimalDataTypeSet.contains(tempDataType)) {
					tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c));
				}
			}

			// Aggregation
			for (NEO_Aggregation__c aggregationRow : tempResourceAggregationList) {
				// Resource value options
				if (String.valueOf(aggregationRow.Id) <> tempResource) {
					tempResourceValueOptions.add(new NEO_Rules_Constants.MySelectOption(aggregationRow.Id, 'Aggregation: ' + aggregationRow.Aggregation_Name__c));
				}
			}

			// User variable
			for (NEO_Variable__c tempVariableRow : tempResourceUserVariableList) {
				// Resource value options
				if (tempVariableRow.NEO_Variable_Data_Type__c == NEO_Rules_Constants.NEO_DATA_TYPE_DECIMAL &&
					String.valueOf(tempVariableRow.Id) <> tempResource) {
					tempResourceValueOptions.add(new NEO_Rules_Constants.MySelectOption('$User.' + tempVariableRow.Id, '$User: ' + tempVariableRow.Variable_Label__c));
				}
			}

			// Change type
			if (changeType == 'Resource') {
				// Change resource
				criteriaWrapperSource.criteriaObj.NEO_Operator_Text__c =  '';
				criteriaWrapperSource.criteriaObj.NEO_Value_Text__c =  '';
				criteriaWrapperSource.criteriaObj.NEO_Value_Date__c =  null;
				criteriaWrapperSource.criteriaObj.NEO_Value_Datetime__c =  null;
				criteriaWrapperSource.criteriaObj.NEO_Resource_Operator__c =  '';
				criteriaWrapperSource.criteriaObj.NEO_Resource_Value__c =  '';
				strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TEXT;

			} else if (changeType == 'ResourceOperator') {
				// Change resource operator
				criteriaWrapperSource.criteriaObj.NEO_Resource_Value__c =  '';

			} else if (changeType == 'Operator') {
				// Change operator
				criteriaWrapperSource.criteriaObj.NEO_Value_Text__c =  '';
				criteriaWrapperSource.criteriaObj.NEO_Value_Date__c =  null;
				criteriaWrapperSource.criteriaObj.NEO_Value_Datetime__c =  null;
			}

			// Resource Operator
			if (NEODataTypeResourceOperatorMaps.containsKey(tempVariableDataTypeKey)) {
				for (NEO_Operator__c tempOperatorRow : NEODataTypeResourceOperatorMaps.get(tempVariableDataTypeKey)) {
					tempResourceOperatorOptions.add(new NEO_Rules_Constants.MySelectOption(tempOperatorRow.Id, tempOperatorRow.Operator_Label__c));
				}
			}

			// Resource value
			String strResourceOperator = criteriaWrapperSource.criteriaObj.NEO_Resource_Operator__c;
			if (String.isNotBlank(strResourceOperator) && NEOOperatorMaps.containsKey(strResourceOperator)) {
				NEO_Operator__c tempResourceOperatorSource = NEOOperatorMaps.get(strResourceOperator);

				// Parameter data type
				if (tempResourceOperatorSource.Parameter_Data_Type__c == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_SPECIAL_VALUE) {
					// Special value
					strResourceValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_PICKLIST;

				} else {
					strResourceValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_DECIMAL;
				}
			}

			// Default value is decimal
			if (String.isBlank(strResourceValueDisplayType)) {
				strResourceValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_DECIMAL;
			}

			// Create operator options
			if (fyResource || fqResource || fmResource) {
				tempVariableDataTypeKey = NEO_Rules_Constants.NEO_DATA_TYPE_NUMBER;
			}
			if (NEODataTypeOperatorMaps.containsKey(tempVariableDataTypeKey)) {
				for (NEO_Operator__c tempOperatorRow : NEODataTypeOperatorMaps.get(tempVariableDataTypeKey)) {
					tempOperatorOptions.add(new NEO_Rules_Constants.MySelectOption(tempOperatorRow.Id, tempOperatorRow.Operator_Label__c));
				}
			}

			// Value display type
			String strOperatorText = criteriaWrapperSource.criteriaObj.NEO_Operator_Text__c;

			// Parameter data type
			String strOperatorParameterDataType = '';
			if (NEOOperatorMaps.containsKey(strOperatorText)) {
				strOperatorParameterDataType = NEOOperatorMaps.get(strOperatorText).Parameter_Data_Type__c;
			}

			if (tempVariableOrNot) {
				if (strOperatorParameterDataType == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_SPECIAL_VALUE) {
					// Special value
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_PICKLIST;

					// Data type
					if (tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE && !fyResource && !fqResource && !fmResource) {
						// Date
						tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATE_FUNCTION_TODAY, NEO_Rules_Constants.NEO_DATE_FUNCTION_TODAY_LABEL));
						tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_MONTH, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_MONTH_LABEL));
						tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_MONTH, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_MONTH_LABEL));
						tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_QUARTER, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_QUARTER_LABEL));
						tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_QUARTER, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_QUARTER_LABEL));
						tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_YEAR, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_YEAR_LABEL));
						tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_YEAR, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_YEAR_LABEL));

					} else if (tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME && !fyResource && !fqResource && !fmResource) {
						// Datetime
						tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_NOW, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_NOW_LABEL));
					}

				} else if (strOperatorParameterDataType == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_NUMBER) {
					// Number
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_NUMBER;
					
				} else if (strOperatorParameterDataType == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_QUERY) {
					// Query
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_PICKLIST;
					
				} else if (strOperatorParameterDataType == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_LIST) {
					// List
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TEXT;
					
				} else if (strOperatorParameterDataType == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_TEXT) {
					// Text
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TEXT;
					
				} else {
					// Data type
					if (tempVariableDataType == NEO_Rules_Constants.NEO_DISPLAY_TYPE_CHECKBOX) {
						// Checkbox
						strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_PICKLIST;

						// Value options
						tempValueOptions = new List<NEO_Rules_Constants.MySelectOption>();
						tempValueOptions.add(new NEO_Rules_Constants.MySelectOption('true', 'True'));
						tempValueOptions.add(new NEO_Rules_Constants.MySelectOption('false', 'False'));

					} else if (tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_CURRENCY) {
						// Currency
						strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_CURRENCY;

					} else if (tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE && !fyResource && !fqResource && !fmResource) {
						// Date
						strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_DATE;

					} else if (tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME && !fyResource && !fqResource && !fmResource) {
						// Datetime
						strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_DATETIME;

					} else if (tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_EMAIL) {
						// Datetime
						strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_EMAIL;

					} else if (String.isNotBlank(tempVariableDataType) && 
							   tempVariableDataType.startsWith(NEO_Rules_Constants.NEO_DATA_TYPE_LOOKUP)) {
						// Lookup
						strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TEXT;

					} else if (tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_NUMBER ||
							   tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DOUBLE ||
							   tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DECIMAL ||
							   tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PERCENT) {
						// Number/Double/Decimal/Percent
						strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_NUMBER;

					} else if (tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PHONE ||
							   tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_TEXT ||
							   tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_URL) {
						// Phone/Text
						strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TEXT;

					} else if (tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PICKLIST) {
						// Picklist
						strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_PICKLIST;

						// Value options
						tempValueOptions = NEO_Rules_Utils.getPicklistOptionsByObjectName(tempParentVariableAPIName, tempVariableAPIName);

					} else if (tempVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_TIME) {
						// Time
						strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TIME;

					} else if (fyResource || fqResource || fmResource) {
						strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_NUMBER;
					}
				}
			} else {
				// Aggregation operator
				if (strOperatorParameterDataType == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_SPECIAL_VALUE) {
					// Special value
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_PICKLIST;
				} else {
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_DECIMAL;
				}
			}

			// Blank
			if (String.isBlank(strValueDisplayType)) {
				strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TEXT;
			}
		}
		criteriaWrapperSource.resourceOptions = tempResourceOptions;
		criteriaWrapperSource.resourceOperatorOptions = tempResourceOperatorOptions;
		criteriaWrapperSource.resourceValueOptions = tempResourceValueOptions;
		criteriaWrapperSource.operatorOptions = tempOperatorOptions;
		criteriaWrapperSource.valueOptions = tempValueOptions;
		criteriaWrapperSource.valueDisplayType = strValueDisplayType;
		criteriaWrapperSource.resourceValueDisplayType = strResourceValueDisplayType;
	}

	@AuraEnabled
	public static Map<String, Object> tSave(NEO_Rule__c ruleObj, String jsonString) {
		List<CriteriaWrapper> criteriaWrapperList = null;

		String  strStatusMsg = '';
        String strStatusCode = '';

        try {
			if (String.isNotBlank(jsonString)) {
				criteriaWrapperList = (List<CriteriaWrapper>)JSON.deserialize(jsonString, List<CriteriaWrapper>.class);
			} else {
				criteriaWrapperList = new List<CriteriaWrapper>();
			}
			if (ruleObj.Real_Time_Trigger__c) {
				ruleObj.Hard_Stop_Warning__c = NEO_Rules_Constants.NEO_STRING_HARD_STOP;
			}
			upsert ruleObj;

			List<NEO_Criteria__c> upsertCriteriaList = new List<NEO_Criteria__c>();
			for (CriteriaWrapper tempCriteriaRow : criteriaWrapperList) {
				tempCriteriaRow.criteriaObj.NEO_Rule__c = ruleObj.Id;
				if (tempCriteriaRow.valueDisplayType == NEO_Rules_Constants.NEO_DISPLAY_TYPE_TIME) {
					tempCriteriaRow.criteriaObj.NEO_Value_Date__c = null;
					tempCriteriaRow.criteriaObj.NEO_Value_Datetime__c = null; 
					tempCriteriaRow.criteriaObj.NEO_Value_Text__c = null;

				} else if (tempCriteriaRow.valueDisplayType == NEO_Rules_Constants.NEO_DISPLAY_TYPE_DATE) {
					tempCriteriaRow.criteriaObj.NEO_Value_Time__c = null;
					tempCriteriaRow.criteriaObj.NEO_Value_Datetime__c = null; 
					tempCriteriaRow.criteriaObj.NEO_Value_Text__c = null;

				} else if (tempCriteriaRow.valueDisplayType == NEO_Rules_Constants.NEO_DISPLAY_TYPE_DATETIME) {
					tempCriteriaRow.criteriaObj.NEO_Value_Time__c = null;
					tempCriteriaRow.criteriaObj.NEO_Value_Date__c = null;
					tempCriteriaRow.criteriaObj.NEO_Value_Text__c = null;

				} else {
					tempCriteriaRow.criteriaObj.NEO_Value_Time__c = null;
					tempCriteriaRow.criteriaObj.NEO_Value_Date__c = null;
					tempCriteriaRow.criteriaObj.NEO_Value_Datetime__c = null;
				}
				
				upsertCriteriaList.add(tempCriteriaRow.criteriaObj);
			}

			if (upsertCriteriaList.size() > 0) {
				upsert upsertCriteriaList;
			}

			// Clear criteria
			List<NEO_Criteria__c> tobeDeletedCriteriaList = [SELECT Id FROM NEO_Criteria__c WHERE Id NOT IN :upsertCriteriaList AND NEO_Rule__c = :ruleObj.Id];
			if (tobeDeletedCriteriaList.size() > 0) {
				delete tobeDeletedCriteriaList;
			}

			strStatusCode = 'success';
        	strStatusMsg = System.Label.NEO_RE_Save_Successfully;

		} catch(Exception e) {
			strStatusCode = 'error';
        	strStatusMsg = e.getMessage();
		}

		Map<String, Object> returnMaps = new Map<String, Object> {
			'ruleObj' => ruleObj,
			'criteriaWrapperList' => criteriaWrapperList,
			'strStatusCode' => strStatusCode,
			'strStatusMsg' => strStatusMsg
		};
		return returnMaps;
	}

	@AuraEnabled
	public static Map<String, Object> tClone(NEO_Rule__c ruleObj, String jsonString) {
		List<CriteriaWrapper> criteriaWrapperList = null;
		if (String.isNotBlank(jsonString)) {
			criteriaWrapperList = (List<CriteriaWrapper>)JSON.deserialize(jsonString, List<CriteriaWrapper>.class);
		} else {
			criteriaWrapperList = new List<CriteriaWrapper>();
		}

		ruleObj.Id = null;
		ruleObj.NEO_Active__c = false;
		ruleObj.NEO_Rule_Name__c = ruleObj.NEO_Rule_Name__c + ' - Copy';
		if (ruleObj.Real_Time_Trigger__c) {
			ruleObj.Hard_Stop_Warning__c = NEO_Rules_Constants.NEO_STRING_HARD_STOP;
		}
		upsert ruleObj;

		List<NEO_Criteria__c> upsertCriteriaList = new List<NEO_Criteria__c>();
		for (CriteriaWrapper tempCriteriaRow : criteriaWrapperList) {
			tempCriteriaRow.criteriaObj.Id = null;
			tempCriteriaRow.criteriaObj.NEO_Rule__c = ruleObj.Id;
			
			upsertCriteriaList.add(tempCriteriaRow.criteriaObj);
		}
		if (upsertCriteriaList.size() > 0) {
			upsert upsertCriteriaList;
		}

		Map<String, Object> returnMaps = new Map<String, Object> {
			'ruleObj' => ruleObj,
			'criteriaWrapperList' => criteriaWrapperList
		};

		return returnMaps;
	}

	@AuraEnabled
	public static Map<String, Object> deleteCriteriaRow(String rowIndex, NEO_Rule__c ruleObj, String jsonString) {
		List<CriteriaWrapper> criteriaWrapperList = null;
		if (String.isNotBlank(jsonString)) {
			criteriaWrapperList = (List<CriteriaWrapper>)JSON.deserialize(jsonString, List<CriteriaWrapper>.class);
		} else {
			criteriaWrapperList = new List<CriteriaWrapper>();
		}

		Set<String> deletedIds = new Set<String>();

		Decimal index = 0;
		String strCustomLogic = '';
		List<CriteriaWrapper> tempCriteriaWrapperList = new List<CriteriaWrapper>();
		for (CriteriaWrapper tempCriteriaRow : criteriaWrapperList) {
			if (Decimal.valueOf(rowIndex) == tempCriteriaRow.criteriaObj.Row_Serial_No__c) {
				if (String.isNotBlank(tempCriteriaRow.criteriaObj.Id)) {
					deletedIds.add(tempCriteriaRow.criteriaObj.Id);
				}
				continue;
			}
			tempCriteriaWrapperList.add(tempCriteriaRow);
			tempCriteriaRow.criteriaObj.Row_Serial_No__c = (++index);

			if (String.isNotBlank(strCustomLogic)) {
				strCustomLogic += ' AND ';
			}
			strCustomLogic += tempCriteriaRow.criteriaObj.Row_Serial_No__c;
		}
		criteriaWrapperList = tempCriteriaWrapperList;
		ruleObj.Custom_Logic__c = strCustomLogic;

		if (deletedIds.size() > 0) {
			delete [SELECT Id FROM NEO_Criteria__c WHERE Id IN :deletedIds];
		}

		Map<String, Object> returnMaps = new Map<String, Object> {
			'ruleObj' => ruleObj,
			'criteriaWrapperList' => criteriaWrapperList
		};

		return returnMaps;
	}


	class CriteriaWrapper {
		@AuraEnabled
		public NEO_Criteria__c criteriaObj { get; set; }
		@AuraEnabled
		public List<NEO_Rules_Constants.MySelectOption> resourceOptions { get; set; }
		@AuraEnabled
		public List<NEO_Rules_Constants.MySelectOption> resourceOperatorOptions { get; set; }
		@AuraEnabled
		public List<NEO_Rules_Constants.MySelectOption> resourceValueOptions { get; set; }
		@AuraEnabled
		public List<NEO_Rules_Constants.MySelectOption> operatorOptions { get; set; }
		@AuraEnabled
		public List<NEO_Rules_Constants.MySelectOption> valueOptions { get; set; }
		@AuraEnabled
		public String valueDisplayType { get; set; }
		@AuraEnabled
		public String resourceValueDisplayType { get; set; }

		public CriteriaWrapper(NEO_Criteria__c criteriaObj) {
			this.criteriaObj = criteriaObj;
			this.resourceOptions = new List<NEO_Rules_Constants.MySelectOption>();
			this.resourceOperatorOptions = new List<NEO_Rules_Constants.MySelectOption>();
			this.resourceValueOptions = new List<NEO_Rules_Constants.MySelectOption>();
			this.operatorOptions = new List<NEO_Rules_Constants.MySelectOption>();
			this.valueOptions = new List<NEO_Rules_Constants.MySelectOption>();
			this.valueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TEXT;
			this.resourceValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_NUMBER;
		}
	}
}