public with sharing class CaseContactProductController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getContactProductDetails(Id caseId) {
        // Query to get the Contact's Product__c and Home_Country__c from the Case Id
        Case caseRecord = [SELECT Contact.Product__c, Contact.Home_Country__c 
                           FROM Case 
                           WHERE Id = :caseId LIMIT 1];
        
        // If there is no associated Contact or Product, return null
        if (caseRecord.Contact == null || caseRecord.Contact.Product__c == null) {
            return null;
        }
        
        // Query the Product2 record to get the necessary product details
        Product2 productRecord = [SELECT Name, Country__c, Cost_Per_Calendar_Month__c, ATM_Fee_Other_Currencies__c, Card_Replacement_Cost__c 
                                  FROM Product2 
                                  WHERE Id = :caseRecord.Contact.Product__c LIMIT 1];
        
        // Create and populate the result map
        Map<String, Object> result = new Map<String, Object>();
        result.put('product', productRecord);
        result.put('homeCountry', caseRecord.Contact.Home_Country__c);
        
        // Return the result map
        return result;
    }
}