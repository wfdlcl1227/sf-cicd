({
    helperMethod: function () {
        
    },
    
    handleLogin: function (username,
                           password) {
        console.log("called helper");
        var username = username;
        console.log("username " +
                    username);
        var password = password;
        var action = component.get(
            "c.login");
        var startUrl = component.get(
            "v.startUrl");
        
        console.log("password " +
                    password);
        console.log("startUrl " +
                    startUrl);
        
        startUrl =
            decodeURIComponent(
            startUrl);
        
        action.setParams({
            username: username,
            password: password,
            startUrl: startUrl
        });
        action.setCallback(this,
                           function (a) {
                               var rtnValue = a.getReturnValue();
                               if (rtnValue !==
                                   null) {
                                   component.set(
                                       "v.errorMessage",
                                       rtnValue);
                                   component.set(
                                       "v.showError",
                                       true);
                               }
                           });
        $A.enqueueAction(action);
    },
    
    
})