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

        // Query the Product record associated with the contact
        Product2 productRecord = [SELECT Name, Cost_Per_Calendar_Month__c, ATM_Fee_Other_Currencies__c, Card_Replacement_Cost__c, Country__c 
                                  FROM Product2 
                                  WHERE Id = :contactRecord.Product__c 
                                  LIMIT 1];

        // Create the response object
        ContactResponse response = new ContactResponse('Success', new ContactInfo(contactRecord, productRecord));

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

        public ContactInfo(Contact contact, Product2 product) {
            this.firstName = contact.FirstName;
            this.lastName = contact.LastName;
            this.email = contact.Email;
            this.phone = contact.Phone;
            this.productName = product.Name;
            this.homeCountry = contact.Home_Country__c;
            this.costPerMonth = product.Cost_Per_Calendar_Month__c;
            this.atmFee = product.ATM_Fee_Other_Currencies__c;
            this.replacementCost = product.Card_Replacement_Cost__c;
        }
    }
}