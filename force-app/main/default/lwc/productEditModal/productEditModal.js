import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProductEditModal extends LightningElement {
    @api productId; // Public property to hold the product ID
    @track isOpen = false; // Track property to manage the modal's open/close state

    // Public method to open the modal
    @api
    openModal() {
        this.isOpen = true;
    }

    // Method to close the modal
    closeModal() {
        this.isOpen = false;
    }

    // Method to handle save action
    handleSave() {
        // Submit the form inside the modal
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    // Method to handle successful form submission
    handleSuccess() {
        // Show a success toast message
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Product updated successfully',
                variant: 'success'
            })
        );
        // Close the modal after successful save
        this.closeModal();
        // Dispatch a custom event to notify the parent component that the product has been updated
        this.dispatchEvent(new CustomEvent('productupdated'));
    }

    // Method to handle form submission error
    handleError(event) {
        // Show an error toast message
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error updating product',
                message: event.detail.message,
                variant: 'error'
            })
        );
    }
}