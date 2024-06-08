@isTest
public class CaseContactProductControllerTest {
    @testSetup
    static void setupTestData() {
        // Create a Product2 record
        Product2 product = new Product2(
            Name = 'Standard',
            Cost_Per_Calendar_Month__c = '0',
            ATM_Fee_Other_Currencies__c = '1.7%',
            Card_Replacement_Cost__c = '6',
            Country__c = 'DE'
        );
        insert product;

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
        Map<String, Object> result = CaseContactProductController.getContactProductDetails(testCase.Id);
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.get('product'), 'Product should not be null');
        System.assertEquals('DE', result.get('homeCountry'), 'Home country should be DE');
        
        Product2 product = (Product2) result.get('product');
        System.assertEquals('Standard', product.Name, 'Product name should be Standard');
        System.assertEquals('0', product.Cost_Per_Calendar_Month__c, 'Cost per calendar month should be 0');
        System.assertEquals('1.7%', product.ATM_Fee_Other_Currencies__c, 'ATM fee in other currencies should be 1.7%');
        System.assertEquals('6', product.Card_Replacement_Cost__c, 'Card replacement cost should be 6');
        System.assertEquals('DE', product.Country__c, 'Country should be DE');
    }

    @isTest
    static void testGetContactProductDetailsNoContact() {
        // Create a Case record with no associated contact
        Case testCase = new Case(Subject = 'Test Case No Contact');
        insert testCase;
        
        Test.startTest();
        Map<String, Object> result = CaseContactProductController.getContactProductDetails(testCase.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(null, result, 'Result should be null when there is no contact');
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
        Map<String, Object> result = CaseContactProductController.getContactProductDetails(testCase.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(null, result, 'Result should be null when there is no product');
    }
}