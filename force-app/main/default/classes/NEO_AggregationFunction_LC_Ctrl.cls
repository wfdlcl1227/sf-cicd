public class NEO_AggregationFunction_LC_Ctrl {

	@AuraEnabled
	public static Map<String, Object> initialize(String recordId) {
		String strSOQL = '';

		// Master Object Options
		List<NEO_Rules_Constants.MySelectOption> masterObjects = new List<NEO_Rules_Constants.MySelectOption>();
		strSOQL = 'SELECT Id, Variable_Label__c, Variable_API_Name__c FROM NEO_Variable__c WHERE Type__c = \'Object\' AND Is_Master_Object__c = true ORDER BY Variable_Label__c';
		for (NEO_Variable__c tempVariableRow : Database.query(strSOQL)) {
			masterObjects.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Variable_Label__c));
		}

		// NEO_Aggregation__c
		NEO_Aggregation__c tempAggregationObj = new NEO_Aggregation__c();
		if (String.isNotBlank(recordId)) {
			// Sub Query Clause
			Set<String> subQuerySelectFieldsSet = new Set<String> {
				'Id', 'Name', 'NEO_Aggregation__c', 'NEO_Rule__c', 'NEO_Resource_Text__c', 'Row_Serial_No__c', 'NEO_Value_Text__c', 'NEO_Value_Date__c', 'NEO_Value_Datetime__c', 'NEO_Operator_Text__c',
				'NEO_Resource_Operator__c', 'NEO_Resource_Value__c', 'NEO_Value_Time__c'
			};
			String subQuerySelectClause = String.join(new List<String>(subQuerySelectFieldsSet), ',');

			Set<String> selectFieldsSet = new Set<String> {
    			'Id', 'Name', 'Active__c', 'Aggregation_Name__c', 'Custom_Logic__c', 'Fields_to_Aggregate__c', 'Fields_To_Group__c', 'Master_Object__c', 'Description__c',
    			'Roll_Up_Type__c', 'NEO_Summarized_Object__c', 'NEO_Summarized_All_Records__c', '(SELECT ' + subQuerySelectClause + ' FROM NEO_Criterias__r ORDER BY Row_Serial_No__c ASC)'
    		};
    		strSOQL = 'SELECT ' + String.join(new List<String>(selectFieldsSet), ',') + ' FROM NEO_Aggregation__c WHERE Id = :recordId';
    		List<NEO_Aggregation__c> aggregationList = Database.query(strSOQL);
    		if (aggregationList.size() > 0) {
    			tempAggregationObj = aggregationList.get(0);
    		}
		} else {
			tempAggregationObj = new NEO_Aggregation__c();
		}

		Map<String, NEO_Variable__c> NEOVariableMaps = NEO_Rules_Constants.NEOVariableMaps;
		Map<String, List<NEO_Variable__c>> parentVariableMaps = NEO_Rules_Constants.parentVariableMaps;
		Map<String, List<NEO_Variable_Association__c>> variableAssociationMaps = NEO_Rules_Constants.variableAssociationMaps;
		Map<String, NEO_Variable_Association__c> NEOVariableAssociationMaps = NEO_Rules_Constants.NEOVariableAssociationMaps;

		// Get summarized object
		List<NEO_Variable_Association__c> tempSummarizedObjects = new List<NEO_Variable_Association__c>();
		if (String.isNotBlank(tempAggregationObj.Master_Object__c) && variableAssociationMaps.containsKey(tempAggregationObj.Master_Object__c)) {
			tempSummarizedObjects = variableAssociationMaps.get(tempAggregationObj.Master_Object__c);
		}

		// Fields to Aggregate/Fields to Group
		List<NEO_Rules_Constants.MySelectOption> tempFieldsToAggregate = new List<NEO_Rules_Constants.MySelectOption>();
		List<NEO_Rules_Constants.MySelectOption> tempFieldsToGroup = new List<NEO_Rules_Constants.MySelectOption>();
		
		String tempStrSummarizedObjectId = '';
		if (String.isNotBlank(tempAggregationObj.NEO_Summarized_Object__c) && NEOVariableAssociationMaps.containsKey(tempAggregationObj.NEO_Summarized_Object__c)) {
			tempStrSummarizedObjectId = NEOVariableAssociationMaps.get(tempAggregationObj.NEO_Summarized_Object__c).NEO_Child_Object__c;
		}

		if (String.isNotBlank(tempStrSummarizedObjectId) && parentVariableMaps.containsKey(tempStrSummarizedObjectId)) {
			for (NEO_Variable__c tempVariableRow : parentVariableMaps.get(tempStrSummarizedObjectId)) {
				if (NEO_Rules_Constants.NEO_ROLL_UP_TYPE_SUM == tempAggregationObj.Roll_Up_Type__c && (
					NEO_Rules_Constants.NEO_DATA_TYPE_DECIMAL == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_CURRENCY == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_NUMBER == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_DOUBLE == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_PERCENT == tempVariableRow.NEO_Variable_Data_Type__c)) {
					// Decimal/Currency/Number/Double/Percent
					tempFieldsToAggregate.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Variable_Label__c));

				} else if ((NEO_Rules_Constants.NEO_ROLL_UP_TYPE_MAX == tempAggregationObj.Roll_Up_Type__c ||
					NEO_Rules_Constants.NEO_ROLL_UP_TYPE_MIN == tempAggregationObj.Roll_Up_Type__c) && (
					NEO_Rules_Constants.NEO_DATA_TYPE_DATE == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_DECIMAL == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_CURRENCY == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_NUMBER == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_DOUBLE == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_PERCENT == tempVariableRow.NEO_Variable_Data_Type__c)) {
					// Max/Min + Date/Datetime/Decimal/Currency/Number/Double/Percent
					tempFieldsToAggregate.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Variable_Label__c));
				}

				if (NEO_Rules_Constants.NEO_ROLL_UP_TYPE_COUNT == tempAggregationObj.Roll_Up_Type__c ||
					NEO_Rules_Constants.NEO_ROLL_UP_TYPE_SUM == tempAggregationObj.Roll_Up_Type__c) {
					tempFieldsToGroup.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Variable_API_Name__c, tempVariableRow.Variable_Label__c));
				}
			}
		}

		List<String> tempFieldsToGroupValues = new List<String>();
		if (String.isNotBlank(tempAggregationObj.Fields_To_Group__c)) {
			tempFieldsToGroupValues = tempAggregationObj.Fields_To_Group__c.split(',');
		}

		// Criteria
		CriteriaWrapper tempCriteriaWrapperRow = null;
		List<CriteriaWrapper> criteriaWrapperList = new List<CriteriaWrapper>();

		if (tempAggregationObj.NEO_Criterias__r <> null) {
			for (NEO_Criteria__c tempCriteriaRow : tempAggregationObj.NEO_Criterias__r) {

				tempCriteriaWrapperRow = new CriteriaWrapper(tempCriteriaRow);
				updateCriteriaWrapperRow(tempAggregationObj, tempCriteriaWrapperRow, null);
				criteriaWrapperList.add(tempCriteriaWrapperRow);
			}
		}

		Map<String, Object> returnMaps = new Map<String, Object> {
			'masterObjects' => masterObjects,
			'aggregationObj' => tempAggregationObj,
			'rollupTypeList' => NEO_Rules_Utils.getPicklistOptionsByObjectName('NEO_Aggregation__c', 'Roll_Up_Type__c'),
			'criteriaWrapperList' => criteriaWrapperList,
			'summarizedObjects' => tempSummarizedObjects,
			'fieldsToAggregate' => tempFieldsToAggregate,
			'fieldsToGroup' => tempFieldsToGroup,
			'fieldsToGroupValues' => tempFieldsToGroupValues,
			'keyPrefix' => NEO_Aggregation__c.SObjectType.getDescribe().getKeyPrefix(),
			'labelMaps' => NEO_Rules_Utils.getFieldLabelMapByObjectName('NEO_Aggregation__c'),
			'criteriaLabelMaps' => NEO_Rules_Utils.getFieldLabelMapByObjectName('NEO_Criteria__c')
		};
		return returnMaps;
	}

	@AuraEnabled
	public static List<NEO_Variable_Association__c> loadSummarizedObjects(String masterObjId) {
		List<NEO_Variable_Association__c> tempSummarizedObjects = new List<NEO_Variable_Association__c>();

		Map<String, List<NEO_Variable_Association__c>> variableAssociationMaps = NEO_Rules_Constants.variableAssociationMaps;
		if (String.isNotBlank(masterObjId) && variableAssociationMaps.containsKey(masterObjId)) {
			tempSummarizedObjects = variableAssociationMaps.get(masterObjId);
		}
		return tempSummarizedObjects;
	}

	@AuraEnabled
	public static Map<String, Object> loadFieldList(NEO_Aggregation__c aggregationObj) {
		Map<String, NEO_Variable_Association__c> NEOVariableAssociationMaps = NEO_Rules_Constants.NEOVariableAssociationMaps;
		Map<String, List<NEO_Variable__c>> parentVariableMaps = NEO_Rules_Constants.parentVariableMaps;

		// NEO_Variable_Association__c
		String tempStrSummarizedObjectId = '';
		if (String.isNotBlank(aggregationObj.NEO_Summarized_Object__c) && NEOVariableAssociationMaps.containsKey(aggregationObj.NEO_Summarized_Object__c)) {
			tempStrSummarizedObjectId = NEOVariableAssociationMaps.get(aggregationObj.NEO_Summarized_Object__c).NEO_Child_Object__c;
		}

		// Fields to Aggregate/Fields to Group
		List<NEO_Rules_Constants.MySelectOption> tempFieldsToAggregate = new List<NEO_Rules_Constants.MySelectOption>();
		List<NEO_Rules_Constants.MySelectOption> tempFieldsToGroup = new List<NEO_Rules_Constants.MySelectOption>();
		if (String.isNotBlank(tempStrSummarizedObjectId) && parentVariableMaps.containsKey(tempStrSummarizedObjectId)) {
			for (NEO_Variable__c tempVariableRow : parentVariableMaps.get(tempStrSummarizedObjectId)) {
				
				if (NEO_Rules_Constants.NEO_ROLL_UP_TYPE_SUM == aggregationObj.Roll_Up_Type__c && (
					NEO_Rules_Constants.NEO_DATA_TYPE_DECIMAL == tempVariableRow.NEO_Variable_Data_Type__c || 
					NEO_Rules_Constants.NEO_DATA_TYPE_CURRENCY == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_NUMBER == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_DOUBLE == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_PERCENT == tempVariableRow.NEO_Variable_Data_Type__c)) {
					// Decimal/Currency/Number/Double/Percent
					tempFieldsToAggregate.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Variable_Label__c));

				} else if ((NEO_Rules_Constants.NEO_ROLL_UP_TYPE_MAX == aggregationObj.Roll_Up_Type__c ||
					NEO_Rules_Constants.NEO_ROLL_UP_TYPE_MIN == aggregationObj.Roll_Up_Type__c) && (
					NEO_Rules_Constants.NEO_DATA_TYPE_DATE == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_DECIMAL == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_CURRENCY == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_NUMBER == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_DOUBLE == tempVariableRow.NEO_Variable_Data_Type__c ||
					NEO_Rules_Constants.NEO_DATA_TYPE_PERCENT == tempVariableRow.NEO_Variable_Data_Type__c)) {
					// Max/Min + Date/Datetime/Decimal/Currency/Number/Percent
					tempFieldsToAggregate.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Variable_Label__c));
				}

				if (NEO_Rules_Constants.NEO_ROLL_UP_TYPE_COUNT == aggregationObj.Roll_Up_Type__c ||
					NEO_Rules_Constants.NEO_ROLL_UP_TYPE_SUM == aggregationObj.Roll_Up_Type__c) {
					// Sum
					tempFieldsToGroup.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Variable_API_Name__c, tempVariableRow.Variable_Label__c));
				}
			}
		}

		Map<String, Object> returnMaps = new Map<String, Object> {
			'fieldsToAggregate' => tempFieldsToAggregate,
			'fieldsToGroup' => tempFieldsToGroup
		};
		return returnMaps;
	}

	@AuraEnabled
	public static Map<String, Object> addCriteriaRow(NEO_Aggregation__c aggregationObj, String jsonString) {
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
		updateCriteriaWrapperRow(aggregationObj, tempCriteriaWrapperRow, null);
		criteriaWrapperList.add(tempCriteriaWrapperRow);

		// Custom Logic
		String strCustomLogic = String.isBlank(aggregationObj.Custom_Logic__c) ? '' : aggregationObj.Custom_Logic__c;
		if (String.isNotBlank(strCustomLogic)) {
			strCustomLogic += ' AND ';
		}
		strCustomLogic += tempCriteriaWrapperRow.criteriaObj.Row_Serial_No__c;
		aggregationObj.Custom_Logic__c = strCustomLogic;

		Map<String, Object> returnMaps = new Map<String, Object> {
			'aggregationObj' => aggregationObj,
			'criteriaWrapperList' => criteriaWrapperList
		};

		return returnMaps;
	}

	@AuraEnabled
	public static Map<String, Object> deleteCriteriaRow(String rowIndex, NEO_Aggregation__c aggregationObj, String jsonString) {
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
		aggregationObj.Custom_Logic__c = strCustomLogic;

		if (deletedIds.size() > 0) {
			delete [SELECT Id FROM NEO_Criteria__c WHERE Id IN :deletedIds];
		}

		Map<String, Object> returnMaps = new Map<String, Object> {
			'aggregationObj' => aggregationObj,
			'criteriaWrapperList' => criteriaWrapperList
		};

		return returnMaps;
	}

	@AuraEnabled
	public static List<CriteriaWrapper> changeCriteriaRowValue(String rowIndex, NEO_Aggregation__c aggregationObj, String jsonString, String changeType) {
		List<CriteriaWrapper> criteriaWrapperList = null;
		if (String.isNotBlank(jsonString)) {
			criteriaWrapperList = (List<CriteriaWrapper>)JSON.deserialize(jsonString, List<CriteriaWrapper>.class);
		} else {
			criteriaWrapperList = new List<CriteriaWrapper>();
		}

		// Get current criteria wrapper row
		CriteriaWrapper currentCriteriaWrapperSource = null;
		for (CriteriaWrapper tempCriteriaWrapperRow : criteriaWrapperList) {
			if (tempCriteriaWrapperRow.criteriaObj.Row_Serial_No__c == Decimal.valueOf(rowIndex)) {
				currentCriteriaWrapperSource = tempCriteriaWrapperRow;
				break;
			}
		}

		if (currentCriteriaWrapperSource <> null) {
			updateCriteriaWrapperRow(aggregationObj, currentCriteriaWrapperSource, changeType);
		}
		return criteriaWrapperList;
	}

	private static void updateCriteriaWrapperRow(NEO_Aggregation__c aggregationObj, CriteriaWrapper criteriaWrapperSource, String changeType) {
		// Get rule constants
		Map<String, List<NEO_Variable__c>> parentVariableMaps = NEO_Rules_Constants.parentVariableMaps;
		Map<String, NEO_Variable__c> NEOVariableMaps = NEO_Rules_Constants.NEOVariableMaps;
		Map<String, List<NEO_Variable_Association__c>> variableAssociationMaps = NEO_Rules_Constants.variableAssociationMaps;
		Map<String, NEO_Operator__c> NEOOperatorMaps = NEO_Rules_Constants.NEOOperatorMaps;
		Map<String, NEO_Variable_Association__c> NEOVariableAssociationMaps = NEO_Rules_Constants.NEOVariableAssociationMaps;
		Map<String, NEO_Variable__c> currentUserFieldsMaps = NEO_Rules_Constants.currentUserFieldsMaps;
		Map<String, List<NEO_Operator__c>> NEODataTypeOperatorMaps = NEO_Rules_Constants.NEODataTypeOperatorMaps;
    	Map<String, List<NEO_Operator__c>> NEODataTypeResourceOperatorMaps = NEO_Rules_Constants.NEODataTypeResourceOperatorMaps;

    	// Resource options
		List<NEO_Rules_Constants.MySelectOption> tempResourceOptions = new List<NEO_Rules_Constants.MySelectOption>();
		List<NEO_Rules_Constants.MySelectOption> tempResourceOperatorOptions = new List<NEO_Rules_Constants.MySelectOption>();
		List<NEO_Rules_Constants.MySelectOption> tempResourceValueOptions = new List<NEO_Rules_Constants.MySelectOption>();

		List<NEO_Rules_Constants.MySelectOption> tempOperatorOptions = new List<NEO_Rules_Constants.MySelectOption>();
		List<NEO_Rules_Constants.MySelectOption> tempValueOptions = new List<NEO_Rules_Constants.MySelectOption>();

		// Default Text
		String strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TEXT;
		String strResourceValueDisplayType = '';

		// Decimal Set
		Set<String> tempDecimalDataTypeSet = new Set<String> {
			NEO_Rules_Constants.NEO_DATA_TYPE_CURRENCY,
			NEO_Rules_Constants.NEO_DATA_TYPE_NUMBER,
			NEO_Rules_Constants.NEO_DATA_TYPE_DOUBLE,
			NEO_Rules_Constants.NEO_DATA_TYPE_DECIMAL,
			NEO_Rules_Constants.NEO_DATA_TYPE_PERCENT
		};

		// Resource Start
		// Set resource options
		List<NEO_Variable__c> tempResourceVariableList = new List<NEO_Variable__c>();
		String summarizedVariableId = '';
		if (String.isNotBlank(aggregationObj.NEO_Summarized_Object__c) && NEOVariableAssociationMaps.containsKey(aggregationObj.NEO_Summarized_Object__c)) {
			summarizedVariableId = NEOVariableAssociationMaps.get(aggregationObj.NEO_Summarized_Object__c).NEO_Child_Object__c;
		}

		if (String.isNotBlank(summarizedVariableId) && parentVariableMaps.containsKey(summarizedVariableId)) {
			tempResourceOptions = new List<NEO_Rules_Constants.MySelectOption>();
			tempResourceVariableList = parentVariableMaps.get(summarizedVariableId);

			for (NEO_Variable__c tempVariableRow : parentVariableMaps.get(summarizedVariableId)) {
				tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c));
			}
		}

		if (String.isNotBlank(summarizedVariableId)) {
			// $User Options
			String strUserVarialeId = NEO_Rules_Constants.USER_VARIABLE_ID;
			if (String.isNotBlank(strUserVarialeId) && parentVariableMaps.containsKey(strUserVarialeId)) {
				for (NEO_Variable__c tempVariableRow : parentVariableMaps.get(strUserVarialeId)) {
					tempResourceOptions.add(new NEO_Rules_Constants.MySelectOption('$User.' + tempVariableRow.Id, '$User: ' + tempVariableRow.Variable_API_Name__c));
				}
			}
		}

		String tempStrResourceText = criteriaWrapperSource.criteriaObj.NEO_Resource_Text__c;
		if (String.isNotBlank(tempStrResourceText)) {
			NEO_Variable__c tempVariableSource = null;
			String tempResourceVariableDataType = '';
			String tempVariableAPIName = '';
			String tempParentVariableAPIName = '';

			// Resource type
			if (NEOVariableMaps.containsKey(tempStrResourceText)) {
				// Variable
				tempVariableSource = NEOVariableMaps.get(tempStrResourceText);
				tempResourceVariableDataType = tempVariableSource.NEO_Variable_Data_Type__c;
				tempParentVariableAPIName = tempVariableSource.Parent_Variable__r.Variable_API_Name__c;
				tempVariableAPIName = tempVariableSource.Variable_API_Name__c;

			} else if (currentUserFieldsMaps.containsKey(tempStrResourceText)) {
				tempVariableSource = currentUserFieldsMaps.get(tempStrResourceText);
				tempResourceVariableDataType = tempVariableSource.NEO_Variable_Data_Type__c;
				tempParentVariableAPIName = tempVariableSource.Parent_Variable__r.Variable_API_Name__c;
				tempVariableAPIName = tempVariableSource.Variable_API_Name__c;
			}

			// Resource value options and value options
			// Variable
			for (NEO_Variable__c tempVariableRow : tempResourceVariableList) {
				// Resource value options
				if (tempDecimalDataTypeSet.contains(tempVariableRow.NEO_Variable_Data_Type__c) &&
					String.valueOf(tempVariableRow.Id) <> tempStrResourceText) {
					tempResourceValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c));
				}

				if (String.valueOf(tempVariableRow.Id) <> tempStrResourceText && tempResourceVariableDataType == tempVariableRow.NEO_Variable_Data_Type__c) {
					tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempVariableRow.Id, tempVariableRow.Parent_Variable__r.Variable_Label__c + ': ' + tempVariableRow.Variable_API_Name__c));
				}
			}

			// If change the resource, reset the operator and value
			if (changeType == 'Resource') {
				criteriaWrapperSource.criteriaObj.NEO_Operator_Text__c = '';
				criteriaWrapperSource.criteriaObj.NEO_Resource_Operator__c = '';
				criteriaWrapperSource.criteriaObj.NEO_Resource_Value__c = '';
				criteriaWrapperSource.criteriaObj.NEO_Value_Text__c = '';
				criteriaWrapperSource.criteriaObj.NEO_Value_Date__c =  null;
				criteriaWrapperSource.criteriaObj.NEO_Value_Datetime__c =  null;
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

			String strDataTypeKey = tempResourceVariableDataType;
			// Lookup
			if (String.isNotBlank(strDataTypeKey) && strDataTypeKey.contains(NEO_Rules_Constants.NEO_DATA_TYPE_LOOKUP)) {
				strDataTypeKey = NEO_Rules_Constants.NEO_DATA_TYPE_LOOKUP;
			}

			// Resource Operator
			if (NEODataTypeResourceOperatorMaps.containsKey(strDataTypeKey)) {
				for (NEO_Operator__c tempOperatorRow : NEODataTypeResourceOperatorMaps.get(strDataTypeKey)) {
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
			if (NEODataTypeOperatorMaps.containsKey(strDataTypeKey)) {
				for (NEO_Operator__c tempOperatorRow : NEODataTypeOperatorMaps.get(strDataTypeKey)) {
					tempOperatorOptions.add(new NEO_Rules_Constants.MySelectOption(tempOperatorRow.Id, tempOperatorRow.Operator_Label__c));
				}
			}

			String strOperatorText = criteriaWrapperSource.criteriaObj.NEO_Operator_Text__c;
			String strOperatorParameterDataType = '';
			// Parameter data type
			if (NEOOperatorMaps.containsKey(strOperatorText)) {
				strOperatorParameterDataType = NEOOperatorMaps.get(strOperatorText).Parameter_Data_Type__c;
			}

			if (strOperatorParameterDataType == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_SPECIAL_VALUE) {
				// Special value
				strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_PICKLIST;

				// Data type
				if (tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE) {
					// Date
					tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATE_FUNCTION_TODAY, NEO_Rules_Constants.NEO_DATE_FUNCTION_TODAY_LABEL));
					tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_MONTH, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_MONTH_LABEL));
					tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_MONTH, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_MONTH_LABEL));
					tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_QUARTER, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_QUARTER_LABEL));
					tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_QUARTER, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_QUARTER_LABEL));
					tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_YEAR, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_YEAR_LABEL));
					tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_YEAR, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_YEAR_LABEL));

				} else if (tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME) {
					// Datetime
					tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(NEO_Rules_Constants.NEO_DATETIME_FUNCTION_NOW, NEO_Rules_Constants.NEO_DATETIME_FUNCTION_NOW_LABEL));
				}

			} else if (strOperatorParameterDataType == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_NUMBER) {
				// Number
				strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_NUMBER;

			} else if (strOperatorParameterDataType == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_QUERY) {
				// Query
				strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_PICKLIST;

				// Value options
				List<NEO_Variable_Association__c> tempMasterObjectAssociationList = new List<NEO_Variable_Association__c>();
				if (String.isNotBlank(aggregationObj.Master_Object__c) && variableAssociationMaps.containsKey(aggregationObj.Master_Object__c)) {
					tempMasterObjectAssociationList = variableAssociationMaps.get(aggregationObj.Master_Object__c);
				}
				for (NEO_Variable_Association__c tempVariableAssociationRow : tempMasterObjectAssociationList) {
					if (!parentVariableMaps.containsKey(tempVariableAssociationRow.NEO_Child_Object__c)) {
						continue;
					}
					//  || tempVariableAssociationRow.Id == aggregationObj.NEO_Summarized_Object__c

					for (NEO_Variable__c tempChildObjectFields : parentVariableMaps.get(tempVariableAssociationRow.NEO_Child_Object__c)) {
						if (tempResourceVariableDataType == tempChildObjectFields.NEO_Variable_Data_Type__c) {
							String tempStrValue = tempVariableAssociationRow.NEO_Relationship_Name__c + '.' + tempChildObjectFields.Variable_API_Name__c;
							String tempStrLabel = tempVariableAssociationRow.NEO_Child_Object_Label__c + ': ' + tempChildObjectFields.Variable_Label__c;
							
							tempValueOptions.add(new NEO_Rules_Constants.MySelectOption(tempStrValue, tempStrLabel));
						}
					}
				}

			}  else if (strOperatorParameterDataType == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_LIST) {
				// List
				strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TEXT;
				
			} else if (strOperatorParameterDataType == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_TEXT) {
				// Text
				strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TEXT;
				
			} else {
				// Data type
				if (tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_CHECKBOX) {
					// Checkbox
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_PICKLIST;

					// Set checkbox value options
					tempValueOptions = new List<NEO_Rules_Constants.MySelectOption>();
					tempValueOptions.add(new NEO_Rules_Constants.MySelectOption('true', System.Label.NEO_RE_True));
					tempValueOptions.add(new NEO_Rules_Constants.MySelectOption('false', System.Label.NEO_RE_False));

				} else if (tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_CURRENCY) {
					// Currency
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_CURRENCY;

				} else if (tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE) {
					// Date
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_DATE;

				} else if (tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME) {
					// Datetime
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_DATETIME;

				} else if (tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_EMAIL) {
					// Datetime
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_EMAIL;

				} else if (String.isNotBlank(tempResourceVariableDataType) && 
						   tempResourceVariableDataType.startsWith(NEO_Rules_Constants.NEO_DATA_TYPE_LOOKUP)) {
					// Lookup
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_PICKLIST;

				} else if (tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_NUMBER ||
						   tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DOUBLE ||
						   tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DECIMAL ||
						   tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PERCENT) {
					// Number/Decimal/Percent
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_NUMBER;

				} else if (tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PHONE ||
						   tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_TEXT ||
						   tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_URL) {
					// Phone/Text
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TEXT;

				} else if (tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PICKLIST) {
					// Picklist
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_PICKLIST;

					// Value options
					tempValueOptions = NEO_Rules_Utils.getPicklistOptionsByObjectName(tempParentVariableAPIName, tempVariableAPIName);

				} else if (tempResourceVariableDataType == NEO_Rules_Constants.NEO_DATA_TYPE_TIME) {
					// Time
					strValueDisplayType = NEO_Rules_Constants.NEO_DISPLAY_TYPE_TIME;

				}
			}

			// Default display text
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
	public static Map<String, Object> tSave(NEO_Aggregation__c aggregationObj, String jsonString) {
		List<CriteriaWrapper> criteriaWrapperList = null;

		String  strStatusMsg = '';
        String strStatusCode = '';
        try {
			if (String.isNotBlank(jsonString)) {
				criteriaWrapperList = (List<CriteriaWrapper>)JSON.deserialize(jsonString, List<CriteriaWrapper>.class);
			} else {
				criteriaWrapperList = new List<CriteriaWrapper>();
			}
			upsert aggregationObj;

			List<NEO_Criteria__c> upsertCriteriaList = new List<NEO_Criteria__c>();
			for (CriteriaWrapper tempCriteriaRow : criteriaWrapperList) {
				tempCriteriaRow.criteriaObj.NEO_Aggregation__c = aggregationObj.Id;
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
			List<NEO_Criteria__c> tobeDeletedCriteriaList = [SELECT Id FROM NEO_Criteria__c WHERE Id NOT IN :upsertCriteriaList AND NEO_Aggregation__c = :aggregationObj.Id];
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
			'aggregationObj' => aggregationObj,
			'criteriaWrapperList' => criteriaWrapperList,
			'strStatusCode' => strStatusCode,
			'strStatusMsg' => strStatusMsg
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


		@AuraEnabled
		public String testMsgString { get; set; }

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