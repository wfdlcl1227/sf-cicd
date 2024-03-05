({
	helperMethod : function(component, action) {
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				let _state = response.getState();
                if (_state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                	reject(new Error(response.getError()));
                }
            });
            $A.enqueueAction(action);
		});
	},
    helperShowAlert : function(component, alertType, alertMsg) {
        let _show_success = false;
        let _show_warning = false;
        let _show_error = false;

        if (alertType == 'success') {
            _show_success = true;
        } else if (alertType == 'warning') {
            _show_warning = true;
        } else if (alertType == 'error') {
            _show_error = true;
        }

        component.set("v.showSuccess", _show_success);
        component.set("v.showWarning", _show_warning);
        component.set("v.showError", _show_error);
        component.set("v.alternativeText", alertMsg);

        window.setTimeout($A.getCallback(function() {
            component.set("v.showSuccess", false);
            component.set("v.showWarning", false);
            component.set("v.showError", false);
            component.set("v.alternativeText", "");
        }), 5000);
    },
    helperCloseAlert : function(component) {
        component.set("v.showSuccess", false);
        component.set("v.showWarning", false);
        component.set("v.showError", false);
        component.set("v.alternativeText", "");
    }
})