import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

import getSalesStatistics from '@salesforce/apex/BL_customBookListHelper.getSalesStatistics';

export default class CustomSalesDataBooklistView extends NavigationMixin(LightningElement) {

    @api recordId;

    @track YearValue;
    @track MonthValue;

    @track items = [];
    @track recordsToDisplay = [];
    @track YearOptions = [];
    @track MonthOptions = [];
    fullDataList = [];

    @track yearSelected = false;
    @track monthSelected = false;
    
    //PAGINATION ATTRIBUTES
    @track page = 1;
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 15;
    @track totalRecountCount = 0;
    @track totalPage = 1;
    @track filterActive = false;

    @track actions = [
        { label: 'Edit', name: 'Edit' },
        { label: 'Clone', name: 'Clone' }
    ]

    @track columns = [
        {
            label: 'Name',
            fieldName: 'Url',
            type: 'url',
            typeAttributes: {label: {fieldName: 'Name'},
            target: '_self'}
        },
        {
            label: 'Product Title',
            fieldName: 'ProductTitle',
        },
        {
            label: 'Value',
            fieldName: 'Value',
            type: 'currency'
        },
        {
            label: 'Quantity',
            fieldName: 'Quantity',
        },
        {
            label: 'Year',
            fieldName: 'Year',
        },
        {
            label: 'CreatedMonth',
            fieldName: 'CreatedDate',
        },
        {
            type: 'action', 
            typeAttributes: { 
                rowActions: this.actions, 
                menuAlignment: 'right' 
            } 
        }
    ]

    @wire(getSalesStatistics, { "recordId": '$recordId'})    
    wiredGetSalesStatistics ({ error, data }) {

        let y = [];
        for (let i = new Date().getFullYear(); i >= 2016; i--) {
            y.push({ label: i.toString(), value: i.toString() });
        }
        this.YearOptions = y;

        var options = { month: 'long'};
        let m = [];
        for (let i = 1; i <= 12; i++) {
            let d = new Intl.DateTimeFormat('en-US', options).format(new Date(i+' 25, 1995 23:15:30'))
            m.push({ label: d, value: d});
        }
        this.MonthOptions = m;

        if (data) {
            if (data.length > 0) {
                
                let x = [];
    
                data.forEach(element => {
                    let elt = {};
                    elt.Id = element.Id;
                    elt.Url = `/${element.Id}`;

                    if (element.Name) {
                        elt.Name = element.Name;
                    } else {
                        elt.Name = '-';
                    }
                    
                    if (element.Product2) {
                        elt.ProductTitle = element.Product2.Name;
                    } else {
                        elt.ProductTitle = '';
                    }
                    
                    if (element.Value__c) {
                        elt.Value = element.Value__c;
                    } else {
                        elt.Value = '-';
                    }
                    
                    if (element.Year__c) {
                        elt.Year = element.Year__c;
                    } else {
                        elt.Year = '-';
                    }
                    
                    if (element.Quantity) {
                        elt.Quantity = element.Quantity;
                    } else {
                        elt.Quantity = '-';
                    }

                    elt.CreatedDate = new Intl.DateTimeFormat('en-US', options).format(new Date(element.CreatedDate));

                    x.push(elt);
                    console.log('----------------------');
                })
                this.recordsToDisplay = x;
                this.fullDataList = x;
////////
                this.totalRecountCount = this.recordsToDisplay.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);

                this.recordsToDisplay = this.fullDataList.slice(0,this.pageSize);
                this.endingRecord = this.pageSize;


            }
        } else if (error) {
            console.log('ERROR: ' + error);
        } else {
            console.log('we have found no data');
        }
    }

    get recordsToDisplayInTable() {
        return this.recordsToDisplay;
    }

    get YearOptionsSelection() {
        return this.YearOptions;
    }

    createYearOptions() {
        let y = [];
        for (let i = new Date().getFullYear(); i >= 2016; i--) {
            y.push({ label: i.toString(), value: i.toString() });
        }
        this.YearOptions = y;
    }

    createMonthOptions() {
        var options = { month: 'long'};
        let m = [];
        for (let i = 1; i <= 12; i++) {
            let d = new Intl.DateTimeFormat('en-US', options).format(new Date(i+' 25, 1995 23:15:30'))
            m.push({ label: d, value: d});
        }
        this.MonthOptions = m;
    }

    handleYearChange(event) {
        this.yearSelected = true;
        this.YearValue = event.detail.value;
        this.createFilteredList();
    }

    handleMonthChange(event) {
        this.monthSelected = true;
        this.MonthValue = event.detail.value;
        this.createFilteredList();
    }

    createFilteredList() {
        let Baselist = [];
        Baselist = this.fullDataList;
        this.recordsToDisplay = [];

        let x = [];

        for (let i = 0; i < this.fullDataList.length; i ++) {
            let addToList= false;
           
            if (this.yearSelected && this.monthSelected) {
                if (this.fullDataList[i].CreatedDate == this.MonthValue && this.fullDataList[i].Year == this.YearValue) {
                    addToList = true;
                }
            } else if (this.yearSelected) {
                if (this.fullDataList[i].Year == this.YearValue) {
                    addToList = true;
                }
            } else if (this.monthSelected) {
                if (this.fullDataList[i].CreatedDate == this.MonthValue) {
                    addToList = true;
                }
            }

            if (addToList) {
                x.push(this.fullDataList[i]);
            }
        }
        this.recordsToDisplay = x;

       /////
       this.filterSubSetDataList = x;

        this.totalRecountCount = x.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        
        this.recordsToDisplay = this.filterSubSetDataList.slice(0,this.pageSize);
        this.endingRecord = this.totalPage;
        this.filterActive = true;
        
        if ((this.YearValue === null || this.YearValue === undefined)) {
                this.recordsToDisplay = this.fullDataList;

                this.totalRecountCount = this.recordsToDisplay.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);

                this.recordsToDisplay = this.fullDataList.slice(0,this.pageSize);
                this.filterActive = false;
                this.startingRecord = 1;
                this.page = 1;
                this.endingRecord = this.pageSize;
        }

    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'Edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'edit',
                    },
                });
                break;
            case 'Clone':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'clone',
                    },
                });
                break;
        }
    }

//ON CLICK OF PREVIOUS BUTTON
previousHandler() {
    if (this.page > 1) {
        this.page = this.page - 1; //DECREASE PAGE NO
        this.displayRecordPerPage(this.page);
    }
}

//ON CLICK OF NEXT BUTTON
nextHandler() {
    if((this.page<this.totalPage) && this.page !== this.totalPage){
        this.page = this.page + 1; //INCREASE PAGE NO
        this.displayRecordPerPage(this.page);            
    }             
}

//DISPLAY RECORDS PAGE FOR PAGE
displayRecordPerPage(page){

    let baseList = [];
    baseList = this.filterSubSetDataList;
    console.log("displayRecordPerPage baseList: " + baseList);

    this.startingRecord = ((page -1) * this.pageSize) ;
    this.endingRecord = (this.pageSize * page);

    this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord;

    if(this.filterActive == false){
        this.recordsToDisplay = this.fullDataList.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }else{
        this.recordsToDisplay = this.filterSubSetDataList.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }
}

//SET DISABLED BUTTON ATTRIBUTE DYNAMICALLY
get disableButton(){
    return(this.totalPage<2);
}

    
}