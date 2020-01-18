({
    openFile : function(component, event, helper) {
        console.log('cc ');
        var currentRecordId = component.get('v.recordId');
        var action = component.get('c.getDefaultImageId');
        action.setParams({'creditMemoId': currentRecordId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            $A.get("e.force:closeQuickAction").fire();
            if (state === 'SUCCESS') {
                var fileId = response.getReturnValue();
                console.log('fileId ', fileId);
                if ($A.get('e.lightning:openFiles')) {
                    $A.get('e.lightning:openFiles').fire({
                        recordIds: [fileId]
                    });
                }
                else {
                    window.open('/' + fileId, '_self', 'width=760,height=400');
                }
                // component.set('v.fileId', fileId);
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
        // console.log('component date ', component.get('v.expireDate'));
        // var fileId = '0692v00000DK7dv';//event.currentTarget.dataset.value;
        // console.log('aaa', $A.get('e.lightning:openFiles'));
        // if ($A.get('e.lightning:openFiles')) {
        //     $A.get('e.lightning:openFiles').fire({
        //         recordIds: [fileId]
        //     });
        // }
        // else {
        //     window.open('/0692v00000DK7dv', '_self', 'width=760,height=400');
        // }

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
