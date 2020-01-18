public with sharing class ContentDocumentSelector {

    public static Id getContentDocumentIdByExpireDate(Date expireDate, String libraryUniqueName) {
        
        return ContentDocumentSelector.getContentVersionByExpireDate(expireDate, libraryUniqueName).ContentDocumentId;
    }

    public static Id getContentVersionIdByExpireDate(Date expireDate, String libraryUniqueName) {
        
        return ContentDocumentSelector.getContentVersionByExpireDate(expireDate, libraryUniqueName).Id;
    }

    public static Id getContentVersionIdByUniqueTitle(String uniqueTitle) {
        List <ContentVersion> contentDocuments = [
            SELECT Id 
            FROM ContentVersion 
            WHERE Unique_Title__c = :uniqueTitle
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];

        if (contentDocuments.isEmpty()) {
            throw new CannotFindContentException('We\'re not able to find an image based on specified Unique Title. Please check configuration');
        }

        return contentDocuments.get(0).Id;
    }

    private static ContentVersion getContentVersionByExpireDate(Date expireDate, String libraryUniqueName) {
        List<ContentWorkspace> contentLibraries = [
            SELECT Id 
            FROM ContentWorkspace 
            WHERE DeveloperName = :libraryUniqueName
            LIMIT 1
        ];
        if (contentLibraries.isEmpty()) {
            throw new CannotFindContentException('We\'re not able to find the library by specified unique name. Please check Credit Memo Config settings');
        }

        List <ContentVersion> contentDocuments = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion 
            WHERE ContentDocument.ParentId = :contentLibraries.get(0).Id
                AND isLatest = true
                AND Expiry_From_Date__c <= :expireDate
                AND Expiry_To_Date__c >= :expireDate
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];

        if (contentDocuments.isEmpty()) {
            throw new CannotFindContentException('We\'re not able to find an image based on specified Expire Date and Content Library name. Please check configuration');
        }

        return contentDocuments.get(0);
    }
}