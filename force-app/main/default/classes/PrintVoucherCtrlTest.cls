@isTest
private class PrintVoucherCtrlTest {

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
    private static void initPageWithDefaultImageTest() {
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
            Credit_Expiry_Date__c = Date.newinstance(2020, 1, 18),
            Note__c = '. Valid term 1\n.Valid term 2\n.Valid term 3'
        );
        insert creditMemo;

        PrintVoucherCtrlTest.setupCustomSettign();
        Test.startTest();
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(creditMemo);
        PrintVoucherCtrl extentionCtrl = new PrintVoucherCtrl(standardCtrl);
        Test.stopTest();

        System.assertEquals(PrintVoucherCtrl.CONTENT_VERSION_ACCESS_URL + cv.Id, extentionCtrl.imageUrl, 'The image url was not set as expected');
        System.assertEquals(3, extentionCtrl.notes.size(), 'Note field was not parsed correctly');
    }

    @isTest
    private static void initPageWithOverrideImageTest() {
        ContentWorkspace library = [SELECT Id FROM ContentWorkspace WHERE DeveloperName = 'Global_Image_Test' LIMIT 1];
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        ContentVersion cv1 = new ContentVersion(
            Title = 'Image 1',
            PathOnClient = 'Image1.jpg',
            VersionData = Blob.valueof('TestImageData1'),
            IsMajorVersion = true,
            FirstPublishLocationId = library.Id,
            Expiry_From_Date__c = Date.newinstance(2020, 1, 17),
            Expiry_To_Date__c = Date.newinstance(2020, 1, 20)
        );
        ContentVersion cv2 = new ContentVersion(
            Title = 'Image 2',
            PathOnClient = 'Image2.jpg',
            VersionData = Blob.valueof('TestImageData2'),
            IsMajorVersion = true,
            FirstPublishLocationId = library.Id,
            Expiry_From_Date__c = Date.newinstance(2020, 1, 17),
            Expiry_To_Date__c = Date.newinstance(2020, 1, 20)
        );
        contentVersions.add(cv1);
        contentVersions.add(cv2);
        insert contentVersions;

        ContentVersion selectedCV = [SELECT Unique_Title__c FROM ContentVersion WHERE Id =: cv2.Id LIMIT 1];
        Credit_Memo__c creditMemo = new Credit_Memo__c(
            Credit_Expiry_Date__c = Date.newinstance(2020, 1, 18),
            Background_Image__c = selectedCV.Unique_Title__c
        );
        insert creditMemo;

        PrintVoucherCtrlTest.setupCustomSettign();
        Test.startTest();
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(creditMemo);
        PrintVoucherCtrl extentionCtrl = new PrintVoucherCtrl(standardCtrl);
        Test.stopTest();

        System.assertEquals(PrintVoucherCtrl.CONTENT_VERSION_ACCESS_URL + cv2.Id, extentionCtrl.imageUrl, 'The image url was not set as expected');
    }

    @isTest
    private static void initPageWithConfigErrorTest() {
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
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(creditMemo);
        try {
            PrintVoucherCtrl extentionCtrl = new PrintVoucherCtrl(standardCtrl);
        }
        catch(CannotFindContentException e) {
            System.assert(e.getMessage().contains('Please check settings.'), 'The expected error was not thrown');
        }
        Test.stopTest();
    }

    private static void initPageWithFileNameErrorTest() {
        Credit_Memo__c creditMemo = new Credit_Memo__c(
            Credit_Expiry_Date__c = Date.newinstance(2020, 1, 18),
            Background_Image__c = 'Wrong_Unique_Name'
        );
        insert creditMemo;

        PrintVoucherCtrlTest.setupCustomSettign();
        Test.startTest();
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(creditMemo);
        try {
            PrintVoucherCtrl extentionCtrl = new PrintVoucherCtrl(standardCtrl);
        }
        catch(CannotFindContentException e) {
            System.assert(e.getMessage().contains('not able to find an image based on specified Unique Title'), 'The expected error was not thrown');
        }
        Test.stopTest();
    }

    @isTest
    private static void initPageWithExpireDateErrorTest() {
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
            Credit_Expiry_Date__c = Date.newinstance(2022, 1, 18)
        );
        insert creditMemo;

        PrintVoucherCtrlTest.setupCustomSettign();
        Test.startTest();
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(creditMemo);
        try {
            PrintVoucherCtrl extentionCtrl = new PrintVoucherCtrl(standardCtrl);
        }
        catch(CannotFindContentException e) {
            System.assert(e.getMessage().contains('not able to find an image based on specified Expire Date'), 'The expected error was not thrown');
        }
        Test.stopTest();
    }
}