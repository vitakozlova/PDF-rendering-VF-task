@isTest
private class NavigateToPrintVoucherPageCtrlTest {
    @isTest
    private static void fakeServerCallTest() {
        Test.startTest();
        String result = NavigateToPrintVoucherPageCtrl.fakeServerCall();
        Test.stopTest();

        System.assertEquals('Success', result);
    }
}