import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import getContactList from '@salesforce/apex/AccountController.getContactList';

export default class CompositionIteration extends LightningElement {
    error;
    wiredContactsResult;
    contacts;
    selectedID;

    @wire(getContactList)
    wiredAccounts(result) {
        this.wiredContactsResult = result;
        if (result.data) {
            this.contacts = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.contacts = undefined;
        }
    }    
    
    handleselect(event) {
        this.selectedID = '0032x000002yyTjAAI';
    }
    handleKeyChange(event) {
        //this.selectedID = '0032x000002yyTjAAI';
    }
}