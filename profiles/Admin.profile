<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <categoryGroupVisibilities>
        <dataCategoryGroup>test</dataCategoryGroup>
        <visibility>ALL</visibility>
    </categoryGroupVisibilities>
    <classAccesses>
        <apexClass>Order_AssetsCreateOnOrderActivation</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>Order_OrderandOrdeItemHandler</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>Order_ProductCalculationDates</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>Order_ProductSelectController</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>Order_UpdateOrderListPriceDiscountAll</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <custom>false</custom>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.ReasonLost__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>OpportunityLineItem.ProductEndDate__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Order.OperatingCompany__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <userLicense>Salesforce</userLicense>
</Profile>