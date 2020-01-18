trigger CreditMemoTrigger on Credit_Memo__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CreditMemoTriggerHandler.updateNoteOnInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            CreditMemoTriggerHandler.updateNoteOnUpdate(trigger.old, Trigger.new);
        }
    }
}