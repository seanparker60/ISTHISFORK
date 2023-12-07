import { LightningElement, track, wire } from 'lwc';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import TYPE_FIELD from '@salesforce/schema/Product2.Type__c';

import getFirstReleasePartners from '@salesforce/apex/FRM_firstReleaseManagementHelper.getFirstReleasePartners';
import createFirstReleasePartner from '@salesforce/apex/FRM_firstReleaseManagementHelper.createFirstReleasePartner';
import changeFirstReleasePartnerQuantity from '@salesforce/apex/FRM_firstReleaseManagementHelper.changeFirstReleasePartnerQuantity';
import changeFirstReleasePartnerProductQuantity from '@salesforce/apex/FRM_firstReleaseManagementHelper.changeFirstReleasePartnerProductQuantity';
import deleteFirstReleasePartner from '@salesforce/apex/FRM_firstReleaseManagementHelper.deleteFirstReleasePartner';
import deleteFirstReleasePartnerProduct from '@salesforce/apex/FRM_firstReleaseManagementHelper.deleteFirstReleasePartnerProduct';
import createFirstReleasePartnerProduct from '@salesforce/apex/FRM_firstReleaseManagementHelper.addFirstReleasePartnerProduct';

export default class FirstReleaseManagement extends LightningElement {

    @track accounts = [];
    @track fullDataList = [];
    @track showPopup = false;
    @track showFrppPopup = false;
    
    @track productId;
    @track accountId;
    @track quantityValue;
    @track productQuantityValue;
    @track firstReleasePartnerId;
    @track firstReleasePartnerProductId;

    @track typeValue;
    @track typePreview = '';

    @track typePicklist = [];

    @wire(getPicklistValues,
        {
            recordTypeId: '012000000000000AAA',
            fieldApiName: TYPE_FIELD
        })
        wiredPicklistValues ({ error, data }) {
            if (data) {
                let x = [];

                x.push({ label: 'Show all', value: 'Show all' });

                data.values.forEach(element => {
                    x.push({ label: element.label, value: element.label })
                })
                this.typePicklist = x;
            }
        }

    @wire(getFirstReleasePartners, {})
    wiredGetFirstReleasePartners({ error, data }) {

        if (data) {
            let x = [];

            data.forEach(element => {
                let elt = {};
                elt.Id = element.Id;
                if (element.Account__c) {
                    elt.Url = `/${element.Account__c}`;
                    elt.AccountName = element.Account__r.Name;
                } else {
                    elt.Url = '';
                    elt.AccountName = '-';
                }
                if (element.Quantity__c) {
                    elt.Quantity = element.Quantity__c;
                } else {
                    elt.Quantity = '';
                }
                if (element.FirstReleasePartnerProducts__r) {
                    let frppTmpLst = [];
                    element.FirstReleasePartnerProducts__r.forEach(product => {
                        let frpp = {};
                        frpp.Id = product.Id;
                        frpp.Name = product.Product__r.Name;
                        frpp.Url = `/${product.Product__c}`;
                        frpp.Quantity = product.Quantity__c;
                        frppTmpLst.push(frpp);
                    })
                    elt.frppList = frppTmpLst;
                } else {
                    elt.frppList = [];
                }
                x.push(elt);
            })
            this.fullDataList = x;
            this.accounts = x;
        }
    }

    get accountsForTable() {
        return this.accounts;
    }

    get typeOptions() {
        return this.typePicklist;
    }

    handleValueSelcted(event) {
        this.accountId = event.detail;
    }

    handleFrppValueSelcted(event) {
        this.productId = event.detail;
        console.log('this.productId ==> ' + this.productId);
    }

    handleQuantityChange(event) {
        this.quantityValue = event.detail.value;
        console.log('this.quantityValue ==> ' + this.quantityValue);
    }

    handleFrppQuantityChange(event) {
        this.productQuantityValue = event.detail.value;
        console.log('this.quantityValue ==> ' + this.quantityValue);
    }

    openPopup(event) {
        this.quantityValue = 1;
        this.showPopup = true;
    }

    openFrppPopup(event) {
        this.showFrppPopup = true;
        this.firstReleasePartnerId = event.currentTarget.dataset.id;
        this.productQuantityValue = event.currentTarget.dataset.quantity;
    }

    hidePopup() {
        this.showPopup = false;
    }

