({
	doInit : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);
		
		let _record_id = component.get("v.recordId");
		let _variable_obj = component.get("v.variableObj");
		let _lc_record_type_id = '';
		if (component.get("v.pageReference") != null && component.get("v.pageReference").state != null) {
			_lc_record_type_id = component.get("v.pageReference").state.recordTypeId;
		}
		let _record_type_id = component.get("v.recordTypeId") || _lc_record_type_id;
		let _speaker_id = component.get("v.speakerId");

		let _action = component.get("c.initialize");
		_action.setParams({
			"recordId": _record_id,
			"inputVarObj" : _variable_obj
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			console.log(_returnValue);

			if (_returnValue == null || _returnValue == "") {
				return;
			}

			component.set("v.labelMaps", _returnValue.labelMaps);
			component.set("v.variableAssociationLabelMaps", _returnValue.variableAssociationLabelMaps);
			component.set("v.ruleLabelMaps", _returnValue.ruleLabelMaps);
			component.set("v.variableWrapperList", _returnValue.variableWrapperList);
			component.set("v.variableAssociationWrapperList", _returnValue.variableAssociationWrapperList);
			component.set("v.fieldsWrapperList", _returnValue.fieldsWrapperList);

			component.set("v.stepWrapperList", _returnValue.stepWrapperList);
			component.set("v.initStepWrapperList", _returnValue.stepWrapperList);

			component.set("v.objectVariableCache", _returnValue.objectVariableCache);
			component.set("v.keyPrefix", _returnValue.keyPrefix);
			component.set("v.ruleWrapperList", _returnValue.ruleWrapperList);

			component.set("v.variableObj", _returnValue.variableObj);
			component.set("v.oldVariableObj", _returnValue.oldVariableObj);
			component.set("v.variableWrapperObj", _returnValue.variableWrapperObj);


			let _event_handler = $A.get("e.force:navigateToSObject");
			if (_event_handler) {
				component.set("v.isLightning", true);
			} else {
				component.set("v.isLightning", false);
			}

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
			component.set("v.showScope", true);
			component.set("v.showLoading", false);
		});
	},
	jsChangeObjectType : function(component, event, helper) {
		component.set("v.variableAssociationWrapperList", []);
		component.set("v.fieldsWrapperList", []);
		component.set("v.variableObj.Id", "");
		component.set("v.variableObj.Is_Master_Object__", false);

		let _variable_obj = component.get("v.variableObj");
		let _variable_wrapper_list = component.get("v.variableWrapperList");
		let _object_variable_cache = component.get("v.objectVariableCache");

		let _record_id = "";
		for (var j = 0; j < _object_variable_cache.length; j++) {
			if (_variable_obj.Variable_API_Name__c == _object_variable_cache[j].Variable_API_Name__c) {
				component.set("v.variableObj.Variable_Label__c", _variable_obj.Variable_Label__c);
				_record_id = _object_variable_cache[j].Id;
				break;
			}
		}

		if (!_record_id) {
			for (var j = 0; j < _variable_wrapper_list.length; j++) {
				if (_variable_obj.Variable_API_Name__c == _variable_wrapper_list[j].variableObj.Variable_API_Name__c) {
					component.set("v.variableObj.Variable_Label__c", _variable_wrapper_list[j].variableObj.Variable_Label__c);
					break;
				}
			}
		}

		component.set("v.recordId", _record_id);
		let _do_init = component.get('c.doInit');
    	$A.enqueueAction(_do_init);
	},
	jsShowFieldSearchModal : function(component, event, helper) {
		component.set("v.showListLoading", true);
		component.set("v.fieldSearchModalClass", "slds-show");
		component.set("v.allFieldsWrapperList", []);

		let _variable_obj = component.get("v.variableObj");
		let _selected_fields_wrapper_list = component.get("v.fieldsWrapperList");

		let _action = component.get("c.loadAllFieldsWrapperList");
		_action.setParams({
			"variableObj" : _variable_obj,
			"selectedFieldsWrapperListJSON" : JSON.stringify(_selected_fields_wrapper_list)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			if (_returnValue == null || _returnValue == "") {
				return;
			}
			console.log(_returnValue);

			component.set("v.allFieldsWrapperList", _returnValue.allFieldsWrapperList);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
			component.set("v.showListLoading", false);
		});
	},
	jsSwitchStep : function(component, event, helper) {
		component.set("v.showListLoading", true);
		component.set("v.allFieldsWrapperList", []);

		let _step_index = event.currentTarget.dataset.rowIndex;
		let _variable_obj = component.get("v.variableObj");
		let _step_wrapper_list = component.get("v.stepWrapperList");
		let _selected_fields_wrapper_list = component.get("v.fieldsWrapperList");

		console.log(_step_wrapper_list);

		let _action = component.get("c.gotoStepIndex");
		_action.setParams({
			"variableObj" : _variable_obj,
			"stepIndex" : _step_index,
			"stepWrapperList" : _step_wrapper_list,
			"selectedFieldsWrapperListJSON" : JSON.stringify(_selected_fields_wrapper_list)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			if (_returnValue == null || _returnValue == "") {
				return;
			}

			console.log(_returnValue);
			component.set("v.stepWrapperList", _returnValue.stepWrapperList);
			component.set("v.allFieldsWrapperList", _returnValue.allFieldsWrapperList);
			
		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
			component.set("v.showListLoading", false);
		});
	},
	jsGotoChildObject : function(component, event, helper) {
		component.set("v.showListLoading", true);
		component.set("v.allFieldsWrapperList", []);

		let _variable_obj = component.get("v.variableObj");
		let _select_variable_api_name = event.currentTarget.dataset.rowIndex;
		let _step_wrapper_list = component.get("v.stepWrapperList");
		let _selected_fields_wrapper_list = component.get("v.fieldsWrapperList");

		console.log(_select_variable_api_name);

		let _action = component.get("c.gotoChildObject");
		_action.setParams({
			"variableObj" : _variable_obj,
			"selectVariableApiName" : _select_variable_api_name,
			"stepWrapperList" : _step_wrapper_list,
			"selectedFieldsWrapperListJSON" : JSON.stringify(_selected_fields_wrapper_list)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			console.log(_returnValue);

			if (_returnValue == null || _returnValue == "") {
				return;
			}

			component.set("v.stepWrapperList", _returnValue.stepWrapperList);
			component.set("v.allFieldsWrapperList", _returnValue.allFieldsWrapperList);
			
		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
			component.set("v.showListLoading", false);
		});
	},
	jsCloseFieldSearchModal : function(component, event, helper) {
		component.set("v.fieldSearchModalClass", "slds-hide");
		component.set("v.stepWrapperList", component.get("v.initStepWrapperList"));
		component.set("v.allFieldsWrapperList", []);
		component.set("v.showListMessage", false);
		component.set("v.showListLoading", false);
	},
	jsChangeValueKey : function(component, event, helper) {
		let _fields_wrapper_list = component.get("v.fieldsWrapperList");

		for (var j = 0; j < _fields_wrapper_list.length; j++) {
			let _value_key = _fields_wrapper_list[j].variableObj.NEO_Value_Key__c;
			if (!_value_key) {
				_fields_wrapper_list[j].variableObj.NEO_Data_Source__c = "";
			}
		}

		component.set("v.fieldsWrapperList", _fields_wrapper_list);
	},
	jsAllChangeValueKey : function(component, event, helper) {
		let _all_fields_wrapper_list = component.get("v.allFieldsWrapperList");

		for (var j = 0; j < _all_fields_wrapper_list.length; j++) {
			let _value_key = _all_fields_wrapper_list[j].variableObj.NEO_Value_Key__c;
			if (!_value_key) {
				_all_fields_wrapper_list[j].variableObj.NEO_Data_Source__c = "";
			}
		}

		component.set("v.allFieldsWrapperList", _all_fields_wrapper_list);
	},
	jsAddFields : function(component, event, helper) {
		let _all_fields_wrapper_list = component.get("v.allFieldsWrapperList");
		let _fields_wrapper_list = component.get("v.fieldsWrapperList");

		let _new_all_fields_wrapper_list = [];

		let _selected_row_number = 0;

		for (var j = 0; j < _all_fields_wrapper_list.length; j++) {
			let _temp_field_wrapper_row = _all_fields_wrapper_list[j];
			if (_temp_field_wrapper_row.isSelected) {
				_fields_wrapper_list.push(_temp_field_wrapper_row);
				++_selected_row_number;
			} else {
				_new_all_fields_wrapper_list.push(_temp_field_wrapper_row);
			}
		}
		console.log(_selected_row_number);
		if (_selected_row_number < 1) {
			component.set("v.showListMessage", true);
			return;
		}

		component.set("v.allFieldsWrapperList", _new_all_fields_wrapper_list);
		component.set("v.fieldsWrapperList", _fields_wrapper_list);
	},
	jsDeleteFields : function(component, event, helper) {
		let _row_index = event.currentTarget.dataset.rowIndex;
		let _fields_wrapper_list = component.get("v.fieldsWrapperList");

		let _new_fields_wrapper_list = [];

		for (var j = 0; j < _fields_wrapper_list.length; j++) {
			let _temp_field_wrapper_row = _fields_wrapper_list[j];
			if (_row_index != j) {
				_new_fields_wrapper_list.push(_temp_field_wrapper_row);
			}
		}
		component.set("v.fieldsWrapperList", _new_fields_wrapper_list);
	},
	jsShowChildObjectSearchModal : function(component, event, helper) {
		component.set("v.showListLoading", true);
		component.set("v.childObjectSearchModalClass", "slds-show");
		component.set("v.allVariableAssociationWrapperList", []);

		let _variable_obj = component.get("v.variableObj");
		let _variable_association_wrapper_list = component.get("v.variableAssociationWrapperList");
		let _object_variable_cache = component.get("v.objectVariableCache");

		let _action = component.get("c.loadAllVariableAssociationWrapperList");
		_action.setParams({
			"variableObj" : _variable_obj,
			"variableAssociationWrapperListJSON" : JSON.stringify(_variable_association_wrapper_list),
			"objectVariableCacheJSON" : JSON.stringify(_object_variable_cache),
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			console.log(_returnValue);
			if (_returnValue == null || _returnValue == "") {
				return;
			}

			component.set("v.allVariableAssociationWrapperList", _returnValue.allVariableAssociationWrapperList);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
			component.set("v.showListLoading", false);
		});
	},
	jsCloseChildObjectSearchModal : function(component, event, helper) {
		component.set("v.childObjectSearchModalClass", "slds-hide");
		component.set("v.allVariableAssociationWrapperList", []);
		component.set("v.showListMessage", false);
		component.set("v.showListLoading", false);
	},
	jsAddVariableAssociation : function(component, event, helper) {
		let _all_variable_association_wrapper_list = component.get("v.allVariableAssociationWrapperList");
		let _variable_association_wrapper_list = component.get("v.variableAssociationWrapperList");

		let _new_all_variable_association_wrapper_list = [];

		let _selected_row_number = 0;

		for (var j = 0; j < _all_variable_association_wrapper_list.length; j++) {
			let _temp_variable_association_wrapper_row = _all_variable_association_wrapper_list[j];
			if (_temp_variable_association_wrapper_row.isSelected) {
				_variable_association_wrapper_list.push(_temp_variable_association_wrapper_row);
				++_selected_row_number;
			} else {
				_new_all_variable_association_wrapper_list.push(_temp_variable_association_wrapper_row);
			}
		}

		if (_selected_row_number < 1) {
			component.set("v.showListMessage", true);
			return;
		}

		console.log(_variable_association_wrapper_list);

		component.set("v.allVariableAssociationWrapperList", _new_all_variable_association_wrapper_list);
		component.set("v.variableAssociationWrapperList", _variable_association_wrapper_list);
	},
	jsDeleteVariableAssociation : function(component, event, helper) {
		let _row_index = event.currentTarget.dataset.rowIndex;
		let _variable_association_wrapper_list = component.get("v.variableAssociationWrapperList");

		let _new_variable_association_wrapper_list = [];

		for (var j = 0; j < _variable_association_wrapper_list.length; j++) {
			let _temp_variable_association_wrapper_row = _variable_association_wrapper_list[j];

			if (_row_index != j) {
				_new_variable_association_wrapper_list.push(_temp_variable_association_wrapper_row);
			}
		}

		component.set("v.variableAssociationWrapperList", _new_variable_association_wrapper_list);
	},
	jsSave : function(component, event, helper) {
		var allValid = component.find("NEO_variable_form_item").reduce(function(validFields, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return validFields && inputCmp.get('v.validity').valid;
		}, true);

		if (!allValid) {
			helper.helperShowAlert(component, "warning", component.get("v.defaultWarningMsg"));
			return;
		}

		let _variable_obj = component.get("v.variableObj");
		let _fields_wrapper_list = component.get("v.fieldsWrapperList");
		let _variable_association_wrapper_list = component.get("v.variableAssociationWrapperList");
		let _object_variable_cache = component.get("v.objectVariableCache");

		component.set("v.showLoading", true);

		let _action = component.get("c.tSave");
		_action.setParams({
			"variableObj" : _variable_obj,
			"variableAssociationWrapperListJSON" : JSON.stringify(_variable_association_wrapper_list),
			"fieldsWrapperListJSON" : JSON.stringify(_fields_wrapper_list),
			"objectVariableCacheJSON" : JSON.stringify(_object_variable_cache)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			console.log(_returnValue);

			if (_returnValue == null || _returnValue == "") {
				return;
			}

			component.set("v.variableAssociationWrapperList", _returnValue.variableAssociationWrapperList);
			component.set("v.fieldsWrapperList", _returnValue.fieldsWrapperList);

			component.set("v.objectVariableCache", _returnValue.objectVariableCache);

			component.set("v.variableObj", _returnValue.variableObj);
			component.set("v.oldVariableObj", _returnValue.oldVariableObj);
			component.set("v.variableWrapperObj", _returnValue.variableWrapperObj);

			helper.helperShowAlert(component, _returnValue.strStatusCode, _returnValue.strStatusMsg);
			
		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
			component.set("v.showLoading", false);
		});
	},
	jsCancel : function(component, event, helper) {
		let _object_home_event = $A.get("e.force:navigateToObjectHome");
		if (_object_home_event) {
    		_object_home_event.setParams({
		        "scope": "NEO_Variable__c"
		    });
		    _object_home_event.fire();
    	} else {
    		location.href = '/' + component.get("v.keyPrefix");
    	}
	},
	jsEdit : function(component, event, helper) {
		let _variable_obj = component.get("v.variableObj");

		let _event_handler = $A.get("e.force:navigateToSObject");
		if (_event_handler) {
    		_event_handler.setParams({
		        "recordId": _variable_obj.Parent_Variable__c,
      			"slideDevName": "detail"
		    });
		    _event_handler.fire();
    	} else {
    		location.href = '/' + _variable_obj.Parent_Variable__c;
    	}
	},
	jsViewRule : function(component, event, helper) {
		let _rule_id = event.currentTarget.dataset.rowIndex;
		console.log(_rule_id);

		let _event_handler = $A.get("e.force:navigateToSObject");
		if (_event_handler) {
    		_event_handler.setParams({
		        "recordId": _rule_id,
      			"slideDevName": "detail"
		    });
		    _event_handler.fire();
    	} else {
    		location.href = '/' + _rule_id;
    	}
	},
	jsCreateRule : function(component, event, helper) {
		let _master_object_name = component.get("v.variableObj.Variable_API_Name__c");
		console.log(_master_object_name);

		let _event_handler = $A.get("e.force:navigateToComponent");
		if (_event_handler) {
			_event_handler.setParams({
		        componentDef : "c:NEO_Rules_LC",
		        componentAttributes: {
		            strMasterObjectName : _master_object_name
		        }
		    });
		    _event_handler.fire();
		} else {
			location.href = '/apex/NEO_Rules?strMasterObjectName=' + _master_object_name;
		}
	},
	jsCloseAlert : function(component, event, helper) {
		helper.helperCloseAlert(component);
	}
})