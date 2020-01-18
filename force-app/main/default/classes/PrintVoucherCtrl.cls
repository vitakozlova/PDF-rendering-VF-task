public with sharing class PrintVoucherCtrl {

    private final Credit_Memo__c creditMemoRecord;
    public String imageUrl {get; set;}
    public String message {get; set;}


    public PrintVoucherCtrl(ApexPages.StandardController stdController) {
        stdController.addFields(new List<String>{'Credit_Expiry_Date__c', 'Background_Image__c'});
        this.creditMemoRecord = (Credit_Memo__c) stdController.getRecord();

        Credit_Memo_Config__c config = Credit_Memo_Config__c.getInstance();
        if (config == null || config.Library_Unique_Name__c == null) {
            this.message = 'The Credit Memo Config or Files Library Unique name doesn\'t set. Please check settings.';
            return;
        }

        // try {
            Id contentVersionId;

            if (this.creditMemoRecord.Background_Image__c != null) {
                contentVersionId = ContentDocumentSelector.getContentVersionIdByUniqueTitle(this.creditMemoRecord.Background_Image__c);
            }
            else {
                contentVersionId = ContentDocumentSelector.getContentVersionIdByExpireDate(
                                                        this.creditMemoRecord.Credit_Expiry_Date__c, config.Library_Unique_Name__c);
            }   

            this.imageUrl = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + contentVersionId;
        // }
        // catch(CannotFindContentException e) {
        //     this.message = e.getMessage();
        // }
    }
}