    hideFrppPopup() {
        this.showFrppPopup = false;
    }

    handleSave() {

        createFirstReleasePartner({
            accountId: this.accountId.toString(),
            quantity: this.quantityValue
        })
        .then(result => {
            if (result) {
                let x = [];

                result.forEach(element => {
                    let elt = {};
                elt.Id = element.Id;
                if (element.Account__c) {
                    elt.Url = `/${element.Account__c}`;
                    elt.AccountName = element.Account__r.Name;
                } else {
                    elt.Url = '';
                    elt.AccountName = '-';
                }
                if (element.Quantity__c) {
                    elt.Quantity = element.Quantity__c;
                } else {
                    elt.Quantity = '';
                }
                if (element.FirstReleasePartnerProducts__r) {
                    let frppTmpLst = [];
                    element.FirstReleasePartnerProducts__r.forEach(product => {
                        let frpp = {};
                        frpp.Id = product.Id;
                        frpp.Name = product.Product__r.Name;
                        frpp.Url = `/${product.Product__c}`;
                        frpp.Quantity = product.Quantity__c;
                        frppTmpLst.push(frpp);
                    })
                    elt.frppList = frppTmpLst;
                } else {
                    elt.frppList = [];
                }
                x.push(elt);
                })
                this.fullDataList = x;
                this.accounts = x;
            }
        })
        this.showPopup = false;
    }

    handleFrppSave() {

        createFirstReleasePartnerProduct({
            firstReleasePartnerId: this.firstReleasePartnerId,
            quantity: this.productQuantityValue,
            ProductId: this.productId.toString()
        })
        .then(result => {
            if (result) {
                let x = [];

                result.forEach(element => {
                    let elt = {};
                elt.Id = element.Id;
                if (element.Account__c) {
                    elt.Url = `/${element.Account__c}`;
                    elt.AccountName = element.Account__r.Name;
                } else {
                    elt.Url = '';
                    elt.AccountName = '-';
                }
                if (element.Quantity__c) {
                    elt.Quantity = element.Quantity__c;
                } else {
                    elt.Quantity = '';
                }
                if (element.FirstReleasePartnerProducts__r) {
                    let frppTmpLst = [];
                    element.FirstReleasePartnerProducts__r.forEach(product => {
                        let frpp = {};
                        frpp.Id = product.Id;
                        frpp.Name = product.Product__r.Name;
                        frpp.Url = `/${product.Product__c}`;
                        frpp.Quantity = product.Quantity__c;
                        frppTmpLst.push(frpp);
                    })
                    elt.frppList = frppTmpLst;
                } else {
                    elt.frppList = [];
                }
                x.push(elt);
                })
                this.fullDataList = x;
                this.accounts = x;
            }
        })
        this.showFrppPopup = false;
    }

    // createFilteredList() {
    //     let baseList = [];
    //     baseList = this.fullDataList;
    //     this.products = [];

    //     let x = [];

    //     if (this.typeValue === 'Show all') {
    //         this.products = baseList;
    //     } else {
    //         for (let i = 0; i < this.fullDataList.length; i++) {
    //             let addToList = false;
    
    //             // TYPE FILTER
    //             if (this.typeValue != null) {
    //                 if (this.typeValue === this.fullDataList[i].Type) {
    //                     addToList = true;
    //                 }
    //             }
    
    //             // ADDING TO LIST
    //             if (addToList) {
    //                 x.push(this.fullDataList[i]);
    //             }
    //         }
    //         this.products = x;
    //     }
        
    // }

