import { LightningElement, wire, track, api } from 'lwc';

export default class ActivateOrdersInBulk extends LightningElement {
    recordsToDisplay = []; //Records to be displayed on the page
    
    connectedCallback() {
        console.log('[MOUNTED]');
    }

    activate(){
        alert('are you sure?');
    }

    cancel(){
        setTimeout(() => {
            window.history.back();
        }, 1000);
    }
}