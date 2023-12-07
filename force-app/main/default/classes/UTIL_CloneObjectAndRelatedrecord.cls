public with sharing class UTIL_CloneObjectAndRelatedrecord {


    
    public static void CloneRelatedListItems(Id RecordId, List<String> lstofRelatedObjects){

        String sobjectType = RecordId.getSObjectType().getDescribe().getName();
    
    
        Map<String, Map<String,String>> Map_ObjField = new Map<String, Map<String,String>>(); 
        List<String> lstHeader = new List<String>();
        lstHeader.Add(sobjectType);
        
        Map_ObjField = ReturnAllFields(lstHeader);
        
        Map<String, String> Map_ObjSoql = CreateSOQL(Map_ObjField,RecordId,SObjectType);
        
        Map<String, List<SObject>> Map_Objrecord = new Map<String, List<SObject>>();
    
        for(String obj:Map_ObjSoql.keyset()){
            Map_Objrecord.put(obj, getRecords(Map_ObjSoql.get(obj)));
        }
    
        List<sObject> lstSobj = InsertRecords(Map_ObjField,Map_Objrecord,RecordId,SObjectType);
        
        /*
        for(String obj:lstofRelatedObjects){
        
            SObjectType accountType = Schema.getGlobalDescribe().get(obj);
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        
            Map<String,String> Map_field = new Map<String,String>();
            
            for(String str: mfields.keyset()){
                
                Map_field.put(str,'');
                
                Schema.DescribeFieldResult fieldResult = mfields.get(str).getDescribe();
                fieldResult.getReferenceTo();
                system.debug('FieldName**'+str +'****'+fieldResult.getReferenceTo());
                
                
                
               // Schema.DescribeFieldResult fieldResult = mfields.get(str).getDescribe();
               // if(fieldResult.isUpdateable()) {
                     
               // }
                
                
            }
            Map_ObjField.put(obj,Map_field);
    
        }
        */
        
         Map_ObjField = ReturnAllFields(lstofRelatedObjects);
         Map_ObjSoql = CreateSOQL(Map_ObjField,RecordId,SObjectType);
        
        Map_Objrecord = new Map<String, List<SObject>>();
    
        for(String obj:Map_ObjSoql.keyset()){
            Map_Objrecord.put(obj, getRecords(Map_ObjSoql.get(obj)));
        }
    
        InsertRecords(Map_ObjField,Map_Objrecord,lstSobj[0].id,SObjectType);
    
    }
    /*
    @future
    public static void insertrelatedRecords(Map<String, Map<String,String>> Map_ObjField,Map<String, List<SObject>> Map_Objrecord,id RecordId,String sobjectType){
        InsertRecords(Map_ObjField,Map_Objrecord,lstSobj[0].id,SObjectType);
    }
    */

    public static Map<String, Map<String,String>> ReturnAllFields(List<String> lstofObjects){
    
        
        Map<String, Map<String,String>> Map_ObjField = new Map<String, Map<String,String>>();
        
        for(String obj:lstofObjects){
            system.debug('obj**'+obj);
            
            SObjectType accountType = Schema.getGlobalDescribe().get(obj);
          if(accountType != null){   
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        
            Map<String,String> Map_field = new Map<String,String>();
            
            for(String field: mfields.keyset()){
                
               
                
                Schema.DescribeFieldResult fieldResult = mfields.get(field).getDescribe();
                fieldResult.getReferenceTo();
                 
                   //&& !fieldResult.isCustom() 
    
                if(fieldResult.isCreateable() && field !='IsReductionOrder' && field !='OriginalOrderId' && field !='cleanstatus'  && field !='billingstatecode' && field != 'billingcountrycode'  && field !='shippingstatecode' && field !='shippingcountrycode' && field !='currencyisocode' ) {
                        
                        
                        if(fieldResult.getReferenceTo()==null){
                            Map_field.put(field,'');
                        } 
                        else{
                           // system.debug('FieldName**'+field +'****'+fieldResult.getReferenceTo());
                           String strreference=string.valueof(fieldResult.getReferenceTo());
                           strreference=strreference.replace('(','');
                           strreference=strreference.replace(')','');
                          
                            Map_field.put(field,strreference);   
                        }
                        
                }
                
                
            }
            Map_ObjField.put(obj,Map_field);
           }
    
        }
        return Map_ObjField;
        
    }
    
                 
    public static Map<String, String> CreateSOQL(Map<String, Map<String,String>> Map_ObjField, String RecordId,String sobjectType){
        
        String Soql='';
    
        Map<String, String> Map_ObjSoql = new Map<String, String>();
        
        
        Map<integer, String> Map_FieldEdit = new Map<integer, String>();
        system.debug('sobjectType**'+sobjectType);
        for(String obj:Map_ObjField.keyset()){
            Soql='Select';
           
            
            
            SObjectType accountType = Schema.getGlobalDescribe().get(obj);
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            
            String referenceObject='';
            integer i=1;
            for(String field:Map_ObjField.get(obj).Keyset()){
                //Soql = Soql + ' '+ field; OLD
                     
                        Soql = Soql + ' '+field;
                        
                        if(Map_ObjField.get(obj).size() > i){
                          //  Soql = Soql + ',';
                              Soql = Soql + ' ,';
                              system.debug('**LessONE**');
                        }
                        else{
                             // Soql = Soql + '+';
                              system.debug('**FINAL**');
                        }
                        
                        
                        system.debug('referenceObject MAP**'+Map_ObjField.get(obj).get(field)+'**sobjectType**'+sobjectType+'**field**'+field);

                      if(Map_ObjField.get(obj).get(field) == sobjectType){
                        system.debug('referenceObject MAP: field**'+field);  
                        referenceObject = field;
                      }  
                       
               i++;
                
                
            }
           
            system.debug('referenceObject MAP: referenceObject**'+referenceObject);  
            String WhereClause;
            if(sobjectType == obj){
                WhereClause = ' where id =   \''+ RecordId +'\' ';
            }
            else{
                WhereClause = ' where '+referenceObject + ' =   \''+ RecordId +'\' ';
            }
                
            
            // Soql = Soql + ' from' + obj;
            system.debug('WhereClause**'+WhereClause);
             system.debug('Soql**'+Soql);
             Soql = Soql + ' from ' + obj + WhereClause; //' where '+PrimaryObject + '=   \''+ RecordId +'\' limit 1';
            
            Map_ObjSoql.put(obj,Soql);
                
        }
        
        return Map_ObjSoql;
    
    }
    
    public static List<sObject> InsertRecords(Map<String, Map<String,String>> Map_ObjField,Map<String, List<SObject>> Map_Objrecord,id RecordId,String sobjectType){
       
       // sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
       //     sObj.put('name' , RecordName) ;
       //     insert sObj ;
        
        List<sObject> lstSobj = new List<sObject>();
        

        for(String obj:Map_ObjField.keyset()){
            
            
            String PrimLookUp='';   
            
            SObjectType accountType = Schema.getGlobalDescribe().get(obj);        
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            
            

            
            for(SObject val:Map_Objrecord.get(obj)){    

                sObject sObj = Schema.getGlobalDescribe().get(obj).newSObject() ;
                
                for(String field: Map_ObjField.get(obj).Keyset()){
                
                    
                 
                       Schema.DescribeFieldResult fieldResult = mfields.get(field).getDescribe();
                    
                        if(fieldResult.isCreateable()) {
                            
                           for(Schema.SObjectType reference : fieldResult.getReferenceTo()) {
                                
                                if(reference.getDescribe().getName() == sobjectType){
                                    system.debug('**field**'+field+'**value*'+val.get(field));
                                    sObj.put(field ,RecordId);
                                    PrimLookUp=field;          
                                }
                                
                            }
                            
                            
                            if(PrimLookUp=='' || PrimLookUp!=field){
                                    sObj.put(field ,val.get(field));
                                    system.debug('**field**'+field+'**value*'+val.get(field));
                            }
                                
                        }    
                     
                         
                                            
                  //  }
                }
                lstSobj.add(sObj);
            }
           
           
            
                        
        }
        
        system.debug('**lstSobj**'+lstSobj.size());
        insert lstSobj;
            
        return lstSobj;
        
        
    }
    
    
    public static list<sobject> getRecords(String query){
            list<sobject> records;
            
            records = Database.query(query);

            system.debug('**Query size**'+records.size());
            return records;
    }
    
}