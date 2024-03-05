({
	doInit : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);
		
		let _record_id = component.get("v.recordId");
		let _action = component.get("c.initialize");
		_action.setParams({
			"recordId": _record_id
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.masterObjects", _returnValue.masterObjects);
			component.set("v.rollupTypeList", _returnValue.rollupTypeList);
			component.set("v.criteriaWrapperList", _returnValue.criteriaWrapperList);
			component.set("v.summarizedObjects", _returnValue.summarizedObjects);
			component.set("v.fieldsToAggregate", _returnValue.fieldsToAggregate);
			component.set("v.fieldsToGroup", _returnValue.fieldsToGroup);
			component.set("v.fieldsToGroupValues", _returnValue.fieldsToGroupValues);
			component.set("v.keyPrefix", _returnValue.keyPrefix);

			component.set("v.labelMaps", _returnValue.labelMaps);
			component.set("v.criteriaLabelMaps", _returnValue.criteriaLabelMaps);

			component.set("v.aggregationObj", _returnValue.aggregationObj);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
			component.set("v.showScope", true);
		   	component.set("v.showLoading", false);
		});
	},
	jsSave : function(component, event, helper) {
		let _valid_rule = true;
		var allValid = component.find("NEO_aggregation_form_item").reduce(function(validFields, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			return validFields && inputCmp.get('v.validity').valid;
		}, true);

		if (!allValid) {
			helper.helperShowAlert(component, "warning", component.get('v.defaultWarningMsg'));
			return;
		}
		
		// Show Loading
		component.set("v.showLoading", true);

		// Save
		let _aggregationObj = component.get("v.aggregationObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");

		let _action = component.get("c.tSave");
		_action.setParams({
			"aggregationObj": _aggregationObj,
			"jsonString": JSON.stringify(_criteriaWrapperList)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.aggregationObj", _returnValue.aggregationObj);
			component.set("v.criteriaWrapperList", _returnValue.criteriaWrapperList);
			
			helper.helperShowAlert(component, _returnValue.strStatusCode, _returnValue.strStatusMsg);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});
	},
	jsLoadSummarizedObjects : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);
		
		component.set("v.fieldsToAggregate", []);
		component.set("v.fieldsToGroup", []);
		component.set("v.aggregationObj.NEO_Summarized_Object__c", "");
		component.set("v.aggregationObj.Custom_Logic__c", "");
		component.set("v.criteriaWrapperList", []);

		// Get summarized object list
		let _aggregationObj = component.get("v.aggregationObj");

		let _action = component.get("c.loadSummarizedObjects");
		_action.setParams({
			"masterObjId": _aggregationObj.Master_Object__c,
		});

		let _promiseHandler = helper.helperMethod(component, _action);

		_promiseHandler.then(function(_returnValue) {
			component.set("v.summarizedObjects", _returnValue);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});
	},
	jsLoadFieldList : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);

		component.set("v.fieldsToAggregate", []);
		component.set("v.fieldsToGroup", []);
		component.set("v.fieldsToGroupValues", "");
		component.set("v.aggregationObj.Fields_To_Aggregate__c", "");
		component.set("v.aggregationObj.Fields_To_Group__c", "");
		component.set("v.aggregationObj.Custom_Logic__c", "");
		component.set("v.criteriaWrapperList", []);
		
		// Get Field to Group & Field to Aggregate
		let _aggregationObj = component.get("v.aggregationObj");
		if (_aggregationObj.NEO_Summarized_Object__c == null) {
			//return;
		}

		let _action = component.get("c.loadFieldList");
		_action.setParams({
			"aggregationObj": _aggregationObj
		});

		let _promiseHandler = helper.helperMethod(component, _action);

		_promiseHandler.then(function(_returnValue) {
			component.set("v.fieldsToAggregate", _returnValue.fieldsToAggregate);
			component.set("v.fieldsToGroup", _returnValue.fieldsToGroup);

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {
		   component.set("v.showLoading", false);
		});
	},
	jsChangeFieldsToGroup : function(component, event, helper) {
		let selectedOptionValue = event.getParam("value");

		component.set("v.aggregationObj.Fields_To_Group__c", selectedOptionValue.toString());
	},
	jsAddCriteriaRow : function(component, event, helper) {
		// Show Loading
		component.set("v.showLoading", true);

		let _aggregationObj = component.get("v.aggregationObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");

		let _action = component.get("c.addCriteriaRow");
		_action.setParams({
			"aggregationObj": _aggregationObj,
			"jsonString": JSON.stringify(_criteriaWrapperList)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.aggregationObj", _returnValue.aggregationObj);
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
		
		let _aggregationObj = component.get("v.aggregationObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");
		var _row_index = event.getSource().get("v.value");

		let _action = component.get("c.deleteCriteriaRow");
		_action.setParams({
			"rowIndex": _row_index,
			"aggregationObj": _aggregationObj,
			"jsonString": JSON.stringify(_criteriaWrapperList)
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			component.set("v.aggregationObj", _returnValue.aggregationObj);
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

		let _aggregationObj = component.get("v.aggregationObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");
		let _row_index = event.getSource().get("v.class");

    	let _action = component.get("c.changeCriteriaRowValue");
		_action.setParams({
			"rowIndex": _row_index,
			"aggregationObj": _aggregationObj,
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

		let _aggregationObj = component.get("v.aggregationObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");
		let _row_index = event.getSource().get("v.class");

    	let _action = component.get("c.changeCriteriaRowValue");
		_action.setParams({
			"rowIndex": _row_index,
			"aggregationObj": _aggregationObj,
			"jsonString": JSON.stringify(_criteriaWrapperList),
			"changeType" : "Resource"
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

		let _aggregationObj = component.get("v.aggregationObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");
		let _row_index = event.getSource().get("v.class");

    	let _action = component.get("c.changeCriteriaRowValue");
		_action.setParams({
			"rowIndex": _row_index,
			"aggregationObj": _aggregationObj,
			"jsonString": JSON.stringify(_criteriaWrapperList),
			"changeType": "ResourceOperator"
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

		let _aggregationObj = component.get("v.aggregationObj");
		let _criteriaWrapperList = component.get("v.criteriaWrapperList");
		let _row_index = event.getSource().get("v.class");

    	let _action = component.get("c.changeCriteriaRowValue");
		_action.setParams({
			"rowIndex": _row_index,
			"aggregationObj": _aggregationObj,
			"jsonString": JSON.stringify(_criteriaWrapperList),
			"changeType": "Operator"
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
		let _keyPrefix = component.get("v.keyPrefix");
		location = '/' + _keyPrefix;
	}
})