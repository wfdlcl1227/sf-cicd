global without sharing class NEO_Rules_Utils {

	//public static String strUserKey = Schema.User.getSObjectType().getDescribe().getKeyPrefix();
    //public static String strSpeakerKey = Schema.EM_Speaker_vod__c.getSObjectType().getDescribe().getKeyPrefix();
    public static Map<String, SObject> lookupObjectCache = new Map<String, SObject>();

	// Summarized all records cache
	public static Map<String, List<sObject>> allRecordsCache = new Map<String, List<sObject>>();
	//public static Map<String, NEO_User_Accumulated__c> userAccumulatedRecordsCache = new Map<String, NEO_User_Accumulated__c>();
	//public static Map<String, NEO_Speaker_Accumulated__c> speakerAccumulatedRecordsCache = new Map<String, NEO_Speaker_Accumulated__c>();
	public static Set<String> cacheKeysSet = new Set<String>();

	// Real-time trigger rules portal
	public static Map<String, List<NEO_Rule__c>> rulesRealtimeCheck(List<SObject> objList, String objType, String triggerType) {

		Map<String, List<NEO_Rule__c>> masterObjectRealtimeRuleMaps = new Map<String, List<NEO_Rule__c>>();
		// Trigger Type
		if (triggerType == NEO_Rules_Constants.NEO_INSERT_TRIGGER_TYPE) {
			// Insert
			masterObjectRealtimeRuleMaps = NEO_Rules_Constants.masterObjectRealTimeInsertRuleMaps;

		} else if (triggerType == NEO_Rules_Constants.NEO_UPDATE_TRIGGER_TYPE) {
			// Update
			masterObjectRealtimeRuleMaps = NEO_Rules_Constants.masterObjectRealTimeUpdateRuleMaps;

		} else if (triggerType == NEO_Rules_Constants.NEO_DELETE_TRIGGER_TYPE) {
			// Delete
			masterObjectRealtimeRuleMaps = NEO_Rules_Constants.masterObjectRealTimeDeleteRuleMaps;

		}

		return rulesCheck(objList, objType, masterObjectRealtimeRuleMaps, true);
	}

	// Non Real-time trigger rules portal
	public static Map<String, List<NEO_Rule__c>> rulesNonRealtimeCheck(List<SObject> objList, String objType) {
		Map<String, List<NEO_Rule__c>> masterObjectNonRealtimeRuleMaps = NEO_Rules_Constants.masterObjectRuleMaps;
		return rulesCheck(objList, objType, masterObjectNonRealtimeRuleMaps, false);
	}

	// Layout rule check
	public static Map<String, List<NEO_Rule__c>> rulesLayoutCheck(List<SObject> objList, String objType) {
		Map<String, List<NEO_Rule__c>> layoutRuleMaps = NEO_Rules_Constants.layoutRuleMaps;
		return rulesCheck(objList, objType, layoutRuleMaps, true);
	}

	public static Map<String, List<NEO_Rule__c>> rulesCheck(List<sObject> objList, String objType, Map<String, List<NEO_Rule__c>> masterObjectRuleMaps, Boolean realtimeOrNot) {
		Map<String, List<NEO_Rule__c>> triggeredRulesMaps = new Map<String, List<NEO_Rule__c>>();

		Map<String, NEO_Variable__c> objApiNameVariableMaps = NEO_Rules_Constants.objApiNameVariableMaps;

		List<NEO_Rule__c> objTypeRulesList = new List<NEO_Rule__c>();
		NEO_Variable__c tempMasterObjectVariableSource = (String.isNotBlank(objType) && objApiNameVariableMaps.containsKey(objType)) ? objApiNameVariableMaps.get(objType) : null;
		if (tempMasterObjectVariableSource <> null && 
			masterObjectRuleMaps.containsKey(tempMasterObjectVariableSource.Id)) {
			objTypeRulesList = masterObjectRuleMaps.get(tempMasterObjectVariableSource.Id);
		}

		if (objList.size() < 1 || objTypeRulesList.size() < 1) {
			return triggeredRulesMaps;
		}

		// Get object ids
		Set<Id> objIdsSet = new Set<Id>();
		System.debug(LoggingLevel.DEBUG, '-------->objList: ' + objList);
		for (SObject tempObjRow : objList) {
			Object tempStrId = tempObjRow.get('Id');
			if (tempStrId == null) {
				continue;
			}
			objIdsSet.add(Id.valueOf(String.valueOf(tempStrId)));
		}

		List<SObject> finalObjectList = new List<SObject>();
		List<SObject> oldObjectList = new List<SObject>();
		
		// Update / Non Real-time
		if (objIdsSet.size() > 0) {
			String tempStrSOQL = createQueryString(objType);

			if (String.isNotBlank(tempStrSOQL)) {
				tempStrSOQL += ' WHERE Id IN :objIdsSet';
				System.debug(LoggingLevel.DEBUG, '-------->tempStrSOQL: ' + tempStrSOQL);
				oldObjectList = Database.query(tempStrSOQL);
			}
		}

		Map<String, SObject> oldObjectMaps = new Map<String, SObject>();
		// Rule type
		if (realtimeOrNot) {
			// Real-time
			List<SObject> clonedObjList = new List<SObject>();
			for (SObject objRow : objList) {
				clonedObjList.add(objRow.clone(true, true, true, true));
			}

			// Set lookup values
			setLookupValues(objTypeRulesList, clonedObjList, objType);

			finalObjectList = clonedObjList;

		} else {
			// Non Real-time
			finalObjectList = oldObjectList;
		}

		// Convert to maps
		for (SObject sobjectRow : oldObjectList) {
			oldObjectMaps.put(String.valueOf(sobjectRow.get('Id')), sobjectRow);
		}

		Integer rowIndex = 0;
		for (SObject tempObjRow : finalObjectList) {
			// Get object id
			Object strObjectKey = tempObjRow.get('Id');
			if (strObjectKey == null) {
				strObjectKey = rowIndex;
			}

			// Get old object row
			System.debug(LoggingLevel.DEBUG, '-------->oldObjectMaps: ' + oldObjectMaps);
			System.debug(LoggingLevel.DEBUG, '-------->String.valueOf(strObjectKey): ' + String.valueOf(strObjectKey));

			SObject tempOldObjRow = tempObjRow;
			if (oldObjectMaps.containsKey(String.valueOf(strObjectKey))) {
				tempOldObjRow = oldObjectMaps.get(String.valueOf(strObjectKey));
			} else {
				List<Schema.DescribeSObjectResult> dsrList = Schema.describeSObjects(new List<String> { objType });
				if (dsrList.size() > 0) {
					tempOldObjRow = dsrList.get(0).getSobjectType().newSObject();
				}
			}
			System.debug(LoggingLevel.DEBUG, '-------->tempOldObjRow: ' + tempOldObjRow);

			// Check rules
			List<NEO_Rule__c> triggeredRulesList = executeRules(tempObjRow, tempOldObjRow, objType, objTypeRulesList, oldObjectList);
			
			triggeredRulesMaps.put(String.valueOf(strObjectKey), triggeredRulesList);

			++rowIndex;
		}
		return triggeredRulesMaps;
	}
/*
	public static void cacheUserAccumulated(Set<String> userIdsSet) {
		if (userIdsSet == null || userIdsSet.size() < 1) {
			return;
		}

		cacheKeysSet.addAll(userIdsSet);

		// Cache NEO_User_Accumulated__c
		List<String> selectedFieldsList = getFieldsByObjectName('NEO_User_Accumulated__c');
		String strSOQL = 'SELECT ' + String.join(selectedFieldsList, ', ') + ' FROM NEO_User_Accumulated__c WHERE NEO_User__c IN :userIdsSet';
		
		for (NEO_User_Accumulated__c userAccumulatedRow : Database.query(strSOQL)) {
			if (String.isBlank(userAccumulatedRow.NEO_External_ID__c)) {
				continue;
			}
			userAccumulatedRecordsCache.put(userAccumulatedRow.NEO_External_ID__c, userAccumulatedRow);
		}
	}

	public static void cacheSpeakerAccumulated(Set<String> speakerIdsSet) {
		if (speakerIdsSet == null || speakerIdsSet.size() < 1) {
			return;
		}

		cacheKeysSet.addAll(speakerIdsSet);

		// Cache NEO_Speaker_Accumulated__c
		List<String> selectedFieldsList = getFieldsByObjectName('NEO_Speaker_Accumulated__c');
		String strSOQL = 'SELECT ' + String.join(selectedFieldsList, ', ') + ' FROM NEO_Speaker_Accumulated__c WHERE NEO_Speaker__c IN :speakerIdsSet';
		
		for (NEO_Speaker_Accumulated__c speakerAccumulatedRow : Database.query(strSOQL)) {
			if (String.isBlank(speakerAccumulatedRow.NEO_External_ID__c)) {
				continue;
			}
			speakerAccumulatedRecordsCache.put(speakerAccumulatedRow.NEO_External_ID__c, speakerAccumulatedRow);
		}
	}
*/
	// Assign the lookup field value
	public static void setLookupValues(List<NEO_Rule__c> objTypeRulesList, List<SObject> objList, String objType) {
		Map<String, NEO_Variable__c> NEOVariableMaps = NEO_Rules_Constants.NEOVariableMaps;

		// Get all lookup fields
		Map<String, Set<String>> tempLookupFieldsMap = getLookupFieldsMap(objTypeRulesList);

		// Get lookup field value
		Map<String, Set<String>> tempLookupValuesMap = new Map<String, Set<String>>();
		Map<String, String> tempLookupSObjectTypeMaps = new Map<String, String>();
		Map<String, String> tempLookupNameToLookupFieldsNameMaps = new Map<String, String>();

		for (String strLookupName : tempLookupFieldsMap.keySet()) {
			String tempStrLookupFieldName = '';
			if (strLookupName.endsWith('__r')) {
				// Custom fields
				tempStrLookupFieldName = strLookupName.replaceAll('__r', '__c');
			} else {
				// Standard Field
				tempStrLookupFieldName = strLookupName + 'Id';
			}

			if (!tempLookupNameToLookupFieldsNameMaps.containsKey(strLookupName)) {
				tempLookupNameToLookupFieldsNameMaps.put(strLookupName, tempStrLookupFieldName);
			}

			// Get object type
			if (!tempLookupSObjectTypeMaps.containsKey(strLookupName)) {
				tempLookupSObjectTypeMaps.put(strLookupName, getSObjectTypeByObjectName(objType, tempStrLookupFieldName));
			}

			// Get lookup field value
			String tempObjectValue = null;
			for (SObject objectRow : objList) {
				tempObjectValue = String.valueOf(objectRow.get(tempStrLookupFieldName));
			}

			if (tempObjectValue <> null) {
				if (tempLookupValuesMap.containsKey(strLookupName)) {
					tempLookupValuesMap.get(strLookupName).add(tempObjectValue);

				} else {
					tempLookupValuesMap.put(strLookupName, new Set<String> { tempObjectValue });
				}
			}
		}

		Map<String, SObject> sobjectCache = new Map<String, SObject>();
		// Create Cache
		for (String strLookupName : tempLookupValuesMap.keySet()) {
			if (!tempLookupSObjectTypeMaps.containsKey(strLookupName) || 
				!tempLookupFieldsMap.containsKey(strLookupName) || 
				!tempLookupValuesMap.containsKey(strLookupName)) {
				continue;
			}

			// Fields
			Set<String> tempSelectFieldsSet = new Set<String> { 'Id' };
			tempSelectFieldsSet.addAll(tempLookupFieldsMap.get(strLookupName));

			// Object
			String tempStrObjectName = tempLookupSObjectTypeMaps.get(strLookupName);

			// ID List
			List<String> tempIdsList = new List<String>(tempLookupValuesMap.get(strLookupName));

			// Query Start
			String strSOQL = 'SELECT ' + String.join(new List<String>(tempSelectFieldsSet), ', ') + ' FROM ' + tempStrObjectName + ' WHERE Id IN :tempIdsList';
			for (SObject objectRow : Database.query(strSOQL)) {
				sobjectCache.put(objectRow.Id, objectRow);
			}
		}

		// Assign lookup value
		for (String strLookupName : tempLookupNameToLookupFieldsNameMaps.keySet()) {
			String tempStrLookupFieldName = tempLookupNameToLookupFieldsNameMaps.get(strLookupName);

			Object tempObjectValue = null;
			for (SObject objectRow : objList) {
				tempObjectValue = objectRow.get(tempStrLookupFieldName);

				if (tempObjectValue <> null && sobjectCache.containsKey(String.valueOf(tempObjectValue))) {
					objectRow.putSObject(strLookupName, sobjectCache.get(String.valueOf(tempObjectValue)));
				}
			}
		}
	}

	// Get lookup fields map
	private static Map<String, Set<String>> getLookupFieldsMap(List<NEO_Rule__c> objTypeRulesList) {
		Map<String, NEO_Variable__c> NEOVariableMaps = NEO_Rules_Constants.NEOVariableMaps;

		Map<String, Set<String>> tempLookupFieldsMap = new Map<String, Set<String>>();
		for (NEO_Rule__c ruleRow : objTypeRulesList) {
			if (ruleRow.NEO_Criterias__r == null || ruleRow.NEO_Criterias__r.size() < 1) {
				continue;
			}

			for (NEO_Criteria__c criteriaRow : ruleRow.NEO_Criterias__r) {
				// Variable ID
				String tempStrResourceText = criteriaRow.NEO_Resource_Text__c;
				String tempStrResourceValueText = criteriaRow.NEO_Resource_Value__c;
				String tempStrValueText = criteriaRow.NEO_Value_Text__c;

				Set<String> tempResourceOrValueTextSet = new Set<String>();
				// Get resource variable id
				if (String.isNotBlank(tempStrResourceText) && NEOVariableMaps.containsKey(tempStrResourceText)) {
					tempResourceOrValueTextSet.add(tempStrResourceText);
				}

				// Get resource value variable id
				if (String.isNotBlank(tempStrResourceValueText) && NEOVariableMaps.containsKey(tempStrResourceValueText)) {
					tempResourceOrValueTextSet.add(tempStrResourceValueText);
				}

				// Get value variable id
				if (String.isNotBlank(tempStrValueText) && NEOVariableMaps.containsKey(tempStrValueText)) {
					tempResourceOrValueTextSet.add(tempStrValueText);
				}

				if (tempResourceOrValueTextSet.size() < 1) {
					continue;
				}

				// Get variable API name
				for (String strResourceOrValueText : tempResourceOrValueTextSet) {
					NEO_Variable__c tempResourceOrValueVariableObj = NEOVariableMaps.get(strResourceOrValueText);
					String tempStrVariableName = tempResourceOrValueVariableObj.Variable_API_Name__c;

					List<String> tempFieldsPartList = new List<String>();
					if (String.isNotBlank(tempStrVariableName) && tempStrVariableName.indexOf('.') != -1) {
						// Split varibale API name
						tempFieldsPartList = tempStrVariableName.split('\\.');
					}

					if (tempFieldsPartList.size() > 0) {
						Integer j = 0;
						String tempStrKeyFieldsPart = '';
						String tempStrOtherFieldsPart = '';
						for (String strFieldsPart : tempFieldsPartList) {
							if (j == 0) {
								tempStrKeyFieldsPart = strFieldsPart;
								++j;
								continue;
							}

							if (String.isNotBlank(tempStrOtherFieldsPart)) {
								tempStrOtherFieldsPart += '.';
							}
							tempStrOtherFieldsPart += strFieldsPart;
							++j;
						}
						
						if (String.isNotBlank(tempStrKeyFieldsPart) && String.isNotBlank(tempStrOtherFieldsPart)) {
							if (tempLookupFieldsMap.containsKey(tempStrKeyFieldsPart)) {
								tempLookupFieldsMap.get(tempStrKeyFieldsPart).add(tempStrOtherFieldsPart);
							} else {
								tempLookupFieldsMap.put(tempStrKeyFieldsPart, new Set<String> { tempStrOtherFieldsPart });
							}
						}
					}
				}
			}
		}

		return tempLookupFieldsMap;
	}

	public static String createQueryString(String objType) {
		Map<String, NEO_Variable__c> objApiNameVariableMaps = NEO_Rules_Constants.objApiNameVariableMaps;

		String strSOQL = '';

		if (!objApiNameVariableMaps.containsKey(objType)) {
			return strSOQL;
		}

		NEO_Variable__c objTypeVariableSource = objApiNameVariableMaps.get(objType);

		Map<String, List<NEO_Variable_Association__c>> variableAssociationMaps = NEO_Rules_Constants.variableAssociationMaps;
		Map<String, List<NEO_Variable__c>> parentVariableMaps = NEO_Rules_Constants.parentVariableMaps;

		Set<String> selectedFieldsSet = new Set<String> { 'Id', 'Name' };

		// Get object type select fields
		List<NEO_Variable__c> objectFieldsList = new List<NEO_Variable__c>();
		if (parentVariableMaps.containsKey(objTypeVariableSource.Id)) {
			objectFieldsList = parentVariableMaps.get(objTypeVariableSource.Id);
		}

		for (NEO_Variable__c tempFieldRow : objectFieldsList) {
			// NEO_Object_Variable
			if (tempFieldRow.RecordType.DeveloperName == NEO_Rules_Constants.NEO_VARIABLE_RECORD_TYPE_OBJECT) {
				continue;
			}
			selectedFieldsSet.add(tempFieldRow.Variable_API_Name__c);
		}

		// Get object type child object fields
		List<NEO_Variable_Association__c> tempVariableAssociationList = new List<NEO_Variable_Association__c>();
		if (variableAssociationMaps.containsKey(objTypeVariableSource.Id)) {
			tempVariableAssociationList = variableAssociationMaps.get(String.valueOf(objTypeVariableSource.Id));
		}

		for (NEO_Variable_Association__c tempVariableAssociationRow : tempVariableAssociationList) {
			String tempStrChildVariableId = tempVariableAssociationRow.NEO_Child_Object__c;
			String tempStrRelationShipName = tempVariableAssociationRow.NEO_Relationship_Name__c;

			if (String.isBlank(tempStrChildVariableId) || 
				String.isBlank(tempStrRelationShipName)) {
				continue;
			}

			String tempStrChildQuery = '';
			Set<String> childObjectSelectedFields = new Set<String> { 'Id' };

			if (parentVariableMaps.containsKey(tempStrChildVariableId)) {
				for (NEO_Variable__c tempChildObjectFieldRow :parentVariableMaps.get(tempStrChildVariableId)) {
					// NEO_Object_Variable
					if (tempChildObjectFieldRow.RecordType.DeveloperName == NEO_Rules_Constants.NEO_VARIABLE_RECORD_TYPE_OBJECT) {
						continue;
					}
					childObjectSelectedFields.add(tempChildObjectFieldRow.Variable_API_Name__c);
				}
			}

			if (childObjectSelectedFields.size() > 0) {
				tempStrChildQuery = '(SELECT ' + String.join(new List<String>(childObjectSelectedFields), ', ') + ' FROM ' + tempStrRelationShipName + ')';
				selectedFieldsSet.add(tempStrChildQuery);
			}
		}

		if (selectedFieldsSet.size() > 0) {
			strSOQL = 'SELECT ' + String.join(new List<String>(selectedFieldsSet), ', ') + ' FROM ' + objTypeVariableSource.Variable_API_Name__c;
		}

		return strSOQL;
	}

	public static List<NEO_Rule__c> executeRules(SObject objRow, SObject oldObjRow, String objType, List<NEO_Rule__c> objTypeRulesList, List<SObject> oldObjectList) {
		List<NEO_Rule__c> triggeredRulesList = new List<NEO_Rule__c>();
		Map<Decimal, Boolean> tempCriteriaResultMaps = new Map<Decimal, Boolean>();

		for (NEO_Rule__c tempRuleRow : objTypeRulesList) {

			String tempStrCustomLogic = tempRuleRow.Custom_Logic__c;
			if (String.isBlank(tempStrCustomLogic) || tempRuleRow.NEO_Criterias__r.size() < 1) {
				triggeredRulesList.add(tempRuleRow);
				continue;
			}

			tempCriteriaResultMaps = new Map<Decimal, Boolean>();
			for (NEO_Criteria__c tempCriteriaRow : tempRuleRow.NEO_Criterias__r) {
				Decimal tempRowSerialNo = tempCriteriaRow.Row_Serial_No__c;
				if (tempRowSerialNo == null) {
					continue;
				}

				tempCriteriaResultMaps.put(tempRowSerialNo, checkCriteriaRow(objRow, oldObjRow, oldObjRow, tempCriteriaRow, oldObjectList, tempRuleRow));
			}

			// Custom Logic Result
			if (checkCustomLogic(tempStrCustomLogic, tempCriteriaResultMaps)) {
				triggeredRulesList.add(tempRuleRow);
			}
		}

		return triggeredRulesList;
	}

	private static Boolean checkCustomLogic(String strCustomLogic, Map<Decimal, Boolean> criteriaResultMaps) {
		System.debug(LoggingLevel.DEBUG, '-------->strCustomLogic: ' + strCustomLogic);
		System.debug(LoggingLevel.DEBUG, '-------->criteriaResultMaps: ' + criteriaResultMaps);

		String tempStrCustomLogic = strCustomLogic.toUpperCase();
		tempStrCustomLogic = tempStrCustomLogic.replaceAll('AND', '&&');
		tempStrCustomLogic = tempStrCustomLogic.replaceAll('OR', '||');

		List<Decimal> tempSerialNoList = new List<Decimal>(criteriaResultMaps.keySet());
		tempSerialNoList.sort();

		for (Integer i = tempSerialNoList.size() - 1; i >= 0; i--) {
			Decimal tempDecimalTarget = tempSerialNoList.get(i);
			String tempStrReplacement = String.valueOf(criteriaResultMaps.get(tempDecimalTarget));

			tempStrCustomLogic = tempStrCustomLogic.replaceAll(String.valueOf(tempDecimalTarget), tempStrReplacement);
		}

		Boolean tempCustomLogicResult = false;
		if (String.isNotBlank(tempStrCustomLogic)) {
			tempCustomLogicResult = new NEO_Rules_Expression(tempStrCustomLogic).evalBool();
		}
		return tempCustomLogicResult;
	}

	public static Object convertRecourceValue(SObject objRow,
											  SObject oldObjRow,
									   		  SObject parentObjRow,
									   		  NEO_Variable__c resourceVariableObj,
									   		  String idFieldName,
									   		  Map<String, NEO_Variable__c> NEOVariableMaps,
									   		  NEO_Rule__c ruleRow,
									   		  Boolean oldValue) {
		/*
		String tempValueKey = resourceVariableObj.NEO_Value_Key__c;
		String tempDataSource = resourceVariableObj.NEO_Data_Source__c;
		String tempVariableApiName = resourceVariableObj.Variable_API_Name__c;

		System.debug(LoggingLevel.DEBUG, '------->tempValueKey: ' + tempValueKey);
		System.debug(LoggingLevel.DEBUG, '------->tempDataSource: ' + tempDataSource);

		// Don't need convert
		if (String.isBlank(tempValueKey) || String.isBlank(tempDataSource)) {
			SObject tempObjRow = objRow;
			if (oldValue) {
				tempObjRow = oldObjRow;
			}
			return getValueByFieldName(tempObjRow, tempVariableApiName);
		}

		// Day ID
		Date dayIDDate = System.today();
		System.debug(LoggingLevel.DEBUG, '------->ruleRow.NEO_Day_ID__c: ' + ruleRow.NEO_Day_ID__c);
		if (String.isNotBlank(ruleRow.NEO_Day_ID__c) && NEOVariableMaps.containsKey(ruleRow.NEO_Day_ID__c)) {
			NEO_Variable__c variableRow = NEOVariableMaps.get(ruleRow.NEO_Day_ID__c);

			System.debug(LoggingLevel.DEBUG, '------->ruleRow.NEO_Day_ID__c: ' + ruleRow.NEO_Day_ID__c);
			System.debug(LoggingLevel.DEBUG, '------->parentObjRow: ' + parentObjRow);

			if (variableRow.NEO_Variable_Data_Type__c == NEO_Rules_Constants.NEO_DATA_TYPE_DATE) {
				Object valueObj = getValueByFieldName(parentObjRow, variableRow.Variable_API_Name__c);
				System.debug(LoggingLevel.DEBUG, '------->valueObj1: ' + valueObj);
				dayIDDate = (valueObj <> null ? Date.valueOf(valueObj) : System.today());

			} else if (variableRow.NEO_Variable_Data_Type__c == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME) {
				Object valueObj = getValueByFieldName(parentObjRow, variableRow.Variable_API_Name__c);
				System.debug(LoggingLevel.DEBUG, '------->valueObj2: ' + valueObj);
				dayIDDate = (valueObj <> null ? DateTime.valueOf(valueObj).date() : System.today());
			}
		}

		System.debug(LoggingLevel.DEBUG, '------->dayIDDate: ' + dayIDDate);
		String tempDay = null;
		if (dayIDDate <> null) {
			tempDay = NEO_Utils.getFiscalQuarterKey(dayIDDate);
		}

		// Get AP record
		CMS_DIM_TIME_CALENDAR__c dimTimeCalendarRow = NEO_Utils.getAPRecordByDate(dayIDDate);
		System.debug(LoggingLevel.DEBUG, '-------->dimTimeCalendarRow: ' + dimTimeCalendarRow);

		Decimal tempMonth = null, tempQuarter = null, tempYear = null;
		if (dimTimeCalendarRow <> null) {
			tempMonth = dimTimeCalendarRow.NEO_MONTH_NUM_OF_FISCAL_YEAR__c;
			tempQuarter = dimTimeCalendarRow.NEO_QUARTER_NUM_OF_FISCAL_YEAR__c;
			tempYear = dimTimeCalendarRow.NEO_FISCAL_YEAR_ID__c;
		}

		System.debug(LoggingLevel.DEBUG, '-------->tempMonth: ' + tempMonth);
		System.debug(LoggingLevel.DEBUG, '-------->tempQuarter: ' + tempQuarter);
		System.debug(LoggingLevel.DEBUG, '-------->tempYear: ' + tempYear);

		System.debug(LoggingLevel.DEBUG, '-------->idFieldName: ' + idFieldName);

		String strTargetFieldsName = '';
		if (String.isNotBlank(idFieldName)) {
			List<String> idFieldNameParts = idFieldName.split('\\.');
			if (idFieldNameParts.size() > 1) {
				strTargetFieldsName = idFieldNameParts.get(idFieldNameParts.size() - 1);

				String tempStrLastPart = '__r.' + strTargetFieldsName;
				idFieldName = idFieldName.replaceAll(tempStrLastPart, '__c');

				tempStrLastPart = '.' + strTargetFieldsName;
				idFieldName = idFieldName.replaceAll(tempStrLastPart, 'Id');

			} else if (idFieldNameParts.size() > 0) {
				strTargetFieldsName = tempVariableApiName;
				idFieldName = 'Id';
			}
		}

		System.debug(LoggingLevel.DEBUG, '-------->objRow: ' + objRow);
		System.debug(LoggingLevel.DEBUG, '-------->idFieldName: ' + idFieldName);

		Object tempId = getValueByFieldName(objRow, idFieldName);

		String strKey = '';
		List<String> keyPartsList = new List<String>();
		if (tempValueKey == NEO_Rules_Constants.NEO_VALUE_KEY_MONTH_FORMAT) {
			if (tempId <> null &&
				tempYear <> null && 
				tempQuarter <> null && 
				tempMonth <> null) {
				String tempStrMonth = tempMonth < 10 ? '0' + tempMonth : tempMonth + '';
				strKey = String.format(tempValueKey, new List<String> { String.valueOf(tempId), String.valueOf(tempYear), String.valueOf(tempQuarter), tempStrMonth });
			}
		} else if (tempValueKey == NEO_Rules_Constants.NEO_VALUE_KEY_QUARTER_FORMAT) {
			if (tempId <> null &&
				tempYear <> null && 
				tempQuarter <> null) {
				strKey = String.format(tempValueKey, new List<String> { String.valueOf(tempId), String.valueOf(tempYear), String.valueOf(tempQuarter) });
			}

		} else if (tempValueKey == NEO_Rules_Constants.NEO_VALUE_KEY_YEAR_FORMAT) {
			if (tempId <> null &&
				tempYear <> null) {
				strKey = String.format(tempValueKey, new List<String> { String.valueOf(tempId), String.valueOf(tempYear) });
			}
		} else if (tempValueKey == NEO_Rules_Constants.NEO_VALUE_KEY_DAY_FORMAT) {
			if (tempId <> null &&
				tempYear <> null && 
				tempQuarter <> null && 
				tempMonth <> null &&
				String.isNotBlank(tempDay)) {
				String tempStrMonth = tempMonth < 10 ? '0' + tempMonth : tempMonth + '';
				strKey = String.format(tempValueKey, new List<String> { String.valueOf(tempId), String.valueOf(tempYear), String.valueOf(tempQuarter), tempStrMonth, tempDay });
			}
		}

		System.debug(LoggingLevel.DEBUG, '-------->tempId: ' + tempId);
		System.debug(LoggingLevel.DEBUG, '-------->tempQuarter: ' + tempQuarter);
		System.debug(LoggingLevel.DEBUG, '-------->tempYear: ' + tempYear);
		System.debug(LoggingLevel.DEBUG, '-------->strKey: ' + strKey);
		System.debug(LoggingLevel.DEBUG, '-------->strUserKey: ' + strUserKey);
		System.debug(LoggingLevel.DEBUG, '-------->cacheKeysSet: ' + cacheKeysSet);

		Object finalValue = null;
		SObject sourceObj = null;

		// Cache User Accumulated
		if (String.isNotBlank(strKey) && 
			strKey.startsWith(strUserKey) && 
			!userAccumulatedRecordsCache.containsKey(strKey) &&
			!cacheKeysSet.contains(String.valueOf(tempId))) {
			cacheUserAccumulated(new Set<String> { String.valueOf(tempId) });
		}

		// Cache Speaker Accumulated
		if (String.isNotBlank(strKey) && 
			strKey.startsWith(strSpeakerKey) && 
			!speakerAccumulatedRecordsCache.containsKey(strKey) &&
			!cacheKeysSet.contains(String.valueOf(tempId))) {
			cacheSpeakerAccumulated(new Set<String> { String.valueOf(tempId) });
		}

		System.debug(LoggingLevel.DEBUG, '-------->userAccumulatedRecordsCache: ' + userAccumulatedRecordsCache);
		System.debug(LoggingLevel.DEBUG, '-------->speakerAccumulatedRecordsCache: ' + speakerAccumulatedRecordsCache);
		

		if (String.isNotBlank(strKey)) {
			if (userAccumulatedRecordsCache.containsKey(strKey) && strKey.startsWith(strUserKey)) {
				sourceObj = userAccumulatedRecordsCache.get(strKey);
				System.debug(LoggingLevel.DEBUG, '-------->sourceObj: ' + sourceObj);
				System.debug(LoggingLevel.DEBUG, '-------->strTargetFieldsName: ' + strTargetFieldsName);
				finalValue = getValueByFieldName(sourceObj, strTargetFieldsName);
				System.debug(LoggingLevel.DEBUG, '-------->finalValue: ' + finalValue);

			} else if (speakerAccumulatedRecordsCache.containsKey(strKey) && strKey.startsWith(strSpeakerKey)) {
				sourceObj = speakerAccumulatedRecordsCache.get(strKey);
				System.debug(LoggingLevel.DEBUG, '-------->sourceObj: ' + sourceObj);
				System.debug(LoggingLevel.DEBUG, '-------->strTargetFieldsName: ' + strTargetFieldsName);
				finalValue = getValueByFieldName(sourceObj, strTargetFieldsName);
				System.debug(LoggingLevel.DEBUG, '-------->finalValue: ' + finalValue);
			}

		} else {
			finalValue = getValueByFieldName(objRow, tempVariableApiName);
		}

		System.debug(LoggingLevel.DEBUG, '-------->finalValue: ' + finalValue);
		return finalValue;*/
		return null;
	}

	// Get criteria row result
	public static Boolean checkCriteriaRow(SObject objRow, 
										   SObject oldObjRow, 
										   SObject parentObjRow, 
										   NEO_Criteria__c objCriteriaRow, 
										   List<SObject> oldObjectList, 
										   NEO_Rule__c ruleRow) {

		System.debug(LoggingLevel.DEBUG, '-------->ruleRow: ' + ruleRow);

		Map<String, NEO_Variable__c> NEOVariableMaps = NEO_Rules_Constants.NEOVariableMaps;
		Map<String, NEO_Aggregation__c> aggregationMaps = NEO_Rules_Constants.aggregationMaps;
		Map<String, NEO_Operator__c> NEOOperatorMaps = NEO_Rules_Constants.NEOOperatorMaps;
		Map<String, NEO_Variable__c> currentUserFieldsMaps = NEO_Rules_Constants.currentUserFieldsMaps;
		Map<String, List<NEO_Operator__c>> NEODataTypeOperatorMaps = NEO_Rules_Constants.NEODataTypeOperatorMaps;
		Map<String, List<NEO_Operator__c>> NEODataTypeResourceOperatorMaps = NEO_Rules_Constants.NEODataTypeResourceOperatorMaps;

		// Resource start
		NEO_Variable__c tempResourceVariableObj = null;
		NEO_Variable__c tempResourceValueVariableObj = null;
		NEO_Variable__c tempValueVariableObj = null;
		NEO_Variable__c tempResourceOperatorValueVariableObj = null;
		NEO_Aggregation__c tempResourceAggregationObj = null;
		List<Object> tempResourceValueList = new List<Object>();

		// Resource, variable or aggregation
		String tempStrResourceVariableId = objCriteriaRow.NEO_Resource_Text__c;
		String strResourceDataType = '';
		String strResourceValueDataType = '';

		// Old Resource
		Boolean oldResource = false, fyResource = false, fqResource = false, fmResource = false, isAP = false;
		if (String.isNotBlank(tempStrResourceVariableId) && tempStrResourceVariableId.endsWithIgnoreCase(NEO_Rules_Constants.NEO_FY_LABEL)) {
			fyResource = true;
			tempStrResourceVariableId = tempStrResourceVariableId.replaceAll('_' + NEO_Rules_Constants.NEO_FY_LABEL, '');

		} else if (String.isNotBlank(tempStrResourceVariableId) && tempStrResourceVariableId.endsWithIgnoreCase(NEO_Rules_Constants.NEO_FQ_LABEL)) {
			fqResource = true;
			tempStrResourceVariableId = tempStrResourceVariableId.replaceAll('_' + NEO_Rules_Constants.NEO_FQ_LABEL, '');

		} else if (String.isNotBlank(tempStrResourceVariableId) && tempStrResourceVariableId.endsWithIgnoreCase(NEO_Rules_Constants.NEO_FM_LABEL)) {
			fmResource = true;
			tempStrResourceVariableId = tempStrResourceVariableId.replaceAll('_' + NEO_Rules_Constants.NEO_FM_LABEL, '');
		}

		if (String.isNotBlank(tempStrResourceVariableId) && tempStrResourceVariableId.endsWithIgnoreCase(NEO_Rules_Constants.NEO_OLD_LABEL)) {
			oldResource = true;
			tempStrResourceVariableId = tempStrResourceVariableId.replaceAll('_' + NEO_Rules_Constants.NEO_OLD_LABEL, '');
		}

		isAP = (fyResource || fqResource || fmResource);
		
		if (String.isNotBlank(tempStrResourceVariableId) && NEOVariableMaps.containsKey(tempStrResourceVariableId)) {
			// Variable
			tempResourceVariableObj = NEOVariableMaps.get(tempStrResourceVariableId);
			strResourceDataType = tempResourceVariableObj.NEO_Variable_Data_Type__c;

			// Get value by field name
			String tempStrVariableAPIName = tempResourceVariableObj.Variable_API_Name__c;
			// Include null value
			tempResourceValueList.add(convertRecourceValue(objRow, oldObjRow, parentObjRow, tempResourceVariableObj, tempStrVariableAPIName, NEOVariableMaps, ruleRow, oldResource));
			// Object tempResourceValue = convertRecourceValue(objRow, oldObjRow, parentObjRow, tempResourceVariableObj, tempStrVariableAPIName, NEOVariableMaps, ruleRow, oldResource);
		
		} else if (String.isNotBlank(tempStrResourceVariableId) && aggregationMaps.containsKey(tempStrResourceVariableId)) {
			// Aggregation
			strResourceDataType = NEO_Rules_Constants.NEO_DATA_TYPE_CURRENCY;

			tempResourceAggregationObj = aggregationMaps.get(tempStrResourceVariableId);
			tempResourceValueList = checkAggregationResult(oldObjRow, parentObjRow, tempResourceAggregationObj, NEOVariableMaps, NEOOperatorMaps, oldObjectList, ruleRow);

		} else if (String.isNotBlank(tempStrResourceVariableId) && currentUserFieldsMaps.containsKey(tempStrResourceVariableId)) {
			// $User
			tempResourceVariableObj = currentUserFieldsMaps.get(tempStrResourceVariableId);
			strResourceDataType = tempResourceVariableObj.NEO_Variable_Data_Type__c;

			// Include null value
			tempResourceValueList.add(convertRecourceValue(NEO_Rules_Constants.MyUserInfo, oldObjRow, parentObjRow, tempResourceVariableObj, 'Id', NEOVariableMaps, ruleRow, false));
		}

		// Resource Operator Start
		String strResourceOperatorTextId = objCriteriaRow.NEO_Resource_Operator__c;
		NEO_Operator__c resourceOperatorSource = null;
		String strResourceOperatorParameterDataType = '', strResourceOperatorFormatter = '';

		if (String.isNotBlank(strResourceOperatorTextId) && NEOOperatorMaps.containsKey(strResourceOperatorTextId)) {
			resourceOperatorSource = NEOOperatorMaps.get(strResourceOperatorTextId);
			strResourceOperatorParameterDataType = resourceOperatorSource.Parameter_Data_Type__c;
			strResourceOperatorFormatter = resourceOperatorSource.Operator_Format__c;
		}

		// Resource Value Start
		String strResourceValue = objCriteriaRow.NEO_Resource_Value__c;

		List<Object> tempResourceOperatorValueList = new List<Object>();
		NEO_Aggregation__c tempResourceOperatorValueAggregationObj = null;

		if (strResourceOperatorParameterDataType == NEO_Rules_Constants.NEO_PARAMETERS_DATA_TYPE_SPECIAL_VALUE) {
			// Special value
			if (String.isNotBlank(strResourceValue) && NEOVariableMaps.containsKey(strResourceValue)) {
				// Variable
				tempResourceValueVariableObj = NEOVariableMaps.get(strResourceValue);
				strResourceValueDataType = tempResourceValueVariableObj.NEO_Variable_Data_Type__c;

				// Get value by field name
				String tempStrVariableAPIName = tempResourceValueVariableObj.Variable_API_Name__c;

				tempResourceOperatorValueList.add(convertRecourceValue(objRow, oldObjRow, parentObjRow, tempResourceValueVariableObj, tempStrVariableAPIName, NEOVariableMaps, ruleRow, false));

			} else if (String.isNotBlank(strResourceValue) && aggregationMaps.containsKey(strResourceValue)) {
				// Aggregate
				tempResourceOperatorValueAggregationObj = aggregationMaps.get(strResourceValue);
				tempResourceOperatorValueList = checkAggregationResult(oldObjRow, parentObjRow, tempResourceOperatorValueAggregationObj, NEOVariableMaps, NEOOperatorMaps, oldObjectList, ruleRow);
			}
		} else {
			if (strResourceValue <> null) {
				tempResourceOperatorValueList.add(strResourceValue);
			}
		}

		System.debug(LoggingLevel.DEBUG, '-------->tempResourceValueList: ' + tempResourceValueList);
		System.debug(LoggingLevel.DEBUG, '-------->tempResourceOperatorValueList: ' + tempResourceOperatorValueList);

		List<Object> finalResourceValueList = new List<Object>();
		if (tempResourceValueList.size() > 0 && 
			String.isNotBlank(strResourceOperatorFormatter) && 
			tempResourceOperatorValueList.size() > 0) {

			for (Object arg0 : tempResourceValueList) {
				for (Object arg1 : tempResourceOperatorValueList) {
					// Resource data type
					if (strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_CURRENCY ||
						strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_NUMBER ||
						strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DOUBLE ||
						strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PERCENT) {
						// Currency
						finalResourceValueList.add(executeNumericEval(arg0, arg1, strResourceOperatorFormatter));

					} else if (strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE) {
						// Date
						Date tempDateValue = executeDateEval(arg0, arg1, strResourceOperatorFormatter);
						if (tempDateValue <> null && isAP) {
							finalResourceValueList.add(getAPValue(tempDateValue, fyResource, fqResource, fmResource));
						} else {
							finalResourceValueList.add(tempDateValue);
						}
						
					} else if (strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME) {
						// Datetime
						Datetime tempDateTimeValue = executeDatetimeEval(arg0, arg1, strResourceOperatorFormatter);
						if (tempDateTimeValue <> null && isAP) {
							finalResourceValueList.add(getAPValue(tempDateTimeValue.date(), fyResource, fqResource, fmResource));

						} else {
							finalResourceValueList.add(tempDateTimeValue);
						}
					}
				}
			}

		} else {
			for (Object arg0 : tempResourceValueList) {
				if (strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE && arg0 <> null && isAP) {
					finalResourceValueList.add(getAPValue(Date.valueOf(arg0), fyResource, fqResource, fmResource));

				} else if (strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME && arg0 <> null && isAP) {
					finalResourceValueList.add(getAPValue(DateTime.valueOf(arg0).date(), fyResource, fqResource, fmResource));

				} else {
					finalResourceValueList.add(arg0);
				}
			}
			// finalResourceValueList = tempResourceValueList;
		}

		// Operator start
		// NEO_Operator__c
		String tempStrOperatorTextId = objCriteriaRow.NEO_Operator_Text__c;
		String tempStrOperatorDisplayType = '';
		String tempStrOperatorFormatter = '';
		if (String.isNotBlank(tempStrOperatorTextId) && NEOOperatorMaps.containsKey(tempStrOperatorTextId)) {
			NEO_Operator__c tempOperatorSource = NEOOperatorMaps.get(tempStrOperatorTextId);
			tempStrOperatorDisplayType = tempOperatorSource.Parameter_Data_Type__c;
			tempStrOperatorFormatter = tempOperatorSource.Operator_Format__c;
		}

		// Value start
		String tempStrValueText = objCriteriaRow.NEO_Value_Text__c;
		Boolean oldValue = false, fyValue = false, fqValue = false, fmValue = false;
		if (String.isNotBlank(tempStrValueText) && tempStrValueText.endsWithIgnoreCase(NEO_Rules_Constants.NEO_FY_LABEL)) {
			fyValue = true;
			tempStrValueText = tempStrValueText.replaceAll('_' + NEO_Rules_Constants.NEO_FY_LABEL, '');

		} else if (String.isNotBlank(tempStrValueText) && tempStrValueText.endsWithIgnoreCase(NEO_Rules_Constants.NEO_FQ_LABEL)) {
			fqValue = true;
			tempStrValueText = tempStrValueText.replaceAll('_' + NEO_Rules_Constants.NEO_FQ_LABEL, '');

		} else if (String.isNotBlank(tempStrValueText) && tempStrValueText.endsWithIgnoreCase(NEO_Rules_Constants.NEO_FM_LABEL)) {
			fmValue = true;
			tempStrValueText = tempStrValueText.replaceAll('_' + NEO_Rules_Constants.NEO_FM_LABEL, '');
		}

		if (String.isNotBlank(tempStrValueText) && tempStrValueText.endsWithIgnoreCase(NEO_Rules_Constants.NEO_OLD_LABEL)) {
			oldValue = true;
			tempStrValueText = tempStrValueText.replaceAll('_' + NEO_Rules_Constants.NEO_OLD_LABEL, '');
		}

		Date tempValueDate = objCriteriaRow.NEO_Value_Date__c;
		Datetime tempValueDatetime = objCriteriaRow.NEO_Value_Datetime__c;

		Object tempValueObject = null;
		Boolean specalValueOrNot = false;
		if (String.isNotBlank(tempStrValueText) && NEOVariableMaps.containsKey(tempStrValueText)) {
			// Value variable object
			tempValueVariableObj = NEOVariableMaps.get(tempStrValueText);

			String tempStrVariableAPIName = tempValueVariableObj.Variable_API_Name__c;

			// Variable
			tempValueObject = convertRecourceValue(objRow, oldObjRow, parentObjRow, tempValueVariableObj, tempStrVariableAPIName, NEOVariableMaps, ruleRow, oldValue);
			specalValueOrNot = true;

			if (strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE && isAP) {
				if (tempValueObject <> null) {
					tempValueObject = getAPValue(Date.valueOf(tempValueObject), fyResource, fqResource, fmResource);
				}

			} else if (strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME && isAP) {
				if (tempValueObject <> null) {
					tempValueObject = getAPValue(DateTime.valueOf(tempValueObject).date(), fyResource, fqResource, fmResource);
				}
			}

		} else if (tempStrValueText == NEO_Rules_Constants.NEO_DATE_FUNCTION_TODAY) {
			// Date today
			tempValueObject = System.today();
			
		} else if (tempStrValueText == NEO_Rules_Constants.NEO_DATETIME_FUNCTION_NOW) {
			// Datetime now
			tempValueObject = System.now();

		} 
/*
		else if (tempStrValueText == NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_MONTH) {
			// Date: first day of fiscal month
			tempValueObject = NEO_Utils.getFirstDayByFiscalMonth(null);

		} else if (tempStrValueText == NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_MONTH) {
			// Date: last day of fiscal month
			tempValueObject = NEO_Utils.getLastDayByFiscalMonth(null);
			
		} else if (tempStrValueText == NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_QUARTER) {
			// Date: first day of fiscal quarter
			tempValueObject = NEO_Utils.getFirstDayByFiscalQuarter(null);

		} else if (tempStrValueText == NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_QUARTER) {
			// Date: last day of fiscal quarter
			tempValueObject = NEO_Utils.getLastDayByFiscalQuarter(null);
			
		} else if (tempStrValueText == NEO_Rules_Constants.NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_YEAR) {
			// Date: first day of fiscal year
			tempValueObject = NEO_Utils.getFirstDayByFiscalYear(null);

		} else if (tempStrValueText == NEO_Rules_Constants.NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_YEAR) {
			// Date: last day of fiscal year
			tempValueObject = NEO_Utils.getLastDayByFiscalYear(null);
			
		}
*/
		 else {
			// Precise Value
			tempValueObject = tempStrValueText;
			// Value type
			if (tempValueDate <> null) {
				// Date
				tempValueObject = tempValueDate;

			} else if (tempValueDatetime <> null) {
				// Datetime
				tempValueObject = tempValueDatetime;

			} else if (String.isNotBlank(tempStrValueText)) {
				// Text
				tempValueObject = tempStrValueText;
			}
		}

		// Return value
		Boolean returnValue = getCriteriaRowReturnValue(finalResourceValueList, 
												strResourceDataType, 
								  				tempStrOperatorDisplayType,
								  				tempValueObject,
								  				tempStrOperatorFormatter,
								  				objRow,
												parentObjRow,
												specalValueOrNot,
												isAP);
		return returnValue;
	}

	// Get AP value from date
	private static Decimal getAPValue(Date inputDate, Boolean fyResource, Boolean fqResource, Boolean fmResource) {
		Decimal tempAPValue = null;
		//CMS_DIM_TIME_CALENDAR__c tempAPObj = NEO_Utils.getAPRecordByDate(inputDate);

		//System.debug(LoggingLevel.DEBUG, '------->tempAPObj: ' + tempAPObj);

		// Date
		if (fyResource) {
			//tempAPValue = tempAPObj.NEO_FISCAL_YEAR_ID__c;

		} else if (fqResource) {
			//tempAPValue = tempAPObj.NEO_QUARTER_NUM_OF_FISCAL_YEAR__c;

		} else if (fmResource) {
			//tempAPValue = tempAPObj.NEO_MONTH_NUM_OF_FISCAL_YEAR__c;
		}

		return tempAPValue;
	}

	// Get criteria row return value
	public static Boolean getCriteriaRowReturnValue(List<Object> resourceValueList,
											String strResourceDataType, 
											String strOperatorDisplayType,
											Object tempValueObject,
											String strOperatorFormatter,
											SObject objRow,
											SObject parentObjRow,
											Boolean specalValueOrNot,
											Boolean isAP) {
		System.debug(LoggingLevel.DEBUG, '-------->resourceValueList: ' + resourceValueList);
		System.debug(LoggingLevel.DEBUG, '-------->tempValueObject: ' + tempValueObject);
		System.debug(LoggingLevel.DEBUG, '-------->strOperatorFormatter: ' + strOperatorFormatter);
		Boolean tempReturnValue = false;

		if (String.isBlank(strResourceDataType) || 
			strResourceDataType.contains(NEO_Rules_Constants.NEO_DATA_TYPE_LOOKUP) ||
			strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_EMAIL ||
			strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PHONE ||
			strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_TEXT ||
			strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_CHECKBOX ||
			strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_URL ||
			strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_MULTI_PICKLIST ||
			strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_ID ||
			strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PICKLIST) {
			// Blank/Lookup/Email/Phone/Text/URL/Picklist
			Integer c = 0;
			for (Object tempResourceValue : resourceValueList) {
				if (strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_CHECKBOX && tempResourceValue == null) {
					tempResourceValue = false;
				}
				if (c > 0) {
					tempReturnValue = tempReturnValue && executeStringFormatter(tempResourceValue, tempValueObject, strOperatorFormatter);
				} else {
					tempReturnValue = executeStringFormatter(tempResourceValue, tempValueObject, strOperatorFormatter);
				}
				++c;
			}
		} else if (strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE && !isAP) {
			// Date
			Integer c = 0;
			for (Object tempResourceValue : resourceValueList) {
				if (c > 0) {
					tempReturnValue = tempReturnValue && executeDateFormatter(tempResourceValue, tempValueObject, strOperatorFormatter, specalValueOrNot);
				} else {
					tempReturnValue = executeDateFormatter(tempResourceValue, tempValueObject, strOperatorFormatter, specalValueOrNot);
				}
				++c;
			}
		} else if (strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME && !isAP) {
			// Datetime
			Integer c = 0;
			for (Object tempResourceValue : resourceValueList) {
				if (c > 0) {
					tempReturnValue = tempReturnValue && executeDateTimeFormatter(tempResourceValue, tempValueObject, strOperatorFormatter, specalValueOrNot);
				} else {
					tempReturnValue = executeDateTimeFormatter(tempResourceValue, tempValueObject, strOperatorFormatter, specalValueOrNot);
				}
				++c;
			}
		} else if (strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_TIME) {
			// Time

		} else if (strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DECIMAL ||
				   strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_CURRENCY ||
				   strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_NUMBER ||
				   strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DOUBLE ||
				   strResourceDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PERCENT ||
				   isAP) {
			// Decimal/Currency/Number/Double/Percent/isAP
			Integer c = 0;
			for (Object tempResourceValue : resourceValueList) {
				if (c > 0) {
					tempReturnValue = tempReturnValue || executeNumericFormatter(tempResourceValue, tempValueObject, null, strOperatorFormatter);
				} else {
					tempReturnValue = executeNumericFormatter(tempResourceValue, tempValueObject, null, strOperatorFormatter);
				}
				++c;
			}
		} else {
			Integer c = 0;
			for (Object tempResourceValue : resourceValueList) {
				if (c > 0) {
					tempReturnValue = tempReturnValue && executeStringFormatter(tempResourceValue, tempValueObject, strOperatorFormatter);
				} else {
					tempReturnValue = executeStringFormatter(tempResourceValue, tempValueObject, strOperatorFormatter);
				}
				++c;
			}
		}

		System.debug(LoggingLevel.DEBUG, '-------->tempReturnValue: ' + tempReturnValue);
		System.debug(LoggingLevel.DEBUG, '=======================================');
		return tempReturnValue;
	}

	// Create all summarized records query
	public static String createAllSummarizedRecordsQuery(NEO_Aggregation__c tempResourceAggregationObj) {

		Map<String, NEO_Variable__c> NEOVariableMaps = NEO_Rules_Constants.NEOVariableMaps;
		Map<String, NEO_Variable_Association__c> NEOVariableAssociationMaps = NEO_Rules_Constants.NEOVariableAssociationMaps;

		// NEO_Summarized_Object__c
		NEO_Variable_Association__c tempVariableAssociationSource = null;
		if (String.isNotBlank(tempResourceAggregationObj.NEO_Summarized_Object__c) && 
			NEOVariableAssociationMaps.containsKey(tempResourceAggregationObj.NEO_Summarized_Object__c)) {
			tempVariableAssociationSource = NEOVariableAssociationMaps.get(tempResourceAggregationObj.NEO_Summarized_Object__c);
		}

		String tempStrSelectFields = '';
		Set<String> tempSelectedFields = new Set<String> { 'Id' };

		String tempStrFromObjName = '', tempStrLookupName = '';
		List<String> tempGroupFieldsList = new List<String>();
		if (tempVariableAssociationSource <> null) {
			tempStrFromObjName = tempVariableAssociationSource.NEO_Child_Object_API_Name__c;
			tempStrLookupName = tempVariableAssociationSource.NEO_Lookup_Name__c;
		}

		// Fields_To_Aggregate__c
		if (String.isNotBlank(tempResourceAggregationObj.Fields_To_Aggregate__c) && 
			NEOVariableMaps.containsKey(tempResourceAggregationObj.Fields_To_Aggregate__c)) {
			tempSelectedFields.add(NEOVariableMaps.get(tempResourceAggregationObj.Fields_To_Aggregate__c).Variable_API_Name__c);
		}

		// Fields_To_Group__c
		String tempStrGroupFields = tempResourceAggregationObj.Fields_To_Group__c;
		if (String.isNotBlank(tempStrGroupFields)) {
			tempGroupFieldsList = tempStrGroupFields.split(',');
			for (String tempStrFieldRow : tempGroupFieldsList) {
				tempSelectedFields.add(tempStrFieldRow);
			}
		}

		// Aggregation criteria
		if (tempResourceAggregationObj.NEO_Criterias__r <> null) {
			for (NEO_Criteria__c tempAggregationCriteriaRow : tempResourceAggregationObj.NEO_Criterias__r) {
				if (String.isBlank(tempAggregationCriteriaRow.NEO_Resource_Text__c) ||
					!NEOVariableMaps.containsKey(tempAggregationCriteriaRow.NEO_Resource_Text__c)) {
					continue;
				}

				tempSelectedFields.add(NEOVariableMaps.get(tempAggregationCriteriaRow.NEO_Resource_Text__c).Variable_API_Name__c);
			}
		}

		String strSOQL = '';
		if (tempSelectedFields.size() > 0 && 
			String.isNotBlank(tempStrFromObjName) && 
			String.isNotBlank(tempStrLookupName)) {
			strSOQL = 'SELECT ' + String.join(new List<String>(tempSelectedFields), ', ') + ' FROM ' + tempStrFromObjName;
		}
		return strSOQL;
	}

	public static List<Decimal> checkAggregationResult(SObject oldObjRow,
													   SObject parentObjRow, 
													   NEO_Aggregation__c tempResourceAggregationObj,
													   Map<String, NEO_Variable__c> NEOVariableMaps,
													   Map<String, NEO_Operator__c> NEOOperatorMaps,
													   List<SObject> oldObjectList,
													   NEO_Rule__c ruleRow) {
		Map<String, NEO_Variable_Association__c> NEOVariableAssociationMaps = NEO_Rules_Constants.NEOVariableAssociationMaps;

		String relationshipName = '';
		String summarizedObjectName = '';
		if (String.isNotBlank(tempResourceAggregationObj.NEO_Summarized_Object__c) && 
			NEOVariableAssociationMaps.containsKey(tempResourceAggregationObj.NEO_Summarized_Object__c)) {
			NEO_Variable_Association__c tempVariableAssociationSource = NEOVariableAssociationMaps.get(tempResourceAggregationObj.NEO_Summarized_Object__c);

			relationshipName = tempVariableAssociationSource.NEO_Relationship_Name__c;
			summarizedObjectName = tempVariableAssociationSource.NEO_Child_Object_API_Name__c;
		}

		List<Decimal> tempAggregtionResultList = new List<Decimal>();

		// Custom_Logic__c
		String tempStrAggregationCustomLogic = tempResourceAggregationObj.Custom_Logic__c;

		// Get field to group list
		List<String> fieldsToGroupList = new List<String>();
		String strFieldsToGroup = tempResourceAggregationObj.Fields_To_Group__c;
		if (String.isNotBlank(strFieldsToGroup)) {
			fieldsToGroupList = strFieldsToGroup.split(',');
		}

		// Fields_To_Aggregate__c
		String strFieldsToAggregateVariableAPIName = '';
		if (String.isNotBlank(tempResourceAggregationObj.Fields_To_Aggregate__c) && 
			NEOVariableMaps.containsKey(tempResourceAggregationObj.Fields_To_Aggregate__c)) {
			strFieldsToAggregateVariableAPIName = NEOVariableMaps.get(tempResourceAggregationObj.Fields_To_Aggregate__c).Variable_API_Name__c;
		}

		// Roll-up type
		String tempRollupType = tempResourceAggregationObj.Roll_Up_Type__c;

		// NEO_Summarized_All_Records__c
		if (tempResourceAggregationObj.NEO_Summarized_All_Records__c) {
			tempAggregtionResultList = checkSummarizedAllAggregationResult(parentObjRow, 
																		   tempResourceAggregationObj, 
																		   oldObjectList, 
																		   ruleRow, 
																		   tempStrAggregationCustomLogic,
																		   strFieldsToAggregateVariableAPIName,
																		   fieldsToGroupList,
																		   relationshipName,
																		   summarizedObjectName,
																		   tempRollupType);
		} else {
			tempAggregtionResultList = checkChildRecordsAggregationResult(oldObjRow,
																		  parentObjRow,
																		  tempResourceAggregationObj,
																		  oldObjectList,
																		  ruleRow,
																		  tempStrAggregationCustomLogic,
																		  strFieldsToAggregateVariableAPIName,
																		  fieldsToGroupList,
																		  relationshipName,
																		  summarizedObjectName,
																		  tempRollupType);
		}

		return tempAggregtionResultList;
	}

	public static List<Decimal> checkChildRecordsAggregationResult(SObject oldObjRow,
																   SObject parentObjRow,
																   NEO_Aggregation__c tempResourceAggregationObj,
																   List<SObject> oldObjectList,
																   NEO_Rule__c ruleRow,
																   String strAggregationCustomLogic,
																   String strFieldsToAggregateVariableAPIName,
																   List<String> fieldsToGroupList,
																   String relationshipName,
																   String summarizedObjectName,
																   String rollupType) {
		Map<Decimal, Boolean> tempAggregationCriteriaResultMaps = new Map<Decimal, Boolean>();
		List<Decimal> rollupResultsList = new List<Decimal>();

		System.debug(LoggingLevel.DEBUG, '-------->JSON.serialize(oldObjRow): ' + JSON.serialize(oldObjRow));

		// No child records
		if (String.isBlank(relationshipName) || !(JSON.serialize(oldObjRow).contains(relationshipName))) {
			if (rollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_COUNT ||
				rollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_SUM) {
				rollupResultsList = new List<Decimal> { 0 };
			}
			return rollupResultsList;
		}

		// Get roll-up type: Count, Sum, Max, Min
		if (rollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_COUNT) {
			Map<String, Decimal> aggregateResultMaps = new Map<String, Decimal>();

			// Count
			for (SObject tempAvailableObjRow : oldObjRow.getSObjects(relationshipName)) {
				for (NEO_Criteria__c tempAggregationCriteriaRow : tempResourceAggregationObj.NEO_Criterias__r) {
					Decimal tempRowSerialNo = tempAggregationCriteriaRow.Row_Serial_No__c;
					if (tempRowSerialNo == null) {
						continue;
					}
					tempAggregationCriteriaResultMaps.put(tempRowSerialNo, checkCriteriaRow(tempAvailableObjRow, tempAvailableObjRow, parentObjRow, tempAggregationCriteriaRow, oldObjectList, ruleRow));
				}

				// Custom Logic Result
				if (String.isBlank(strAggregationCustomLogic) || checkCustomLogic(strAggregationCustomLogic, tempAggregationCriteriaResultMaps)) {
					if (fieldsToGroupList.size() < 1) {
						if (aggregateResultMaps.containsKey('$Other')) {
							aggregateResultMaps.put('$Other', aggregateResultMaps.get('$Other') + 1);
						} else {
							aggregateResultMaps.put('$Other', 1);
						}
					} else {
						// Get key
						String strKey = '';
						for (String tempStrFieldToGroupName : fieldsToGroupList) {
							if (String.isNotBlank(strKey)) {
								strKey += '__';
							}
							strKey += getValueByFieldName(tempAvailableObjRow, tempStrFieldToGroupName);
						}

						if (String.isBlank(strKey)) {
							continue;
						}

						if (aggregateResultMaps.containsKey(strKey)) {
							aggregateResultMaps.put(strKey, (aggregateResultMaps.get(strKey) + 1));
						} else {
							aggregateResultMaps.put(strKey, 1);
						}
					}
				}
			}

			System.debug(LoggingLevel.DEBUG, '-------->aggregateResultMaps: ' + aggregateResultMaps);
			if (aggregateResultMaps.size() > 0) {
				rollupResultsList = aggregateResultMaps.values();
			}

		} else if (rollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_SUM) {
			// Sum
			if (fieldsToGroupList.size() < 1) {
				// No group
				Decimal totalAggregateValue = 0;

				for (SObject tempAvailableObjRow : oldObjRow.getSObjects(relationshipName)) {
					for (NEO_Criteria__c tempAggregationCriteriaRow : tempResourceAggregationObj.NEO_Criterias__r) {
						Decimal tempRowSerialNo = tempAggregationCriteriaRow.Row_Serial_No__c;
						if (tempRowSerialNo == null) {
							continue;
						}
						tempAggregationCriteriaResultMaps.put(tempRowSerialNo, checkCriteriaRow(tempAvailableObjRow, tempAvailableObjRow, parentObjRow, tempAggregationCriteriaRow, oldObjectList, ruleRow));
					}

					// Custom Logic Result
					if (String.isBlank(strAggregationCustomLogic) || checkCustomLogic(strAggregationCustomLogic, tempAggregationCriteriaResultMaps)) {
						Object objFieldToAggregateValue = getValueByFieldName(tempAvailableObjRow, strFieldsToAggregateVariableAPIName);
						
						if (objFieldToAggregateValue <> null) {
							totalAggregateValue += Decimal.valueOf(String.valueOf(objFieldToAggregateValue));
						}
					}
				}
				rollupResultsList.add(totalAggregateValue);

			} else {
				// Group by
				Map<String, Decimal> aggregateResultMaps = new Map<String, Decimal>();
				for (SObject tempAvailableObjRow : oldObjRow.getSObjects(relationshipName)) {
					for (NEO_Criteria__c tempAggregationCriteriaRow : tempResourceAggregationObj.NEO_Criterias__r) {
						Decimal tempRowSerialNo = tempAggregationCriteriaRow.Row_Serial_No__c;
						if (tempRowSerialNo == null) {
							continue;
						}
						tempAggregationCriteriaResultMaps.put(tempRowSerialNo, checkCriteriaRow(tempAvailableObjRow, tempAvailableObjRow, parentObjRow, tempAggregationCriteriaRow, oldObjectList, ruleRow));
					}

					// Custom Logic Result
					if (String.isBlank(strAggregationCustomLogic) || checkCustomLogic(strAggregationCustomLogic, tempAggregationCriteriaResultMaps)) {
						Object objFieldToAggregateValue = getValueByFieldName(tempAvailableObjRow, strFieldsToAggregateVariableAPIName);
						if (objFieldToAggregateValue == null) {
							continue;
						}

						Decimal decimalFieldToAggregateValue = Decimal.valueOf(String.valueOf(objFieldToAggregateValue));
						// Get key
						String strKey = '';
						for (String tempStrFieldToGroupName : fieldsToGroupList) {
							if (String.isNotBlank(strKey)) {
								strKey += '__';
							}
							strKey += getValueByFieldName(tempAvailableObjRow, tempStrFieldToGroupName);
						}

						if (String.isBlank(strKey)) {
							continue;
						}

						if (aggregateResultMaps.containsKey(strKey)) {
							aggregateResultMaps.put(strKey, (aggregateResultMaps.get(strKey) + decimalFieldToAggregateValue));
						} else {
							aggregateResultMaps.put(strKey, decimalFieldToAggregateValue);
						}
					}
				}

				if (aggregateResultMaps.size() > 0) {
					rollupResultsList = aggregateResultMaps.values();
				}
			}

		} else if (rollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_MAX) {
			// Max
			Integer j = 0;
			Decimal maxRollupValue = null;

			for (SObject tempAvailableObjRow : oldObjRow.getSObjects(relationshipName)) {
				for (NEO_Criteria__c tempAggregationCriteriaRow : tempResourceAggregationObj.NEO_Criterias__r) {
					Decimal tempRowSerialNo = tempAggregationCriteriaRow.Row_Serial_No__c;
					if (tempRowSerialNo == null) {
						continue;
					}
					tempAggregationCriteriaResultMaps.put(tempRowSerialNo, checkCriteriaRow(tempAvailableObjRow, tempAvailableObjRow, parentObjRow, tempAggregationCriteriaRow, oldObjectList, ruleRow));
				}

				// Custom Logic Result
				if (String.isBlank(strAggregationCustomLogic) || checkCustomLogic(strAggregationCustomLogic, tempAggregationCriteriaResultMaps)) {
					Decimal decimalFieldToAggregateValue = Decimal.valueOf(String.valueOf(tempAvailableObjRow.get(strFieldsToAggregateVariableAPIName)));
					if (decimalFieldToAggregateValue == null) {
						continue;
					}

					if (j < 1) {
						maxRollupValue = decimalFieldToAggregateValue;
					} else {
						maxRollupValue = Math.max(maxRollupValue, decimalFieldToAggregateValue);
					}
					++j;
				}
			}

			if (maxRollupValue <> null) {
				rollupResultsList.add(maxRollupValue);
			}

		} else if (rollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_MIN) {
			// Min
			Integer j = 0;
			Decimal minRollupValue = null;

			for (SObject tempAvailableObjRow : oldObjRow.getSObjects(relationshipName)) {
				for (NEO_Criteria__c tempAggregationCriteriaRow : tempResourceAggregationObj.NEO_Criterias__r) {
					Decimal tempRowSerialNo = tempAggregationCriteriaRow.Row_Serial_No__c;
					if (tempRowSerialNo == null) {
						continue;
					}
					tempAggregationCriteriaResultMaps.put(tempRowSerialNo, checkCriteriaRow(tempAvailableObjRow, tempAvailableObjRow, parentObjRow, tempAggregationCriteriaRow, oldObjectList, ruleRow));
				}

				if (String.isBlank(strAggregationCustomLogic) || checkCustomLogic(strAggregationCustomLogic, tempAggregationCriteriaResultMaps)) {
					Decimal decimalFieldToAggregateValue = Decimal.valueOf(String.valueOf(tempAvailableObjRow.get(strFieldsToAggregateVariableAPIName)));
					if (decimalFieldToAggregateValue == null) {
						continue;
					}

					if (j < 1) {
						minRollupValue = decimalFieldToAggregateValue;
					} else {
						minRollupValue = Math.min(minRollupValue, decimalFieldToAggregateValue);
					}
					++j;
				}
			}

			if (minRollupValue <> null) {
				rollupResultsList.add(minRollupValue);
			}
		}
		System.debug(LoggingLevel.DEBUG, '-------->tempResourceAggregationObj: ' + tempResourceAggregationObj);
		return rollupResultsList;
	}

	public static List<Decimal> checkSummarizedAllAggregationResult(SObject parentObjRow,
																	NEO_Aggregation__c tempResourceAggregationObj,
																	List<SObject> oldObjectList,
																	NEO_Rule__c ruleRow,
																	String strAggregationCustomLogic,
																	String strFieldsToAggregateVariableAPIName,
																	List<String> fieldsToGroupList,
																	String relationshipName,
																	String summarizedObjectName,
																	String rollupType) {
		Map<Decimal, Boolean> tempAggregationCriteriaResultMaps = new Map<Decimal, Boolean>();
		List<Decimal> tempAggregtionResultList = new List<Decimal>();

		// Get total summarized object list
		List<sObject> cacheAllSummarizedObjectList = new List<sObject>();
		List<sObject> allSummarizedObjectList = new List<sObject>();

		String strSOQL = createAllSummarizedRecordsQuery(tempResourceAggregationObj);

		Set<String> filterPartsSet = new Set<String>();
		List<Object> groupObjectsList = new List<Object>();

		for (SObject tempOldObjRow : oldObjectList) {
			if (String.isBlank(relationshipName) || !(JSON.serialize(tempOldObjRow).contains(relationshipName))) {
				continue;
			}

			for (SObject summarizedSObjectRow : tempOldObjRow.getSObjects(relationshipName)) {
				for (String strGroupFieldName : fieldsToGroupList) {
					// Get group field value
					Object objectValue = getValueByFieldName(summarizedSObjectRow, strGroupFieldName);

					// Get group field data type
					String groupFieldDataType = getFieldTypeByName(summarizedObjectName, strGroupFieldName, false);

					if (groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_REFERENCE.toUpperCase() ||
						groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_EMAIL.toUpperCase() ||
						groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PHONE.toUpperCase() ||
						groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PICKLIST.toUpperCase() ||
						groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_TEXT.toUpperCase() ||
						groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_URL.toUpperCase() ||
						groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_STRING.toUpperCase()) {
						// String
						filterPartsSet.add(strGroupFieldName + ' = \'' + String.valueOf(objectValue) + '\'');

					} else if (groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE.toUpperCase()) {
						// Date
						String strDateValue = DateTime.newInstance(Date.valueOf(objectValue), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
						filterPartsSet.add(strGroupFieldName + ' = ' + strDateValue);

					} else if (groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME.toUpperCase()) {
						// Datetime
						String strDatetimeValue = objectValue <> null ? Datetime.valueOf(objectValue).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : '';
						filterPartsSet.add(strGroupFieldName + ' = ' + String.valueOf(objectValue));

					} else if (groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_BOOLEAN.toUpperCase()) {
						// Boolean
						filterPartsSet.add(strGroupFieldName + ' = ' + Boolean.valueOf(objectValue));
					}

					// Group fields value set
					groupObjectsList.add(objectValue);
				}
			}
		}

		// Summarize all records
		if (allRecordsCache.containsKey(tempResourceAggregationObj.Id)) {
			cacheAllSummarizedObjectList = allRecordsCache.get(tempResourceAggregationObj.Id);

		} else {
			String strWhere = '';
			if (filterPartsSet.size() > 0) {
				if (String.isNotBlank(strWhere)) {
					strWhere += ' AND ';
				}
				strWhere += '(' + String.join(new List<String>(filterPartsSet), ' OR ') + ')';
			}

			if (String.isNotBlank(strWhere)) {
				strSOQL += ' WHERE ' + strWhere;
				cacheAllSummarizedObjectList = Database.query(strSOQL);
			}
			System.debug(LoggingLevel.DEBUG, '-------->allSummarizedObjectList#strSOQL: ' + strSOQL);

			if (cacheAllSummarizedObjectList == null) {
				cacheAllSummarizedObjectList = new List<sObject>(); 
			}

			allRecordsCache.put(tempResourceAggregationObj.Id, cacheAllSummarizedObjectList);
		}

		for (SObject tempSObjectRow : cacheAllSummarizedObjectList) {
			List<Object> tempGroupObjectsList = new List<Object>();
			for (String strGroupFieldName : fieldsToGroupList) {
				Object tempObjectValue = getValueByFieldName(tempSObjectRow, strGroupFieldName);
				tempGroupObjectsList.add(tempObjectValue);
			}

			System.debug(LoggingLevel.DEBUG, '-------->tempGroupObjectsList: ' + tempGroupObjectsList);
			System.debug(LoggingLevel.DEBUG, '-------->groupObjectsList: ' + groupObjectsList);

			if (groupObjectsList.equals(tempGroupObjectsList)) {
				allSummarizedObjectList.add(tempSObjectRow);
			}
		}

		System.debug(LoggingLevel.DEBUG, '-------->cacheAllSummarizedObjectList: ' + cacheAllSummarizedObjectList);
		System.debug(LoggingLevel.DEBUG, '-------->allSummarizedObjectList: ' + allSummarizedObjectList);

		// Filter available sobject list
		List<SObject> tempAvailableSobjectList = new List<SObject>();

		if (String.isBlank(strAggregationCustomLogic)) {
			tempAvailableSobjectList = allSummarizedObjectList;

		} else {
			// Filter available records list
			for (sObject tempSummarizedObjRow : allSummarizedObjectList) {
				for (NEO_Criteria__c tempAggregationCriteriaRow : tempResourceAggregationObj.NEO_Criterias__r) {
					Decimal tempRowSerialNo = tempAggregationCriteriaRow.Row_Serial_No__c;
					if (tempRowSerialNo == null) {
						continue;
					}
					tempAggregationCriteriaResultMaps.put(tempRowSerialNo, checkCriteriaRow(tempSummarizedObjRow, tempSummarizedObjRow, parentObjRow, tempAggregationCriteriaRow, oldObjectList, ruleRow));
				}

				// Custom Logic Result
				if (checkCustomLogic(strAggregationCustomLogic, tempAggregationCriteriaResultMaps)) {
					tempAvailableSobjectList.add(tempSummarizedObjRow);
				}
			}
		}

		// Get roll-up type: Count, Sum, Max, Min
		if (rollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_COUNT) {
			// Count
			tempAggregtionResultList = getCountRollupResultsList(tempAvailableSobjectList, fieldsToGroupList);

		} else if (rollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_SUM) {
			// Sum
			tempAggregtionResultList = getSumRollupResultsList(tempAvailableSobjectList, strFieldsToAggregateVariableAPIName, fieldsToGroupList);

		} else if (rollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_MAX) {
			// Max
			tempAggregtionResultList = getMaxRollupResultsList(tempAvailableSobjectList, strFieldsToAggregateVariableAPIName);
			
		} else if (rollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_MIN) {
			// Min
			tempAggregtionResultList = getMinRollupResultsList(tempAvailableSobjectList, strFieldsToAggregateVariableAPIName);
		}

		System.debug(LoggingLevel.DEBUG, '-------->tempResourceAggregationObj: ' + tempResourceAggregationObj);

		return tempAggregtionResultList;
	}

	// Get aggregation result
	/*public static List<Decimal> checkAggregationResult(SObject oldObjRow,
													   SObject parentObjRow, 
													   NEO_Aggregation__c tempResourceAggregationObj,
													   Map<String, NEO_Variable__c> NEOVariableMaps,
													   Map<String, NEO_Operator__c> NEOOperatorMaps,
													   List<SObject> oldObjectList,
													   NEO_Rule__c ruleRow) {
		Map<String, NEO_Variable_Association__c> NEOVariableAssociationMaps = NEO_Rules_Constants.NEOVariableAssociationMaps;

		// Get total summarized object list
		List<sObject> allSummarizedObjectList = new List<sObject>();

		String relationshipName = '';
		String summarizedObjectName = '';
		if (String.isNotBlank(tempResourceAggregationObj.NEO_Summarized_Object__c) && 
			NEOVariableAssociationMaps.containsKey(tempResourceAggregationObj.NEO_Summarized_Object__c)) {
			NEO_Variable_Association__c tempVariableAssociationSource = NEOVariableAssociationMaps.get(tempResourceAggregationObj.NEO_Summarized_Object__c);

			relationshipName = tempVariableAssociationSource.NEO_Relationship_Name__c;
			summarizedObjectName = tempVariableAssociationSource.NEO_Child_Object_API_Name__c;
		}

		if (String.isNotBlank(relationshipName)) {
			allSummarizedObjectList = oldObjRow.getSObjects(relationshipName);
		}

		if (allSummarizedObjectList == null) {
			allSummarizedObjectList = new List<sObject>();
		}

		System.debug(LoggingLevel.DEBUG, '-------->allSummarizedObjectList: ' + allSummarizedObjectList);

		// Need NEO_Summarized_All_Records__c
		if (tempResourceAggregationObj.NEO_Summarized_All_Records__c) {
			String strSOQL = createAllSummarizedRecordsQuery(tempResourceAggregationObj);

			// Summarize all records
			if (allRecordsCache.containsKey(tempResourceAggregationObj.Id)) {
				allSummarizedObjectList = allRecordsCache.get(tempResourceAggregationObj.Id);

			} else {
				List<String> fieldsToGroupList = new List<String>();
				String strFieldsToGroup = tempResourceAggregationObj.Fields_To_Group__c;
				if (String.isNotBlank(strFieldsToGroup)) {
					// Field to group list
					fieldsToGroupList = strFieldsToGroup.split(',');
				}

				String strWhere = '';
				for (String strGroupFieldName : fieldsToGroupList) {
					Set<String> filterPartsSet = new Set<String>();

					for (SObject summarizedSObjectRow : allSummarizedObjectList) {
						Object objectValue = getValueByFieldName(summarizedSObjectRow, strGroupFieldName);

						String groupFieldDataType = getFieldTypeByName(summarizedObjectName, strGroupFieldName, false);
						
						if (groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_REFERENCE.toUpperCase() ||
							groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_EMAIL.toUpperCase() ||
							groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PHONE.toUpperCase() ||
							groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PICKLIST.toUpperCase() ||
							groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_TEXT.toUpperCase() ||
							groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_URL.toUpperCase() ||
							groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_STRING.toUpperCase()) {
							// String
							filterPartsSet.add(strGroupFieldName + ' = \'' + String.valueOf(objectValue) + '\'');

						} else if (groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE.toUpperCase()) {
							// Date
							String strDateValue = DateTime.newInstance(Date.valueOf(objectValue), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
							filterPartsSet.add(strGroupFieldName + ' = ' + strDateValue);

						} else if (groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME.toUpperCase()) {
							// Datetime
							String strDatetimeValue = objectValue <> null ? Datetime.valueOf(objectValue).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : '';
							filterPartsSet.add(strGroupFieldName + ' = ' + String.valueOf(objectValue));

						} else if (groupFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_BOOLEAN.toUpperCase()) {
							// Boolean
							filterPartsSet.add(strGroupFieldName + ' = ' + Boolean.valueOf(objectValue));
						}
					}

					if (filterPartsSet.size() > 0) {
						if (String.isNotBlank(strWhere)) {
							strWhere += ' AND ';
						}
						strWhere += '(' + String.join(new List<String>(filterPartsSet), ' OR ') + ')';
					}
				}

				if (String.isNotBlank(strWhere)) {
					strSOQL += ' WHERE ' + strWhere;
					allSummarizedObjectList = Database.query(strSOQL);
				}

				if (allSummarizedObjectList <> null && allSummarizedObjectList.size() > 0) {
					allRecordsCache.put(tempResourceAggregationObj.Id, allSummarizedObjectList);
				}
			}
		}

		List<SObject> tempAvailableSobjectList = new List<SObject>();
		Map<Decimal, Boolean> tempAggregationCriteriaResultMaps = new Map<Decimal, Boolean>();

		// Custom_Logic__c
		String tempStrAggregationCustomLogic = tempResourceAggregationObj.Custom_Logic__c;

		if (String.isBlank(tempStrAggregationCustomLogic)) {
			tempAvailableSobjectList = allSummarizedObjectList;

		} else {
			// Filter available records list
			for (sObject tempSummarizedObjRow : allSummarizedObjectList) {
				for (NEO_Criteria__c tempAggregationCriteriaRow : tempResourceAggregationObj.NEO_Criterias__r) {
					Decimal tempRowSerialNo = tempAggregationCriteriaRow.Row_Serial_No__c;
					if (tempRowSerialNo == null) {
						continue;
					}
					tempAggregationCriteriaResultMaps.put(tempRowSerialNo, checkCriteriaRow(tempSummarizedObjRow, tempSummarizedObjRow, parentObjRow, tempAggregationCriteriaRow, oldObjectList, ruleRow));
				}

				// Custom Logic Result
				if (checkCustomLogic(tempStrAggregationCustomLogic, tempAggregationCriteriaResultMaps)) {
					tempAvailableSobjectList.add(tempSummarizedObjRow);
				}
			}
		}

		// Field to group list
		List<String> fieldsToGroupList = new List<String>();
		String strFieldsToGroup = tempResourceAggregationObj.Fields_To_Group__c;
		if (String.isNotBlank(strFieldsToGroup)) {
			fieldsToGroupList = strFieldsToGroup.split(',');
		}

		// Fields_To_Aggregate__c
		String strFieldsToAggregateVariableAPIName = '';
		if (String.isNotBlank(tempResourceAggregationObj.Fields_To_Aggregate__c) && 
			NEOVariableMaps.containsKey(tempResourceAggregationObj.Fields_To_Aggregate__c)) {
			strFieldsToAggregateVariableAPIName = NEOVariableMaps.get(tempResourceAggregationObj.Fields_To_Aggregate__c).Variable_API_Name__c;
		}

		// Roll-up type
		List<Decimal> tempAggregtionResultList = new List<Decimal>();

		// Get roll-up type: Count, Sum, Max, Min
		String tempRollupType = tempResourceAggregationObj.Roll_Up_Type__c;
		if (tempRollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_COUNT) {
			// Count
			tempAggregtionResultList = getCountRollupResultsList(tempAvailableSobjectList, fieldsToGroupList);

		} else if (tempRollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_SUM) {
			// Sum
			tempAggregtionResultList = getSumRollupResultsList(tempAvailableSobjectList, strFieldsToAggregateVariableAPIName, fieldsToGroupList);

		} else if (tempRollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_MAX) {
			// Max
			tempAggregtionResultList = getMaxRollupResultsList(tempAvailableSobjectList, strFieldsToAggregateVariableAPIName);
			
		} else if (tempRollupType == NEO_Rules_Constants.NEO_ROLL_UP_TYPE_MIN) {
			// Min
			tempAggregtionResultList = getMinRollupResultsList(tempAvailableSobjectList, strFieldsToAggregateVariableAPIName);
		}

		System.debug(LoggingLevel.DEBUG, '-------->tempAggregtionResultList: ' + tempAggregtionResultList);

		return tempAggregtionResultList;
	}*/

	// Get count roll-up results
	private static List<Decimal> getCountRollupResultsList(List<SObject> availableSobjectList, List<String> fieldsToGroupList) {
		List<Decimal> rollupResultsList = new List<Decimal>();
		// No group field
		if (fieldsToGroupList.size() < 1) {
			rollupResultsList.add(availableSobjectList.size());
			return rollupResultsList;
		}

		Map<String, Decimal> aggregateResultMaps = new Map<String, Decimal>();
		for (SObject tempAvailableObjRow : availableSobjectList) {
			// Get key
			String strKey = '';
			for (String tempStrFieldToGroupName : fieldsToGroupList) {
				if (String.isNotBlank(strKey)) {
					strKey += '__';
				}
				strKey += getValueByFieldName(tempAvailableObjRow, tempStrFieldToGroupName);
			}

			if (String.isBlank(strKey)) {
				continue;
			}

			if (aggregateResultMaps.containsKey(strKey)) {
				aggregateResultMaps.put(strKey, (aggregateResultMaps.get(strKey) + 1));
			} else {
				aggregateResultMaps.put(strKey, 1);
			}
		}

		if (aggregateResultMaps.size() > 0) {
			rollupResultsList = aggregateResultMaps.values();
		}
		return rollupResultsList;
	}

	// Get sum roll-up results
	private static List<Decimal> getSumRollupResultsList(List<SObject> availableSobjectList, String strFieldsToAggregateVariableAPIName, List<String> fieldsToGroupList) {
		List<Decimal> rollupResultsList = new List<Decimal>();

		if (fieldsToGroupList.size() < 1) {
			// No group
			Decimal totalAggregateValue = 0;
			for (SObject tempAvailableObjRow : availableSobjectList) {
				Object objFieldToAggregateValue = getValueByFieldName(tempAvailableObjRow, strFieldsToAggregateVariableAPIName);
				
				if (objFieldToAggregateValue <> null) {
					totalAggregateValue += Decimal.valueOf(String.valueOf(objFieldToAggregateValue));
				}
			}
			rollupResultsList.add(totalAggregateValue);

		} else {
			// Group by
			Map<String, Decimal> aggregateResultMaps = new Map<String, Decimal>();
			for (SObject tempAvailableObjRow : availableSobjectList) {
				Object objFieldToAggregateValue = getValueByFieldName(tempAvailableObjRow, strFieldsToAggregateVariableAPIName);
				if (objFieldToAggregateValue == null) {
					continue;
				}

				Decimal decimalFieldToAggregateValue = Decimal.valueOf(String.valueOf(objFieldToAggregateValue));
				// Get key
				String strKey = '';
				for (String tempStrFieldToGroupName : fieldsToGroupList) {
					if (String.isNotBlank(strKey)) {
						strKey += '__';
					}
					strKey += getValueByFieldName(tempAvailableObjRow, tempStrFieldToGroupName);
				}

				if (String.isBlank(strKey)) {
					continue;
				}

				if (aggregateResultMaps.containsKey(strKey)) {
					aggregateResultMaps.put(strKey, (aggregateResultMaps.get(strKey) + decimalFieldToAggregateValue));
				} else {
					aggregateResultMaps.put(strKey, decimalFieldToAggregateValue);
				}
			}

			if (aggregateResultMaps.size() > 0) {
				rollupResultsList = aggregateResultMaps.values();
			}
		}

		return rollupResultsList;
	}

	// Get max roll-up results
	private static List<Decimal> getMaxRollupResultsList(List<SObject> availableSobjectList, String strFieldsToAggregateVariableAPIName) {
		List<Decimal> rollupResultsList = new List<Decimal>();

		Integer j = 0;
		Decimal maxRollupValue = null;

		for (SObject tempAvailableObjRow : availableSobjectList) {
			Decimal decimalFieldToAggregateValue = Decimal.valueOf(String.valueOf(tempAvailableObjRow.get(strFieldsToAggregateVariableAPIName)));
			if (decimalFieldToAggregateValue == null) {
				continue;
			}

			if (j < 1) {
				maxRollupValue = decimalFieldToAggregateValue;
			} else {
				maxRollupValue = Math.max(maxRollupValue, decimalFieldToAggregateValue);
			}

			++j;
		}

		if (maxRollupValue <> null) {
			rollupResultsList.add(maxRollupValue);
		}
		return rollupResultsList;
	}

	// Get min roll-up results
	private static List<Decimal> getMinRollupResultsList(List<SObject> availableSobjectList, String strFieldsToAggregateVariableAPIName) {
		List<Decimal> rollupResultsList = new List<Decimal>();

		Integer j = 0;
		Decimal minRollupValue = null;

		for (SObject tempAvailableObjRow : availableSobjectList) {
			Decimal decimalFieldToAggregateValue = Decimal.valueOf(String.valueOf(tempAvailableObjRow.get(strFieldsToAggregateVariableAPIName)));
			if (decimalFieldToAggregateValue == null) {
				continue;
			}

			if (j < 1) {
				minRollupValue = decimalFieldToAggregateValue;
			} else {
				minRollupValue = Math.min(minRollupValue, decimalFieldToAggregateValue);
			}

			++j;
		}

		if (minRollupValue <> null) {
			rollupResultsList.add(minRollupValue);
		}
		return rollupResultsList;
	}

	// Get value by field name
	public static Object getValueByFieldName(SObject objRow, String fieldName) {
		Object returnValueObj = null;
		SObject tempSObjectSource = objRow;

		if (tempSObjectSource == null || String.isBlank(fieldName)) {
			return returnValueObj;
		}

		// Split field name
		List<String> fieldNameList = fieldName.split('\\.');
		Integer j = 0;
		for (String tempStrFieldNameRow : fieldNameList) {
			if (j == (fieldNameList.size() - 1) && tempSObjectSource <> null) {
				returnValueObj = tempSObjectSource.get(tempStrFieldNameRow);
			} else if (tempSObjectSource <> null) {
				tempSObjectSource = tempSObjectSource.getSObject(tempStrFieldNameRow);
			}

			++j;
		}
		return returnValueObj;
	}

	// Datetime
	private static Boolean executeDateTimeFormatter(Object arg0, Object arg1, String formatter, Boolean specalValueOrNot) {
		Boolean booleanResult = false;
		if (String.isBlank(formatter)) {
			return booleanResult;
		}

		if (formatter == NEO_Rules_Constants.NEO_DATETIME_ADD_YEARS_FORMATTER) {
			// Now Add N years
			Datetime dtArg0 = (arg0 == null ? null : Datetime.valueOf(String.valueOf(arg0)));
			Integer dtArg1 = (arg1 == null ? 0 : Integer.valueOf(String.valueOf(arg1)));
			booleanResult = dtArg0 > System.now().addMonths(-dtArg1);

		} else if (formatter == NEO_Rules_Constants.NEO_DATETIME_ADD_MONTHS_FORMATTER) {
			// Now Add N months
			Datetime dtArg0 = (arg0 == null ? null : Datetime.valueOf(String.valueOf(arg0)));
			Integer dtArg1 = (arg1 == null ? 0 : Integer.valueOf(String.valueOf(arg1)));
			booleanResult = dtArg0 > System.now().addMonths(-dtArg1);

		} else if (formatter == NEO_Rules_Constants.NEO_DATETIME_ADD_DAYS_FORMATTER) {
			// Now Add N days
			Datetime dtArg0 = (arg0 == null ? null : Datetime.valueOf(String.valueOf(arg0)));
			Integer dtArg1 = (arg1 == null ? 0 : Integer.valueOf(String.valueOf(arg1)));
			booleanResult = dtArg0 > System.now().addDays(-dtArg1);

		} else if (NEO_Rules_Constants.NEO_EQUAL_FORMATTER == formatter) {
			// Equal
			Datetime dtArg0 = (arg0 == null ? null : Datetime.valueOf(String.valueOf(arg0)));
			Datetime dtArg1 = (arg1 == null ? null : Datetime.valueOf(String.valueOf(arg1)));
			booleanResult = (dtArg0 == dtArg1);

		} else if (NEO_Rules_Constants.NEO_NOT_EQUAL_FORMATTER == formatter) {
			// Not equal
			Datetime dtArg0 = (arg0 == null ? null : Datetime.valueOf(String.valueOf(arg0)));
			Datetime dtArg1 = (arg1 == null ? null : Datetime.valueOf(String.valueOf(arg1)));
			booleanResult = (dtArg0 <> dtArg1);

		} else if (NEO_Rules_Constants.NEO_GREATER_THAN_FORMATTER == formatter) {
			// Greater than
			Datetime dtArg0 = (arg0 == null ? null : Datetime.valueOf(String.valueOf(arg0)));
			Datetime dtArg1 = (arg1 == null ? null : (specalValueOrNot ? Datetime.valueOf(String.valueOf(arg1)) : (DateTime)Json.deserialize('"' + arg1 + '"', DateTime.class)));
			booleanResult = (dtArg0 > dtArg1);

		} else if (NEO_Rules_Constants.NEO_GREATER_OR_EQUAL_FORMATTER == formatter) {
			// Greater or equal
			Datetime dtArg0 = (arg0 == null ? null : Datetime.valueOf(String.valueOf(arg0)));
			Datetime dtArg1 = (arg1 == null ? null : Datetime.valueOf(String.valueOf(arg1)));
			booleanResult = (dtArg0 >= dtArg1);

		} else if (NEO_Rules_Constants.NEO_LESS_THAN_FORMATTER == formatter) {
			// Less than
			Datetime dtArg0 = (arg0 == null ? null : Datetime.valueOf(String.valueOf(arg0)));
			Datetime dtArg1 = (arg1 == null ? null : Datetime.valueOf(String.valueOf(arg1)));
			booleanResult = (dtArg0 < dtArg1);

		} else if (NEO_Rules_Constants.NEO_LESS_OR_EQUAL_FORMATTER == formatter) {
			// Less or equal
			Datetime dtArg0 = (arg0 == null ? null : Datetime.valueOf(String.valueOf(arg0)));
			Datetime dtArg1 = (arg1 == null ? null : Datetime.valueOf(String.valueOf(arg1)));
			booleanResult = (dtArg0 <= dtArg1);
		}

		return booleanResult;
	}

	// Date
	private static Boolean executeDateFormatter(Object arg0, Object arg1, String formatter, Boolean specalValueOrNot) {
		Boolean booleanResult = false;
		if (String.isBlank(formatter)) {
			return booleanResult;
		}

		if (formatter == NEO_Rules_Constants.NEO_DATE_ADD_YEARS_FORMATTER) {
			// Add years
			Date dtArg0 = (arg0 == null ? null : Date.valueOf(arg0));
			Integer dtArg1 = (arg1 == null ? 0 : Integer.valueOf(String.valueOf(arg1)));
			booleanResult = dtArg0 > System.today().addYears(-dtArg1);
		}
		if (formatter == NEO_Rules_Constants.NEO_DATE_ADD_MONTHS_FORMATTER) {
			Date dtArg0 = (arg0 == null ? null : Date.valueOf(arg0));
			Integer dtArg1 = (arg1 == null ? 0 : Integer.valueOf(String.valueOf(arg1)));
			booleanResult = dtArg0 > System.today().addMonths(-dtArg1);

		} else if (formatter == NEO_Rules_Constants.NEO_DATE_ADD_DAYS_FORMATTER) {
			Date dtArg0 = (arg0 == null ? null : Date.valueOf(arg0));
			Integer dtArg1 = (arg1 == null ? 0 : Integer.valueOf(String.valueOf(arg1)));
			booleanResult = dtArg0 > System.today().addDays(-dtArg1);

		} else if (NEO_Rules_Constants.NEO_EQUAL_FORMATTER == formatter) {
			// Equal
			Date dtArg0 = (arg0 == null ? null : Date.valueOf(arg0));
			Date dtArg1 = (arg1 == null ? null : Date.valueOf(arg1));
			booleanResult = (dtArg0 == dtArg1);

		} else if (NEO_Rules_Constants.NEO_NOT_EQUAL_FORMATTER == formatter) {
			// Not equal
			Date dtArg0 = (arg0 == null ? null : Date.valueOf(arg0));
			Date dtArg1 = (arg1 == null ? null : Date.valueOf(arg1));
			booleanResult = (dtArg0 <> dtArg1);

		} else if (NEO_Rules_Constants.NEO_GREATER_THAN_FORMATTER == formatter) {
			// Greater than
			Date dtArg0 = (arg0 == null ? null : Date.valueOf(arg0));
			Date dtArg1 = (arg1 == null ? null : Date.valueOf(arg1));
			booleanResult = (dtArg0 > dtArg1);

		} else if (NEO_Rules_Constants.NEO_GREATER_OR_EQUAL_FORMATTER == formatter) {
			// Greater or equal
			Date dtArg0 = (arg0 == null ? null : Date.valueOf(arg0));
			Date dtArg1 = (arg1 == null ? null : Date.valueOf(arg1));
			booleanResult = (dtArg0 >= dtArg1);

		} else if (NEO_Rules_Constants.NEO_LESS_THAN_FORMATTER == formatter) {
			// Less than
			Date dtArg0 = (arg0 == null ? null : Date.valueOf(arg0));
			Date dtArg1 = (arg1 == null ? null : Date.valueOf(arg1));
			booleanResult = (dtArg0 < dtArg1);

		} else if (NEO_Rules_Constants.NEO_LESS_OR_EQUAL_FORMATTER == formatter) {
			// Less or equal
			Date dtArg0 = (arg0 == null ? null : Date.valueOf(arg0));
			Date dtArg1 = (arg1 == null ? null : Date.valueOf(arg1));
			booleanResult = (dtArg0 <= dtArg1);

		}

		return booleanResult;
	}

	// Numeric math operator
	private static Decimal executeNumericEval(Object arg0, Object arg1, String formatter) {
		Decimal decimalResult = null;
		if (arg0 == null) {
			arg0 = 0;
		}
		if (arg1 == null) {
			arg1 = 0;
		}
		if (String.isBlank(formatter)) {
			return decimalResult;
		}

		if ((formatter == NEO_Rules_Constants.NEO_DIVIDE_FORMATTER || 
			formatter == NEO_Rules_Constants.NEO_MODE_FORMATTER) && 
			Decimal.valueOf(String.valueOf(arg1)) == 0) {
			return decimalResult;
		}

		Decimal tempArg0 = Decimal.valueOf(String.valueOf(arg0));
		Decimal tempArg1 = Decimal.valueOf(String.valueOf(arg1));

		// Formatter type
		if (formatter == NEO_Rules_Constants.NEO_MODE_FORMATTER) {
			// Mod
			decimalResult = Math.mod(Integer.valueOf(tempArg0), Integer.valueOf(tempArg1));

		} else {
			// Other
			formatter = formatter.replaceAll('arg0', String.valueOf(tempArg0));
			formatter = formatter.replaceAll('arg1', String.valueOf(tempArg1));
			decimalResult = new NEO_Rules_Expression(formatter).eval();
		}
		return decimalResult;
	}

	// Date math operator
	private static Date executeDateEval(Object arg0, Object arg1, String formatter) {
		Date dateResult = null;
		if (arg0 == null || arg1 == null ||String.isBlank(formatter)) {
			return dateResult;
		}

		Date tempArg0 = Date.valueOf(String.valueOf(arg0));
		Integer tempArg1 = Integer.valueOf(String.valueOf(arg1));

		// Formatter type
		if (formatter == NEO_Rules_Constants.NEO_DATE_OR_DATETIME_ADD_DAYS) {
			// Add days
			dateResult = tempArg0.addDays(tempArg1);

		} else if (formatter == NEO_Rules_Constants.NEO_DATE_OR_DATETIME_ADD_MONTHS) {
			// Add months
			dateResult = tempArg0.addMonths(tempArg1);

		} else if (formatter == NEO_Rules_Constants.NEO_DATE_OR_DATETIME_ADD_YEARS) {
			// Add years
			dateResult = tempArg0.addYears(tempArg1);
		}

		return dateResult;
	}

	// Datetime math operator
	private static Datetime executeDatetimeEval(Object arg0, Object arg1, String formatter) {
		Datetime dateResult = null;
		if (arg0 == null || arg1 == null ||String.isBlank(formatter)) {
			return dateResult;
		}

		Datetime tempArg0 = Datetime.valueOf(String.valueOf(arg0));
		Integer tempArg1 = Integer.valueOf(String.valueOf(arg1));

		// Formatter type
		if (formatter == NEO_Rules_Constants.NEO_DATE_OR_DATETIME_ADD_HOURS) {
			// Add hours
			dateResult = tempArg0.addHours(tempArg1);

		} else if (formatter == NEO_Rules_Constants.NEO_DATE_OR_DATETIME_ADD_DAYS) {
			// Add days
			dateResult = tempArg0.addDays(tempArg1);

		} else if (formatter == NEO_Rules_Constants.NEO_DATE_OR_DATETIME_ADD_MONTHS) {
			// Add months
			dateResult = tempArg0.addMonths(tempArg1);

		} else if (formatter == NEO_Rules_Constants.NEO_DATE_OR_DATETIME_ADD_YEARS) {
			// Add years
			dateResult = tempArg0.addYears(tempArg1);
		}

		return dateResult;
	}

	// String
	private static Boolean executeStringFormatter(Object arg0, Object arg1, String formatter) {
		Boolean booleanResult = false;
		if (String.isBlank(formatter)) {
			return booleanResult;
		}

		String tempArg0 = (arg0 == null) ? '' : String.valueOf(arg0).toUpperCase();
		String tempArg1 = (arg1 == null) ? '' : String.valueOf(arg1).toUpperCase();

		if (NEO_Rules_Constants.NEO_EQUAL_FORMATTER == formatter) {
			// Equal
			booleanResult = (tempArg0 == tempArg1);
		} else if (NEO_Rules_Constants.NEO_NOT_EQUAL_FORMATTER == formatter) {
			// Not equal
			booleanResult = (tempArg0 <> tempArg1);
		} else if (NEO_Rules_Constants.NEO_CONTAINS_FORMATTER == formatter) {
			// Contains
			booleanResult = (tempArg0.contains(tempArg1));

		} else if (NEO_Rules_Constants.NEO_NOT_CONTAINS_FORMATTER == formatter) {
			// Not Contains
			booleanResult = !(tempArg0.contains(tempArg1));

		} else if (NEO_Rules_Constants.NEO_IN_FORMATTER == formatter) {
			// In
			List<String> tempArg1List = new List<String>();
			for (String tempArg1Row : tempArg1.split(',')) {
				tempArg1List.add(tempArg1Row.trim());
			}

			booleanResult = (tempArg1List.contains(tempArg0));

		} else if (NEO_Rules_Constants.NEO_NOT_IN_FORMATTER == formatter) {
			// Not IN
			List<String> tempArg1List = new List<String>();
			for (String tempArg1Row : tempArg1.split(',')) {
				tempArg1List.add(tempArg1Row.trim());
			}

			booleanResult = !(tempArg1List.contains(tempArg0));

		} else if (NEO_Rules_Constants.NEO_STARTS_WITH_FORMATTER == formatter) {
			// Starts with
			booleanResult = (tempArg0.startsWith(tempArg1));

		} else if (NEO_Rules_Constants.NEO_NOT_STARTS_WITH_FORMATTER == formatter) {
			// Not starts with
			booleanResult = !(tempArg0.startsWith(tempArg1));

		}
		return booleanResult;
	}

	// Numeric
	private static Boolean executeNumericFormatter(Object arg0, Object arg1, Object arg2, String formatter) {
		Boolean booleanResult = false;
		if (String.isBlank(formatter)) {
			return booleanResult;
		}

		Decimal tempArg0 = (arg0 == null) ? null : Decimal.valueOf(String.valueOf(arg0));
		Decimal tempArg1 = (arg1 == null) ? null : Decimal.valueOf(String.valueOf(arg1));
		Decimal tempArg2 = (arg2 == null) ? null : Decimal.valueOf(String.valueOf(arg2));

		if (NEO_Rules_Constants.NEO_EQUAL_FORMATTER == formatter) {
			// Equal
			booleanResult = (tempArg0 == tempArg1);

		} else if (NEO_Rules_Constants.NEO_NOT_EQUAL_FORMATTER == formatter) {
			// Not equal
			booleanResult = (tempArg0 <> tempArg1);

		} else if (NEO_Rules_Constants.NEO_GREATER_THAN_FORMATTER == formatter) {
			// Greater than
			booleanResult = (tempArg0 > tempArg1);

		} else if (NEO_Rules_Constants.NEO_GREATER_OR_EQUAL_FORMATTER == formatter) {
			// Greater or equal
			booleanResult = (tempArg0 >= tempArg1);

		} else if (NEO_Rules_Constants.NEO_LESS_THAN_FORMATTER == formatter) {
			// Less than
			booleanResult = (tempArg0 < tempArg1);

		} else if (NEO_Rules_Constants.NEO_LESS_OR_EQUAL_FORMATTER == formatter) {
			// Less or equal
			booleanResult = (tempArg0 <= tempArg1);

		} else if (NEO_Rules_Constants.NEO_BETWEEN_AND_FORMATTER == formatter) {
			// Between and
			booleanResult = (tempArg0 >= tempArg1 && tempArg0 < tempArg2);

		}
		return booleanResult;
	}

	// Get picklist values by object name and field name
	global static List<NEO_Rules_Constants.MySelectOption> getPicklistOptionsByObjectName(String objectTypeName, String fieldName) {
		List<NEO_Rules_Constants.MySelectOption> picklistValueOptions = new List<NEO_Rules_Constants.MySelectOption>();

		Map<String, Schema.DescribeSObjectResult> describeSObjectMaps = NEO_Rules_Constants.describeSObjectMaps;
		if (String.isBlank(objectTypeName) || String.isBlank(fieldName)) {
			return picklistValueOptions;
		}

		// Lookup fields
		if (fieldName.indexOf('.') != -1) {
			List<String> fieldPartList = fieldName.split('\\.');

			Integer length = fieldPartList.size();
			String tempStrFieldName = fieldPartList.get(length - 1);

			String tempFinalSObjectType = objectTypeName;

			for (Integer j = 0; j < length - 1; j++) {
				String tempStrLookupName = fieldPartList.get(j).replaceAll('__r', '__c');
				tempFinalSObjectType = getSObjectTypeByObjectName(tempFinalSObjectType, tempStrLookupName);
			}

			return getPicklistOptionsByObjectName(tempFinalSObjectType, tempStrFieldName);
		}

		if (!describeSObjectMaps.containsKey(objectTypeName)) {
			for (Schema.DescribeSObjectResult tempDescribeSObjectResultRow : Schema.describeSObjects(new List<String> { objectTypeName })) {
            	describeSObjectMaps.put(tempDescribeSObjectResultRow.getName(), tempDescribeSObjectResultRow);
        	}
		}

		Map<String, Schema.SObjectField> sobjectTypeFieldsMaps = describeSObjectMaps.get(objectTypeName).fields.getMap();

		if (sobjectTypeFieldsMaps.containsKey(fieldName)) {
            Schema.SObjectField sobjectFieldSource = sobjectTypeFieldsMaps.get(fieldName);
            String strFieldDataType = sobjectFieldSource.getDescribe().getType().name();

            if (strFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PICKLIST ||
            	strFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_MULTI_PICKLIST) {
                for (Schema.PicklistEntry picklistEntryRow : sobjectFieldSource.getDescribe().getPicklistValues()) {
                    picklistValueOptions.add(new NEO_Rules_Constants.MySelectOption(picklistEntryRow.getValue(), picklistEntryRow.getLabel()));
                }
            }
		}
		
		return picklistValueOptions;
	}

	// Get lookup field sobject type by object name and field name
	global static String getSObjectTypeByObjectName(String objectTypeName, String fieldName) {
		String sObjectTypeName = '';

		Map<String, Schema.DescribeSObjectResult> describeSObjectMaps = NEO_Rules_Constants.describeSObjectMaps;
		if (String.isBlank(objectTypeName) || String.isBlank(fieldName)) {
			return sObjectTypeName;
		}

		if (!describeSObjectMaps.containsKey(objectTypeName)) {
			for (Schema.DescribeSObjectResult tempDescribeSObjectResultRow : Schema.describeSObjects(new List<String> { objectTypeName })) {
            	describeSObjectMaps.put(tempDescribeSObjectResultRow.getName(), tempDescribeSObjectResultRow);
        	}
		}

		Map<String, Schema.SObjectField> sobjectTypeFieldsMaps = describeSObjectMaps.get(objectTypeName).fields.getMap();

		if (sobjectTypeFieldsMaps.containsKey(fieldName)) {
            Schema.SObjectField sobjectFieldSource = sobjectTypeFieldsMaps.get(fieldName);
            String strFieldDataType = sobjectFieldSource.getDescribe().getType().name();
            if (String.isNotBlank(strFieldDataType)) {
            	strFieldDataType = strFieldDataType.toLowerCase().capitalize();
            }

            if (strFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_REFERENCE) {
            	List<Schema.SObjectType> tempSObjectTypeList = sobjectFieldSource.getDescribe().getReferenceTo();
            	if (tempSObjectTypeList.size() > 0) {
            		sObjectTypeName = tempSObjectTypeList.get(0).getDescribe().getName();
            	}
            }
		}
		return sObjectTypeName;
	}

	// Get filed type by object name and field name
	global static String getFieldTypeByName(String objectTypeName, String fieldName, Boolean isObjectType) {
		String strFieldDataType = null;

		Map<String, Schema.DescribeSObjectResult> describeSObjectMaps = NEO_Rules_Constants.describeSObjectMaps;

		// Lookup fields
		if (fieldName.indexOf('.') != -1) {
			List<String> fieldPartList = fieldName.split('\\.');

			Integer length = fieldPartList.size();

			String tempStrFieldName = fieldPartList.get(length - 1);
			String tempFinalSObjectType = objectTypeName;

			for (Integer j = 0; j < length - 1; j++) {
				String tempStrLookupName = fieldPartList.get(j).replaceAll('__r', '__c');
				tempFinalSObjectType = getSObjectTypeByObjectName(tempFinalSObjectType, tempStrLookupName);
			}

			return getFieldTypeByName(tempFinalSObjectType, tempStrFieldName, isObjectType);
		}

		if (!describeSObjectMaps.containsKey(objectTypeName)) {
			for (Schema.DescribeSObjectResult tempDescribeSObjectResultRow : Schema.describeSObjects(new List<String> { objectTypeName })) {
            	describeSObjectMaps.put(tempDescribeSObjectResultRow.getName(), tempDescribeSObjectResultRow);
        	}
		}

		Map<String, Schema.SObjectField> sobjectTypeFieldsMaps = describeSObjectMaps.get(objectTypeName).fields.getMap();

		if (sobjectTypeFieldsMaps.containsKey(fieldName)) {
            Schema.SObjectField sobjectFieldSource = sobjectTypeFieldsMaps.get(fieldName);
            strFieldDataType = sobjectFieldSource.getDescribe().getType().name();
            strFieldDataType = String.isNotBlank(strFieldDataType) ? strFieldDataType.toUpperCase() : strFieldDataType;

            if (strFieldDataType == NEO_Rules_Constants.NEO_DATA_TYPE_REFERENCE.toUpperCase() && isObjectType) {
            	List<Schema.SObjectType> tempSObjectTypeList = sobjectFieldSource.getDescribe().getReferenceTo();
            	if (tempSObjectTypeList.size() > 0) {
            		strFieldDataType = tempSObjectTypeList.get(0).getDescribe().getName();
            	}
            }
		}

		return strFieldDataType;
	}

	// Get field label maps by object type
	global static Map<String, Map<String, String>> getFieldsMapByObjectName(Set<String> objectTypeSet) {
		Map<String, Map<String, String>> objectTypeFieldsMap = new Map<String, Map<String, String>>();
		Map<String, Schema.DescribeSObjectResult> describeSObjectMaps = new Map<String, Schema.DescribeSObjectResult>();

		Map<String, String> fieldsNameMaps = new Map<String, String>();

		if (objectTypeSet == null || objectTypeSet.size() < 1) {
			return objectTypeFieldsMap;
		}

		for (Schema.DescribeSObjectResult tempDescribeSObjectResultRow : Schema.describeSObjects(new List<String>(objectTypeSet))) {
			describeSObjectMaps.put(tempDescribeSObjectResultRow.getName(), tempDescribeSObjectResultRow);
		}

		for (String objName : objectTypeSet) {
			Map<String, Schema.SObjectField> sobjectTypeFieldsMaps = describeSObjectMaps.get(objName).fields.getMap(); 

			Map<String, String> fieldsNameMap = new Map<String, String>(); 
			Set<String> objNameSet = sobjectTypeFieldsMaps.keySet();
			for (String fieldsName : objNameSet) {
				SObjectField sObjectfields = sobjectTypeFieldsMaps.get(fieldsName);
				DescribeFieldResult selectField = sObjectfields.getDescribe();
				fieldsNameMap.put(selectField.getName(), selectField.getLabel());
			}
			objectTypeFieldsMap.put(objName, fieldsNameMap);
		}
		return objectTypeFieldsMap;
	}

	// Get all fields by object type
	public static List<String> getFieldsByObjectName(String objectType) {
		List<String> objectTypeFieldsList = new List<String>();

		Map<String, Schema.DescribeSObjectResult> describeSObjectMaps = new Map<String, Schema.DescribeSObjectResult>();

		List<String> fieldsNameList = new List<String>();

		if (String.isBlank(objectType)) {
			return objectTypeFieldsList;
		}

		for (Schema.DescribeSObjectResult tempDescribeSObjectResultRow : Schema.describeSObjects(new List<String> { objectType })) {
			describeSObjectMaps.put(tempDescribeSObjectResultRow.getName(), tempDescribeSObjectResultRow);
		}

		Map<String, Schema.SObjectField> sobjectTypeFieldsMaps = describeSObjectMaps.get(objectType).fields.getMap();

		Set<String> objNameSet = sobjectTypeFieldsMaps.keySet();
		for (String fieldsName : objNameSet) {
			SObjectField sObjectfields = sobjectTypeFieldsMaps.get(fieldsName);
			DescribeFieldResult selectField = sObjectfields.getDescribe();
			objectTypeFieldsList.add(selectField.getName());
		}

		return objectTypeFieldsList;
	}

	// Get select fields list
	global static List<String> getSelectedFieldsList(String objectTypeName, Set<String> includeFieldsSet, Set<String> excludeFieldsSet, Boolean isReadOnly) {
		List<String> selectedFieldsList = new List<String>();
		Set<String> upperCaseExcludeFieldsSet = new Set<String>();

		if (includeFieldsSet == null) {
			includeFieldsSet = new Set<String>();
		}
		includeFieldsSet.add('CreatedBy.Name');
		includeFieldsSet.add('LastModifiedBy.Name');

		if (excludeFieldsSet <> null && excludeFieldsSet.size() > 0) {
			for (String strExcludeFieldName : excludeFieldsSet) {
				if (String.isBlank(strExcludeFieldName)) {
					continue;
				}
				upperCaseExcludeFieldsSet.add(strExcludeFieldName.toUpperCase());
			}
		}

		if (isReadOnly == null) {
			isReadOnly = false;
		}

		if (String.isBlank(objectTypeName)) {
			return selectedFieldsList;
		}

		Set<String> selectedFieldsSet = new Set<String>();

		Map<String, Schema.DescribeSObjectResult> describeSObjectMaps = new Map<String, Schema.DescribeSObjectResult>();
		if (!describeSObjectMaps.containsKey(objectTypeName)) {
			for (Schema.DescribeSObjectResult tempDescribeSObjectResultRow : Schema.describeSObjects(new List<String> { objectTypeName })) {
				describeSObjectMaps.put(tempDescribeSObjectResultRow.getName(), tempDescribeSObjectResultRow);
			}
		}

		Map<String, Schema.SObjectField> sobjectTypeFieldsMaps = describeSObjectMaps.get(objectTypeName).fields.getMap();
		for (Schema.SObjectField sobjectFieldObj : sobjectTypeFieldsMaps.values()) {
			Schema.DescribeFieldResult dfr = sobjectFieldObj.getDescribe();

			Boolean isUpdateable = (dfr.isUpdateable() || dfr.isCreateable()) && !dfr.isAutoNumber() && !dfr.isCalculated();
			String strFieldName = dfr.getName();
			if (upperCaseExcludeFieldsSet.contains(strFieldName.toUpperCase())) {
				continue;
			}

			if (isReadOnly) {
				selectedFieldsSet.add(strFieldName);

			} else if (isUpdateable) {
				selectedFieldsSet.add(strFieldName);
			}
		}

		if (includeFieldsSet.size() > 0) {
			selectedFieldsSet.addAll(includeFieldsSet);
		}

		if (selectedFieldsSet.size() > 0) {
			selectedFieldsList = new List<String>(selectedFieldsSet);
			selectedFieldsList.sort();
		}

		return selectedFieldsList;
	}

	public static Map<String, String> getFieldLabelMapByObjectName(String sObjectType) {
		Map<String, String> fieldLabelMaps = new Map<String, String>();
		Map<String, Schema.DescribeSObjectResult> describeSObjectMaps = new Map<String, Schema.DescribeSObjectResult>();

		if (String.isBlank(sObjectType)) {
			return fieldLabelMaps;
		}

		for (Schema.DescribeSObjectResult tempDescribeSObjectResultRow : Schema.describeSObjects(new List<String> { sObjectType })) {
			describeSObjectMaps.put(tempDescribeSObjectResultRow.getName(), tempDescribeSObjectResultRow);
		}
		Map<String, Schema.SObjectField> sobjectTypeFieldsMaps = describeSObjectMaps.get(sObjectType).fields.getMap();
		for (Schema.SObjectField sobjectFieldRow : sobjectTypeFieldsMaps.values()) {
			Schema.DescribeFieldResult dfr = sobjectFieldRow.getDescribe();

			fieldLabelMaps.put(dfr.getName(), dfr.getLabel());
		}
		return fieldLabelMaps;
	}

	public static Map<String, Object> getLayoutInfosMap(SObject obj, String sObjectType, NEO_Rule__c ruleObj) {
		Map<String, NEO_Rules_Constants.ObjectWrapper> objectWrapperMap = NEO_Rules_Constants.objectWrapperMap;

		Set<String> selectedFieldsSet = new Set<String>();
		String strSOQL = '';

		String layoutName = ruleObj.NEO_Layout__r.NEO_Layout_Full_Name__c;
        Object strRecordID = getValueByFieldName(obj, 'Id');

        Schema.DescribeSObjectResult dsrObj = Schema.describeSObjects(new List<String> { sObjectType }).get(0);
        Map<String, Schema.SObjectField> sObjectFieldMaps = dsrObj.fields.getMap();

        Map<String, Schema.DescribeFieldResult> dfrMaps = new Map<String, Schema.DescribeFieldResult>();
        for (Schema.SObjectField sfObj : sObjectFieldMaps.values()) {
            Schema.DescribeFieldResult dfr = sfObj.getDescribe();
            dfrMaps.put(dfr.getName(), dfr);
        }

        Set<String> removedEndIDFieldsSet = new Set<String> {
        	'CreatedById', 'LastModifiedById', 'RecordTypeId'
        };

        List<Metadata.Metadata> layoutMetadataList = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String>(new Set<String> { layoutName }));
        List<NEO_Rules_Constants.MyLayoutSection> layoutSectionList = new List<NEO_Rules_Constants.MyLayoutSection>();
        List<NEO_Rules_Constants.MyRelatedListItem> relatedListItems = new List<NEO_Rules_Constants.MyRelatedListItem>();

        for (Metadata.Metadata lmObj : layoutMetadataList) {
            String strFullName = lmObj.fullName;
            Metadata.Layout layoutObj = (Metadata.Layout)lmObj;

            List<Metadata.LayoutSection> tempLayoutSections = new List<Metadata.LayoutSection>();
            List<Metadata.RelatedListItem> tempRelatedListItems = new List<Metadata.RelatedListItem>();

            if (layoutObj.layoutSections <> null) {
            	tempLayoutSections = layoutObj.layoutSections;
            }

            if (layoutObj.relatedLists <> null) {
            	tempRelatedListItems = layoutObj.relatedLists;
            	System.debug(LoggingLevel.DEBUG, '-------->tempRelatedListItems: ' + tempRelatedListItems);
            }

            // Layout sections
            for (Metadata.LayoutSection layoutSectionObj : tempLayoutSections) {
                if (layoutSectionObj.layoutColumns == null || layoutSectionObj.label == 'Custom Links') {
                    continue;
                }

                Integer layoutColumnSize = layoutSectionObj.layoutColumns.size();
                NEO_Rules_Constants.MyLayoutSection myLayoutSectionObj = new NEO_Rules_Constants.MyLayoutSection(layoutColumnSize, layoutSectionObj.label);

                List<Integer> keyIndexList = new List<Integer>();
                Map<String, NEO_Rules_Constants.MyLayoutItem> layoutItemsMap = new Map<String, NEO_Rules_Constants.MyLayoutItem>();

                Integer columnIndex = 0;
                for (Metadata.LayoutColumn layoutColumnObj : layoutSectionObj.layoutColumns) {
                    if (layoutColumnObj.layoutItems == null) {
                        continue;
                    }

                    Integer keyIndex = columnIndex;

                    for (Metadata.LayoutItem layoutItemObj : layoutColumnObj.layoutItems) {
                        String strField = layoutItemObj.field;
                        /*
                        if (String.isBlank(strField)) {
                            continue;
                        }
                        */

                        Schema.DescribeFieldResult dfrObj = null;
                        String strBehavior = null;
                        if (String.isNotBlank(strField)) {
                        	dfrObj = dfrMaps.get(strField);
                        	strBehavior = layoutItemObj.behavior.name();
                        }

                        // Create layout item
                        NEO_Rules_Constants.MyLayoutItem myLayoutItemObj = new NEO_Rules_Constants.MyLayoutItem();
                        myLayoutItemObj.isReadOnly = (strBehavior == 'Readonly');
                        myLayoutItemObj.isRequired = (strBehavior == 'Required');

                        if (dfrObj <> null) {
                        	myLayoutItemObj.strName = dfrObj.getName();
	                        myLayoutItemObj.strLabel = dfrObj.getLabel();
	                        myLayoutItemObj.strValue = getValueByFieldName(obj, myLayoutItemObj.strName);
	                        myLayoutItemObj.strDisplayValue = myLayoutItemObj.strValue;
	                        myLayoutItemObj.strDataType = dfrObj.getType().name();
	                        myLayoutItemObj.strDisplayType = myLayoutItemObj.strDataType;
                        }

                        if (String.isNotBlank(myLayoutItemObj.strName) && removedEndIDFieldsSet.contains(myLayoutItemObj.strName)) {
                        	myLayoutItemObj.strLabel = myLayoutItemObj.strLabel.removeEnd('ID').trim();
                        }

                        if (myLayoutItemObj.strDataType == NEO_Rules_Constants.NEO_DATA_TYPE_REFERENCE.toUpperCase()) {
                            // Reference
                            List<Schema.SObjectType> fieldSObjectTypeList = dfrObj.getReferenceTo();
                            if (fieldSObjectTypeList.size() > 0) {
                                myLayoutItemObj.strReferenceTo = fieldSObjectTypeList.get(0).getDescribe().getName();
                                myLayoutItemObj.strRelationshipName = dfrObj.getRelationshipName();
                            }

                            if (myLayoutItemObj.strName == 'RecordTypeId') {
                            	List<NEO_Rules_Constants.MySelectOption> rtOptions = new List<NEO_Rules_Constants.MySelectOption>();
						        for (Schema.RecordTypeInfo rtObj : dsrObj.getRecordTypeInfosByDeveloperName().values()) {
						            String strRtId = rtObj.getRecordTypeId();
						            String strRtLabel = rtObj.getName();
						            String strRtName = rtObj.getDeveloperName();

						            if (!strRtName.startsWith('NEO_')) {
						            	continue;
						            }

						            if (myLayoutItemObj.strValue == strRtId) {
						            	myLayoutItemObj.strDisplayValue = strRtLabel;
						            }
						            rtOptions.add(new NEO_Rules_Constants.MySelectOption(strRtId, strRtLabel));
						        }
						        myLayoutItemObj.valueOptions = rtOptions;

						        // Reset recordtype display type
						        if (strRecordID == null) {
					            	myLayoutItemObj.strDisplayType = NEO_Rules_Constants.NEO_DATA_TYPE_PICKLIST.toUpperCase();
					            	myLayoutItemObj.isReadOnly = false;
					            	myLayoutItemObj.isRequired = true;
					            }
                            } else if (myLayoutItemObj.strName == 'CreatedById') {
                     			List<String> valuePartList = new List<String>();
                     			Object valueObj = getValueByFieldName(obj, 'CreatedBy.Name');
                     			if (valueObj <> null) {
                     				valuePartList.add(String.valueOf(valueObj));
                     			}
                     			valueObj = getValueByFieldName(obj, 'CreatedDate');
                     			if (valueObj <> null) {
                     				valuePartList.add(Datetime.valueOf(valueObj).format('yyyy-MM-dd HH:mm:ss'));
                     			}

                     			if (valuePartList.size() > 0) {
                     				myLayoutItemObj.strDisplayValue = String.join(valuePartList, ', ');
                     			}

                            } else if (myLayoutItemObj.strName == 'LastModifiedById') {
                            	List<String> valuePartList = new List<String>();
                     			Object valueObj = getValueByFieldName(obj, 'LastModifiedBy.Name');
                     			if (valueObj <> null) {
                     				valuePartList.add(String.valueOf(valueObj));
                     			}
                     			valueObj = getValueByFieldName(obj, 'LastModifiedDate');
                     			if (valueObj <> null) {
                     				valuePartList.add(Datetime.valueOf(valueObj).format('yyyy-MM-dd HH:mm:ss'));
                     			}

                     			if (valuePartList.size() > 0) {
                     				myLayoutItemObj.strDisplayValue = String.join(valuePartList, ', ');
                     			}
                            } else {
                            	List<String> displayFieldsList = new List<String>();

                            	SObject lookupObj = null;
                            	String strObjId = String.valueOf(myLayoutItemObj.strValue);
                            	String strLookupObjectType = myLayoutItemObj.strReferenceTo;

                            	NEO_Rules_Constants.ObjectWrapper objectWrapperObj = null;
                    			if (objectWrapperMap.containsKey(strLookupObjectType)) {
                    				objectWrapperObj = objectWrapperMap.get(strLookupObjectType);
                    			}

                    			selectedFieldsSet = new Set<String> { 'Id', 'Name' };
                    			if (objectWrapperObj <> null) {
	                				myLayoutItemObj.strDisplayFieldsString = String.join(objectWrapperObj.lookupDisplayFields, ', ');
	                				for (String strLookupField : objectWrapperObj.lookupDisplayFields) {
	                					selectedFieldsSet.add(strLookupField);
	                					displayFieldsList.add(strLookupField);
	                				}

	                				myLayoutItemObj.strSubDisplayFieldsString = String.join(objectWrapperObj.lookupSubDisplayFields, ', ');
	                				for (String strLookupField : objectWrapperObj.lookupSubDisplayFields) {
	                					selectedFieldsSet.add(strLookupField);
	                				}

	                				myLayoutItemObj.strFilterFieldsString = String.join(objectWrapperObj.lookupFilterFields, ', ');
	                				for (String strLookupField : objectWrapperObj.lookupFilterFields) {
	                					selectedFieldsSet.add(strLookupField);
	                				}
	                			}

                        		if (String.isNotBlank(strObjId) && lookupObjectCache.containsKey(strObjId)) {
                        			lookupObj = lookupObjectCache.get(strObjId);

                        		} else if (String.isNotBlank(strObjId)) {
                        			strSOQL = 'SELECT ' + String.join(new List<String>(selectedFieldsSet), ', ') + ' FROM ' + strLookupObjectType + ' WHERE Id = \'' + strObjId + '\'';
                        			for (SObject tempLookupObj : Database.query(strSOQL)) {
                        				lookupObj = tempLookupObj;
                        				lookupObjectCache.put(strObjId, lookupObj);
                        			}
                        		}

                            	String strLookupField = '';
                            	if (myLayoutItemObj.strName.endsWith('Id')) {
                            		strLookupField = myLayoutItemObj.strName.removeEnd('Id');
                            	} else if (myLayoutItemObj.strName.endsWith('__c')) {
                            		strLookupField = myLayoutItemObj.strName.removeEnd('__c') + '__r';
                            	}

                            	if (lookupObj <> null) {
                            		obj.putSObject(strLookupField, lookupObj);

                            		List<String> displayValuesList = new List<String>();
                            		for (String strDisplayField : displayFieldsList) {
                            			displayValuesList.add(String.valueOf(getValueByFieldName(obj, strLookupField + '.' + strDisplayField)));
                            		}

                            		myLayoutItemObj.strDisplayValue = String.join(displayValuesList, ', ');
                            	} else {
                            		myLayoutItemObj.strDisplayValue = '';
                            	}
                            }

                        } else if (myLayoutItemObj.strDataType == NEO_Rules_Constants.NEO_DATA_TYPE_PICKLIST.toUpperCase() ||
                        		   myLayoutItemObj.strDataType == NEO_Rules_Constants.NEO_DATA_TYPE_MULTI_PICKLIST.toUpperCase()) {
                        	// Picklist/Multipicklist
                        	myLayoutItemObj.valueOptions = getPicklistOptionsByObjectName(sObjectType, myLayoutItemObj.strName);

                        	for (NEO_Rules_Constants.MySelectOption mySelectOptionObj : myLayoutItemObj.valueOptions) {
					            String strValue = mySelectOptionObj.value;
					            String strLabel = mySelectOptionObj.label;

					            if (myLayoutItemObj.strValue == strValue) {
					            	myLayoutItemObj.strDisplayValue = strLabel;
					            }
					        }

                        } else if (myLayoutItemObj.strDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATE.toUpperCase()) {
                        	// Date
                        	myLayoutItemObj.strDisplayValue = myLayoutItemObj.strValue <> null ? String.valueOf(myLayoutItemObj.strValue).substringBeforeLast(' ') : myLayoutItemObj.strValue;

                        } else if (myLayoutItemObj.strDataType == NEO_Rules_Constants.NEO_DATA_TYPE_DATETIME.toUpperCase()) {
                        	// Datetime
                        	if (myLayoutItemObj.strValue <> null) {
                        		myLayoutItemObj.strDisplayValue = myLayoutItemObj.strValue <> null ? Datetime.valueOf(myLayoutItemObj.strValue).format('yyyy-MM-dd HH:mm') : myLayoutItemObj.strValue;
                        	}
                        }

                        /*
                        if (ruleObj.NEO_Readonly_Mode__c) {
                        	myLayoutItemObj.isReadOnly = true;
                        	myLayoutItemObj.isRequired = false;
                        }
                        */

                        if (myLayoutItemObj.strDataType == 'STRING' ||
                        	myLayoutItemObj.strDataType == 'PICKLIST' ||
                        	myLayoutItemObj.strDataType == 'REFERENCE') {
                        	myLayoutItemObj.strAppDisplayType = 'text';

                        } else if (myLayoutItemObj.strDataType == 'DATETIME') {
                        	myLayoutItemObj.strAppDisplayType = 'datetime';

                        } else if (myLayoutItemObj.strDataType == 'DATE') {
                        	myLayoutItemObj.strAppDisplayType = 'date';

                        } else if (myLayoutItemObj.strDataType == 'DOUBLE') {
                        	myLayoutItemObj.strAppDisplayType = 'number';

                        } else if (myLayoutItemObj.strDataType == 'TEXTAREA') {
                        	myLayoutItemObj.strAppDisplayType = 'textarea';
                        	
                        } else {
                        	myLayoutItemObj.strAppDisplayType = 'text';
                        }



                        String strKey = String.valueOf(keyIndex);
                        layoutItemsMap.put(strKey, myLayoutItemObj);
                        keyIndexList.add(keyIndex);

                        keyIndex += layoutColumnSize;
                    }
                    ++columnIndex;
                }

                keyIndexList.sort();

                Integer maxKeyIndex = 0;
                if (keyIndexList.size() > 0) {
                    maxKeyIndex = keyIndexList.get(keyIndexList.size() - 1);
                }

                for (Integer j = 0; j <= maxKeyIndex; j++) {
                    if (layoutItemsMap.containsKey(String.valueOf(j))) {
                        myLayoutSectionObj.layoutItemList.add(layoutItemsMap.get(String.valueOf(j)));
                    } else {
                        myLayoutSectionObj.layoutItemList.add(new NEO_Rules_Constants.MyLayoutItem());
                    }
                }

                layoutSectionList.add(myLayoutSectionObj);
            }

            // Related list
            for (Metadata.RelatedListItem relatedListItemObj : tempRelatedListItems) {
            	NEO_Rules_Constants.MyRelatedListItem myRelatedListItemObj = new NEO_Rules_Constants.MyRelatedListItem();

		    	// NEO_Event_Speaker__c.NEO_Event__c
		    	List<String> relatedListParts = relatedListItemObj.relatedList.split('\\.');
		    	if (relatedListParts.size() < 2) {
		    		continue;
		    	}
		    	System.debug(LoggingLevel.DEBUG, '-------->relatedListParts: ' + relatedListParts);
		    	myRelatedListItemObj.realtedObjectType = relatedListParts.get(0);
		    	myRelatedListItemObj.realtedFieldName = relatedListParts.get(1);

		    	Schema.DescribeSObjectResult childDsrObj = Schema.describeSObjects(new List<String> { myRelatedListItemObj.realtedObjectType }).get(0);

		    	myRelatedListItemObj.realtedObjectLabel = childDsrObj.getLabel();
		    	myRelatedListItemObj.excludeButtons = relatedListItemObj.excludeButtons;

		    	for (String strRelatedField : relatedListItemObj.fields) {
		    		if (strRelatedField == 'CREATED_DATE') {
		    			strRelatedField = 'CreatedDate';

		    		} else if (strRelatedField == 'CREATEDBY_USER') {
		    			strRelatedField = 'CreatedById';

		    		} else if (strRelatedField == 'UPDATEDBY_USER') {
		    			strRelatedField = 'LastModifiedById';
		    			
		    		} else if (strRelatedField == 'LAST_UPDATE') {
		    			strRelatedField = 'LastModifiedDate';
		    			
		    		} else if (strRelatedField == 'UPDATEDBY_USER.ALIAS') {
		    			strRelatedField = 'LastModifiedBy.Alias';
		    			
		    		} else if (strRelatedField == 'CREATEDBY_USER.ALIAS') {
		    			strRelatedField = 'CreatedBy.Alias';
		    			
		    		} else if (strRelatedField == 'OBJECT_ID') {
		    			strRelatedField = 'Id';

		    		} else if (strRelatedField == 'NAME') {
		    			strRelatedField = 'Name';
		    		}
		    		myRelatedListItemObj.relatedListFields.add(strRelatedField);
		    	}

		    	relatedListItems.add(myRelatedListItemObj);
		    }
        }

        return new Map<String, Object> {
        	'layoutSectionList' => layoutSectionList,
        	'relatedListItems' => relatedListItems
        };
    }

    public static Map<String, Object> getLayoutAll(SObject sObj, String sObjectType) {
    	Map<String, NEO_Variable__c> NEOVariableMaps = NEO_Rules_Constants.NEOVariableMaps;

    	// Get layout rule information
    	Map<String, List<NEO_Rule__c>> rulesMap = NEO_Rules_Utils.rulesLayoutCheck(new List<SObject> { sObj }, sObjectType);
		List<NEO_Rule__c> rulesList = new List<NEO_Rule__c>();
		if (rulesMap.size() > 0) {
			rulesList = rulesMap.values().get(0);
		}

		NEO_Rule__c ruleObj = new NEO_Rule__c();
		for (NEO_Rule__c tempRuleObj : rulesList) {
			ruleObj = tempRuleObj;
		}

		Map<String, Boolean> layoutFieldsMap = new Map<String, Boolean>();
		for (NEO_Criteria__c criteriaObj : ruleObj.NEO_Criterias__r) {
			String strVariableAPIName = '';
			if (NEOVariableMaps.containsKey(criteriaObj.NEO_Resource_Text__c)) {
				strVariableAPIName = NEOVariableMaps.get(criteriaObj.NEO_Resource_Text__c).Variable_API_Name__c;
			}
			if (String.isNotBlank(strVariableAPIName)) {
				List<String> apiNamePartList = strVariableAPIName.split('\\.');
				if (apiNamePartList.size() > 1) {
					String strFirstPart = apiNamePartList.get(0);
					strVariableAPIName = strFirstPart.endsWith('__r') ? strFirstPart.removeEnd('__r') + '__c' : strFirstPart + 'Id';

				} else if (apiNamePartList.size() > 0) {
					strVariableAPIName = apiNamePartList.get(0);
				}
				layoutFieldsMap.put(strVariableAPIName, true);
			}
		}

		// Get layout information
		Map<String, Object> layoutInfosMap = NEO_Rules_Utils.getLayoutInfosMap(sObj, sObjectType, ruleObj);

		return new Map<String, Object> {
			'ruleObj' => ruleObj,
        	'layoutSectionList' => layoutInfosMap.get('layoutSectionList'),
        	'relatedListItems' => layoutInfosMap.get('relatedListItems'),
        	'layoutFieldsMap' => layoutFieldsMap
        };
    }
}