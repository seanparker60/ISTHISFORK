import { LightningElement, api, track } from 'lwc';

export default class ListItems extends LightningElement {

    @api key = '';
    @api value = '';
    @api label = '';
    @api selected = false;

    get listStyle() {
        var initial = ' slds-media  slds-listbox__option_plain slds-media_small slds-listbox__option ';
    return this.selected === true ? initial + ' slds-is-selected ' : initial ;
    }

    eventHandler(event) {
        event.preventDefault();
        event.stopPropagation();
        console.log('selcted value..'+this.selected);
        const selectedEvent = new CustomEvent('selected', { detail: {label:this.label,value:this.value,selected:this.selected,shift:event.shiftKey} });
        this.dispatchEvent(selectedEvent);
  }

}