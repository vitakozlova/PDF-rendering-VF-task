public with sharing class PrintVoucherCtrl {

    public String imageUrl {get; private set;}
    public List<String> notes {get; private set;}

    private final Credit_Memo__c creditMemoRecord;
    @TestVisible
    private final static String CONTENT_VERSION_ACCESS_URL = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=';
    
    public PrintVoucherCtrl(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String>{'Credit_Expiry_Date__c', 'Background_Image__c', 'Note__c'});
        }
        this.creditMemoRecord = (Credit_Memo__c) stdController.getRecord();
        this.prepareImageUrl();
        this.prepareNotesList();
    }

    private void prepareNotesList() {
        if (this.creditMemoRecord.Note__c == null) {
            this.notes = new List<String>();
            return;
        }

        List<String> notes = this.creditMemoRecord.Note__c.split('\n.');
        if (notes.get(0).startsWith('.')) {
            String firstElement = notes.get(0);
            notes.set(0, firstElement.substring(1, firstElement.length()));
        }
        for (String note: notes) {
            note = note.trim();
        }

        this.notes = notes;
    }

    private void prepareImageUrl() {
        Id contentVersionId;

        if (this.creditMemoRecord.Background_Image__c != null) {
            contentVersionId = ContentDocumentSelector.getContentVersionIdByUniqueTitle(this.creditMemoRecord.Background_Image__c);
        }
        else {
            Credit_Memo_Config__c config = Credit_Memo_Config__c.getInstance();
            if (config == null || config.Library_Unique_Name__c == null) {
               throw new CannotFindContentException('The Credit Memo Config or Files Library Unique name doesn\'t set. Please check settings.');
            }

            contentVersionId = ContentDocumentSelector.getContentVersionIdByExpireDate(
                                                    this.creditMemoRecord.Credit_Expiry_Date__c, config.Library_Unique_Name__c);
        }   

        this.imageUrl = PrintVoucherCtrl.CONTENT_VERSION_ACCESS_URL + contentVersionId;
    }
}