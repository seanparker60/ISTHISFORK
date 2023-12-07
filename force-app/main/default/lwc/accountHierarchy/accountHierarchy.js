import { LightningElement, api, track, wire } from 'lwc';
import mainAccount from '@salesforce/apex/AH_AccountHierarchyHeper.getMainAccount';
import getLocations from '@salesforce/apex/AH_AccountHierarchyHeper.getLocations';
import PurchasingGroupChk from '@salesforce/apex/AH_AccountHierarchyHeper.purchasingGroupCheck';
import getSchoolsFromSchoolGroup from '@salesforce/apex/AH_AccountHierarchyHeper.getSchoolsFromSchoolGroupId';
import getSchoolsAndLocationsForSchoolGroup from '@salesforce/apex/AH_AccountHierarchyHeper.getSchoolsAndLocationsFromSchoolGroupId';
import getAccount from '@salesforce/apex/AH_AccountHierarchyHeper.getAccountDetails';

export default class AccountHierarchy extends LightningElement {

    @api recordId;
    @track currentRecordId;

    @track mainAccountName;
    @track mainAccountId;
    @track mainAccountLink;
    @track mainAccountHasPG = false;
    @track mainAccountPgId;
    @track mainAccountHasBill = false;
    @track mainAccountBillId;
    @track mainAccountHasShip = false;
    @track mainAccountShippId;

    @track mainAccount = {};

    @track schoolGroups = [];
    @track schools = [];
    @track locations = [];

    @track weHaveLocations = false;
    @track isPurchasingGroup = false;
    @track isSchoolgroup = false;
    @track schoolGroupsFound = false;
    @track isSchool = false;
    @track isLocation = false;

    @track displayedAccount = {};
    @track displayedAccountTitle;
    @track displayAccount = false;
    @track accName;
    @track accEmail;
    @track accPhone;
    @track accBillingStreet;
    @track accBillingPostalCode;
    @track accBillingCity;
    @track accBillingCountry;
    @track accShippingStreet;
    @track accShippingPostalCode;
    @track accShippingCity;
    @track accShippingCountry;

    @wire(mainAccount, { "accountId": '$recordId' })
    wiredMainAccount({ error, data }) {

        this.currentRecordId = this.recordId;
        console.log('AccountId ==> ' + this.currentRecordId);

        if (data) {
            let x = [];
            console.log('Main Account ==>' + data.Name);
            console.log('data.PurchasingGroup__c ==> ' + data.PurchasingGroup__c);
            this.mainAccountName = data.Name;
            this.mainAccountId = data.Id;
            this.mainAccountLink = `/${data.Id}`
            if (data.PurchasingGroup__c != null) {
                this.mainAccountHasPG = true;
                this.mainAccountPgId = data.PurchasingGroup__c;
            }
            if (data.DefaultShipTo__c != null) {
                this.mainAccountHasShip = true;
                this.mainAccountShippId = data.DefaultShipTo__c;
            }
            if (data.DefaultBillto__c != null) {
                this.mainAccountHasBill = true;
                this.mainAccountBillId = data.DefaultBillto__c;
            }
            
            if (data.SchoolType__c == 'Location') {
                this.isLocation = true;
                console.log('Main Account is a Location');
            } else if (data.ParentId != null) {
                this.isSchool = true;
                console.log('Main Account is a School');
            } else {
                PurchasingGroupChk({ "accountId": this.currentRecordId})
                .then(result => {
                    this.isPurchasingGroup = result;
                })
                .catch(error => {
                    console.log('Error: ' + error);
                })
                if (!this.isPurchasingGroup) {
                    this.isSchoolgroup = true;
                    console.log('Main Account is a SchoolGroup');
                } else {
                    console.log('Main Account is a Purchasing Group');
                }
            }

            if (this.isSchoolgroup) {
                this.handleSchoolGroup();
            } else if (this.isSchool) {
                this.handleSchool();
            } else if (this.isLocation) {
                this.handleLocation();
            } else if (this.isPurchasingGroup) {
                this.handlePurchasingGroup();
            } else {
                console.log('ERROR: We would not see what kind of account this is');
            }

        } else if ( error ) {
            console.log('ERROR: ' + error);
        } else {
            console.log('We did not receive Data');
        }
    }

