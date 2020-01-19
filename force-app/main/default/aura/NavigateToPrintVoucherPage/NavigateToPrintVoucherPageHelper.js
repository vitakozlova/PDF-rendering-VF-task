({
    navigateToPrintVoucherPage : function(component, event) {
        var currentRecordId = component.get('v.recordId');
        var fakeAction = component.get('c.fakeServerCall');

        fakeAction.setCallback(this, function(response) {
            $A.get("e.force:closeQuickAction").fire();
            window.open('/apex/PrintVoucher?id=' + currentRecordId, '_blank', 'width=900,height=700');
        })

        $A.enqueueAction(fakeAction);
    }
})
