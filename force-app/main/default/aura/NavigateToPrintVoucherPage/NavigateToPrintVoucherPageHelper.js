({
    navigateToPrintVoucherPage : function(component, event) {
        var currentRecordId = component.get('v.recordId');
        var fakeAction = component.get('c.getDefaultImageId');
        fakeAction.setParams({'creditMemoId': currentRecordId});

        fakeAction.setCallback(this, function(response) {
            $A.get("e.force:closeQuickAction").fire();
            window.open('/apex/PrintVoucher?id=' + currentRecordId, '_blank', 'width=850,height=600');
        })

        $A.enqueueAction(fakeAction);
    }
})
