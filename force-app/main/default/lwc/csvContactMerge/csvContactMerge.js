import { LightningElement, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import saveFile from '@salesforce/apex/MERGE_csvContactMerge.mergeContacts';
import getUserEmail from '@salesforce/apex/MERGE_csvContactMerge.getEmailFromUser';

export default class csvContactMerge extends LightningElement {

    @track data;
    @track fileName = 'Please select a (UTF-8, comma seperated) CSV file to upload (in the form of: MasterContact,DuplicateContact)';
    @track UploadFile = 'Upload CSV File';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    @track progress = 0;
    @track sendEmail = false;
    @track showEmailBox = false;
    @track emailAddress = '';
    @track finalMessage = 'Merging Contacts. You can close this window.';

    userId = Id;
    startProgressBar = false;
    progressTotalValue = 0;
    progressCurrentValue = 0;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;

    handleFilesChange(event) {

        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = 'File Name: ' + event.target.files[0].name;
        }
 
    }

    handleSendMailChange(event) {
        console.log('checked = ' + event.target.checked);
        if (event.target.checked === true) {
            this.getUserEmail();
            this.showEmailBox = true;
            this.finalMessage = 'Merging Contacts. You can close this window.\nYou will receive an e-mail with the results when the process is finished.';
        } else {
            this.showEmailBox = false;
            this.emailAddress = '';
            this.finalMessage = 'Merging Contacts. You can close this window.';
        }
    }

    handleEmailChange(event) {
        this.emailAddress = event.target.value;
    }

    handleSave() {

        if(this.filesUploaded.length > 0) {
            this.uploadHelper();
        } else {
            this.fileName = 'You did not select a CSV file yet...';
        }

    }

    uploadHelper() {

        this.file = this.filesUploaded[0];
 
        if (this.file.size > this.MAX_FILE_SIZE) {
            window.console.log('File Size is to big');
            return ;
        }
        this.showLoadingSpinner = true;
 
        this.fileReader= new FileReader();
 
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            this.saveToFile();
        });
 
        this.fileReader.readAsText(this.file);
 
    }

    getUserEmail() {
        getUserEmail( {userId: this.userId})

        .then(result => {
            this.emailAddress = result;
        })
    }

    saveToFile() {

        saveFile({ base64Data: JSON.stringify(this.fileContents), email: this.emailAddress })
 
        .then(result => {
 
            this.data = result;
            this.showEmailBox = false;
 
            this.fileName = this.fileName + ' - Uploaded Successfully';
            this.isTrue = false;
            this.showLoadingSpinner = false;
            this.startProgressBar = true;

            this.dispatchEvent(

                new ShowToastEvent({
                    title: 'Success!!',
                    message: this.file.name + ' - Uploaded Successfully!!!',
                    variant: 'success',
                }),

            );

        })
 
        .catch(error => {

            window.console.log('ERROR: ' + error);
            window.console.log('ERROR-message: ' + error.message);
            window.console.log('ERROR-finalmessage: ' + error.finalMessage);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while uploading File',
                    message: error.message,
                    variant: 'error',
                }),
            );

        });
 
    }

    get progressPercentValue() {
        var progressPercent = 0;
        try {
            if (this.progressTotalValue != undefined && this.progressCurrentValue != undefined) {
                progressPercent = (parseInt(this.progressCurrentValue) / parseInt(this.progressTotalValue)) * 100;
            }
        } catch (error) {
            console.log("***** error ***** = " + error.message + error.stack);
        }
        return progressPercent;
    }

}