    handleSchoolGroup() {
        console.log('==> handleSchoolGroup');

        let mainAccount = {};
        mainAccount.Name = this.mainAccountName;
        mainAccount.Id = this.mainAccountId;
        mainAccount.Link = `/${this.mainAccountId}`;
        mainAccount.Class = 'mainAccount';
        mainAccount.hasPG = this.mainAccountHasPG;
        mainAccount.hasBill = this.mainAccountHasBill;
        mainAccount.hasShip = this.mainAccountHasShip;
        if (this.mainAccountHasPG) {
            mainAccount.pgLink = `/${this.mainAccountPgId}`;
            mainAccount.pgId = this.mainAccountPgId;
        }
        if (this.mainAccountHasBill) {
            mainAccount.BillLink = `/${this.mainAccountBillId}`;
            mainAccount.BillId = this.mainAccountBillId;
        }
        if (this.mainAccountHasShip) {
            mainAccount.ShipLink = `/${this.mainAccountShippId}`;
            mainAccount.ShipId = this.mainAccountShippId;
        }

        let sg = [];
        sg.push(mainAccount);

        this.schoolGroups = [];
        this.schoolGroups = sg;
        this.schoolGroupsFound = true;

        getSchoolsAndLocationsForSchoolGroup({ "accountId": this.currentRecordId })
        .then(result => {
            console.log('result ==> ' + JSON.stringify(result));
            let schoolSet = [];
            schoolSet = result;
            let schoolSet2 = [];
            schoolSet2 = Reflect.ownKeys(result);

            console.log('schoolSet2.length ==> ' + schoolSet2.length);
            console.log('schoolSet2 ==> ' + JSON.stringify(schoolSet2));

            console.log('Reflect.ownKeys(schoolSet).length ==> ' + Reflect.ownKeys(schoolSet).length);

            if (Reflect.ownKeys(schoolSet).length > 0) {
                let x = [];
                let schoolCounter = 1;

                for (var key in schoolSet) {
                    console.log('key ==> ' + key);
                    console.log('Name ==> ' + schoolSet[key].record.Name);

                    let sch = {};
                    sch.Name = schoolSet[key].record.Name;
                    sch.Id = schoolSet[key].record.Id;
                    sch.Link = `/${schoolSet[key].record.Id}`;
                    sch.Class = "SubAccounts";
                    
                    console.log('schoolSet[key].record.PurchasingGroup__c ==> ' + schoolSet[key].record.PurchasingGroup__c);
                    console.log('schoolSet[key].record.DefaultBillto__c ==> ' + schoolSet[key].record.DefaultBillto__c);
                    console.log('schoolSet[key].record.DefaultShipTo__c ==> ' + schoolSet[key].record.DefaultShipTo__c);
                    
                    if (schoolSet[key].record.PurchasingGroup__c != null) {
                        sch.pgLink = `/${schoolSet[key].record.PurchasingGroup__c}`;
                        sch.pgId = schoolSet[key].record.PurchasingGroup__c;
                        sch.hasPG = true;
                    } else {
                        sch.hasPG = false;
                    }

                    if (schoolSet[key].record.DefaultBillto__c != null) {
                        sch.BillLink = `/${schoolSet[key].record.DefaultBillto__c}`;
                        sch.BillId = schoolSet[key].record.DefaultBillto__c;
                        sch.hasBill = true;
                    } else {
                        sch.hasBill = false;
                    }

                    if (schoolSet[key].record.DefaultShipTo__c != null) {
                        sch.ShipLink = `/${schoolSet[key].record.DefaultShipTo__c}`;
                        sch.ShipId = schoolSet[key].record.DefaultShipTo__c;
                        sch.hasShip = true;
                    } else {
                        sch.hasShip = false;
                    }

                    if (schoolCounter === 1) {
                        sch.start = true;
                        sch.middle = false;
                        sch.stop = false;
                    } else if (schoolCounter === Reflect.ownKeys(schoolSet).length) {
                        sch.start = false;
                        sch.middle = false;
                        sch.stop = true;
                    } else {
                        sch.start = false;
                        sch.middle = true;
                        sch.stop = false;
                    }
                    schoolCounter ++;
                    //HANDLE LOCATIONS
                    let locationSet = [];
                    locationSet = schoolSet[key].AccountList;

                    if (locationSet.length > 0) {
                        let y = [];
                        let locationCounter = 1;

                        locationSet.forEach(element => {
                            console.log('Name ==> ' + element.Name);

                            let loc = {};
                            loc.Name = element.Name;
                            loc.Id = element.Id;
                            loc.Link = `/${element.Id}`;
                            loc.Class = "SubAccounts";

                            if (element.PurchasingGroup__c != null) {
                                loc.pgId = element.PurchasingGroup__c;
                                loc.pgLink = `/${element.PurchasingGroup__c}`
                                loc.hasPG = true;
                            } else {
                                loc.hasPG = false;
                            }
                            if (element.DefaultBillto__c != null) {
                                loc.BillId = element.DefaultBillto__c;
                                loc.BillLink = `/${element.DefaultBillto__c}`;
                                loc.hasBill = true;
                            } else {
                                loc.hasBill = false;
                            }
                            if (element.DefaultShipTo__c != null) {
                                loc.ShipId = element.DefaultShipTo__c;
                                loc.ShipLink = `/${element.DefaultShipTo__c}`;
                                loc.hasShip = true;
                            } else {
                                loc.hasShip = false;
                            }

                            if (locationCounter === 1) {
                                loc.start = true;
                                loc.middle = false;
                                loc.stop = false;
                            } else if (locationCounter === locationSet.length) {
                                loc.start = false;
                                loc.middle = false;
                                loc.stop = true;
                            } else {
                                loc.start = false;
                                loc.middle = true;
                                loc.stop = false;
                            }
                            locationCounter ++;
                            y.push(loc);
                        })
                        sch.Locations = y;
                    } else {
                        console.log('We have found no Locations belonging to any of these Schools.');
                    }
                    x.push(sch);
                }
                this.schools = x;
            } else {
                console.log('We have found no Schools belonging to this School Group.');
            }
        })
        .catch(error => {
            console.log('ERROR: ' + error);
        })

    }

    handleSchool() {
        console.log('==> handleSchool');
    }

    handleLocation() {
        console.log('==> handleLocation');
    }

    handlePurchasingGroup() {
        console.log('==> handlePurchasingGroup');
    }

    handleExtraAccountSelect(event) {
        console.log('clickEvent ==> ' + event.currentTarget.dataset.id);

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

    handleMouseOut() {
        this.displayedAccount = {};
        this.displayedAccountTitle = '';
        this.displayAccount = false;
    }

}