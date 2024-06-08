@isTest
public class CaseContactProductControllerTest {
    @testSetup
    static void setupTestData() {
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
            FirstName = 'Test',
            LastName = 'User',
            Product__c = product.Id,
            Home_Country__c = 'DE'
        );
        insert contact;

        // Create a Case record and associate it with the contact
        Case caseRecord = new Case(
            ContactId = contact.Id,
            Subject = 'Test Case'
        );
        insert caseRecord;
    }

    @isTest
    static void testGetContactProductDetails() {
        // Retrieve the Case record created in the test setup
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        List<PricebookEntry> result = CaseContactProductController.getContactProductDetails(testCase.Id);
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'There should be one PricebookEntry');

        PricebookEntry pricebookEntry = result[0];
        System.assertEquals('Standard', pricebookEntry.Product2.Name, 'Product name should be Standard');
        System.assertEquals('0', pricebookEntry.Cost_Per_Calendar_Month__c, 'Cost per calendar month should be 0');
        System.assertEquals('1.7%', pricebookEntry.ATM_Fee_in_Other_Currencies__c, 'ATM fee in other currencies should be 1.7%');
        System.assertEquals('6', pricebookEntry.Card_Replacement_Cost__c, 'Card replacement cost should be 6');
    }

    @isTest
    static void testGetContactProductDetailsNoContact() {
        // Create a Case record with no associated contact
        Case testCase = new Case(Subject = 'Test Case No Contact');
        insert testCase;
        
        Test.startTest();
        List<PricebookEntry> result = CaseContactProductController.getContactProductDetails(testCase.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(0, result.size(), 'Result should be empty when there is no contact');
    }

    @isTest
    static void testGetContactProductDetailsNoProduct() {
        // Create a Contact record with no associated product
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'User No Product',
            Home_Country__c = 'DE'
        );
        insert contact;

        // Create a Case record and associate it with the contact
        Case testCase = new Case(
            ContactId = contact.Id,
            Subject = 'Test Case No Product'
        );
        insert testCase;
        
        Test.startTest();
        List<PricebookEntry> result = CaseContactProductController.getContactProductDetails(testCase.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(0, result.size(), 'Result should be empty when there is no product');
    }
}