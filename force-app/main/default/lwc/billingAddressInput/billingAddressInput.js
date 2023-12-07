import { api, LightningElement, track, wire } from 'lwc';
import getAccountAddresses from '@salesforce/apex/ADDR_addressInputHelper.getAddressDetails';
import saveBillingAddress from '@salesforce/apex/ADDR_addressInputHelper.saveBillingAddress';
import saveShippingAddress from '@salesforce/apex/ADDR_addressInputHelper.saveShippingAddress';

export default class BillingAddressInput extends LightningElement {

    @api recordId;

    @track BaSaved = true;
    @track BaEdit = false;
    @track BaError = false;
    @track BaLoading = false;
    @track BaErrorMessage = '';

    @track SaSaved = true;
    @track SaEdit = false;
    @track SaError = false;
    @track SaLoading = false;
    @track SaErrorMessage = '';

    @track billingStreet = "-";
    @track billingPostalCode = "-";
    @track billingCity = "-";
    @track billingProvince = "-";
    @track billingCountry = "-";

    @track shippingStreet = "-";
    @track shippingPostalCode = "-";
    @track shippingCity = "-";
    @track shippingProvince = "-";
    @track shippingCountry = "-";

    @track billingMapMarkers = [];
    @track shippingMapMarkers = [];
    @track mapOptions = {
        disableDefaultUI: true
    }

    @wire(getAccountAddresses, { "accountId": '$recordId' })
    wiredAccountAddresses({ error, data }) {

        if (data) {
            this.billingStreet = data.BillingStreet;
            this.billingPostalCode = data.BillingPostalCode;
            this.billingCity = data.BillingCity;
            this.billingProvince = data.BillingState;
            this.billingCountry = data.BillingCountry;

            this.shippingStreet = data.ShippingStreet;
            this.shippingPostalCode = data.ShippingPostalCode;
            this.shippingCity = data.ShippingCity;
            this.shippingProvince = data.ShippingState;
            this.shippingCountry = data.ShippingCountry;

            this.billingMapMarkers = [];
            this.billingMapMarkers = [...this.billingMapMarkers, {
                location: {
                    Street: this.billingStreet,
                    City: this.billingCity,
                    Country: this.billingCountry
                },
                scale: .2,
                title: 'Billing Address Map'
            }]

            this.shippingMapMarkers = [];
            this.shippingMapMarkers = [...this.shippingMapMarkers, {
                location: {
                    Street: this.shippingStreet,
                    City: this.shippingCity,
                    Country: this.shippingCountry
                },
                scale: .2,
                title: 'Shipping Address Map'
            }]
        }
    }

    billingStreetUpdate(event) {
        this.billingStreet = event.target.street;
        this.billingCity = event.target.city;
        this.billingPostalCode = event.target.postalCode;
        this.billingProvince = event.target.province;
        this.billingCountry = event.target.country;

        this.billingMapMarkers = [];
        this.billingMapMarkers = [...this.billingMapMarkers, {
            location: {
                Street: this.billingStreet,
                City: this.billingCity,
                Country: this.billingCountry
            },
            scale: .2,
            title: 'Billing Address Map'
        }]

        this.BaSaved = false;
        this.BaLoading = false;
        this.BaError = false;
        this.BaEdit = true;

        console.log('Street => ' , event.target.street);
        console.log('City => ' , event.target.city);
        console.log('Province => ' , event.target.province);
        console.log('Country => ' , event.target.country);
        console.log('postal Code => ' , event.target.postalCode);
    }

    shippingStreetUpdate(event) {
        this.shippingStreet = event.target.street;
        this.shippingCity = event.target.city;
        this.shippingPostalCode = event.target.postalCode;
        this.shippingProvince = event.target.province;
        this.shippingCountry = event.target.country;

        this.shippingMapMarkers = [];
        this.shippingMapMarkers = [...this.shippingMapMarkers, {
            location: {
                Street: this.shippingStreet,
                City: this.shippingCity,
                Country: this.shippingCountry
            },
            scale: .2,
            title: 'shipping Address Map'
        }]

        this.SaSaved = false;
        this.SaLoading = false;
        this.SaError = false;
        this.SaEdit = true;

        console.log('Street => ' , event.target.street);
        console.log('City => ' , event.target.city);
        console.log('Province => ' , event.target.province);
        console.log('Country => ' , event.target.country);
        console.log('postal Code => ' , event.target.postalCode);
    }

    saveBAddress() {
        this.BaSaved = false;
        this.BaEdit = false;
        this.BaError = false;
        this.BaLoading = true;

        console.log('saving');
        console.log('hasNumber(this.billingStreet) ==> ' + hasNumber(this.billingStreet));

        if (hasNumber(this.billingStreet)) {
            saveBillingAddress({ 
                accountId: this.recordId,
                billingStreet: this.billingStreet,
                billingPostalCode: this.billingPostalCode,
                billingCity: this.billingCity,
                billingState: this.billingProvince,
                billingCountry: this.billingCountry    
            })
            .then(result => {
                console.log('Result ==> ' + result);
                if (result == 'success') {
                    this.BaSaved = true;
                    this.BaLoading = false;
                    this.BaEdit = false;
                    this.BaError = false;
                } else {
                    this.BaErrorMessage = result;
                    this.BaError = true;
                }
            })
            .catch(error => {
                console.log('Error: ' + error);
                this.BaSaved = false;
                this.BaEdit = false;
                this.BaLoading = false;
                this.BaError = true;
                this.BaErrorMessage = error;
            })
        } else {
            console.log('ERROR: It looks like the Street does not contain a house number');
            this.BaSaved = false;
            this.BaEdit = false;
            this.BaLoading = false;
            this.BaError = true;
            this.BaErrorMessage = 'ERROR: Street does not contain a number';  
        }

        function hasNumber(myString) {
            return /\d/.test(myString);
        }
    }

    saveSAddress() {
        this.SaSaved = false;
        this.SaEdit = false;
        this.SaError = false;
        this.SaLoading = true;

        console.log('saving');
        console.log('hasNumber(this.shippingStreet) ==> ' + hasNumber(this.shippingStreet));

        if (hasNumber(this.shippingStreet)) {
            saveShippingAddress({ 
                accountId: this.recordId,
                shippingStreet: this.shippingStreet,
                shippingPostalCode: this.shippingPostalCode,
                shippingCity: this.shippingCity,
                shippingState: this.shippingProvince,
                shippingCountry: this.shippingCountry
            })
            .then(result => {
                console.log('Result ==> ' + result);
                if (result == 'success') {
                    this.SaSaved = true;
                    this.SaLoading = false;
                    this.SaEdit = false;
                    this.SaError = false;
                } else {
                    this.SaErrorMessage = result;
                    this.SaError = true;
                }
            })
            .catch(error => {
                console.log('Error: ' + error);
                this.SaSaved = false;
                this.SaEdit = false;
                this.SaLoading = false;
                this.SaError = true;
                this.SaErrorMessage = error;
            })
        } else {
            console.log('ERROR: It looks like the Street does not contain a house number');
            this.SaSaved = false;
            this.SaEdit = false;
            this.SaLoading = false;
            this.SaError = true;
            this.SaErrorMessage = 'ERROR: Street does not contain a number';  
        }

        function hasNumber(myString) {
            return /\d/.test(myString);
        }
    }

}