global without sharing class NEO_Rules_Constants {

    // Variable record type
    public static String NEO_VARIABLE_RECORD_TYPE_OBJECT = 'NEO_Object_Variable';
    public static String NEO_VARIABLE_RECORD_TYPE_FIELD = 'NEO_Field_Variable';

    // Varibable Data Type
    public static String NEO_DATA_TYPE_AGGREGATION = 'Aggregation';
    public static String NEO_DATA_TYPE_CHECKBOX = 'Checkbox';
    public static String NEO_DATA_TYPE_BOOLEAN = 'Boolean';
    public static String NEO_DATA_TYPE_CURRENCY = 'Currency';
    public static String NEO_DATA_TYPE_DATE = 'Date';
    public static String NEO_DATA_TYPE_DATETIME = 'Datetime';
    public static String NEO_DATA_TYPE_EMAIL = 'Email';
    public static String NEO_DATA_TYPE_LOOKUP = 'Lookup';
    public static String NEO_DATA_TYPE_NUMBER = 'Number';
    public static String NEO_DATA_TYPE_DOUBLE = 'Double';
    public static String NEO_DATA_TYPE_DECIMAL = 'Decimal';
    public static String NEO_DATA_TYPE_PERCENT = 'Percent';
    public static String NEO_DATA_TYPE_PHONE = 'Phone';
    public static String NEO_DATA_TYPE_PICKLIST = 'Picklist';
    public static String NEO_DATA_TYPE_MULTI_PICKLIST = 'Multipicklist';
    public static String NEO_DATA_TYPE_TIME = 'Time';
    public static String NEO_DATA_TYPE_TEXT = 'Text';
    public static String NEO_DATA_TYPE_ID = 'Id';
    public static String NEO_DATA_TYPE_URL = 'URL';
    public static String NEO_DATA_TYPE_REFERENCE = 'Reference';
    public static String NEO_DATA_TYPE_STRING = 'String';

    // Display Type
    public static String NEO_DISPLAY_TYPE_CHECKBOX = 'Checkbox';
    public static String NEO_DISPLAY_TYPE_CURRENCY = 'Currency';
    public static String NEO_DISPLAY_TYPE_DATE = 'Date';
    public static String NEO_DISPLAY_TYPE_DATETIME = 'Datetime';
    public static String NEO_DISPLAY_TYPE_DECIMAL = 'Decimal';
    public static String NEO_DISPLAY_TYPE_EMAIL = 'Email';
    public static String NEO_DISPLAY_TYPE_PICKLIST = 'Picklist';
    public static String NEO_DISPLAY_TYPE_TEXT = 'Text';
    public static String NEO_DISPLAY_TYPE_TIME = 'Time';
    public static String NEO_DISPLAY_TYPE_NUMBER = 'Number';
    
    // Aggregation Roll-up Type
    public static String NEO_ROLL_UP_TYPE_COUNT = 'COUNT';
    public static String NEO_ROLL_UP_TYPE_SUM = 'SUM';
    public static String NEO_ROLL_UP_TYPE_MAX = 'MAX';
    public static String NEO_ROLL_UP_TYPE_MIN = 'MIN';

    public static String NEO_PARAMETERS_DATA_TYPE_QUERY = 'Query';
    public static String NEO_PARAMETERS_DATA_TYPE_SPECIAL_VALUE = 'Special Value';
    public static String NEO_PARAMETERS_DATA_TYPE_NUMBER = 'Number';
    public static String NEO_PARAMETERS_DATA_TYPE_TEXT = 'Text';
    public static String NEO_PARAMETERS_DATA_TYPE_LIST = 'List';

    // Datetime && Date
    public static String NEO_DATE_ADD_YEARS_FORMATTER = 'arg0 > TODAY.addYears(-arg1)';
    public static String NEO_DATE_ADD_MONTHS_FORMATTER = 'arg0 > TODAY.addMonths(-arg1)';
    public static String NEO_DATE_ADD_DAYS_FORMATTER = 'arg0 > TODAY.addDays(-arg1)';

    public static String NEO_DATETIME_ADD_YEARS_FORMATTER = 'arg0 > NOW.addYears(-arg1)';
    public static String NEO_DATETIME_ADD_MONTHS_FORMATTER = 'arg0 > NOW.addMonths(-arg1)';
    public static String NEO_DATETIME_ADD_DAYS_FORMATTER = 'arg0 > NOW.addDays(-arg1)';

    // Logic Operator
    public static String NEO_CONTAINS_FORMATTER = 'arg0.contains(arg1)';
    public static String NEO_NOT_CONTAINS_FORMATTER = 'not(arg0.contains(arg1))';
    public static String NEO_IN_FORMATTER = 'arg0 in arg1';
    public static String NEO_IN_SUB_QUERY_FORMATTER = 'arg0 IN (arg1)';
    public static String NEO_NOT_IN_FORMATTER = 'arg0 not in arg1';
    public static String NEO_STARTS_WITH_FORMATTER = 'arg0.startsWith(arg1)';
    public static String NEO_NOT_STARTS_WITH_FORMATTER = 'NOT(arg0.startsWith(arg1))';
    public static String NEO_EQUAL_FORMATTER = 'arg0 == arg1';
    public static String NEO_NOT_EQUAL_FORMATTER = 'arg0 <> arg1';
    public static String NEO_GREATER_THAN_FORMATTER = 'arg0 > arg1';
    public static String NEO_GREATER_OR_EQUAL_FORMATTER = 'arg0 >= arg1';
    public static String NEO_LESS_THAN_FORMATTER = 'arg0 < arg1';
    public static String NEO_LESS_OR_EQUAL_FORMATTER = 'arg0 <= arg1';
    public static String NEO_BETWEEN_AND_FORMATTER = 'arg0 >= arg1 && arg0 < arg2';

    // Math Operator
    public static String NEO_ADD_FORMATTER = 'arg0 + arg1';
    public static String NEO_SUBTRACT_FORMATTER = 'arg0 - arg1';
    public static String NEO_MULTIPLY_FORMATTER = 'arg0 * arg1';
    public static String NEO_DIVIDE_FORMATTER = 'arg0 / arg1';
    public static String NEO_MODE_FORMATTER = 'Mod(arg0, arg1)';

    // Date/Datetime
    public static String NEO_DATE_OR_DATETIME_ADD_HOURS = 'arg0.addHours(arg1)';
    public static String NEO_DATE_OR_DATETIME_ADD_DAYS = 'arg0.addDays(arg1)';
    public static String NEO_DATE_OR_DATETIME_ADD_MONTHS = 'arg0.addMonths(arg1)';
    public static String NEO_DATE_OR_DATETIME_ADD_YEARS = 'arg0.addYears(arg1)';


    public static String NEO_STRING_HARD_STOP = 'Hard Stop';
    public static String NEO_STRING_WARNING = 'Warning';

    // Trigger Type
    public static String NEO_INSERT_TRIGGER_TYPE = 'insert';
    public static String NEO_UPDATE_TRIGGER_TYPE = 'update';
    public static String NEO_DELETE_TRIGGER_TYPE = 'delete';

    // Function Type
    public static String NEO_DATE_FUNCTION_TODAY = 'function-today';
    public static String NEO_DATE_FUNCTION_TODAY_LABEL = '$Date: TODAY()';

    public static String NEO_DATETIME_FUNCTION_NOW = 'function-now';
    public static String NEO_DATETIME_FUNCTION_NOW_LABEL = '$Datetime: NOW()';

    public static String NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_MONTH = 'function-first-day-fiscal-month';
    public static String NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_MONTH_LABEL = '$Date: FIRST DAY(Fiscal Month)';
    public static String NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_MONTH = 'function-last-day-fiscal-month';
    public static String NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_MONTH_LABEL = '$Date: LAST DAY(Fiscal Month)';

    public static String NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_QUARTER = 'function-first-day-fiscal-quarter';
    public static String NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_QUARTER_LABEL = '$Date: FIRST DAY(Fiscal Quarter)';
    public static String NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_QUARTER = 'function-last-day-fiscal-quarter';
    public static String NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_QUARTER_LABEL = '$Date: LAST DAY(Fiscal Quarter)';

    public static String NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_YEAR = 'function-first-day-fiscal-year';
    public static String NEO_DATETIME_FUNCTION_FIRST_DAY_OF_FISCAL_YEAR_LABEL = '$Date: FIRST DAY(Fiscal Year)';
    public static String NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_YEAR = 'function-last-day-fiscal-year';
    public static String NEO_DATETIME_FUNCTION_LAST_DAY_OF_FISCAL_YEAR_LABEL = '$Date: LAST DAY(Fiscal Year)';

    public static String NEO_VALUE_KEY_MONTH_FORMAT = '{0}__{1}{2}{3}';
    public static String NEO_VALUE_KEY_QUARTER_FORMAT = '{0}__{1}{2}';
    public static String NEO_VALUE_KEY_YEAR_FORMAT = '{0}__{1}';
    public static String NEO_VALUE_KEY_DAY_FORMAT = '{0}__{1}{2}{3}__{4}';

    public static String NEO_USER_ACCUMULATED_DATA_SOURCE = 'NEO_User_Accumulated__c';
    public static String NEO_SPEAKER_ACCUMULATED_DATA_SOURCE = 'NEO_Speaker_Accumulated__c';

    public static Boolean NEO_TRIGGER_HANDLER_SWITCH = false;


    public static String NEO_OLD_LABEL = 'Old';
    public static String NEO_FY_LABEL = 'FY';
    public static String NEO_FQ_LABEL = 'FQ';
    public static String NEO_FM_LABEL = 'FM';

    public static Map<String, Schema.DescribeSObjectResult> describeSObjectMaps = new Map<String, Schema.DescribeSObjectResult>();
    // $User
    public static String USER_VARIABLE_ID;
    public static User MyUserInfo = new User();
    public static Map<String, NEO_Variable__c> currentUserFieldsMaps = new Map<String, NEO_Variable__c>();

	// Key => Id
	public static Map<String, NEO_Variable__c> NEOVariableMaps = new Map<String, NEO_Variable__c>();
    public static Map<String, NEO_Variable__c> objApiNameVariableMaps = new Map<String, NEO_Variable__c>();

	// Key => Parent_Variable__c
	public static Map<String, List<NEO_Variable__c>> parentVariableMaps = new Map<String, List<NEO_Variable__c>>();

	// Key => NEO_Variable__c
	public static Map<String, List<NEO_Variable_Operator__c>> variableOperatorMaps = new Map<String, List<NEO_Variable_Operator__c>>();
    public static Map<String, List<NEO_Variable_Operator__c>> variableMathOperatorMaps = new Map<String, List<NEO_Variable_Operator__c>>();
    public static Map<String, NEO_Variable_Operator__c> NEOVariableOperatorMaps = new Map<String, NEO_Variable_Operator__c>();

	// Key => NEO_Parent_Object__c
	public static Map<String, NEO_Variable_Association__c> NEOVariableAssociationMaps = new Map<String, NEO_Variable_Association__c>();
    public static Map<String, List<NEO_Variable_Association__c>> variableAssociationMaps = new Map<String, List<NEO_Variable_Association__c>>();
    public static Map<String, NEO_Variable_Association__c> parentChildAssociationMaps = new Map<String, NEO_Variable_Association__c>();

    // Key => NEO_Operator__c
    public static Map<String, NEO_Operator__c> NEOOperatorMaps = new Map<String, NEO_Operator__c>();
    // Key => Datatype
    public static Map<String, List<NEO_Operator__c>> NEODataTypeOperatorMaps = new Map<String, List<NEO_Operator__c>>();
    public static Map<String, List<NEO_Operator__c>> NEODataTypeResourceOperatorMaps = new Map<String, List<NEO_Operator__c>>();

    // NEO_Aggregation__c Mapping, Key => Master_Object__c
    public static Map<String, List<NEO_Aggregation__c>> masterObjectAggregationMaps = new Map<String, List<NEO_Aggregation__c>>();
    // NEO_Aggregation__c Mapping, Key => Record Id
    public static Map<String, NEO_Aggregation__c> aggregationMaps = new Map<String, NEO_Aggregation__c>();

    // Key => Master_Object__c
    public static Map<String, List<NEO_Rule__c>> masterObjectRuleMaps = new Map<String, List<NEO_Rule__c>>();
    public static Map<String, List<NEO_Rule__c>> masterObjectRealTimeRuleMaps = new Map<String, List<NEO_Rule__c>>();
    public static Map<String, List<NEO_Rule__c>> masterObjectRealTimeInsertRuleMaps = new Map<String, List<NEO_Rule__c>>();
    public static Map<String, List<NEO_Rule__c>> masterObjectRealTimeUpdateRuleMaps = new Map<String, List<NEO_Rule__c>>();
    public static Map<String, List<NEO_Rule__c>> masterObjectRealTimeDeleteRuleMaps = new Map<String, List<NEO_Rule__c>>();

    public static Map<String, List<NEO_Rule__c>> layoutRuleMaps = new Map<String, List<NEO_Rule__c>>();
    // Key => Id
    public static Map<String, NEO_Rule__c> ruleMaps = new Map<String, NEO_Rule__c>();

    public static Map<String, Schema.SObjectType> sObjectTypeMapping = Schema.getGlobalDescribe();

    public static Map<String, NEO_Rules_Constants.ObjectWrapper> objectWrapperMap = new Map<String, NEO_Rules_Constants.ObjectWrapper>();
    
    global class MySelectOption {
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public String label { get; set; }

        public MySelectOption() {
        }

        public MySelectOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

    public interface RuleHandler {
        void handleRealtime(List<SObject> objList, String objectType, String triggerType);
    }

    static {
        // NEO_Event__c
        NEO_Rules_Constants.ObjectWrapper objectWrapperObj = new NEO_Rules_Constants.ObjectWrapper();
        objectWrapperObj.strObjectLabel = 'Event';
        objectWrapperObj.strObjectType = 'NEO_Event__c';
        objectWrapperObj.lookupDisplayFields.add('NEO_Event_Name__c');
        objectWrapperObj.lookupSubDisplayFields.add('NEO_Location__c');
        objectWrapperObj.lookupFilterFields.add('NEO_Event_Name__c');
        objectWrapperMap.put(objectWrapperObj.strObjectType, objectWrapperObj);

        // NEO_Speaker__c
        objectWrapperObj = new NEO_Rules_Constants.ObjectWrapper();
        objectWrapperObj.strObjectLabel = 'Speaker';
        objectWrapperObj.strObjectType = 'NEO_Speaker__c';
        objectWrapperObj.lookupDisplayFields.add('Name');
        objectWrapperObj.lookupSubDisplayFields = new List<String> { 'NEO_Hospital_Name__c', 'NEO_Department__c', 'NEO_Medical_Title__c' };
        objectWrapperObj.lookupFilterFields.add('Name');
        objectWrapperMap.put(objectWrapperObj.strObjectType, objectWrapperObj);

        // NEO_Product__c
        objectWrapperObj = new NEO_Rules_Constants.ObjectWrapper();
        objectWrapperObj.strObjectLabel = 'Product';
        objectWrapperObj.strObjectType = 'NEO_Product__c';
        objectWrapperObj.lookupDisplayFields.add('Name');
        objectWrapperObj.lookupSubDisplayFields = new List<String> { 'NEO_Product_Code__c', 'NEO_English_Name__c' };
        objectWrapperObj.lookupFilterFields.add('Name');
        objectWrapperMap.put(objectWrapperObj.strObjectType, objectWrapperObj);

        // Account
        objectWrapperObj = new NEO_Rules_Constants.ObjectWrapper();
        objectWrapperObj.strObjectLabel = 'Account';
        objectWrapperObj.strObjectType = 'Account';
        objectWrapperObj.lookupDisplayFields = new List<String> { 'Name' };
        objectWrapperObj.lookupSubDisplayFields = new List<String> {};
        objectWrapperObj.lookupFilterFields = new List<String> { 'Name' };
        objectWrapperMap.put(objectWrapperObj.strObjectType, objectWrapperObj);

        // NEO_Event_Speaker__c
        objectWrapperObj = new NEO_Rules_Constants.ObjectWrapper();
        objectWrapperObj.strObjectLabel = 'Event Speaker';
        objectWrapperObj.strObjectType = 'NEO_Event_Speaker__c';
        objectWrapperObj.lookupDisplayFields = new List<String> { 'NEO_Speaker_Name__c'};
        objectWrapperObj.lookupSubDisplayFields = new List<String> {};
        objectWrapperObj.lookupFilterFields = new List<String> { 'NEO_Speaker_Name__c' };
        objectWrapperObj.strMasterFieldName = 'NEO_Event__c';
        objectWrapperMap.put(objectWrapperObj.strObjectType, objectWrapperObj);

        // NEO_Event_Product__c
        objectWrapperObj = new NEO_Rules_Constants.ObjectWrapper();
        objectWrapperObj.strObjectLabel = 'Event Product';
        objectWrapperObj.strObjectType = 'NEO_Event_Product__c';
        objectWrapperObj.lookupDisplayFields = new List<String> { 'NEO_Product_Name__c'};
        objectWrapperObj.lookupSubDisplayFields = new List<String> {};
        objectWrapperObj.lookupFilterFields = new List<String> { 'NEO_Product_Name__c' };
        objectWrapperObj.strMasterFieldName = 'NEO_Event__c';
        objectWrapperMap.put(objectWrapperObj.strObjectType, objectWrapperObj);

        // NEO_Event_Attendee__c
        objectWrapperObj = new NEO_Rules_Constants.ObjectWrapper();
        objectWrapperObj.strObjectLabel = 'Event Attendee';
        objectWrapperObj.strObjectType = 'NEO_Event_Attendee__c';
        objectWrapperObj.strMasterFieldName = 'NEO_Event__c';
        objectWrapperMap.put(objectWrapperObj.strObjectType, objectWrapperObj);

        // NEO_Budget__c
        objectWrapperObj = new NEO_Rules_Constants.ObjectWrapper();
        objectWrapperObj.strObjectLabel = 'Budget';
        objectWrapperObj.strObjectType = 'NEO_Budget__c';
        objectWrapperObj.lookupDisplayFields = new List<String> { 'Name'};
        objectWrapperObj.lookupSubDisplayFields = new List<String> {};
        objectWrapperObj.lookupFilterFields = new List<String> { 'Name' };
        objectWrapperMap.put(objectWrapperObj.strObjectType, objectWrapperObj);

        // NEO_Event_Budget__c
        objectWrapperObj = new NEO_Rules_Constants.ObjectWrapper();
        objectWrapperObj.strObjectLabel = 'Event Budget';
        objectWrapperObj.strObjectType = 'NEO_Event_Budget__c';
        objectWrapperObj.lookupDisplayFields = new List<String> { 'NEO_Budget_Name__c'};
        objectWrapperObj.lookupSubDisplayFields = new List<String> {};
        objectWrapperObj.lookupFilterFields = new List<String> { 'NEO_Budget_Name__c' };
        objectWrapperObj.strMasterFieldName = 'NEO_Event__c';
        objectWrapperMap.put(objectWrapperObj.strObjectType, objectWrapperObj);

        Set<String> userSelectFieldsSet = new Set<String> { 'Id' };
        List<String> selectedFieldsList = new List<String>();
        Set<String> includeFieldsSet = new Set<String> {};
        Set<String> excludeFieldsSet = new Set<String> {};
        String strUserVariableId = '';

        // 1. NEO_Variable__c Mapping, Key => Record Id
        // 2. NEO_Variable__c Mapping, Key => Parent_Variable__c
        Set<String> objectNamesSet = new Set<String>();
        Set<String> selectFieldsSet = new Set<String> {
            'Id', 'Parent_Variable__c', 'Type__c', 'Variable_API_Name__c', 'NEO_Variable_Data_Type__c', 'Variable_Label__c',
            'RecordTypeId', 'RecordType.DeveloperName', 'Parent_Variable__r.Variable_Label__c', 'Object_Name__c', 'Parent_Variable__r.Variable_API_Name__c',
            'NEO_Data_Source__c', 'NEO_Value_Key__c', 'NEO_Active__c'
        };
        String strSOQL = 'SELECT ' + String.join(new List<String>(selectFieldsSet), ',') + ' FROM NEO_Variable__c ORDER BY Variable_Label__c ASC';
        for (NEO_Variable__c tempVariableRow : Database.query(strSOQL)) {
            NEOVariableMaps.put(tempVariableRow.Id, tempVariableRow);

            if (parentVariableMaps.containsKey(tempVariableRow.Parent_Variable__c)) {
                parentVariableMaps.get(tempVariableRow.Parent_Variable__c).add(tempVariableRow);
            } else {
                parentVariableMaps.put(tempVariableRow.Parent_Variable__c, new List<NEO_Variable__c> { tempVariableRow });
            }

            if (tempVariableRow.RecordType.DeveloperName == NEO_Rules_Constants.NEO_VARIABLE_RECORD_TYPE_OBJECT 
                && tempVariableRow.Variable_API_Name__c == 'User') {
                NEO_Rules_Constants.USER_VARIABLE_ID = tempVariableRow.Id;
            }

            if (tempVariableRow.RecordType.DeveloperName == NEO_Rules_Constants.NEO_VARIABLE_RECORD_TYPE_OBJECT &&
                tempVariableRow.Type__c == 'Object' &&
                tempVariableRow.NEO_Active__c) {
                if (String.isNotBlank(tempVariableRow.Variable_API_Name__c)) {
                    objApiNameVariableMaps.put(tempVariableRow.Variable_API_Name__c, tempVariableRow);
                    objectNamesSet.add(tempVariableRow.Variable_API_Name__c);
                }
            }
        }

        // Cache SObject type
        if (objectNamesSet.size() > 0) {
            for (Schema.DescribeSObjectResult tempDescribeSObjectResultRow : Schema.describeSObjects(new List<String>(objectNamesSet))) {
                describeSObjectMaps.put(tempDescribeSObjectResultRow.getName(), tempDescribeSObjectResultRow);
            }
        }

        // $User
        if (String.isNotBlank(NEO_Rules_Constants.USER_VARIABLE_ID) && parentVariableMaps.containsKey(NEO_Rules_Constants.USER_VARIABLE_ID)) {
            for (NEO_Variable__c tempUserVariableRow : parentVariableMaps.get(NEO_Rules_Constants.USER_VARIABLE_ID)) {
                userSelectFieldsSet.add(tempUserVariableRow.Variable_API_Name__c);

                currentUserFieldsMaps.put('$User.' + tempUserVariableRow.Id, tempUserVariableRow);
            }
            String strCurrentUserId = UserInfo.getUserId();
            strSOQL = 'SELECT ' + String.join(new List<String>(userSelectFieldsSet), ',') + ' FROM User WHERE Id = :strCurrentUserId';
            List<User> tempUserList = Database.query(strSOQL);
            if (tempUserList.size() > 0) {
                MyUserInfo = tempUserList.get(0);
            }
        }

        // NEO_Variable_Operator__c, Key => NEO_Variable__c
        selectFieldsSet = new Set<String> {
            'Id', 'NEO_Operator__c', 'NEO_Operator__r.Operator_Label__c', 'NEO_Operator__r.Parameter_Data_Type__c', 'NEO_Variable__c', 'NEO_Display_Type__c', 'NEO_Math_Operator__c'
        };
        strSOQL = 'SELECT ' + String.join(new List<String>(selectFieldsSet), ',') + ' FROM NEO_Variable_Operator__c ORDER BY NEO_Operator__r.Operator_Label__c';
        for (NEO_Variable_Operator__c tempVariableOperatorRow : Database.query(strSOQL)) {
            if (tempVariableOperatorRow.NEO_Math_Operator__c) {
                if (variableMathOperatorMaps.containsKey(tempVariableOperatorRow.NEO_Variable__c)) {
                    variableMathOperatorMaps.get(tempVariableOperatorRow.NEO_Variable__c).add(tempVariableOperatorRow);
                } else {
                    variableMathOperatorMaps.put(tempVariableOperatorRow.NEO_Variable__c, new List<NEO_Variable_Operator__c> { tempVariableOperatorRow });
                }
            } else {
                if (variableOperatorMaps.containsKey(tempVariableOperatorRow.NEO_Variable__c)) {
                    variableOperatorMaps.get(tempVariableOperatorRow.NEO_Variable__c).add(tempVariableOperatorRow);
                } else {
                    variableOperatorMaps.put(tempVariableOperatorRow.NEO_Variable__c, new List<NEO_Variable_Operator__c> { tempVariableOperatorRow });
                }
            }
            
            NEOVariableOperatorMaps.put(tempVariableOperatorRow.Id, tempVariableOperatorRow);
        }

        // NEO_Variable_Association__c, Key => NEO_Parent_Object__c
        selectFieldsSet = new Set<String> {
            'Id', 'NEO_Child_Object__c', 'NEO_Child_Object_Label__c', 'NEO_Child_Object_API_Name__c', 'NEO_Parent_Object__c', 'NEO_Parent_Object_API_Name__c',
            'NEO_Parent_Object_Label__c', 'NEO_Relationship_Name__c', 'NEO_Lookup_Name__c'
        };
        strSOQL = 'SELECT ' + String.join(new List<String>(selectFieldsSet), ',') + ' FROM NEO_Variable_Association__c';
        for (NEO_Variable_Association__c tempVariableAssociationRow : Database.query(strSOQL)) {
            if (variableAssociationMaps.containsKey(tempVariableAssociationRow.NEO_Parent_Object__c)) {
                variableAssociationMaps.get(tempVariableAssociationRow.NEO_Parent_Object__c).add(tempVariableAssociationRow);
            } else {
                variableAssociationMaps.put(tempVariableAssociationRow.NEO_Parent_Object__c, new List<NEO_Variable_Association__c> { tempVariableAssociationRow });
            }

            String tempParentChildKey = tempVariableAssociationRow.NEO_Parent_Object__c + '__' + tempVariableAssociationRow.NEO_Child_Object__c;
            parentChildAssociationMaps.put(tempParentChildKey, tempVariableAssociationRow);

            NEOVariableAssociationMaps.put(tempVariableAssociationRow.Id, tempVariableAssociationRow);
        }

        // NEO_Operator__c Mapping, Key => Record Id
        Map<String, Set<NEO_Operator__c>> tempDataTypeOperatorSetMaps = new Map<String, Set<NEO_Operator__c>>();
        Map<String, Set<NEO_Operator__c>> tempDataTypeResourceOperatorSetMaps = new Map<String, Set<NEO_Operator__c>>();
        selectFieldsSet = new Set<String> {
            'Id', 'Operator_Label__c', 'Operator_Format__c', 'Parameter_Data_Type__c', 'NEO_Math_Operator_Used__c', 'NEO_Data_Type_Available__c'
        };
        strSOQL = 'SELECT ' + String.join(new List<String>(selectFieldsSet), ',') + ' FROM NEO_Operator__c ORDER BY Operator_Label__c';
        for (NEO_Operator__c tempOperatorRow : Database.query(strSOQL)) {
            NEOOperatorMaps.put(tempOperatorRow.Id, tempOperatorRow);

            if (String.isBlank(tempOperatorRow.NEO_Data_Type_Available__c)) {
                continue;
            }
            for (String strDataType : tempOperatorRow.NEO_Data_Type_Available__c.split(';')) {
                strDataType = strDataType.trim();
                // Math operator or not
                if (tempOperatorRow.NEO_Math_Operator_Used__c) {
                    // Math operator
                    if (tempDataTypeResourceOperatorSetMaps.containsKey(strDataType)) {
                        tempDataTypeResourceOperatorSetMaps.get(strDataType).add(tempOperatorRow);
                    } else {
                        tempDataTypeResourceOperatorSetMaps.put(strDataType, new Set<NEO_Operator__c> { tempOperatorRow });
                    }

                } else {
                    if (tempDataTypeOperatorSetMaps.containsKey(strDataType)) {
                        tempDataTypeOperatorSetMaps.get(strDataType).add(tempOperatorRow);
                    } else {
                        tempDataTypeOperatorSetMaps.put(strDataType, new Set<NEO_Operator__c> { tempOperatorRow });
                    }
                }
            }
        }

        for (String strKey : tempDataTypeOperatorSetMaps.keySet()) {
            NEODataTypeOperatorMaps.put(strKey, new List<NEO_Operator__c>(tempDataTypeOperatorSetMaps.get(strKey)));
        }

        for (String strKey : tempDataTypeResourceOperatorSetMaps.keySet()) {
            NEODataTypeResourceOperatorMaps.put(strKey, new List<NEO_Operator__c>(tempDataTypeResourceOperatorSetMaps.get(strKey)));
        }

        // 1, NEO_Aggregation__c Mapping, Key => Id
        // 2, NEO_Aggregation__c Mapping, Key => Master_Object__c
        selectFieldsSet = new Set<String> {
            'Id', 'Active__c', 'Aggregation_Name__c', 'Custom_Logic__c', 'Description__c', 'Fields_To_Aggregate__c', 'Fields_To_Group__c',
            'Master_Object__c', 'Master_Object_Label__c', 'Roll_Up_Type__c', 'NEO_Summarized_Object__c', 'NEO_Summarized_All_Records__c',
            '(SELECT Id, NEO_Operator_Text__c, NEO_Resource_Text__c, Row_Serial_No__c, NEO_Value_Text__c, NEO_Value_Date__c, NEO_Value_Datetime__c, NEO_Resource_Operator__c, NEO_Resource_Value__c FROM NEO_Criterias__r ORDER BY Row_Serial_No__c ASC)'
        };
        strSOQL = 'SELECT ' + String.join(new List<String>(selectFieldsSet), ',') + ' FROM NEO_Aggregation__c WHERE Active__c = true';
        for (NEO_Aggregation__c tempAggregationRow : Database.query(strSOQL)) {
            aggregationMaps.put(tempAggregationRow.Id, tempAggregationRow);

            if (masterObjectAggregationMaps.containsKey(tempAggregationRow.Master_Object__c)) {
                masterObjectAggregationMaps.get(tempAggregationRow.Master_Object__c).add(tempAggregationRow);
            } else {
                masterObjectAggregationMaps.put(tempAggregationRow.Master_Object__c, new List<NEO_Aggregation__c> { tempAggregationRow });
            }
        }

        // NEO_Rule__c
        includeFieldsSet = new Set<String> {
            'RecordType.DeveloperName', 'NEO_Layout__r.NEO_Layout_Name__c', 'NEO_Layout__r.NEO_Object_Type__c', 'NEO_Layout__r.NEO_Layout_Full_Name__c',
            '(SELECT Id, NEO_Operator_Text__c, NEO_Resource_Text__c, Row_Serial_No__c, NEO_Value_Text__c, NEO_Value_Date__c, NEO_Value_Datetime__c, NEO_Resource_Operator__c, NEO_Resource_Value__c FROM NEO_Criterias__r ORDER BY Row_Serial_No__c ASC)'
        };
        excludeFieldsSet = new Set<String> {};
        selectedFieldsList = NEO_Rules_Utils.getSelectedFieldsList('NEO_Rule__c', includeFieldsSet, excludeFieldsSet, true);
        selectFieldsSet = new Set<String> {
            'Id', 'NEO_Active__c', 'Alert_Message__c', 'Approval_Level__c', 'Comment_Needed__c', 'Custom_Logic__c', 'Description__c', 'Hard_Stop_Warning__c', 'Master_Object__c',
            'Real_Time_Trigger__c', 'NEO_Rule_Name__c', 'NEO_Insert_Triggered__c', 'NEO_Update_Triggered__c', 'NEO_Delete_Triggered__c', 'NEO_Alert_Message_EN__c', 'NEO_Day_ID__c',
            'RecordTypeId', 'RecordType.DeveloperName', 'NEO_Layout__c', 'NEO_Layout__r.NEO_Layout_Name__c', 'NEO_Layout__r.NEO_Object_Type__c', 'NEO_Layout__r.NEO_Layout_Full_Name__c',
            'NEO_Readonly_Mode__c', 'NEO_Enable_Approve__c', 'NEO_Enable_QR_Code__c', 'NEO_Enable_FACE_Cover__c', 'NEO_Enable_Delete__c', 'NEO_Enable_Edit__c', 'NEO_Enable_New__c',
            '(SELECT Id, NEO_Operator_Text__c, NEO_Resource_Text__c, Row_Serial_No__c, NEO_Value_Text__c, NEO_Value_Date__c, NEO_Value_Datetime__c, NEO_Resource_Operator__c, NEO_Resource_Value__c FROM NEO_Criterias__r ORDER BY Row_Serial_No__c ASC)'
        };
        strSOQL = 'SELECT ' + String.join(selectedFieldsList, ',') + ' FROM NEO_Rule__c WHERE NEO_Active__c = true';
        for (NEO_Rule__c tempRuleRow : Database.query(strSOQL)) {
            ruleMaps.put(tempRuleRow.Id, tempRuleRow);

            if (String.isBlank(tempRuleRow.Master_Object__c)) {
                continue;
            }

            // Real-Time Trigger
            if (tempRuleRow.Real_Time_Trigger__c && tempRuleRow.RecordType.DeveloperName == 'NEO_Validation_Rule') {
                if (masterObjectRealTimeRuleMaps.containsKey(tempRuleRow.Master_Object__c)) {
                    masterObjectRealTimeRuleMaps.get(tempRuleRow.Master_Object__c).add(tempRuleRow);
                } else {
                    masterObjectRealTimeRuleMaps.put(tempRuleRow.Master_Object__c, new List<NEO_Rule__c> { tempRuleRow });
                }

                // Insert
                if (tempRuleRow.NEO_Insert_Triggered__c) {
                    if (masterObjectRealTimeInsertRuleMaps.containsKey(tempRuleRow.Master_Object__c)) {
                        masterObjectRealTimeInsertRuleMaps.get(tempRuleRow.Master_Object__c).add(tempRuleRow);
                    } else {
                        masterObjectRealTimeInsertRuleMaps.put(tempRuleRow.Master_Object__c, new List<NEO_Rule__c> { tempRuleRow });
                    }
                }

                // Update
                if (tempRuleRow.NEO_Update_Triggered__c) {
                    if (masterObjectRealTimeUpdateRuleMaps.containsKey(tempRuleRow.Master_Object__c)) {
                        masterObjectRealTimeUpdateRuleMaps.get(tempRuleRow.Master_Object__c).add(tempRuleRow);
                    } else {
                        masterObjectRealTimeUpdateRuleMaps.put(tempRuleRow.Master_Object__c, new List<NEO_Rule__c> { tempRuleRow });
                    }
                }

                // Delete
                if (tempRuleRow.NEO_Delete_Triggered__c) {
                    if (masterObjectRealTimeDeleteRuleMaps.containsKey(tempRuleRow.Master_Object__c)) {
                        masterObjectRealTimeDeleteRuleMaps.get(tempRuleRow.Master_Object__c).add(tempRuleRow);
                    } else {
                        masterObjectRealTimeDeleteRuleMaps.put(tempRuleRow.Master_Object__c, new List<NEO_Rule__c> { tempRuleRow });
                    }
                }
            } else if (tempRuleRow.RecordType.DeveloperName == 'NEO_Validation_Rule') {
                if (masterObjectRuleMaps.containsKey(tempRuleRow.Master_Object__c)) {
                    masterObjectRuleMaps.get(tempRuleRow.Master_Object__c).add(tempRuleRow);
                } else {
                    masterObjectRuleMaps.put(tempRuleRow.Master_Object__c, new List<NEO_Rule__c> { tempRuleRow });
                }

            } else if (tempRuleRow.RecordType.DeveloperName == 'NEO_Layout_Rule') {
                if (layoutRuleMaps.containsKey(tempRuleRow.Master_Object__c)) {
                    layoutRuleMaps.get(tempRuleRow.Master_Object__c).add(tempRuleRow);
                } else {
                    layoutRuleMaps.put(tempRuleRow.Master_Object__c, new List<NEO_Rule__c> { tempRuleRow });
                }
            }
        }
    }


    global class MyLayoutSection {
        @AuraEnabled
        public Integer columnSize { get; set; }
        @AuraEnabled
        public String strLabel { get; set; }
        @AuraEnabled
        public String strStyle { get; set; }
        @AuraEnabled
        public List<MyLayoutItem> layoutItemList { get; set; }

        public MyLayoutSection() {
            this.columnSize = 2;
            this.layoutItemList = new List<MyLayoutItem>();
        }

        public MyLayoutSection(Integer columnSize, String strLabel) {
            this.columnSize = columnSize;
            this.strLabel = strLabel;
            this.layoutItemList = new List<MyLayoutItem>();
        }
    }

    global class MyLayoutItem {
        @AuraEnabled
        public Boolean isReadOnly { get; set; }
        @AuraEnabled
        public Boolean isRequired { get; set; }
        @AuraEnabled
        public String strName { get; set; }
        @AuraEnabled
        public String strLabel { get; set; }
        @AuraEnabled
        public Object strValue { get; set; }
        @AuraEnabled
        public Object strDisplayValue { get; set; }
        @AuraEnabled
        public String strDataType { get; set; }
        @AuraEnabled
        public String strDisplayType { get; set; }
        @AuraEnabled
        public String strAppDisplayType { get; set; }
        @AuraEnabled
        public String strReferenceTo { get; set; }
        @AuraEnabled
        public String strRelationshipName { get; set; }
        @AuraEnabled
        public List<MySelectOption> valueOptions { get; set; }
        @AuraEnabled
        public String strFilterFieldsString { get; set; }
        @AuraEnabled
        public String strDisplayFieldsString { get; set; }
        @AuraEnabled
        public String strSubDisplayFieldsString { get; set; }

        public MyLayoutItem() {
            this.isReadOnly = false;
            this.isRequired = false;
            this.valueOptions = new List<MySelectOption>();
        }
    }

    global class MyRelatedListItem {
        @AuraEnabled
        public List<String> excludeButtons { get; set; }
        @AuraEnabled
        public List<String> relatedListFields { get; set; }
        @AuraEnabled
        public String realtedObjectType { get; set; }
        @AuraEnabled
        public String realtedFieldName { get; set; }
        @AuraEnabled
        public String realtedObjectLabel { get; set; }
        @AuraEnabled
        public String strSortField { get; set; }
        @AuraEnabled
        public String strSortOrder { get; set; }

        public MyRelatedListItem() {
            this.excludeButtons = new List<String>();
            this.relatedListFields = new List<String>();
        }
    }

    global class ObjectWrapper {
        @AuraEnabled
        public String strObjectLabel { get; set; }
        @AuraEnabled
        public String strObjectType { get; set; }
        @AuraEnabled
        public List<String> lookupDisplayFields { get; set; }
        @AuraEnabled
        public List<String> lookupSubDisplayFields { get; set; }
        @AuraEnabled
        public List<String> lookupFilterFields { get; set; }
        @AuraEnabled
        public Map<String, String> fieldValuesMap { get; set; }
        @AuraEnabled
        public String strMasterFieldName { get; set; }

        public ObjectWrapper() {
            this.lookupDisplayFields = new List<String>();
            this.lookupSubDisplayFields = new List<String>();
            this.lookupFilterFields = new List<String>();
            this.fieldValuesMap = new Map<String, String>();
        }
    }
}