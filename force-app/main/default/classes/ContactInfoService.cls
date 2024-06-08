@RestResource(urlMapping='/ContactInfo/*')
global with sharing class ContactInfoService {

    @HttpGet
    global static String doGet() {
        // Get the current REST request and response
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // Extract the UUID from the request URL
        String uuid = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        System.debug('UUID received: ' + uuid);

        // Query the Contact record using the UUID
        Contact contactRecord;
        try {
            contactRecord = [SELECT Id, FirstName, LastName, Email, Phone, Product__c, Home_Country__c 
                             FROM Contact 
                             WHERE UUID__c = :uuid 
                             LIMIT 1];
        } catch (QueryException e) {
            res.statusCode = 404;
            return '{"status": "Contact not found", "contactInfo": null}';
        }

        // If no contact is found, return a 404 response
        if (contactRecord == null) {
            res.statusCode = 404;
            return '{"status": "Contact not found", "contactInfo": null}';
        }

        // Query the PricebookEntry record associated with the contact's product and home country
        PricebookEntry pricebookEntry;
        try {
            pricebookEntry = [SELECT Product2.Name, Cost_Per_Calendar_Month__c, ATM_Fee_in_Other_Currencies__c, Card_Replacement_Cost__c, Pricebook2.Country__c 
                              FROM PricebookEntry 
                              WHERE Product2Id = :contactRecord.Product__c
                              AND Pricebook2.Country__c = :contactRecord.Home_Country__c
                              AND IsActive = true
                              LIMIT 1];
        } catch (QueryException e) {
            res.statusCode = 404;
            return '{"status": "PricebookEntry not found", "contactInfo": null}';
        }

        // If no pricebook entry is found, return a 404 response
        if (pricebookEntry == null) {
            res.statusCode = 404;
            return '{"status": "PricebookEntry not found", "contactInfo": null}';
        }

        // Create the response object
        ContactResponse response = new ContactResponse('Success', new ContactInfo(contactRecord, pricebookEntry));

        // Return the JSON-serialized response
        return JSON.serialize(response);
    }
    
    // Inner class to represent the API response
    public class ContactResponse {
        public String status;
        public ContactInfo contactInfo;

        public ContactResponse(String status, ContactInfo contactInfo) {
            this.status = status;
            this.contactInfo = contactInfo;
        }
    }

    // Inner class to represent the contact information
    public class ContactInfo {
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
        public String productName;
        public String homeCountry;
        public String costPerMonth;
        public String atmFee;
        public String replacementCost;

        public ContactInfo(Contact contact, PricebookEntry pricebookEntry) {
            this.firstName = contact.FirstName;
            this.lastName = contact.LastName;
            this.email = contact.Email;
            this.phone = contact.Phone;
            this.productName = pricebookEntry.Product2.Name;
            this.homeCountry = contact.Home_Country__c;
            this.costPerMonth = pricebookEntry.Cost_Per_Calendar_Month__c;
            this.atmFee = pricebookEntry.ATM_Fee_in_Other_Currencies__c;
            this.replacementCost = pricebookEntry.Card_Replacement_Cost__c;
        }
    }
}