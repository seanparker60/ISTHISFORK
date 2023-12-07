import { LightningElement, api, wire, track } from 'lwc';
import getAssetListForShipTo from '@salesforce/apex/ASSET_showRenewableAssetsHelper.getAssetListForShipTo';
import getSortedAssetListForShipToJS from '@salesforce/apex/ASSET_showRenewableAssetsHelper.getSortedAssetListForShipTo';
import { pageNumber, pageSize, totalRecords, records } from 'c/paginator';

export default class ShowRenewableAssets extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track columns = [
        {
            label: 'Name',
            fieldName: 'assetUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'AssetName'},
            target: '_self'}
        },
        {
            label: 'Ship-To',
            fieldName: 'shipToUrl',
            type: 'url',
            typeAttributes: 
            {
                label: 
                { 
                    fieldName: 'ShipToName'
                },
                target: '_self'
            }
        },
        {
            label: 'Bill-To',
            fieldName: 'BillToUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'BillToName'},
            target: '_self'}
        },
        {
            label: 'Quantity',
            fieldName: 'Amount',
            type: 'number',
            initialWidth: 80,
            hideDefaultActions: true
        },
        {
            label: 'Renewable Date',
            fieldName: 'RenewalDate',
            type: 'date',
            initialWidth: 100,
            hideDefaultActions: true,
            typeAttributes: {
                day: "2-digit",
                month: "2-digit",
                year: "numeric"
            }
        },
        {
            label: 'Start Date',
            fieldName: 'StartDate',
            type: 'date',
            initialWidth: 100,
            hideDefaultActions: true,
            typeAttributes: {
                day: "2-digit",
                month: "2-digit",
                year: "numeric"
            }
        },
        {
            label: 'End Date',
            fieldName: 'EndDate',
            type: 'date',
            initialWidth: 100,
            hideDefaultActions: true,
            typeAttributes: {
                day: "2-digit",
                month: "2-digit",
                year: "numeric"
            }
        },
        {
            label: 'Cancelation Date',
            fieldName: 'CancelationDate',
            type: 'date',
            initialWidth: 100,
            hideDefaultActions: true,
            typeAttributes: {
                day: "2-digit",
                month: "2-digit",
                year: "numeric"
            }
        }
    ];

    @track showTable = false;
    @track noData = false;
    @track datePicker = false;
    @track error;
    @track assetList = [];
    @track recordsToDisplay = [];
    @track rowNumberOffset;
    @track dateSelection = '';
    @track dateFieldSelectoin = 'RenewalDate__c';
    @track currentRecordId;
    @track selectedDate;
    @track dateValue;

    @track currenObjectName;

    @track filterPopupIsOpen = false;

    @wire(getAssetListForShipTo, { "recordId": '$recordId' })
    wiredShipToAssets({ error, data }) {

        this.currenObjectName = this.objectApiName;
        this.currentRecordId = this.recordId;

        if (data) {
            
            let d = [];
            data.forEach(element => {
                let elt ={};
                elt.Id = element.Id;
                elt.AssetName = element.Name;
                elt.Amount = element.Quantity;
                elt.assetUrl = `/${element.Id}`;
                elt.ShipToName = element.Account.Name;
                elt.shipToUrl = `/${element.AccountId}`;
                elt.BillToName = element.BillToAccount__r.Name;
                elt.BillToUrl = `/${element.BillToAccount__c}`;
                elt.StartDate = element.ActivationDate__c;
                elt.RenewalDate = element.RenewalDate__c;
                elt.CancelationDate = element.CancellationDate__c;
                elt.EndDate = element.UsageEndDate;
                d.push(elt);
            });
            this.assetList = d;

            for (var j=0; j<this.assetList.length; j++) {
                console.log("assetList - Id: " + this.assetList[j].Id);
                console.log("assetList - AssetName: " + this.assetList[j].AssetName);
                console.log("assetList - assetUrl: " + this.assetList[j].assetUrl);
                console.log("assetList - assetUrl: " + this.assetList[j].ShipToName);
                console.log("assetList - assetUrl: " + this.assetList[j].shipToUrl);
                console.log("assetList - Quantity: " + this.assetList[j].Amount);
                console.log("assetList - StartDate: " + this.assetList[j].StartDate);
                console.log("assetList - RenewalDate: " + this.assetList[j].RenewalDate);
                console.log("assetList - CancelationDate: " + this.assetList[j].CancelationDate);
                console.log("assetList - EndDate: " + this.assetList[j].EndDate);
                console.log("---------------------");
            }

            this.showTable = true;
            this.error = null;
            this.noData = false;
            
        } else if (error) {
            this.showTable = false;
            this.error = error;
        }

    }

    handleDateSelection(event) {
        this.dateSelection = event.target.value;
        console.log(this.dateSelection);
        console.log(this.dateFieldSelectoin);

        if (this.dateSelection == "customDate") {
            this.datePicker = true;
        } else {
            this.datePicker = false;

            getSortedAssetListForShipToJS({ 
                "recordId": this.currentRecordId,
                "sorting": this.dateSelection,
                "sortField": this.dateFieldSelectoin,
                "selectedDate": ''
            })
            .then(result => {
                console.log('getting results');
                let dataSet = [];
                dataSet = result;
                console.log(dataSet);
    
                if (dataSet.length > 0) {
                    let x = [];
                    result.forEach(element => {
                        let elt ={};
                        elt.Id = element.Id;
                        elt.AssetName = element.Name;
                        elt.Amount = element.Quantity;
                        elt.assetUrl = `/${element.Id}`;
                        elt.ShipToName = element.Account.Name;
                        elt.shipToUrl = `/${element.AccountId}`;
                        elt.BillToName = element.BillToAccount__r.Name;
                        elt.BillToUrl = `/${element.BillToAccount__c}`;
                        elt.StartDate = element.ActivationDate__c;
                        elt.RenewalDate = element.RenewalDate__c;
                        elt.CancelationDate = element.CancellationDate__c;
                        elt.EndDate = element.UsageEndDate;
                        x.push(elt);
                        });
                    this.assetList = x;
    
                    for (var j=0; j<this.assetList.length; j++) {
                        console.log("assetList - Id: " + this.assetList[j].Id);
                        console.log("assetList - AssetName: " + this.assetList[j].AssetName);
                        console.log("assetList - assetUrl: " + this.assetList[j].assetUrl);
                        console.log("assetList - assetUrl: " + this.assetList[j].ShipToName);
                        console.log("assetList - assetUrl: " + this.assetList[j].shipToUrl);
                        console.log("assetList - Quantity: " + this.assetList[j].Amount);
                        console.log("assetList - StartDate: " + this.assetList[j].StartDate);
                        console.log("assetList - RenewalDate: " + this.assetList[j].RenewalDate);
                        console.log("assetList - CancelationDate: " + this.assetList[j].CancelationDate);
                        console.log("assetList - EndDate: " + this.assetList[j].EndDate);
                        console.log("---------------------");
                    }
                    this.noData = false;
                
                } else {
                    this.showTable = false;
                    this.noData = true;
                    this.assetList = [];
                }
    
                this.showTable = true;
    
                let tempRecords = [];
                console.log('pageNumber: ' + this.pageNumber);
                console.log('pageSize: ' + pageSize);
                console.log('totalRecords: ' + totalRecords);
    
                for(let i=(1-1)*10; i < 1*10; i++){
                    if(i === this.assetList.length) break;
                    tempRecords.push(this.assetList[i]);
                }
                this.recordsToDisplay = tempRecords;
                // setRecordsToDisplayOnPaginator();
    
                this.error = null;
    
            })
            .catch(error => {
                this.error = error;
                console.log('Error: ' + error);
            })

        }
    }

    handleDateFieldSelection(event) {
        this.dateFieldSelectoin = event.target.value;
    }

    handlePaginatorChange(event) {
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = parseInt(this.recordsToDisplay[0].rowNumber-1);
    }

    get activeAssetList() {
        return this.assetList;
    }

    get recordsToDisplayInTable() {
        return this.recordsToDisplay;
    }

    setRecordsToDisplayOnPaginator() {
        const paginator = this.template.querySelector('c-paginator');
        paginator.setRecordsToDisplay();
    }

    handleDateInput(event) {
        this.selectedDate = event.target.value;
        console.log('this.selectedDate = ' + this.selectedDate);
        console.log('this.currentRecordId = ' + this.currentRecordId);   
        console.log('this.dateSelection = ' + this.dateSelection);   
        console.log('this.dateFieldSelectoin = ' + this.dateFieldSelectoin);   

        getSortedAssetListForShipToJS({ 
            "recordId": this.currentRecordId,
            "sorting": this.dateSelection,
            "sortField": this.dateFieldSelectoin,
            "selectedDate": this.selectedDate
        })
        .then(result => {
            console.log('getting results');
            let dataSet = [];
            dataSet = result;
            console.log(dataSet);

            if (dataSet.length > 0) {
                let x = [];
                result.forEach(element => {
                    let elt ={};
                    elt.Id = element.Id;
                    elt.AssetName = element.Name;
                    elt.Amount = element.Quantity;
                    elt.assetUrl = `/${element.Id}`;
                    elt.ShipToName = element.Account.Name;
                    elt.shipToUrl = `/${element.AccountId}`;
                    elt.BillToName = element.BillToAccount__r.Name;
                    elt.BillToUrl = `/${element.BillToAccount__c}`;
                    elt.StartDate = element.ActivationDate__c;
                    elt.RenewalDate = element.RenewalDate__c;
                    elt.CancelationDate = element.CancellationDate__c;
                    elt.EndDate = element.UsageEndDate;
                    x.push(elt);
                    });
                this.assetList = x;

                for (var j=0; j<this.assetList.length; j++) {
                    console.log("assetList - Id: " + this.assetList[j].Id);
                    console.log("assetList - AssetName: " + this.assetList[j].AssetName);
                    console.log("assetList - assetUrl: " + this.assetList[j].assetUrl);
                    console.log("assetList - assetUrl: " + this.assetList[j].ShipToName);
                    console.log("assetList - assetUrl: " + this.assetList[j].shipToUrl);
                    console.log("assetList - Quantity: " + this.assetList[j].Amount);
                    console.log("assetList - StartDate: " + this.assetList[j].StartDate);
                    console.log("assetList - RenewalDate: " + this.assetList[j].RenewalDate);
                    console.log("assetList - CancelationDate: " + this.assetList[j].CancelationDate);
                    console.log("assetList - EndDate: " + this.assetList[j].EndDate);
                    console.log("---------------------");
                }
                this.noData = false;
            
            } else {
                this.showTable = false;
                this.noData = true;
                this.assetList = [];
            }

            this.showTable = true;

            let tempRecords = [];
            console.log('pageNumber: ' + this.pageNumber);
            console.log('pageSize: ' + pageSize);
            console.log('totalRecords: ' + totalRecords);

            for(let i=(1-1)*10; i < 1*10; i++){
                if(i === this.assetList.length) break;
                tempRecords.push(this.assetList[i]);
            }
            this.recordsToDisplay = tempRecords;
            // setRecordsToDisplayOnPaginator();

            this.error = null;

        })
        .catch(error => {
            this.error = error;
            console.log('Error: ' + error);
        })
    }

}