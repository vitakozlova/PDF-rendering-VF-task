@isTest
private class DefaultFilePreviewCtrlTest {

    @testSetup
    private static void setupTestData() {
        ContentWorkspace library = new ContentWorkspace(
            Name = 'Global Image Test',
            DeveloperName = 'Global_Image_Test'
        );
        insert library;
    }

    private static void setupCustomSettign() {
        Credit_Memo_Config__c settings = new Credit_Memo_Config__c(
            Library_Unique_Name__c	= 'Global_Image_Test',
            Note_Default_Value__c = '. Valid term 1\n.Valid term 2\n.Valid term 3'
        );

        insert settings;
    }

    @isTest
    private static void getDefaultImageId() {
        ContentWorkspace library = [SELECT Id FROM ContentWorkspace WHERE DeveloperName = 'Global_Image_Test' LIMIT 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Image 1',
            PathOnClient = 'Image1.jpg',
            VersionData = Blob.valueof('TestImageData'),
            IsMajorVersion = true,
            FirstPublishLocationId = library.Id,
            Expiry_From_Date__c = Date.newinstance(2020, 1, 17),
            Expiry_To_Date__c = Date.newinstance(2020, 1, 20)
        );
        insert cv;

        Credit_Memo__c creditMemo = new Credit_Memo__c(
            Credit_Expiry_Date__c = Date.newinstance(2020, 1, 18)
        );
        insert creditMemo;

        DefaultFilePreviewCtrlTest.setupCustomSettign();
        Test.startTest();
        String contentDocumentId = DefaultFilePreviewCtrl.getDefaultImageId(creditMemo.Id);
        Test.stopTest();
        Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

        System.assertEquals(contentDocId, contentDocumentId, 'The content document id was not found correctly');
    }

    @isTest
    private static void getDefaultImageIdError() {
        ContentWorkspace library = [SELECT Id FROM ContentWorkspace WHERE DeveloperName = 'Global_Image_Test' LIMIT 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Image 1',
            PathOnClient = 'Image1.jpg',
            VersionData = Blob.valueof('TestImageData'),
            IsMajorVersion = true,
            FirstPublishLocationId = library.Id,
            Expiry_From_Date__c = Date.newinstance(2020, 1, 17),
            Expiry_To_Date__c = Date.newinstance(2020, 1, 20)
        );
        insert cv;

        Credit_Memo__c creditMemo = new Credit_Memo__c(
            Credit_Expiry_Date__c = Date.newinstance(2020, 1, 18)
        );
        insert creditMemo;

        Test.startTest();
        try {
            String contentDocumentId = DefaultFilePreviewCtrl.getDefaultImageId(creditMemo.Id);
        }
        catch(AuraException e) {
            System.assert(e.getMessage().contains('Please check settings.'), 'The expected error was not thrown');
        }
        Test.stopTest();
    }
}