import { LightningElement, api, wire, track } from 'lwc';
import getContactProductDetails from '@salesforce/apex/CaseContactProductController.getContactProductDetails';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class CaseContactProduct extends LightningElement {
    @api recordId; // This is the Case Id
    @track productDetails; // Holds the product details to be displayed
    homeCountry; // Stores the home country of the contact
    productId; // Stores the current product Id for editing

    // Defines the columns for the Lightning Data Table
    columns = [
        { label: 'Product Name', fieldName: 'productName', type: 'text' },
        { label: 'Home Country', fieldName: 'homeCountry', type: 'text' },
        { label: 'Cost per Calendar Month', fieldName: 'costPerMonth', type: 'text' },
        { label: 'ATM Fee in Other Currencies', fieldName: 'atmFee', type: 'text' },
        { label: 'Card Replacement Cost', fieldName: 'replacementCost', type: 'text' },
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

    // Wire adapter to call the Apex method and fetch product details for the contact associated with the case
    @wire(getContactProductDetails, { caseId: '$recordId' })
    wiredContactProductDetails(result) {
        this.wiredResult = result;
        if (result.data) {
            console.log('Data received from Apex:', JSON.stringify(result.data));
            const productData = JSON.parse(JSON.stringify(result.data));
            console.log('Parsed Product Data:', productData);

            // Populate the product details
            this.productDetails = [
                {
                    id: productData.product.Id,
                    productName: productData.product.Name,
                    homeCountry: productData.homeCountry, // corrected to use homeCountry from productData
                    costPerMonth: productData.product.Cost_Per_Calendar_Month__c,
                    atmFee: productData.product.ATM_Fee_Other_Currencies__c,
                    replacementCost: productData.product.Card_Replacement_Cost__c
                }
            ];

            console.log('Product Details:', this.productDetails);
        } else if (result.error) {
            this.productDetails = undefined;
            this.homeCountry = undefined;
            console.error('Error received from Apex:', result.error);
        }
    }

    // Handles the actions (edit, delete) from the Lightning Data Table
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

    // Opens the modal for editing the product
    editProduct(row) {
        this.productId = row.id;
        this.template.querySelector('c-product-edit-modal').openModal();
    }

    // Deletes the product record and shows a success or error toast message
    deleteProduct(row) {
        deleteRecord(row.id)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Product deleted',
                        variant: 'success'
                    })
                );
                // Remove the deleted product from the list
                this.productDetails = this.productDetails.filter(product => product.id !== row.id);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting product',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    // Handles the refresh action when the product is updated
    handleProductUpdated() {
        // Refresh the product details
        return refreshApex(this.wiredResult);
    }
}