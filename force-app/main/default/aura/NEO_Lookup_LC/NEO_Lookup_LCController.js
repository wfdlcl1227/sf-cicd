({
	jsInit : function(component, event, helper) {
		let _display_value = component.get("v.displayValue");
		component.set("v.inputKeyword", _display_value);

		let _master_obj = component.get("v.masterObj");
		component.set("v.dataObj", _master_obj);

		let _master_obj_id = component.get("v.masterObjID");
		component.set("v.parentObjID", _master_obj_id);

		let _js_query_list = component.get('c.jsQueryList');
		$A.enqueueAction(_js_query_list);
	},
	jsQueryList : function(component, event, helper) {
		let _input_keyword = component.get("v.inputKeyword");
		let _objectType = component.get("v.objectType");
		let _filter_fields_string = component.get("v.filterFieldsString");
		let _query_string = component.get("v.queryString");
		let _display_fields_string = component.get("v.displayFieldsString");
		let _display_sub_fields_string = component.get("v.displaySubFieldsString");
		let _parent_obj_id = component.get("v.parentObjID");
		console.log("_parent_obj_id: " + _parent_obj_id);
		
		let _action = component.get("c.search");
		_action.setParams({
			"inputKeyword": _input_keyword,
			"objectType": _objectType,
			"filterFieldsString": _filter_fields_string,
			"queryString": _query_string,
			"displayFieldsString": _display_fields_string,
			"displaySubFieldsString": _display_sub_fields_string,
			"masterObjID" : _parent_obj_id
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			if (_returnValue == null || _returnValue == "") {
				return;
			}

			console.log(_returnValue);

			let _temp_sobject_list = _returnValue.sObjectList;
			let _old_sobject_list = component.get("v.sObjectList");
			let _filter_sobject_list = {};
			let _sobject_list = new Array();

			_temp_sobject_list.forEach(function(sObj) {
				if (!_filter_sobject_list[sObj.Id]) {
					_filter_sobject_list[sObj.Id] = true;
					_sobject_list.push(sObj);
				}
			});

			if (_sobject_list.length < 1) {
				_old_sobject_list.forEach(function(sObj) {
					if (!_filter_sobject_list[sObj.Id]) {
						_filter_sobject_list[sObj.Id] = true;
						_sobject_list.push(sObj);
					}
				});
			}

			let _temp_select_options = _returnValue.selectOptions;
			let _old_select_options = component.get("v.selectOptions");
			let _filter_select_options = {};
			let _select_options = new Array();
		
			_temp_select_options.forEach(function(soObj) {
				if (!_filter_select_options[soObj.recordId]) {
					_filter_select_options[soObj.recordId] = true;
					_select_options.push(soObj);
				}
			});
			
			if (_select_options.length < 1) {
				_old_select_options.forEach(function(soObj) {
					if (!_filter_select_options[soObj.recordId]) {
						_filter_select_options[soObj.recordId] = true;
						_select_options.push(soObj);
					}
				});
			}
			
			component.set("v.selectOptions", _select_options);
			component.set("v.sObjectList", _sobject_list);

			let _show_select_list = component.get("v.showSelectList");
			if (_show_select_list && !$A.util.isEmpty(_select_options)) {
				component.set("v.openCss", "slds-is-open");
				component.set("v.expanded", "true");
			}

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {

		});
	},
	jsFocus : function(component, event, helper) {
		let _select_options = component.get("v.selectOptions");
		if (!$A.util.isEmpty(_select_options)) {
			component.set("v.openCss", "slds-is-open");
			component.set("v.expanded", "true");
		}

		let _js_validate = component.get('c.jsValidte');
		$A.enqueueAction(_js_validate);
	},
	jsCommit : function(component, event, helper) {
		let _selected_option_obj = component.get("v.selectedOptionObj");
		let _display_name = component.get("v.displayValue");
		let _input_keyword = component.get("v.inputKeyword");

		console.log("_display_name: " + _display_name);
		console.log("_input_keyword: " + _input_keyword);

		if ($A.util.isEmpty(_input_keyword)) {
			let _data_obj = component.get("v.dataObj");
			let _target_attr = component.get("v.targetAttr");
			_data_obj[_target_attr] = '';

	        let _lookup_lc_event = component.getEvent("lookupEvent");
	        _lookup_lc_event.setParams({
	        	dataObj : _data_obj,
	            selectedObj : {},
	            targetAttr : _target_attr
	        });
	        _lookup_lc_event.fire();
		}
	},
	jsSearch : function(component, event, helper) {
		let _input_keyword = component.get("v.inputKeyword");
		component.set("v.inputKeyword", _input_keyword);
		component.set("v.showSelectList", true);

		if ($A.util.isEmpty(_input_keyword)) {
			return;
		}

		let _js_query_list = component.get('c.jsQueryList');
		$A.enqueueAction(_js_query_list);
	},
	jsSearchOld : function(component, event, helper) {
		// let _input_keyword = event.target.value;
		let _input_keyword = component.get("v.inputKeyword");
		if ($A.util.isEmpty(_input_keyword)) {
			/*
			component.set("v.openCss", "");
			component.set("v.expanded", "false");
			component.set("v.selectOptions", []);
            
            let _js_clear = component.get("c.jsClear");
        	$A.enqueueAction(_js_clear);
        	*/
			return;
		}

		if (_input_keyword.length < 2) {
			return;
		}

		component.set("v.inputKeyword", _input_keyword);
		component.set("v.alertMsg", "");

		let _objectType = component.get("v.objectType");
		let _filter_fields_string = component.get("v.filterFieldsString");
		let _query_string = component.get("v.queryString");
		let _display_fields_string = component.get("v.displayFieldsString");
		let _display_sub_fields_string = component.get("v.displaySubFieldsString");
		
		let _action = component.get("c.search");
		_action.setParams({
			"inputKeyword": _input_keyword,
			"objectType": _objectType,
			"filterFieldsString": _filter_fields_string,
			"queryString": _query_string,
			"displayFieldsString": _display_fields_string,
			"displaySubFieldsString": _display_sub_fields_string
		});

		let _promiseHandler = helper.helperMethod(component, _action);
		_promiseHandler.then(function(_returnValue) {
			if (_returnValue == null || _returnValue == "") {
				return;
			}

			console.log(_returnValue);

			let _temp_sobject_list = _returnValue.sObjectList;
			let _old_sobject_list = component.get("v.sObjectList");
			let _filter_sobject_list = {};
			let _sobject_list = new Array();

			_temp_sobject_list.forEach(function(sObj) {
				if (!_filter_sobject_list[sObj.Id]) {
					_filter_sobject_list[sObj.Id] = true;
					_sobject_list.push(sObj);
				}
			});

			if (_sobject_list.length < 1) {
				_old_sobject_list.forEach(function(sObj) {
					if (!_filter_sobject_list[sObj.Id]) {
						_filter_sobject_list[sObj.Id] = true;
						_sobject_list.push(sObj);
					}
				});
			}

			let _temp_select_options = _returnValue.selectOptions;
			let _old_select_options = component.get("v.selectOptions");
			let _filter_select_options = {};
			let _select_options = new Array();
		
			_temp_select_options.forEach(function(soObj) {
				if (!_filter_select_options[soObj.recordId]) {
					_filter_select_options[soObj.recordId] = true;
					_select_options.push(soObj);
				}
			});
			
			if (_select_options.length < 1) {
				_old_select_options.forEach(function(soObj) {
					if (!_filter_select_options[soObj.recordId]) {
						_filter_select_options[soObj.recordId] = true;
						_select_options.push(soObj);
					}
				});
			}
			
			component.set("v.selectOptions", _select_options);
			component.set("v.sObjectList", _sobject_list);

			component.set("v.openCss", "slds-is-open");
			component.set("v.expanded", "true");

		}).catch(function(_error) {
    		console.log(_error);
		}).finally(function() {

		});
	},
	jsCommit : function(component, event, helper) {
		let _selected_option_obj = component.get("v.selectedOptionObj");
		let _display_name = component.get("v.displayValue");
		let _input_keyword = component.get("v.inputKeyword");

		console.log("_display_name: " + _display_name);
		console.log("_input_keyword: " + _input_keyword);

		if ($A.util.isEmpty(_input_keyword)) {
			let _data_obj = component.get("v.dataObj");
			let _target_attr = component.get("v.targetAttr");
			_data_obj[_target_attr] = '';

	        let _lookup_lc_event = component.getEvent("lookupLCEvent");
	        _lookup_lc_event.setParams({
	        	dataObj : _data_obj,
	            selectedObj : {},
	            targetAttr : _target_attr
	        });
	        _lookup_lc_event.fire();

		}
		/* else if (!$A.util.isUndefinedOrNull(_selected_option_obj) && _selected_option_obj.displayName != _display_name) {
			_display_name = _selected_option_obj.displayName;
			component.set("v.inputKeyword", _display_name);
		}
		*/
	},
	jsSelect : function(component, event, helper) {
		let _record_id = event.currentTarget.getAttribute('id');
		component.set("v.openCss", "");
		component.set("v.expanded", "false");

		let _selected_obj = null;
		let _data_obj = component.get("v.dataObj");
		let _target_attr = component.get("v.targetAttr");

		let _action_type = '';
		if (_record_id == 'New') {
			_action_type = 'New';
		} else {
			let _sobject_list = component.get("v.sObjectList");
			for (let obj of _sobject_list){
			    if (_record_id == obj.Id) {
			    	_selected_obj = obj;
			    	break;
			    }
			}

			let _sobject_options = component.get("v.selectOptions");
			for (let soObj of _sobject_options){
			    if (_record_id == soObj.recordId) {
			    	component.set("v.inputKeyword", soObj.displayName);
			    	component.set("v.selectedOptionObj", soObj);
			    	break;
			    }
			}
		}

		if (_selected_obj && _data_obj) {
			_data_obj[_target_attr] = _selected_obj.Id;
			component.set("v.selectedObj", _selected_obj);
		}

		let _lookup_lc_event = component.getEvent("lookupLCEvent");
        _lookup_lc_event.setParams({
        	"dataObj" : _data_obj,
        	"selectedObj" : _selected_obj,
        	"targetAttr" : _target_attr,
        	"actionType" : _action_type
        });
        _lookup_lc_event.fire();
	},
    jsClear : function(component, event, helper) {
    	console.log("jsClear");

    	let _data_obj = component.get("v.dataObj");
		let _target_attr = component.get("v.targetAttr");
		_data_obj[_target_attr] = '';

        let _lookup_lc_event = component.getEvent("lookupLCEvent");
        _lookup_lc_event.setParams({
        	dataObj : _data_obj,
            selectedObj : {},
            targetAttr : _target_attr
        });
        _lookup_lc_event.fire();
    },
    jsValidte : function(component, event, helper) {
    	let _form_item = component.find("NEO-form-item");
		let _form_item_list = new Array();
		if ($A.util.isArray(_form_item)) {
			_form_item_list = _form_item;
		} else if (!$A.util.isUndefinedOrNull(_form_item)) {
			_form_item_list.push(_form_item);
		}

        let validFields = _form_item_list.reduce(function(validFields, inputCmp) {
			inputCmp.showHelpMessageIfInvalid();
			let _validity_obj = inputCmp.get('v.validity');

			console.log(inputCmp.get("v.label") + "=>" + _validity_obj.valid);

			if (_validity_obj) {
				validFields = validFields && _validity_obj.valid;
			}
			return validFields;
		}, true);
        console.log("validFields: " + validFields);
    }
})