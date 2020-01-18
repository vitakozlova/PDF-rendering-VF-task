public with sharing class CreditMemoTriggerHandler {

    public static final String EXPIRE_DATE_NOTE ='. Valid​ ​for​ ​any​ ​new​ ​bookings​ ​made​ ​by​ {0}';

    public static void updateNoteOnInsert(List<Credit_Memo__c> newRecords) {
        for (Credit_Memo__c newRecord: newRecords) {
            CreditMemoTriggerHandler.prepareNoteField(newRecord);
            String formattedNoteItem = CreditMemoTriggerHandler.getFormattedNoteItem(newRecord.Credit_Expiry_Date__c);
            CreditMemoTriggerHandler.canAddMoreInfoToNote(newRecord, formattedNoteItem.length());

            newRecord.Note__c += formattedNoteItem;
        }
    }
    
    public static void updateNoteOnUpdate(List<Credit_Memo__c> oldRecords, List<Credit_Memo__c> newRecords) {
        for (Integer i = 0; i < newRecords.size(); i++) {
            Credit_Memo__c oldRecord = oldRecords.get(i);
            Credit_Memo__c newRecord = newRecords.get(i);

            if (newRecord.Credit_Expiry_Date__c != oldRecord.Credit_Expiry_Date__c) {
                String formattedNoteItemOld = CreditMemoTriggerHandler.getFormattedNoteItem(oldRecord.Credit_Expiry_Date__c);
                String formattedNoteItemNew = CreditMemoTriggerHandler.getFormattedNoteItem(newRecord.Credit_Expiry_Date__c);

                CreditMemoTriggerHandler.prepareNoteField(newRecord);

                if (newRecord.Note__c.contains(formattedNoteItemOld)) {
                    CreditMemoTriggerHandler.canAddMoreInfoToNote(newRecord, formattedNoteItemNew.length() - formattedNoteItemOld.length());
                    newRecord.Note__c = newRecord.Note__c.replace(formattedNoteItemOld, formattedNoteItemNew);
                }
                else {
                    CreditMemoTriggerHandler.canAddMoreInfoToNote(newRecord, formattedNoteItemNew.length());
                    newRecord.Note__c += formattedNoteItemNew;
                }
            }
        }
    }

    private static String getFormattedDate(Date currentDate) {
        if (currentDate == null) {
            return '{Credit​ ​Expiry​ ​Date}';
        }

        Datetime currentDatetime = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());

        return currentDatetime.format('dd MMMM yyyy');
    }   

    private static String getFormattedNoteItem(Date currentDate) {
        String formattedDate = CreditMemoTriggerHandler.getFormattedDate(currentDate);

        return String.format(EXPIRE_DATE_NOTE, new List<Object>{formattedDate});
    }   

    private static void prepareNoteField(Credit_Memo__c newRecord) {
         if (newRecord.Note__c == null) {
                newRecord.Note__c = '';
        }
        else {
            newRecord.Note__c += '\n';
        }
    }

    private static void canAddMoreInfoToNote(Credit_Memo__c currentRecord, Integer additionalSymbols) {
        if (additionalSymbols > 0 && currentRecord.Note__c.length() + additionalSymbols > 255) {
            Integer extraSymbols = currentRecord.Note__c.length() + additionalSymbols - 254;
            currentRecord.addError('The note value is too large. Please reduce its size on ' + extraSymbols + ' symbols');
        }
    }
}