    changeQuantityMinus(event) {

        if (event.currentTarget.dataset.quantity > 1) {
            this.firstReleasePartnerId = event.currentTarget.dataset.id;
            this.quantityValue = parseInt(event.currentTarget.dataset.quantity) - 1;

            changeFirstReleasePartnerQuantity({
                "firstReleasePartnerId": this.firstReleasePartnerId,
                "quantity": this.quantityValue
            })
            .then(result => {
                if (result) {
                    let x = [];

                    result.forEach(element => {
                        let elt = {};
                    elt.Id = element.Id;
                    if (element.Account__c) {
                        elt.Url = `/${element.Account__c}`;
                        elt.AccountName = element.Account__r.Name;
                    } else {
                        elt.Url = '';
                        elt.AccountName = '-';
                    }
                    if (element.Quantity__c) {
                        elt.Quantity = element.Quantity__c;
                    } else {
                        elt.Quantity = '';
                    }
                    if (element.FirstReleasePartnerProducts__r) {
                        let frppTmpLst = [];
                        element.FirstReleasePartnerProducts__r.forEach(product => {
                            let frpp = {};
                            frpp.Id = product.Id;
                            frpp.Name = product.Product__r.Name;
                            frpp.Url = `/${product.Product__c}`;
                            frpp.Quantity = product.Quantity__c;
                            frppTmpLst.push(frpp);
                        })
                        elt.frppList = frppTmpLst;
                    } else {
                        elt.frppList = [];
                    }
                    x.push(elt);
                    })
                    this.fullDataList = x;
                    this.accounts = x;
                }
            })
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Quantity cannot be less than 0. Please remove the First Releasepartner record if it is not needed.',
                    variant: 'error',
                }),
            );
        }
    }

    changeQuantityPlus(event) {

        this.firstReleasePartnerId = event.currentTarget.dataset.id;
        this.quantityValue = parseInt(event.currentTarget.dataset.quantity) + 1;

        changeFirstReleasePartnerQuantity({
            "firstReleasePartnerId": this.firstReleasePartnerId,
            "quantity": this.quantityValue
        })
        .then(result => {
            if (result) {
                let x = [];

                result.forEach(element => {
                    let elt = {};
                elt.Id = element.Id;
                if (element.Account__c) {
                    elt.Url = `/${element.Account__c}`;
                    elt.AccountName = element.Account__r.Name;
                } else {
                    elt.Url = '';
                    elt.AccountName = '-';
                }
                if (element.Quantity__c) {
                    elt.Quantity = element.Quantity__c;
                } else {
                    elt.Quantity = '';
                }
                if (element.FirstReleasePartnerProducts__r) {
                    let frppTmpLst = [];
                    element.FirstReleasePartnerProducts__r.forEach(product => {
                        let frpp = {};
                        frpp.Id = product.Id;
                        frpp.Name = product.Product__r.Name;
                        frpp.Url = `/${product.Product__c}`;
                        frpp.Quantity = product.Quantity__c;
                        frppTmpLst.push(frpp);
                    })
                    elt.frppList = frppTmpLst;
                } else {
                    elt.frppList = [];
                }
                x.push(elt);
                })
                this.fullDataList = x;
                this.accounts = x;
            }
        })
    }

    changeQuantityOnProductMinus(event) {

        if (event.currentTarget.dataset.quantity > 1) {
            this.firstReleasePartnerProductId = event.currentTarget.dataset.id;
            this.quantityValue = parseInt(event.currentTarget.dataset.quantity) - 1;

            changeFirstReleasePartnerProductQuantity({
                "firstReleasePartnerProductId": this.firstReleasePartnerProductId,
                "quantity": this.quantityValue
            })
            .then(result => {
                if (result) {
                    let x = [];

                    result.forEach(element => {
                        let elt = {};
                    elt.Id = element.Id;
                    if (element.Account__c) {
                        elt.Url = `/${element.Account__c}`;
                        elt.AccountName = element.Account__r.Name;
                    } else {
                        elt.Url = '';
                        elt.AccountName = '-';
                    }
                    if (element.Quantity__c) {
                        elt.Quantity = element.Quantity__c;
                    } else {
                        elt.Quantity = '';
                    }
                    if (element.FirstReleasePartnerProducts__r) {
                        let frppTmpLst = [];
                        element.FirstReleasePartnerProducts__r.forEach(product => {
                            let frpp = {};
                            frpp.Id = product.Id;
                            frpp.Name = product.Product__r.Name;
                            frpp.Url = `/${product.Product__c}`;
                            frpp.Quantity = product.Quantity__c;
                            frppTmpLst.push(frpp);
                        })
                        elt.frppList = frppTmpLst;
                    } else {
                        elt.frppList = [];
                    }
                    x.push(elt);
                    })
                    this.fullDataList = x;
                    this.accounts = x;
                }
            })
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Quantity cannot be less than 0. Please remove the First Releasepartner Product record if it is not needed.',
                    variant: 'error',
                }),
            );
        }
    }

    changeQuantityOnProductPlus(event) {

        this.firstReleasePartnerProductId = event.currentTarget.dataset.id;
        this.quantityValue = parseInt(event.currentTarget.dataset.quantity) + 1;

        changeFirstReleasePartnerProductQuantity({
            "firstReleasePartnerProductId": this.firstReleasePartnerProductId,
            "quantity": this.quantityValue
        })
        .then(result => {
            if (result) {
                let x = [];

                result.forEach(element => {
                    let elt = {};
                elt.Id = element.Id;
                if (element.Account__c) {
                    elt.Url = `/${element.Account__c}`;
                    elt.AccountName = element.Account__r.Name;
                } else {
                    elt.Url = '';
                    elt.AccountName = '-';
                }
                if (element.Quantity__c) {
                    elt.Quantity = element.Quantity__c;
                } else {
                    elt.Quantity = '';
                }
                if (element.FirstReleasePartnerProducts__r) {
                    let frppTmpLst = [];
                    element.FirstReleasePartnerProducts__r.forEach(product => {
                        let frpp = {};
                        frpp.Id = product.Id;
                        frpp.Name = product.Product__r.Name;
                        frpp.Url = `/${product.Product__c}`;
                        frpp.Quantity = product.Quantity__c;
                        frppTmpLst.push(frpp);
                    })
                    elt.frppList = frppTmpLst;
                } else {
                    elt.frppList = [];
                }
                x.push(elt);
                })
                this.fullDataList = x;
                this.accounts = x;
            }
        })
    }

    handleDeleteFRP(event) {
        this.firstReleasePartnerId = event.currentTarget.dataset.id;
        console.log('this.firstReleasePartnerId ==> ' + this.firstReleasePartnerId);

        deleteFirstReleasePartner({
            "firstReleasePartnerId": this.firstReleasePartnerId
        })
        .then(result => {
            if (result) {
                let x = [];

                result.forEach(element => {
                    let elt = {};
                elt.Id = element.Id;
                if (element.Account__c) {
                    elt.Url = `/${element.Account__c}`;
                    elt.AccountName = element.Account__r.Name;
                } else {
                    elt.Url = '';
                    elt.AccountName = '-';
                }
                if (element.Quantity__c) {
                    elt.Quantity = element.Quantity__c;
                } else {
                    elt.Quantity = '';
                }
                if (element.FirstReleasePartnerProducts__r) {
                    let frppTmpLst = [];
                    element.FirstReleasePartnerProducts__r.forEach(product => {
                        let frpp = {};
                        frpp.Id = product.Id;
                        frpp.Name = product.Product__r.Name;
                        frpp.Url = `/${product.Product__c}`;
                        frpp.Quantity = product.Quantity__c;
                        frppTmpLst.push(frpp);
                    })
                    elt.frppList = frppTmpLst;
                } else {
                    elt.frppList = [];
                }
                x.push(elt);
                })
                this.fullDataList = x;
                this.accounts = x;
            }
        })
    }

    handleDeleteFRPP(event) {
        this.firstReleasePartnerProductId = event.currentTarget.dataset.id;
        console.log('Deleting First Releasepartner Product with Id: ' + this.firstReleasePartnerProductId);

        deleteFirstReleasePartnerProduct({
            "firstReleasePartnerProductId": this.firstReleasePartnerProductId
        })
        .then(result => {
            if (result) {
                let x = [];

                result.forEach(element => {
                    let elt = {};
                elt.Id = element.Id;
                if (element.Account__c) {
                    elt.Url = `/${element.Account__c}`;
                    elt.AccountName = element.Account__r.Name;
                } else {
                    elt.Url = '';
                    elt.AccountName = '-';
                }
                if (element.Quantity__c) {
                    elt.Quantity = element.Quantity__c;
                } else {
                    elt.Quantity = '';
                }
                if (element.FirstReleasePartnerProducts__r) {
                    let frppTmpLst = [];
                    element.FirstReleasePartnerProducts__r.forEach(product => {
                        let frpp = {};
                        frpp.Id = product.Id;
                        frpp.Name = product.Product__r.Name;
                        frpp.Url = `/${product.Product__c}`;
                        frpp.Quantity = product.Quantity__c;
                        frppTmpLst.push(frpp);
                    })
                    elt.frppList = frppTmpLst;
                } else {
                    elt.frppList = [];
                }
                x.push(elt);
                })
                this.fullDataList = x;
                this.accounts = x;
            }
        })
    }

}