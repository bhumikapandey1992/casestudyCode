public with sharing class CaseContactProductController {
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getContactProductDetails(Id caseId) {
        // Query the Case record to get the ContactId
        Case caseRecord = [SELECT ContactId FROM Case WHERE Id = :caseId LIMIT 1];
        
        // If there is no associated Contact, return an empty list
        if (caseRecord.ContactId == null) {
            return new List<PricebookEntry>();
        }
        
        // Query the Contact record to get the Product__c and Home_Country__c fields
        Contact contactRecord = [SELECT Product__c, Home_Country__c FROM Contact WHERE Id = :caseRecord.ContactId LIMIT 1];
        
        // If there is no Product__c or Home_Country__c, return an empty list
        if (contactRecord.Product__c == null || contactRecord.Home_Country__c == null) {
            return new List<PricebookEntry>();
        }

        // Query the PricebookEntry records based on the Contact's Home_Country__c and Product__c
        List<PricebookEntry> pricebookEntries = [SELECT Id, Product2.Name, Pricebook2.Name, Cost_Per_Calendar_Month__c, ATM_Fee_in_Other_Currencies__c, Card_Replacement_Cost__c 
                                                 FROM PricebookEntry 
                                                 WHERE Pricebook2.Country__c = :contactRecord.Home_Country__c 
                                                 AND Product2Id = :contactRecord.Product__c
                                                 AND IsActive = true];
        
        return pricebookEntries;
    }
}