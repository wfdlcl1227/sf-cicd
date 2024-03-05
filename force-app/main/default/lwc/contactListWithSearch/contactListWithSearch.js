import { LightningElement } from 'lwc';
import findContacts from '@salesforce/apex/ContactController.findContacts';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 350;

export default class CompositionContactSearch extends LightningElement {
    contacts;
    error;
    selectedID;
    searchmode=true;
    newmode=false;
    detailmode=false;

    handleKeyChange(event) {
        // Debouncing this method: Do not actually invoke the Apex call as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            findContacts({ searchKey })
                .then((result) => {
                    this.contacts = result;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.contacts = undefined;
                });
        }, DELAY);
    }

    handleNew(event) {
        this.detailmode=false;
        this.newmode=true;
        this.searchmode=false;
    }

    handleselect(event) {
        this.detailmode=true;
        this.newmode=false;
        this.searchmode=false;
        this.selectedID = '0032x000002yyTjAAI';

    }

    handleCancel(event) {
        this.detailmode=false;
        this.newmode=false;
        this.searchmode=true;

    }
}