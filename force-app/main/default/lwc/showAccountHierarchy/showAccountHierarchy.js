import { LightningElement, api, track, wire } from 'lwc';
import mainAccount from '@salesforce/apex/AH_AccountHierarchyHeper.getMainAccount';
import getAccount from '@salesforce/apex/AH_AccountHierarchyHeper.getAccountDetails';
import getUltimateParent from '@salesforce/apex/AH_AccountHierarchyHeper.getUltimateParent';

export default class ShowAccountHierarchy extends LightningElement {

    @api recordId;
    @track mainRecordId;
    @track currentRecordId;
    @track ultimateParentId;

    @track generatedHtml = "";
    @track testAccountName = '';

    @track displayAccount = true;

    @track mainAccount = {};
    @track ultimateParent = {};
    @track displayedAccount = {};

    renderedCallback() {

        // create Styles
        var flexContainer = 'width:100%; display:flex;flex-direction:row;align-items:flex-start;justify-content:flex-start;';
        var container = 'width:100%; display:grid;grid-template-columns:20px 1fr;';
        var mainAccount = 'width: 300px;height: 50px;border-radius: 10px;background: rgb(90, 90, 90);border: 2px solid rgb(210, 210, 210);cursor: pointer;display: flex;flex-direction: column;justify-content: center;align-items: center;padding: 5px;text-align: center;font-size: small;color: white;text-decoration: none;';

        this.testAccountName = 'Test Account Name';

        let html = '';
        html += '<a href="/0013N00000irlFRQAY" data-id="0013N00000irlFRQAY" data-title="School Group" onmouseover={mouseOver} onmouseout={mouseOut}>';
        html += '<div Style="' + mainAccount + '"><div>' + this.testAccountName + '</div></div>';
        html += '</a>';
        this.generatedHtml = html;

        // pass generated HTML to Web HTML document.
        this.template.querySelector('.procedurallyGeneratedHtml').innerHTML = this.generatedHtml; 
    }

    @wire(getUltimateParent, { "accountId": '$recordId' })
    wiredGetUltimateParent({ error, data }) {

        this.mainRecordId = this.recordId;
        this.currentRecordId = this.recordId;
        console.log('AccountId ==> ' + this.mainRecordId);

        if (data) {
            // #################### SET ULTIMATE PARENT ACCOUNT ####################
            console.log('Ultimate Parent Account ==>' + data.Name);
            console.log('data.PurchasingGroup__c ==> ' + data.PurchasingGroup__c);
            this.ultimateParentId = data.parentId;

            let acc = {};
            acc.Name = data.Name;
            acc.Id = data.Id;
            acc.Link = `/${data.Id}`
            if (data.PurchasingGroup__c != null) {
                acc.HasPG = true;
                acc.PgId = data.PurchasingGroup__c;
            } else {
                acc.HasPG = false;
            }

            if (data.DefaultShipTo__c != null) {
                acc.HasShip = true;
                acc.ShippId = data.DefaultShipTo__c;
            } else {
                acc.HasShip = false;
            }

            if (data.DefaultBillto__c != null) {
                acc.HasBill = true;
                acc.BillId = data.DefaultBillto__c;
            } else {
                acc.HasBill = false;
            }

            this.ultimateParent = acc;
            // #################### / SET ULTIMATE PARENT ACCOUNT ####################
            

        } else if ( error ) {
            console.log('ERROR: ' + error);
        } else {
            console.log('We did not receive Data');
        }
    }

    mouseOver(event) {
        console.log('mouseOverEvent ==> ' + event.currentTarget.dataset.id);

        this.displayedAccountTitle = event.currentTarget.dataset.title;
        this.displayAccount = true;

        getAccount({ "accountId": event.currentTarget.dataset.id })
        .then(result => {
            this.displayedAccount = {};
            let acc = {};
            acc.Name = result.Name;
            acc.Phone = result.Phone;
            acc.Email = result.Email__c;
            acc.BillingStreet = result.BillingStreet;
            acc.BillingPostalCode = result.BillingPostalCode;
            acc.BillingCity = result.BillingCity;
            acc.BillingCountry = result.BillingCountry;
            acc.ShippingStreet = result.ShippingStreet;
            acc.ShippingPostalCode = result.ShippingPostalCode;
            acc.ShippingCity = result.ShippingCity;
            acc.ShippingCountry = result.ShippingCountry;
            acc.Link = `/${result.Id}`;

            this.displayedAccount = acc;
        })
        .catch(error => {
            console.log('ERROR: ' + error);
        })
    }

    mouseOut() {
        this.displayedAccount = {};
        this.displayedAccountTitle = '';
        this.displayAccount = false;
    }

}