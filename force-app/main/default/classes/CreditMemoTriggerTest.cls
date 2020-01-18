@isTest
private class CreditMemoTriggerTest {

    @isTest
    private static void bulkOnInsertTest() {
        List<Credit_Memo__c> creditMemos = new List<Credit_Memo__c>();

        for (Integer i =0; i < 120; i++) {
            creditMemos.add(new Credit_Memo__c());
        }

        Test.startTest();
        insert creditMemos;
        Test.stopTest();

        List<Credit_Memo__c> resultedCreditMemos = [
            SELECT Note__c
            FROM Credit_Memo__c
            WHERE Note__c = '. Valid​ ​for​ ​any​ ​new​ ​bookings​ ​made​ ​by​ {Credit​ ​Expiry​ ​Date}'
        ];
        System.assertEquals(120, resultedCreditMemos.size(), 'Not all credit memos note fields were set correctly');
    }

    @isTest
    private static void bulkOnUpdateTest() {
        List<Credit_Memo__c> creditMemos = new List<Credit_Memo__c>();

        for (Integer i =0; i < 100; i++) {
            creditMemos.add(new Credit_Memo__c());
        }
        insert creditMemos;

        for (Integer i =0; i < 100; i++) {
            creditMemos.get(i).Credit_Expiry_Date__c = Date.newinstance(2020, 1, 18);
        }

        Test.startTest();
        update creditMemos;
        Test.stopTest();

        List<Credit_Memo__c> resultedCreditMemos = [
            SELECT Note__c
            FROM Credit_Memo__c
            WHERE Note__c = '. Valid​ ​for​ ​any​ ​new​ ​bookings​ ​made​ ​by​ 18 January 2020'
        ];
        System.assertEquals(100, resultedCreditMemos.size(), 'Not all credit memos note fields were set correctly');
    }


    @isTest
    private static void setNoteOnInsertNonEmptyExpireDateTest() {
        Credit_Memo__c creditMemo = new Credit_Memo__c(
            Credit_Expiry_Date__c = Date.newinstance(2020, 1, 18)
        );

        Test.startTest();
        insert creditMemo;
        Test.stopTest();

        Credit_Memo__c creditMemoResult = [
            SELECT Note__c 
            FROM Credit_Memo__c 
            WHERE Id = :creditMemo.Id LIMIT 1
        ];

        System.assertEquals('. Valid​ ​for​ ​any​ ​new​ ​bookings​ ​made​ ​by​ 18 January 2020', creditMemoResult.Note__c, 'The note field was not set correctly');
    }

    @isTest
    private static void updateNoteWithEmptyExpireDateTest() {
        Credit_Memo__c creditMemo = new Credit_Memo__c(
            Credit_Expiry_Date__c = Date.newinstance(2020, 1, 18)
        );
        insert creditMemo;
        creditMemo.Credit_Expiry_Date__c = null;
        
        Test.startTest();
        update creditMemo;
        Test.stopTest();

        Credit_Memo__c creditMemoResult = [
            SELECT Note__c 
            FROM Credit_Memo__c 
            WHERE Id = :creditMemo.Id 
            LIMIT 1
        ];

        System.assertEquals('. Valid​ ​for​ ​any​ ​new​ ​bookings​ ​made​ ​by​ {Credit​ ​Expiry​ ​Date}', creditMemoResult.Note__c, 'The note field was not set correctly');
    }

    @isTest
    private static void updateNoteWithNewExpireDateTest() {
        Credit_Memo__c creditMemo = new Credit_Memo__c(
            Credit_Expiry_Date__c = Date.newinstance(2020, 1, 18)
        );
        insert creditMemo;
        creditMemo.Credit_Expiry_Date__c = Date.newinstance(2020, 1, 19);
        
        Test.startTest();
        update creditMemo;
        Test.stopTest();

        Credit_Memo__c creditMemoResult = [
            SELECT Note__c 
            FROM Credit_Memo__c 
            WHERE Id = :creditMemo.Id 
            LIMIT 1
        ];

        System.assertEquals('. Valid​ ​for​ ​any​ ​new​ ​bookings​ ​made​ ​by​ 19 January 2020', creditMemoResult.Note__c, 'The note field was not set correctly');
    }

    @isTest
    private static void updateNoteWithoutChangeOfExpireDateTest() {
        Credit_Memo__c creditMemo = new Credit_Memo__c(
            Credit_Expiry_Date__c = Date.newinstance(2020, 1, 18)
        );
        insert creditMemo;
        creditMemo.Amount__c = 100;
        
        Test.startTest();
        update creditMemo;
        Test.stopTest();

        Credit_Memo__c creditMemoResult = [
            SELECT Note__c 
            FROM Credit_Memo__c 
            WHERE Id = :creditMemo.Id 
            LIMIT 1
        ];

        System.assertEquals('. Valid​ ​for​ ​any​ ​new​ ​bookings​ ​made​ ​by​ 18 January 2020', creditMemoResult.Note__c, 'The note field was not set correctly'); 
    }

    @isTest
    private static void updateNoteManuallyTest() {
        Credit_Memo__c creditMemo = new Credit_Memo__c();
        insert creditMemo;

        creditMemo.Note__c = null;
        update creditMemo;
        creditMemo.Credit_Expiry_Date__c = Date.newinstance(2020, 1, 18);
        
        Test.startTest();
        update creditMemo;
        Test.stopTest();

        Credit_Memo__c creditMemoResult = [
            SELECT Note__c 
            FROM Credit_Memo__c 
            WHERE Id = :creditMemo.Id 
            LIMIT 1
        ];

        System.assertEquals('. Valid​ ​for​ ​any​ ​new​ ​bookings​ ​made​ ​by​ 18 January 2020', creditMemoResult.Note__c, 'The note field was not set correctly'); 
    }

    @isTest
    private static void noteFieldLimitTest() {
        Credit_Memo__c creditMemo = new Credit_Memo__c(
            Credit_Expiry_Date__c = Date.newinstance(2020, 1, 18),
            Note__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.' +
                    'Nullam in lacus cursus, interdum augue at, tempus erat.' +
                    'Cras accumsan, dolor non sollicitudin commodo, tortor purus ornare ipsum, non tristique justo dui sit amet libero.' +
                    'Vestibulum in lorem nullam.'
        );

        Test.startTest();
        try {
            insert creditMemo;
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'The note field validation does not work correctly');
            System.assert(e.getMessage().contains('The note value is too large.'), 'The note field validation does not work correctly');
        }
        Test.stopTest();
    }
}