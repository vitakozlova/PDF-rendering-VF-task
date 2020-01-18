({
    openFile : function(component, event, helper) {
        var currentRecordId = component.get('v.recordId');
        var action = component.get('c.getDefaultImageId');
        action.setParams({'creditMemoId': currentRecordId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.get('e.force:closeQuickAction').fire();
            if (state === 'SUCCESS') {
                var fileId = response.getReturnValue();
                if ($A.get('e.lightning:openFiles')) {
                    $A.get('e.lightning:openFiles').fire({
                        recordIds: [fileId]
                    });
                }
                else {
                    window.open('/' + fileId, '_self');
                }
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showErrorMessage(errors[0].message);
                    }
                } 
                else {
                    helper.showErrorMessage('Unknown error');
                }
            }
        });

        $A.enqueueAction(action);
    },

    showErrorMessage: function (errorMessage) {
		var toastEvent = $A.get('e.force:showToast');
		if (toastEvent) {
			toastEvent.setParams({
				'title': 'Warning',
				'message': errorMessage,
				'type': 'warning'
			});
			toastEvent.fire();
		} else {
			alert(errorMessage);
		}
	},
})
