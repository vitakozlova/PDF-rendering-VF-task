public with sharing class DefaultFilePreviewCtrl {

    @AuraEnabled
    public static String getDefaultImageId(String creditMemoId) {

        Credit_Memo_Config__c config = Credit_Memo_Config__c.getInstance();
        if (config == null || config.Library_Unique_Name__c == null) {
            throw new AuraException('The Credit Memo Config or Files Library Unique name doesn\'t set. Please check settings.');
        }
        List<Credit_Memo__c> creditMemos = [
            SELECT Credit_Expiry_Date__c 
            FROM Credit_Memo__c 
            WHERE Id = :creditMemoId
            LIMIT 1
        ];

        return ContentDocumentSelector.getContentDocumentIdByExpireDate(
                                                        creditMemos.get(0).Credit_Expiry_Date__c, config.Library_Unique_Name__c);
    }
}