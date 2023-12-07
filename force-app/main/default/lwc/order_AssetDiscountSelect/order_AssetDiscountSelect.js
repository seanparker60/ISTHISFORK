import { 
    LightningElement,
    track,
    wire,
    api
     
} from 'lwc';
 
import ReturnDiscountValues from "@salesforce/apex/Order_AssetDisountSelect.ReturnDiscountValues";
import UpdateAsset from "@salesforce/apex/Order_AssetDisountSelect.UpdateAsset";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

export default class Sample_Combobox extends LightningElement {
    @api recordId;
    @track Asset;
    @track DiscountValues;
    @track SelectedValues;
    @track TypeOptions;
    @track boolPercent = false;
    @track boolAmount = false;
    @track Percent;
    @track Amount;
 
    @wire(ReturnDiscountValues, {AssetId: '$recordId'})
    WiredObjects_Type({ error, data }) {
 
        if (data) {
            try {
                this.DiscountValues = data; 
                let options = [];
                 
                var scount=0;
                for (var key in data) {
                    // Here key will have index of list of records starting from 0,1,2,....
                    options.push({ label: data[key].DiscountType, value: data[key].DiscountType  });
                    console.log('**scount**'+scount);
                    if(data[key].isSelected===true){
                        this.SelectedValue = data[key].DiscountType;
                        if(data[key].DiscountType ==='Percent'){
                            this.boolPercent = true;
                            this.boolAmount = false;
                         }
                         else if(data[key].DiscountType ==='Amount'){
                             this.boolPercent = false;
                             this.boolAmount = true;
                         }
                         else{
                             this.boolPercent = false;
                             this.boolAmount = false;
                         }
                        scount++;
                    }
                    

                    if(data[key].DiscountType === 'Percent'){
                        this.Percent = data[key].Discount ;
                    }
                    else if(data[key].DiscountType === 'Amount'){
                        this.Amount = data[key].Discount ;
                    }

                    console.log('**data[key].DiscountType:**'+data[key].DiscountType);
                    // Here Name and Id are fields from sObject list.
                }
                this.TypeOptions = options;
                 
            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }
        
    }
    
    handleTypeChange(event){
        var Picklist_Value = event.target.value; 

       if(Picklist_Value ==='Percent'){
           this.boolPercent = true;
           this.boolAmount = false;
        }
        else if(Picklist_Value ==='Amount'){
            this.boolPercent = false;
            this.boolAmount = true;
        }
        else{
            this.boolPercent = false;
            this.boolAmount = false;
        }

        console.log('**Picklist_Value**'+Picklist_Value);
        // Do Something.
    }
    handleValueChange(event){
        var Picklist_Id = event.target.name; 
        var Picklist_Value = event.target.value; 
        
        console.log('**Picklist_Id **'+Picklist_Id );
        console.log('**Picklist_Value**'+Picklist_Value);

        if(Picklist_Id === 'Percent'){
           this.Percent = Picklist_Value;
           this.Amount = null;
        }
        else if(Picklist_Id ==='Amount'){
            this.Percent = null;
            this.Amount = Picklist_Value;
        }
        else{
            this.Percent = null;
             this.Amount = null;
        }

        console.log('**Picklist_Value**'+Picklist_Value);
        // Do Something.
    }

    saveDiscount(event){
        // Refering to first method and passwing parameters.
        // Note: a_First_Name, a_Last_Name and a_Email are parameters for the method.
        // all Ref variables are @api references.  
        console.log('**IN Save**');

      var DiscountType; 
      var DiscountValue;

    console.log('**Save: Percent**'+this.Percent);
    console.log('**Save: Amount**'+ this.Amount);


    if(this.boolPercent === true){
        console.log('**Select: Percent**');
      DiscountType = 'Percent'; 
      DiscountValue = this.Percent;
      
    }
    else if(this.boolAmount === true){
        console.log('**Select: Amount**');
        DiscountType = 'Amount'; 
        DiscountValue = this.Amount;
    }
    else{
        console.log('**Save: Amount**');
        DiscountType = ''; 
        DiscountValue = 0;
    }
    console.log('**Save: DiscountType**'+DiscountType);
    console.log('**Save: DiscountValue**'+ DiscountValue);
    console.log('**Save: $recordId**'+ this.recordId);   

        UpdateAsset({ 

            DiscountValue : DiscountValue,
            RecordId : this.recordId,
            DiscountType : DiscountType
        })
        .then(result => {
        
            const event = new ShowToastEvent({
                title: 'Discount Updated',
                message: 'Discount Updated',
                variant: 'success'
            });
            
            this.dispatchEvent(event);
            
           console.log('***Before Refresh');
           updateRecord({fields: { Id: this.recordId }});
            console.log('***after Refresh');
            /*
            const updatedRecords = result.map(rec => {
                return { 'recordId': this.recordId };
            });
            getRecordNotifyChange(updatedRecords);
            */
        })
        .catch(error => {
            const event = new ShowToastEvent({
                title : 'Error',
                message : 'Error Updating Asset. Please Contact System Admin:',
                variant : 'error'
            });
            console.log('**Error**'+error);
            this.dispatchEvent(event);
        });
    }    
}