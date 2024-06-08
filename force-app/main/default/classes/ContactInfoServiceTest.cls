@isTest
private class ContactInfoServiceTest {
    @testSetup
    static void setup() {
        // Create a Product2 record
        Product2 product = new Product2(
            Name = 'Standard'
        );
        insert product;

        // Ensure the standard pricebook exists and get its Id
        Id standardPricebookId = Test.getStandardPricebookId();

        // Create a standard PricebookEntry for the product
        PricebookEntry standardPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = 0,
            IsActive = true
        );
        insert standardPricebookEntry;

        // Create a custom Pricebook
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Standard Pricebook',
            IsActive = true,
            Country__c = 'DE'
        );
        insert customPricebook;

        // Create a custom PricebookEntry for the product
        PricebookEntry customPricebookEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = product.Id,
            UnitPrice = 0,
            IsActive = true,
            Cost_Per_Calendar_Month__c = '0',
            ATM_Fee_in_Other_Currencies__c = '1.7%',
            Card_Replacement_Cost__c = '6'
        );
        insert customPricebookEntry;

        // Create a Contact record and associate it with the product
        Contact contact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            Phone = '1234567890',
            Product__c = product.Id,
            Home_Country__c = 'DE',
            UUID__c = '1234'
        );
        insert contact;
    }

    @isTest
    static void testGetContactProductDetails() {
        // Set up a mock REST request and response
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ContactInfo/1234';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Call the REST service
        String jsonResponse = ContactInfoService.doGet();

        // Parse the JSON response
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);

        // Verify the response
        System.assertEquals('Success', responseMap.get('status'));
        Map<String, Object> contactInfo = (Map<String, Object>) responseMap.get('contactInfo');
        System.assertEquals('John', contactInfo.get('firstName'));
        System.assertEquals('Doe', contactInfo.get('lastName'));
        System.assertEquals('john.doe@example.com', contactInfo.get('email'));
        System.assertEquals('1234567890', contactInfo.get('phone'));
        System.assertEquals('Standard', contactInfo.get('productName'));
        System.assertEquals('DE', contactInfo.get('homeCountry'));
        System.assertEquals('0', contactInfo.get('costPerMonth'));
        System.assertEquals('1.7%', contactInfo.get('atmFee'));
        System.assertEquals('6', contactInfo.get('replacementCost'));
    }

    @isTest
    static void testGetContactProductDetailsNoContact() {
        // Set up a mock REST request and response with a non-existent UUID
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ContactInfo/0000';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Call the REST service
        String jsonResponse = ContactInfoService.doGet();

        // Parse the JSON response
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);

        // Verify the response
        System.assertEquals('Contact not found', responseMap.get('status'));
        System.assertEquals(null, responseMap.get('contactInfo'));
    }
}