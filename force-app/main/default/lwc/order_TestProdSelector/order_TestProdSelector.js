import { LightningElement,wire, track } from 'lwc';

import loadProductsbySearch from'@salesforce/apex/Order_TestProdHandler.loadProductsbySearch';

export default class Order_TestProdSelector extends LightningElement {

    @track searchKey;
    @wire (loadProductsbySearch,{searchString: '$searchKey'}) products;
    handleKeyChange(event){
      console.log('**Search**'+event.target.value);  
      this.searchKey = event.target.value;
    }

}