public with sharing class NEO_Edit_Variable_Override_LC_Ctrl {
    @AuraEnabled
	public static Map<String, Object> initialize(String recordId, NEO_Variable__c inputVarObj) {
		List<String> keysList = new List<String>();
		List<String> selectedFieldsList = new List<String>();
		String strSOQL = '';
		NEO_Variable__c variableObj = new NEO_Variable__c();

		List<String> targetObjects = new List<String>();
		List<String> targetFields = new List<String>();

		if (inputVarObj == null) {
			inputVarObj = new NEO_Variable__c();
		}

		// Get variable object
		if (String.isNotBlank(recordId)) {
			Set<String> includeFieldsSet = new Set<String> {
				'CreatedBy.Name', 'LastModifiedBy.Name'
			};
			Set<String> excludeFieldsSet = new Set<String> {
				'CurrencyIsoCode', 'IsDeleted', 'IsLocked', 'LastReferencedDate', 'LastViewedDate', 'MayEdit', 'SystemModstamp'
			};

			List<String> variableAssociationSelectedFieldsList = NEO_Rules_Utils.getSelectedFieldsList('NEO_Variable_Association__c', null, excludeFieldsSet, true);

			// Get child variable select field
			List<String> childVariableSelectedFieldsList = NEO_Rules_Utils.getSelectedFieldsList('NEO_Variable__c', includeFieldsSet, excludeFieldsSet, true);

			// Get rule select fields
			List<String> ruleSelectedFieldsList = NEO_Rules_Utils.getSelectedFieldsList('NEO_Rule__c', includeFieldsSet, excludeFieldsSet, true);

			includeFieldsSet = new Set<String> {
				'CreatedBy.Name', 'LastModifiedBy.Name', 'RecordType.DeveloperName', 'Parent_Variable__r.Variable_Label__c', 'Parent_Variable__r.Variable_API_Name__c',
				'RecordType.Name',
				'(SELECT ' + String.join(variableAssociationSelectedFieldsList, ', ') + ' FROM NEO_Variable_Associations1__r ORDER BY NEO_Child_Object_Label__c, NEO_Child_Object_API_Name__c)',
				'(SELECT ' + String.join(childVariableSelectedFieldsList, ', ') + ' FROM NEO_Variables__r ORDER BY Variable_Label__c, Variable_API_Name__c)',
				'(SELECT ' + String.join(ruleSelectedFieldsList, ', ') + ' FROM NEO_Rules__r ORDER BY Name DESC, NEO_Active__c)'
			};
			selectedFieldsList = NEO_Rules_Utils.getSelectedFieldsList('NEO_Variable__c', includeFieldsSet, excludeFieldsSet, true);
			strSOQL = 'SELECT ' + String.join(selectedFieldsList, ', ') + ' FROM NEO_Variable__c WHERE Id = :recordId';
			List<NEO_Variable__c> variableList = Database.query(strSOQL);

			if (variableList.size() > 0) {
				variableObj = variableList.get(0);
			}
		} else {
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

			variableObj = new NEO_Variable__c(Type__c = 'Object', NEO_Active__c = true);
			variableObj.Variable_Label__c = inputVarObj.Variable_Label__c;
			variableObj.Variable_API_Name__c = inputVarObj.Variable_API_Name__c;
			variableObj.NEO_External_ID__c = inputVarObj.Variable_API_Name__c;
			variableObj.RecordTypeId = rtMaps.get('NEO_Object_Variable');
		}

		// Get variable association selected fields
		List<VariableAssociationWrapper> variableAssociationWrapperList = new List<VariableAssociationWrapper>();
		if (variableObj.NEO_Variable_Associations1__r <> null) {
			for (NEO_Variable_Association__c tempVariableAssociationRow : variableObj.NEO_Variable_Associations1__r) {
				VariableAssociationWrapper variableAssociationWrapperObj = new VariableAssociationWrapper(tempVariableAssociationRow);
				variableAssociationWrapperObj.strChildLabel = tempVariableAssociationRow.NEO_Child_Object_Label__c;
				variableAssociationWrapperObj.strChildApiName = tempVariableAssociationRow.NEO_Child_Object_API_Name__c;

				variableAssociationWrapperList.add(variableAssociationWrapperObj);
			}
		}

		// Get child variable selected fields
		List<VariableWrapper> fieldsWrapperList = new List<VariableWrapper>();
		if (variableObj.NEO_Variables__r <> null) {
			for (NEO_Variable__c tempFieldVariableRow : variableObj.NEO_Variables__r) {
				VariableWrapper tempVariableWrapperObj = new VariableWrapper(tempFieldVariableRow);
				tempVariableWrapperObj.strFullApiName = tempFieldVariableRow.Variable_API_Name__c;
				tempVariableWrapperObj.strShowName = tempFieldVariableRow.Variable_Label__c + ' [' + tempVariableWrapperObj.strFullApiName + ']';

				fieldsWrapperList.add(tempVariableWrapperObj);
			}
		}

		// Get rules list
		List<RuleWrapper> ruleWrapperList = new List<RuleWrapper>();
		if (variableObj.NEO_Rules__r <> null) {
			for (NEO_Rule__c ruleObj : variableObj.NEO_Rules__r) {
				ruleWrapperList.add(new RuleWrapper(ruleObj));
			}
		}

		List<StepWrapper> stepWrapperList = new List<StepWrapper>();
		if (String.isNotBlank(variableObj.Variable_API_Name__c)) {
			stepWrapperList.add(new StepWrapper(null, new List<String> { variableObj.Variable_API_Name__c }, new List<String> { variableObj.Variable_Label__c }));
		}

		// Cache all object variable
		List<NEO_Variable__c> objectVariableCache = [SELECT Id, Variable_API_Name__c FROM NEO_Variable__c WHERE RecordTypeId = :variableObj.RecordTypeId];

		// Return back
		Map<String, Object> returnMaps = new Map<String, Object> {
			'labelMaps' => NEO_Rules_Utils.getFieldLabelMapByObjectName('NEO_Variable__c'),
			'variableAssociationLabelMaps' => NEO_Rules_Utils.getFieldLabelMapByObjectName('NEO_Variable_Association__c'),
			'ruleLabelMaps' => NEO_Rules_Utils.getFieldLabelMapByObjectName('NEO_Rule__c'),
			'variableWrapperList' => createObjectVariableWrapperList(variableObj),
			'variableAssociationWrapperList' => variableAssociationWrapperList,
			'fieldsWrapperList' => fieldsWrapperList,
			'variableObj' => variableObj,
			'oldVariableObj' => variableObj.clone(true, true, true, true),
			'objectVariableCache' => objectVariableCache,
			'variableWrapperObj' => new VariableWrapper(variableObj),
			'stepWrapperList' => stepWrapperList,
			'keyPrefix' => NEO_Variable__c.SObjectType.getDescribe().getKeyPrefix(),
			'ruleWrapperList' => ruleWrapperList
		};
		return returnMaps;
	}

	@AuraEnabled
	public static Map<String, Object> loadAllVariableAssociationWrapperList(NEO_Variable__c variableObj, String variableAssociationWrapperListJSON, String objectVariableCacheJSON) {
		// Get selected variable association wrapper list
		List<VariableAssociationWrapper> variableAssociationWrapperList = new List<VariableAssociationWrapper>();
		if (String.isNotBlank(variableAssociationWrapperListJSON)) {
			variableAssociationWrapperList = (List<VariableAssociationWrapper>)JSON.deserialize(variableAssociationWrapperListJSON, List<VariableAssociationWrapper>.class);
		}

		// Get all object variable
		List<NEO_Variable__c> objectVariableCache = new List<NEO_Variable__c>();
		if (String.isNotBlank(objectVariableCacheJSON)) {
			objectVariableCache = (List<NEO_Variable__c>)JSON.deserialize(objectVariableCacheJSON, List<NEO_Variable__c>.class);
		}

		Set<String> filterRelationshipNameSet = new Set<String>();
		for (VariableAssociationWrapper variableAssociationWrapperObj : variableAssociationWrapperList) {
			if (String.isBlank(variableAssociationWrapperObj.variableAssociationObj.NEO_Relationship_Name__c)) {
				continue;
			}
			filterRelationshipNameSet.add(variableAssociationWrapperObj.variableAssociationObj.NEO_Relationship_Name__c);
		}

		Set<String> objectVariableSet = new Set<String>();
		for (NEO_Variable__c objectVariableObj : objectVariableCache) {
			objectVariableSet.add(objectVariableObj.Variable_API_Name__c);
		}

		// Return back
		Map<String, Object> returnMaps = new Map<String, Object> {
			'allVariableAssociationWrapperList' => createVariableAssociationWrapperList(variableObj, filterRelationshipNameSet, objectVariableSet),
			'variableAssociationWrapperListJSON' => variableAssociationWrapperList,
			'filterRelationshipNameSet' => filterRelationshipNameSet
		};
		return returnMaps;
	}

	@AuraEnabled
	public static Map<String, Object> loadAllFieldsWrapperList(NEO_Variable__c variableObj, String selectedFieldsWrapperListJSON) {
		// Get selected field variable wrapper list
		List<VariableWrapper> selectedFieldVariableWrapperList = new List<VariableWrapper>();
		if (String.isNotBlank(selectedFieldsWrapperListJSON)) {
			selectedFieldVariableWrapperList = (List<VariableWrapper>)JSON.deserialize(selectedFieldsWrapperListJSON, List<VariableWrapper>.class);
		}

		Set<String> selectedFieldsSet = new Set<String>();
		for (VariableWrapper fieldVariableWrapperObj : selectedFieldVariableWrapperList) {
			String strLabel = fieldVariableWrapperObj.variableObj.Variable_Label__c;
			String strValue = fieldVariableWrapperObj.strFullApiName;
			selectedFieldsSet.add(strLabel + '__' + strValue);
		}

		// Return back
		Map<String, Object> returnMaps = new Map<String, Object> {
			'allFieldsWrapperList' => createVariableWrapperList(variableObj, selectedFieldsSet, null),
			'selectedFieldsWrapperListJSON' => selectedFieldVariableWrapperList
		};
		return returnMaps;
	}

	@AuraEnabled
	public static Map<String, Object> gotoChildObject(NEO_Variable__c variableObj, 
													  String selectVariableApiName,
													  List<StepWrapper> stepWrapperList,
													  String selectedFieldsWrapperListJSON) {
		List<VariableWrapper> allFieldsWrapperList = new List<VariableWrapper>(); 

		List<VariableWrapper> variableWrapperList = new List<VariableWrapper>();
		if (String.isNotBlank(selectVariableApiName) && stepWrapperList.size() > 0) {
			List<String> strObjectNameList = stepWrapperList.get(stepWrapperList.size() - 1).strObjectTypeList;

			// Get lookup object type list
			List<Schema.sObjectType> lookupSObjectTypeList = new List<Schema.sObjectType>();
			for (Schema.DescribeSObjectResult r : Schema.describeSObjects(strObjectNameList)) {
				Map<String, Schema.SObjectField> sobjectTypeFieldsMaps = r.fields.getMap();
				if (sobjectTypeFieldsMaps.containsKey(selectVariableApiName.toLowerCase())) {
					Schema.DescribeFieldResult dfr = sobjectTypeFieldsMaps.get(selectVariableApiName.toLowerCase()).getDescribe();
					lookupSObjectTypeList = dfr.getReferenceTo();
				}
			}

			if (lookupSObjectTypeList.size() > 0) {
				List<String> tempStrObjectNameList = new List<String>();
				List<String> tempStrObjectLabelList = new List<String>();

				for (Schema.sObjectType sObjectTypeObj : lookupSObjectTypeList) {
					Schema.DescribeSObjectResult r = sObjectTypeObj.getDescribe();
					String strLookupObjectName = r.getName();
					String strLookupObjectLabel = r.getLabel();

					tempStrObjectNameList.add(strLookupObjectName);
					tempStrObjectLabelList.add(strLookupObjectLabel);
				}

				stepWrapperList.add(new StepWrapper(selectVariableApiName, tempStrObjectNameList, tempStrObjectLabelList));

				String strLookups = '';
				for (StepWrapper stepWrapperObj: stepWrapperList) {
					String tempStrLookupName = stepWrapperObj.strLookupName;
					if (String.isBlank(tempStrLookupName)) {
						continue;
					}

					if (tempStrLookupName.endsWithIgnoreCase('Id')) {
						tempStrLookupName = tempStrLookupName.removeEndIgnoreCase('Id');

					} else if (tempStrLookupName.endsWithIgnoreCase('__c')) {
						tempStrLookupName = tempStrLookupName.removeEndIgnoreCase('__c') + '__r';
					}

					if (String.isNotBlank(strLookups)) {
						strLookups += '.';
					}
					strLookups += tempStrLookupName;
				}

				// Get selected field variable wrapper list
				List<VariableWrapper> selectedFieldVariableWrapperList = new List<VariableWrapper>();
				if (String.isNotBlank(selectedFieldsWrapperListJSON)) {
					selectedFieldVariableWrapperList = (List<VariableWrapper>)JSON.deserialize(selectedFieldsWrapperListJSON, List<VariableWrapper>.class);
				}

				Set<String> selectedFieldsSet = new Set<String>();
				for (VariableWrapper fieldVariableWrapperObj : selectedFieldVariableWrapperList) {
					String strLabel = fieldVariableWrapperObj.variableObj.Variable_Label__c;
					String strValue = fieldVariableWrapperObj.strFullApiName;
					selectedFieldsSet.add(strLabel + '__' + strValue);
				}
				
				for (String strLookupObjectName : tempStrObjectNameList) {
					variableWrapperList.addAll(createVariableWrapperListByApiName(strLookupObjectName, selectedFieldsSet, strLookups, selectVariableApiName));
				}
			}
		}

		// Return back
		Map<String, Object> returnMaps = new Map<String, Object> {
			'allFieldsWrapperList' => variableWrapperList,
			'stepWrapperList' => stepWrapperList
		};
		return returnMaps;
	}

	@AuraEnabled
	public static Map<String, Object> gotoStepIndex(NEO_Variable__c variableObj,
													  Integer stepIndex,
													  List<StepWrapper> stepWrapperList,
													  String selectedFieldsWrapperListJSON) {
		List<StepWrapper> newStepWrapperList = new List<StepWrapper>();
		List<VariableWrapper> variableWrapperList = new List<VariableWrapper>();

		if (stepWrapperList.size() > 0) {
			Integer k = 0;
			for (StepWrapper tempSetpWrapperObj : stepWrapperList) {
				if (k > stepIndex) {
					break;
				}
				newStepWrapperList.add(tempSetpWrapperObj);
				++k;
			}

			StepWrapper tempSetpWrapperObj = newStepWrapperList.get(newStepWrapperList.size() - 1);
			String strLookupFieldName = tempSetpWrapperObj.strLookupName;
			List<String> strObjectTypeList = tempSetpWrapperObj.strObjectTypeList;
			List<String> strObjectNameLabelList = tempSetpWrapperObj.strObjectTypeLabelList;

			// Create lookup string
			String strLookups = '';
			for (StepWrapper stepWrapperObj : newStepWrapperList) {
				String tempStrLookupName = stepWrapperObj.strLookupName;
				if (String.isBlank(tempStrLookupName)) {
					continue;
				}

				if (tempStrLookupName.endsWithIgnoreCase('Id')) {
					tempStrLookupName = tempStrLookupName.removeEndIgnoreCase('Id');

				} else if (tempStrLookupName.endsWithIgnoreCase('__c')) {
					tempStrLookupName = tempStrLookupName.removeEndIgnoreCase('__c') + '__r';
				}

				if (String.isNotBlank(strLookups)) {
					strLookups += '.';
				}
				strLookups += tempStrLookupName;
			}

			// Get selected field variable wrapper list
			List<VariableWrapper> selectedFieldVariableWrapperList = new List<VariableWrapper>();
			if (String.isNotBlank(selectedFieldsWrapperListJSON)) {
				selectedFieldVariableWrapperList = (List<VariableWrapper>)JSON.deserialize(selectedFieldsWrapperListJSON, List<VariableWrapper>.class);
			}

			Set<String> selectedFieldsSet = new Set<String>();
			for (VariableWrapper fieldVariableWrapperObj : selectedFieldVariableWrapperList) {
				String strLabel = fieldVariableWrapperObj.variableObj.Variable_Label__c;
				String strValue = fieldVariableWrapperObj.strFullApiName;
				selectedFieldsSet.add(strLabel + '__' + strValue);
			}

			for (String strObjectType : strObjectTypeList) {
				variableWrapperList.addAll(createVariableWrapperListByApiName(strObjectType, selectedFieldsSet, strLookups, strLookupFieldName));
			}
		}

		// Return back
		Map<String, Object> returnMaps = new Map<String, Object> {
			'stepIndex' => stepIndex,
			'allFieldsWrapperList' => variableWrapperList,
			'stepWrapperList' => newStepWrapperList
		};
		return returnMaps;
	}

	@AuraEnabled
	public static Map<String, Object> tSave(NEO_Variable__c variableObj,
													  String variableAssociationWrapperListJSON,
													  String fieldsWrapperListJSON,
													  String objectVariableCacheJSON) {
		String  strStatusMsg = '';
        String strStatusCode = '';

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

        List<VariableAssociationWrapper> variableAssociationWrapperList = new List<VariableAssociationWrapper>();
        List<VariableWrapper> fieldsWrapperList = new List<VariableWrapper>();

        List<NEO_Variable__c> objectVariableCache = new List<NEO_Variable__c>();

        Savepoint sp = Database.setSavepoint();
		try {

			if (variableObj <> null) {
				upsert variableObj;
			}

			// Create exist object maps
			Map<String, NEO_Variable__c> objectVariableCacheMaps = new Map<String, NEO_Variable__c>();
			for (NEO_Variable__c tempVariableObj : [SELECT Id, Variable_Label__c, Variable_API_Name__c FROM NEO_Variable__c WHERE RecordTypeId = :rtMaps.get('NEO_Object_Variable')]) {
				objectVariableCacheMaps.put(tempVariableObj.Variable_API_Name__c, tempVariableObj);
				objectVariableCacheMaps.put(tempVariableObj.Id, tempVariableObj);
			}

			// Object association list
			List<NEO_Variable_Association__c> variableAssociationObjList = new List<NEO_Variable_Association__c>(); 
			if (String.isNotBlank(variableAssociationWrapperListJSON)) {
				List<VariableAssociationWrapper> tempVariableAssociationWrapperList = (List<VariableAssociationWrapper>)JSON.deserialize(variableAssociationWrapperListJSON, List<VariableAssociationWrapper>.class);
				
				List<NEO_Variable__c> childObjectVariableList = new List<NEO_Variable__c>();

				for (VariableAssociationWrapper variableAssociationWrapperObj : tempVariableAssociationWrapperList) {
					String strChildApiName = variableAssociationWrapperObj.strChildApiName;
					if (String.isNotBlank(strChildApiName) && 
						!objectVariableCacheMaps.containsKey(strChildApiName)) {
						childObjectVariableList.add(new NEO_Variable__c(
							Type__c = 'Object',
							Variable_API_Name__c = strChildApiName,
							Variable_Label__c = variableAssociationWrapperObj.strChildLabel,
							NEO_Active__c = true,
							RecordTypeId = rtMaps.get('NEO_Object_Variable')
						));
					}
				}

				if (childObjectVariableList.size() > 0) {
					insert childObjectVariableList;

					for (NEO_Variable__c tempVariableObj : childObjectVariableList) {
						objectVariableCacheMaps.put(tempVariableObj.Variable_API_Name__c, tempVariableObj);
						objectVariableCacheMaps.put(tempVariableObj.Id, tempVariableObj);
					}
				}

				for (VariableAssociationWrapper variableAssociationWrapperObj : tempVariableAssociationWrapperList) {
					String strChildApiName = variableAssociationWrapperObj.strChildApiName;
					if (String.isBlank(strChildApiName) ||
						!objectVariableCacheMaps.containsKey(strChildApiName)) {
						continue;
					}

					variableAssociationObjList.add(new NEO_Variable_Association__c(
						Id = variableAssociationWrapperObj.variableAssociationObj.Id,
						NEO_Lookup_Name__c = variableAssociationWrapperObj.variableAssociationObj.NEO_Lookup_Name__c,
						NEO_Relationship_Name__c = variableAssociationWrapperObj.variableAssociationObj.NEO_Relationship_Name__c,
						NEO_Parent_Object__c = variableObj.Id,
						NEO_Child_Object__c = objectVariableCacheMaps.get(strChildApiName).Id
					));
				}
			}

			// Field variable list
			List<NEO_Variable__c> fieldVariableList = new List<NEO_Variable__c>();
			if (String.isNotBlank(fieldsWrapperListJSON)) {
				List<VariableWrapper> tempFieldsVariableWrapperList = (List<VariableWrapper>)JSON.deserialize(fieldsWrapperListJSON, List<VariableWrapper>.class);
				
				for (VariableWrapper variableWrapperObj : tempFieldsVariableWrapperList) {
					NEO_Variable__c childVariableObj = new NEO_Variable__c(
						Id = variableWrapperObj.variableObj.Id,
						Variable_Label__c = variableWrapperObj.variableObj.Variable_Label__c,
						Variable_API_Name__c = variableWrapperObj.strFullApiName,
						Parent_Variable__c = variableObj.Id,
						NEO_Active__c = true,
						NEO_Data_Source__c = variableWrapperObj.variableObj.NEO_Data_Source__c,
						NEO_Value_Key__c = variableWrapperObj.variableObj.NEO_Value_Key__c,
						Type__c = variableWrapperObj.variableObj.Type__c,
						NEO_Variable_Data_Type__c = variableWrapperObj.variableObj.NEO_Variable_Data_Type__c,
						RecordTypeId = rtMaps.get('NEO_Field_Variable')
					);

					fieldVariableList.add(childVariableObj);
				}
			}

			// Upsert variable association
			if (variableAssociationObjList.size() > 0) {
				upsert variableAssociationObjList;

				for (NEO_Variable_Association__c tempVariableAssociationRow : variableAssociationObjList) {
					if (!objectVariableCacheMaps.containsKey(tempVariableAssociationRow.NEO_Child_Object__c)) {
						continue;
					}

					NEO_Variable__c tempChildVariableObj = objectVariableCacheMaps.get(tempVariableAssociationRow.NEO_Child_Object__c);

					VariableAssociationWrapper variableAssociationWrapperObj = new VariableAssociationWrapper(tempVariableAssociationRow);
					variableAssociationWrapperObj.strChildLabel = tempChildVariableObj.Variable_Label__c;
					variableAssociationWrapperObj.strChildApiName = tempChildVariableObj.Variable_API_Name__c;

					variableAssociationWrapperList.add(variableAssociationWrapperObj);
				}
			}
			List<NEO_Variable_Association__c> deletedVariableAssociationList = [SELECT Id FROM NEO_Variable_Association__c WHERE NEO_Parent_Object__c = :variableObj.Id AND Id NOT IN :variableAssociationObjList];
			if (deletedVariableAssociationList.size() > 0) {
				delete deletedVariableAssociationList;
			}

			// Upsert field variable
			if (fieldVariableList.size() > 0) {
				upsert fieldVariableList;

				for (NEO_Variable__c tempFieldVariableRow : fieldVariableList) {
					VariableWrapper tempVariableWrapperObj = new VariableWrapper(tempFieldVariableRow);
					tempVariableWrapperObj.strFullApiName = tempFieldVariableRow.Variable_API_Name__c;
					tempVariableWrapperObj.strShowName = tempFieldVariableRow.Variable_Label__c + ' [' + tempVariableWrapperObj.strFullApiName + ']';

					fieldsWrapperList.add(tempVariableWrapperObj);
				}
			}
			List<NEO_Variable__c> deletedVariableList = [SELECT Id FROM NEO_Variable__c WHERE Parent_Variable__c = :variableObj.Id AND Id NOT IN :fieldVariableList];
			if (deletedVariableList.size() > 0) {
				delete deletedVariableList;
			}

			strStatusCode = 'success';
        	strStatusMsg = System.Label.NEO_RE_Save_Successfully;

		} catch(Exception e) {
			strStatusCode = 'error';
        	strStatusMsg = e.getMessage();
        	Database.rollback(sp);
		}

		// Return back
		Map<String, Object> returnMaps = new Map<String, Object> {
			'variableObj' => variableObj,
			'oldVariableObj' => variableObj.clone(true, true, true, true),
			'variableWrapperObj' => new VariableWrapper(variableObj),
			'variableAssociationWrapperList' => variableAssociationWrapperList,
			'fieldsWrapperList' => fieldsWrapperList,
			'objectVariableCache' => objectVariableCache,
			'strStatusCode' => strStatusCode,
			'strStatusMsg' => strStatusMsg
		};
		return returnMaps;
	}

	public static List<VariableWrapper> createObjectVariableWrapperList(NEO_Variable__c variableObj) {
		List<VariableWrapper> variableWrapperList = new List<VariableWrapper>();
		Map<String, Schema.SObjectType> sObjectTypeMapping = NEO_Rules_Constants.sObjectTypeMapping;
		Map<String, VariableWrapper> variableWrapperMaps = new Map<String, VariableWrapper>();
		List<String> keysList = new List<String>();

		for (Schema.SObjectType sObjectTypeRow : sObjectTypeMapping.values()) {
			Schema.DescribeSObjectResult dsr = sObjectTypeRow.getDescribe();

			String strName = dsr.getName();
			String strLabel = dsr.getLabel();
			if (strName.endsWithIgnoreCase('__ChangeEvent') ||
				strName.endsWithIgnoreCase('Share') ||
				strName.endsWithIgnoreCase('__History') ||
				strName.endsWithIgnoreCase('History') ||
				strName.endsWithIgnoreCase('__Feed') ||
				dsr.isCustomSetting()) {
				continue;
			}

			String strKey = strName + '__' + strLabel;
			keysList.add(strKey);

			NEO_Variable__c tempVariableObj = new NEO_Variable__c(Variable_API_Name__c = strName, Variable_Label__c = strLabel);
			variableWrapperMaps.put(strKey, new VariableWrapper(tempVariableObj));
		}

		keysList.sort();
		for (String strKey : keysList) {
			if (!variableWrapperMaps.containsKey(strKey)) {
				continue;
			}
			variableWrapperList.add(variableWrapperMaps.get(strKey));
		}

		return variableWrapperList;
	}

	public static List<VariableAssociationWrapper> createVariableAssociationWrapperList(NEO_Variable__c variableObj, Set<String> filterRelationshipNameSet, Set<String> objectVariableCache) {
		List<VariableAssociationWrapper> variableAssociationWrapperList = new List<VariableAssociationWrapper>();
		if (variableObj == null || String.isBlank(variableObj.Variable_API_Name__c)) {
			return variableAssociationWrapperList;
		}

		String strVariableAPIName = variableObj.Variable_API_Name__c;
		Map<String, VariableAssociationWrapper> variableAssociationWrapperMaps = new Map<String, VariableAssociationWrapper>();
		List<String> keysList = new List<String>();

		for (Schema.DescribeSObjectResult r : Schema.describeSObjects(new List<String> { strVariableAPIName })) {
			List<Schema.ChildRelationship> c = r.getChildRelationships();
			for (Schema.ChildRelationship crRow : c) {
				Schema.DescribeSObjectResult dsr = crRow.getChildSObject().getDescribe();

				String strChildLabel = dsr.getLabel();
				String strChildApiName = dsr.getName();
				String strRelationshipName = crRow.getRelationshipName();

				if (String.isBlank(strRelationshipName) || 
					filterRelationshipNameSet.contains(strRelationshipName)) {
					continue;
				}

				if (strChildApiName.endsWithIgnoreCase('__ChangeEvent') ||
					strChildApiName.endsWithIgnoreCase('Share') ||
					strChildApiName.endsWithIgnoreCase('__History') ||
					strChildApiName.endsWithIgnoreCase('History') ||
					strChildApiName.endsWithIgnoreCase('__Feed') ||
					dsr.isCustomSetting()) {
					continue;
				}

				String strKey = strChildLabel + '__' + strChildApiName;
				keysList.add(strKey);

				NEO_Variable_Association__c variableAssociationObj = new NEO_Variable_Association__c();
				variableAssociationObj.NEO_Lookup_Name__c = crRow.getField().getDescribe().getName();
				variableAssociationObj.NEO_Relationship_Name__c = strRelationshipName;

				VariableAssociationWrapper variableAssociationWrapperObj = new VariableAssociationWrapper(variableAssociationObj);
				variableAssociationWrapperObj.strParentApiName = strVariableAPIName;
				variableAssociationWrapperObj.strChildLabel = strChildLabel;
				variableAssociationWrapperObj.strChildApiName = strChildApiName;

				variableAssociationWrapperMaps.put(strKey, variableAssociationWrapperObj);
			}
		}

		if (keysList.size() > 0) {
			keysList.sort();
			for (String strKey : keysList) {
				if (!variableAssociationWrapperMaps.containsKey(strKey)) {
					continue;
				}
				variableAssociationWrapperList.add(variableAssociationWrapperMaps.get(strKey));
			}
		}

		return variableAssociationWrapperList;
	}

	public static List<VariableWrapper> createVariableWrapperList(NEO_Variable__c variableObj, Set<String> selectedFieldsSet, String strLookups) {
		String strVariableApiName = '';
		if (variableObj <> null && String.isNotBlank(variableObj.Variable_API_Name__c)) {
			strVariableApiName = variableObj.Variable_API_Name__c;
		}

		return createVariableWrapperListByApiName(strVariableApiName, selectedFieldsSet, strLookups, null);
	}

	public static List<VariableWrapper> createVariableWrapperListByApiName(String strVariableApiName, Set<String> selectedFieldsSet, String strLookups, String strLookupFieldName) {
		List<VariableWrapper> variableWrapperList = new List<VariableWrapper>();
		if (String.isBlank(strVariableApiName)) {
			return variableWrapperList;
		}

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

		Map<String, VariableWrapper> variableWrapperMaps = new Map<String, VariableWrapper>();
		List<String> keysList = new List<String>();

		Set<String> includeFieldsSet = new Set<String> {
			'AccountId', 'IsActive', 'Address', 'Alias', 'CallCenterId', 'City', 'CompanyName', 'ContactId',
			'Country', 'CreatedById', 'CreatedDate', 'DefaultCurrencyIsoCode', 'Department', 'Division', 'Email', 'EmployeeNumber', 'Extension', 'Fax',
			'FirstName', 'Name', 'LastModifiedDate', 'LastModifiedById', 'LastName', 'LocaleSidKey', 'ManagerId', 'MobilePhone',
			'Phone', 'ProfileId', 'UserRoleId', 'State', 'Street', 'TimeZoneSidKey', 'Title', 'Id', 'UserType', 'Username', 'PostalCode'
		};

		Set<String> includeOwnerOnlyFieldsSet = new Set<String> {
			'Id', 'Name', 'Email', 'Type', 'IsActive', 'Alias', 'ProfileId', 'UserRoleId'
		};

		for (Schema.DescribeSObjectResult r : Schema.describeSObjects(new List<String> { strVariableApiName })) {
			String tempStrTargetObjectLabel = r.getLabel();
			String tempStrTargetObjectName = r.getName();

			Map<String, Schema.SObjectField> sobjectTypeFieldsMaps = r.fields.getMap();
			for (Schema.SObjectField tempSObjectTypeFieldRow : sobjectTypeFieldsMaps.values()) {
				Schema.DescribeFieldResult dfr = tempSObjectTypeFieldRow.getDescribe();

				String strFieldLabel = dfr.getLabel();
				String strFieldName = dfr.getName();
				String strFullApiName = strFieldName;
				String strKey = strFieldLabel + '__' + strFullApiName;

				String strDataType = NEO_Rules_Utils.getFieldTypeByName(strVariableApiName, strFieldName, false);
				if (String.isNotBlank(strDataType)) {
					strDataType = strDataType.toLowerCase().capitalize();
				}

				if ((strLookupFieldName == 'OwnerId' && !includeOwnerOnlyFieldsSet.contains(strFieldName)) ||
					(strVariableApiName == 'User' && !strFieldName.endsWithIgnoreCase('__c') && !includeFieldsSet.contains(strFieldName)) ||
					(selectedFieldsSet.contains(strKey) && strDataType <> NEO_Rules_Constants.NEO_DATA_TYPE_REFERENCE.toLowerCase().capitalize()) ||
					(strDataType == 'Base64')) {
					continue;
				}

				keysList.add(strKey);
				Boolean isLookup = false;
				if (strDataType == NEO_Rules_Constants.NEO_DATA_TYPE_REFERENCE.toLowerCase().capitalize()) {
					// Lookup
					if (((strVariableApiName == 'Attachment' || strVariableApiName == 'Note') && strFieldName == 'ParentId') || 
						(strFieldName == 'LinkedEntityId')) {
						isLookup = false;
						strDataType = NEO_Rules_Constants.NEO_DATA_TYPE_LOOKUP + '(SObject)';

					} else {
						strDataType = NEO_Rules_Constants.NEO_DATA_TYPE_LOOKUP + dfr.getReferenceTo();
						isLookup = true;
					}

				} else if (strDataType == NEO_Rules_Constants.NEO_DATA_TYPE_BOOLEAN.toLowerCase().capitalize()) {
					strDataType = NEO_Rules_Constants.NEO_DATA_TYPE_CHECKBOX;

				} else if (strDataType == NEO_Rules_Constants.NEO_DATA_TYPE_STRING.toLowerCase().capitalize()) {
					strDataType = NEO_Rules_Constants.NEO_DATA_TYPE_TEXT;
				}

				if (String.isNotBlank(strLookups)) {
					strFullApiName = strLookups + '.' + strFullApiName;
				}

				NEO_Variable__c fieldVariableObj = new NEO_Variable__c();
				fieldVariableObj.Variable_Label__c = strFieldLabel;
				fieldVariableObj.Variable_API_Name__c = strFieldName;
				fieldVariableObj.NEO_Variable_Data_Type__c = strDataType;
				fieldVariableObj.RecordTypeId = rtMaps.get('NEO_Field_Variable');
				fieldVariableObj.NEO_Active__c = true;
				fieldVariableObj.Type__c = 'Field';

				VariableWrapper fieldVariableWrapperObj = new VariableWrapper(fieldVariableObj);
				fieldVariableWrapperObj.isLookup = isLookup;
				fieldVariableWrapperObj.showSelectedCheckbox = !selectedFieldsSet.contains(strKey);
				fieldVariableWrapperObj.strFullApiName = strFullApiName;
				fieldVariableWrapperObj.strShowName = tempStrTargetObjectLabel + ': ' + strFieldLabel + ' [' + strFullApiName + ']';
				fieldVariableWrapperObj.strParentLabel = tempStrTargetObjectLabel;
				fieldVariableWrapperObj.strParentName = tempStrTargetObjectName;

				variableWrapperMaps.put(strKey, fieldVariableWrapperObj);
			}
		}

		if (keysList.size() > 0) {
			keysList.sort();
			for (String strKey : keysList) {
				if (!variableWrapperMaps.containsKey(strKey)) {
					continue;
				}
				variableWrapperList.add(variableWrapperMaps.get(strKey));
			}
		}

		return variableWrapperList;
	}

	class VariableWrapper {
		@AuraEnabled
		public Boolean isSelected { get; set; }
		@AuraEnabled
		public Boolean showSelectedCheckbox { get; set; }
		@AuraEnabled
		public String strParentLabel { get; set; }
		@AuraEnabled
		public String strParentName { get; set; }
		@AuraEnabled
		public String strShowName { get; set; }
		@AuraEnabled
		public NEO_Variable__c variableObj { get; set; }
		@AuraEnabled
		public List<NEO_Rules_Constants.MySelectOption> keyValueOptions { get; set; }
		@AuraEnabled
		public List<NEO_Rules_Constants.MySelectOption> dataSourceOptions { get; set; }
		@AuraEnabled
		public String strCreatedDate { get; set; }
		@AuraEnabled
		public String strCreatedByName { get; set; }
		@AuraEnabled
		public String strLastModifiedDate { get; set; }
		@AuraEnabled
		public String strLastModifiedByName { get; set; }
		@AuraEnabled
		public Boolean isLookup { get; set; }
		@AuraEnabled
		public String strFullApiName { get; set; }

		public VariableWrapper() {
			this.isSelected = false;
			this.showSelectedCheckbox = true;
			this.variableObj = new NEO_Variable__c();
			this.keyValueOptions = NEO_Rules_Utils.getPicklistOptionsByObjectName('NEO_Variable__c', 'NEO_Value_Key__c');
			this.dataSourceOptions = NEO_Rules_Utils.getPicklistOptionsByObjectName('NEO_Variable__c', 'NEO_Data_Source__c');
		}

		public VariableWrapper(NEO_Variable__c variableObj) {
			this.isSelected = false;
			this.showSelectedCheckbox = true;
			this.variableObj = variableObj;
			this.keyValueOptions = NEO_Rules_Utils.getPicklistOptionsByObjectName('NEO_Variable__c', 'NEO_Value_Key__c');
			this.dataSourceOptions = NEO_Rules_Utils.getPicklistOptionsByObjectName('NEO_Variable__c', 'NEO_Data_Source__c');
			this.strCreatedDate = variableObj.CreatedDate <> null ? String.valueOf(variableObj.CreatedDate) : '';
			this.strCreatedByName = variableObj.CreatedBy.Name;
			this.strLastModifiedDate = variableObj.LastModifiedDate <> null ? String.valueOf(variableObj.LastModifiedDate) : '';
			this.strLastModifiedByName = variableObj.LastModifiedBy.Name;
		}
	}

	class VariableAssociationWrapper {
		@AuraEnabled
		public Boolean isSelected { get; set; }
		@AuraEnabled
		public String strParentApiName { get; set; }
		@AuraEnabled
		public String strChildApiName { get; set; }
		@AuraEnabled
		public String strChildLabel { get; set; }
		@AuraEnabled
		public NEO_Variable_Association__c variableAssociationObj { get; set; }

		public VariableAssociationWrapper() {
			this.isSelected = false;
			this.variableAssociationObj = new NEO_Variable_Association__c();
		}

		public VariableAssociationWrapper(NEO_Variable_Association__c variableAssociationObj) {
			this.isSelected = false;
			this.variableAssociationObj = variableAssociationObj;
		}
	}

	class StepWrapper {
		@AuraEnabled
		public String strLookupName { get; set; }
		@AuraEnabled
		public String strObjectType { get; set; }
		@AuraEnabled
		public List<String> strObjectTypeList { get; set; }
		@AuraEnabled
		public String strObjectTypeLabel { get; set; }
		@AuraEnabled
		public List<String> strObjectTypeLabelList { get; set; }

		public StepWrapper() {
			this.strObjectTypeList = new List<String>();
			this.strObjectTypeLabelList = new List<String>();
		}

		public StepWrapper(String strLookupName, List<String> strObjectTypeList, List<String> strObjectTypeLabelList) {
			this.strLookupName = strLookupName;
			this.strObjectTypeList = strObjectTypeList;
			this.strObjectTypeLabelList = strObjectTypeLabelList;

			if (this.strObjectTypeList <> null) {
				this.strObjectType = String.join(strObjectTypeList, ', ');
			}
			if (this.strObjectTypeLabelList <> null) {
				this.strObjectTypeLabel = String.join(strObjectTypeLabelList, ', ');
			}
		}
	}

	class RuleWrapper {
		@AuraEnabled
		public String strCreatedDate { get; set; }
		@AuraEnabled
		public String strCreatedByName { get; set; }
		@AuraEnabled
		public String strLastModifiedDate { get; set; }
		@AuraEnabled
		public String strLastModifiedByName { get; set; }
		@AuraEnabled
		public NEO_Rule__c ruleObj { get; set; }

		public RuleWrapper() {

		}

		public RuleWrapper(NEO_Rule__c ruleObj) {
			this.ruleObj = ruleObj;
			this.strCreatedDate = ruleObj.CreatedDate <> null ? String.valueOf(ruleObj.CreatedDate) : '';
			this.strCreatedByName = ruleObj.CreatedBy.Name;
			this.strLastModifiedDate = ruleObj.LastModifiedDate <> null ? String.valueOf(ruleObj.LastModifiedDate) : '';
			this.strLastModifiedByName = ruleObj.LastModifiedBy.Name;
		}
	}
}