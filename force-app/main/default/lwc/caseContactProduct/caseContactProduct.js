import { LightningElement, api, wire, track } from 'lwc';
import getContactProductDetails from '@salesforce/apex/CaseContactProductController.getContactProductDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

export default class CaseContactProduct extends LightningElement {
    @api recordId; // This is the Case Id
    @track productDetails = []; // Array to hold product details
    productId; // Variable to hold the product Id for editing

    // Columns definition for the datatable
    columns = [
        { label: 'Product Name', fieldName: 'productName', type: 'text' },
        { label: 'Pricebook Name', fieldName: 'pricebookName', type: 'text' },
        { label: 'Cost per Calendar Month', fieldName: 'costPerMonth', type: 'currency' },
        { label: 'ATM Fee in Other Currencies', fieldName: 'atmFee', type: 'text' },
        { label: 'Card Replacement Cost', fieldName: 'replacementCost', type: 'currency' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Edit', name: 'edit' },
                    { label: 'Delete', name: 'delete' }
                ]
            }
        }
    ];

    // Wired method to fetch product details from Apex
    @wire(getContactProductDetails, { caseId: '$recordId' })
    wiredContactProductDetails(result) {
        this.wiredResult = result;
        if (result.data) {
            console.log('Data received from Apex:', JSON.stringify(result.data));
            
            // Map the received data to the productDetails array
            this.productDetails = result.data.map(entry => ({
                id: entry.Id,
                productName: entry.Product2.Name,
                pricebookName: entry.Pricebook2.Name,
                costPerMonth: entry.Cost_Per_Calendar_Month__c,
                atmFee: entry.ATM_Fee_in_Other_Currencies__c,
                replacementCost: entry.Card_Replacement_Cost__c
            }));

            console.log('Product Details:', this.productDetails);
        } else if (result.error) {
            this.productDetails = [];
            console.error('Error received from Apex:', result.error);
        }
    }

    // Handle row actions (edit and delete)
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'edit':
                this.editProduct(row);
                break;
            case 'delete':
                this.deleteProduct(row);
                break;
            default:
                break;
        }
    }

    // Open the edit modal with the selected product
    editProduct(row) {
        this.productId = row.id;
        this.template.querySelector('c-product-edit-modal').openModal();
    }

    // Delete the selected product
    deleteProduct(row) {
        deleteRecord(row.id)
            .then(() => {
                // Show success toast message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Product deleted',
                        variant: 'success'
                    })
                );
                // Remove the deleted product from the productDetails array
                this.productDetails = this.productDetails.filter(product => product.id !== row.id);
            })
            .catch(error => {
                // Show error toast message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting product',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    // Handle product update and refresh the data
    handleProductUpdated() {
        // Refresh the product details
        return refreshApex(this.wiredResult);
    }
}