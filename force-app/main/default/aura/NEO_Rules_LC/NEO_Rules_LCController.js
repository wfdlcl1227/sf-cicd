({
	doInit : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);
		
		let _record_id = component.get("v.recordId");
		let _master_object_name = component.get("v.strMasterObjectName");

		let _action = component.get("c.initialize");
		_action.setParams({
			"recordId": _record_id,
			"strMasterObjectName": _master_object_name
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			console.log(_returnValue);

			component.set("v.masterObjects", _returnValue.masterObjects);
			component.set("v.dayIDOptions", _returnValue.dayIDOptions);
			component.set("v.hardStopWarningOptions", _returnValue.hardStopWarningOptions);
			component.set("v.approvalLevelOptions", _returnValue.approvalLevelOptions);
			component.set("v.criteriaWrapperList", _returnValue.criteriaWrapperList);
			component.set("v.keyPrefix", _returnValue.keyPrefix);
			component.set("v.fieldsMap", _returnValue.fieldsMap);
			component.set("v.labelMaps", _returnValue.labelMaps);
			component.set("v.criteriaLabelMaps", _returnValue.criteriaLabelMaps);
			component.set("v.ruleRtOptions", _returnValue.ruleRtOptions);
			component.set("v.ruleRtMaps", _returnValue.ruleRtMaps);
			component.set("v.layoutList", _returnValue.layoutList);

			component.set("v.ruleObj", _returnValue.ruleObj);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
			component.set("v.showScope", true);
		   	component.set("v.showLoading", false);
		});
	},
	jsTickRealtimeSwitch : function(component, event, helper) {
		let _realtime_trigger_checkbox = component.get("v.ruleObj.Real_Time_Trigger__c");
		if (_realtime_trigger_checkbox) {
			component.set("v.ruleObj.Hard_Stop_Warning__c", 'Hard Stop');
		}
		component.set("v.ruleObj.NEO_Insert_Triggered__c", _realtime_trigger_checkbox);
		component.set("v.ruleObj.NEO_Update_Triggered__c", _realtime_trigger_checkbox);
		component.set("v.ruleObj.NEO_Delete_Triggered__c", _realtime_trigger_checkbox);

		let _js_tick_update_triggered = component.get("c.jsTickUpdateTriggered");
        $A.enqueueAction(_js_tick_update_triggered);
	},
	jsTickInsertTriggered : function(component, event, helper) {
		let _insert_triggered_checkbox = component.get("v.ruleObj.NEO_Insert_Triggered__c");
		let _update_triggered_checkbox = component.get("v.ruleObj.NEO_Update_Triggered__c");
		let _delete_triggered_checkbox = component.get("v.ruleObj.NEO_Delete_Triggered__c");

		component.set("v.ruleObj.Real_Time_Trigger__c", _insert_triggered_checkbox || _update_triggered_checkbox || _delete_triggered_checkbox);
	},
	jsTickUpdateTriggered : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);

		let _insert_triggered_checkbox = component.get("v.ruleObj.NEO_Insert_Triggered__c");
		let _update_triggered_checkbox = component.get("v.ruleObj.NEO_Update_Triggered__c");
		let _delete_triggered_checkbox = component.get("v.ruleObj.NEO_Delete_Triggered__c");
		component.set("v.ruleObj.Real_Time_Trigger__c", _insert_triggered_checkbox || _update_triggered_checkbox || _delete_triggered_checkbox);

		let _ruleObj = component.get("v.ruleObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");
		let _row_index = "";

    	let _action = component.get("c.changeCriteriaRowValue");
		_action.setParams({
			"rowIndex": _row_index,
			"ruleObj": _ruleObj,
			"changeType": "ruleType",
			"jsonString": JSON.stringify(_criteriaWrapperList)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.criteriaWrapperList", _returnValue);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
			component.set("v.showLoading", false);
		});
	},
	jsTickDeleteTriggered : function(component, event, helper) {
		let _insert_triggered_checkbox = component.get("v.ruleObj.NEO_Insert_Triggered__c");
		let _update_triggered_checkbox = component.get("v.ruleObj.NEO_Update_Triggered__c");
		let _delete_triggered_checkbox = component.get("v.ruleObj.NEO_Delete_Triggered__c");

		component.set("v.ruleObj.Real_Time_Trigger__c", _insert_triggered_checkbox || _update_triggered_checkbox || _delete_triggered_checkbox);
	},
	jsChangeMasterObject : function(component, event, helper) {
		component.set("v.ruleObj.Custom_Logic__c", "");
		component.set("v.criteriaWrapperList", []);

		// Show Loading
		component.set("v.showLoading", true);
		
		let _ruleObj = component.get("v.ruleObj");
		let _action = component.get("c.changeMasterObject");
		_action.setParams({
			"ruleObj": _ruleObj
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			console.log(_returnValue);
			
			component.set("v.ruleObj", _returnValue.ruleObj);
			component.set("v.dayIDOptions", _returnValue.dayIDOptions);
			component.set("v.layoutList", _returnValue.layoutList);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   	component.set("v.showLoading", false);
		});
	},
	jsSave : function(component, event, helper) {
		let _valid_rule = true;
		var allValid = component.find("NEO_rule_form_item").reduce(function(validFields, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return validFields && inputCmp.get('v.validity').valid;
		}, true);

		if (!allValid) {
			helper.helperShowAlert(component, "warning", component.get("v.defaultWarningMsg"));
			return;
		}

		// Show Loading
		component.set("v.showLoading", true);

		// Save
		let _ruleObj = component.get("v.ruleObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");

		let _action = component.get("c.tSave");
		_action.setParams({
			"ruleObj": _ruleObj,
			"jsonString": JSON.stringify(_criteriaWrapperList)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.ruleObj", _returnValue.ruleObj);
			component.set("v.criteriaWrapperList", _returnValue.criteriaWrapperList);

			helper.helperShowAlert(component, _returnValue.strStatusCode, _returnValue.strStatusMsg);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});
	},
	jsClone : function(component, event, helper) {
		let _valid_rule = true;
		var allValid = component.find("NEO_rule_form_item").reduce(function(validFields, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return validFields && inputCmp.get('v.validity').valid;
		}, true);

		if (!allValid) {
			helper.helperShowAlert(component, "warning", component.get("v.defaultWarningMsg"));
			return;
		}

		// Show Loading
		component.set("v.showLoading", true);

		// Clone
		let _ruleObj = component.get("v.ruleObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");

		let _action = component.get("c.tClone");
		_action.setParams({
			"ruleObj": _ruleObj,
			"jsonString": JSON.stringify(_criteriaWrapperList)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {

			let _record_id = _returnValue.ruleObj.Id;

	    	let _event_handler = $A.get("e.force:navigateToSObject");
	    	if (_event_handler) {
	    		_event_handler.setParams({
			        "recordId": _record_id,
	      			"slideDevName": "detail"
			    });
			    _event_handler.fire();
	    	} else {
	    		location.href = '/' + _record_id;
	    	}

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});
	},
	jsAddCriteriaRow : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);

		let _ruleObj = component.get("v.ruleObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");

		let _action = component.get("c.addCriteriaRow");
		_action.setParams({
			"ruleObj": _ruleObj,
			"jsonString": JSON.stringify(_criteriaWrapperList)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.ruleObj", _returnValue.ruleObj);
			component.set("v.criteriaWrapperList", _returnValue.criteriaWrapperList);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});
	},
	jsDeleteCriteriaRow : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);

		let _ruleObj = component.get("v.ruleObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");
		var _row_index = event.getSource().get("v.value");

		let _action = component.get("c.deleteCriteriaRow");
		_action.setParams({
			"rowIndex": _row_index,
			"ruleObj": _ruleObj,
			"jsonString": JSON.stringify(_criteriaWrapperList)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.ruleObj", _returnValue.ruleObj);
			component.set("v.criteriaWrapperList", _returnValue.criteriaWrapperList);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});
	},
	jsChangeRowValue : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);

		let _ruleObj = component.get("v.ruleObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");
		let _row_index = event.getSource().get("v.class");

    	let _action = component.get("c.changeCriteriaRowValue");
		_action.setParams({
			"rowIndex": _row_index,
			"ruleObj": _ruleObj,
			"jsonString": JSON.stringify(_criteriaWrapperList)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.criteriaWrapperList", _returnValue);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});
	},
	jsChangeOperator : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);

		let _ruleObj = component.get("v.ruleObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");
		let _row_index = event.getSource().get("v.class");

    	let _action = component.get("c.changeCriteriaRowValue");
		_action.setParams({
			"rowIndex": _row_index,
			"ruleObj": _ruleObj,
			"changeType": "Operator",
			"jsonString": JSON.stringify(_criteriaWrapperList)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.criteriaWrapperList", _returnValue);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});
	},
	jsChangeResource : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);

		let _ruleObj = component.get("v.ruleObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");
		let _row_index = event.getSource().get("v.class");

    	let _action = component.get("c.changeCriteriaRowValue");
		_action.setParams({
			"rowIndex": _row_index,
			"ruleObj": _ruleObj,
			"changeType": "Resource",
			"jsonString": JSON.stringify(_criteriaWrapperList)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.criteriaWrapperList", _returnValue);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});
	},
	jsChangeResourceOperator : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);

		let _ruleObj = component.get("v.ruleObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");
		let _row_index = event.getSource().get("v.class");

    	let _action = component.get("c.changeCriteriaRowValue");
		_action.setParams({
			"rowIndex": _row_index,
			"ruleObj": _ruleObj,
			"changeType": "ResourceOperator",
			"jsonString": JSON.stringify(_criteriaWrapperList)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.criteriaWrapperList", _returnValue);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});
	},
	jsCloseAlert : function(component, event, helper) {
		helper.helperCloseAlert(component);
	},
	jsCancel : function(component, event, helper) {
		let _master_object_name =  component.get("v.strMasterObjectName");
		
		if (_master_object_name) {
			let _event_handler = $A.get("e.force:navigateToSObject");
			if (_event_handler) {
				_event_handler.setParams({
			    	"recordId": component.get("v.ruleObj.Master_Object__c"),
			    	"slideDevName": "detail"
			    });
			    _event_handler.fire();
			} else {
				location.href = '/' + component.get("v.ruleObj.Master_Object__c");
			}
		} else {
			let _object_home_event = $A.get("e.force:navigateToObjectHome");
			if (_object_home_event) {
	    		_object_home_event.setParams({
			        "scope": "NEO_Rule__c"
			    });
			    _object_home_event.fire();
	    	} else {
	    		location.href = '/' + component.get("v.keyPrefix");
	    	}
		}
	}
})