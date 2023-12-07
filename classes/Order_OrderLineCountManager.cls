public with sharing class Order_OrderLineCountManager implements Queueable {
    
    static final Decimal FIXEDLINECOUNT = 400;
    Public static String DebugLogs;
    Private String load;
    Private Order CurOrder ;
    Private List<Order> MaxOrder;

    public Order_OrderLineCountManager() {

    }

    public Order_OrderLineCountManager(List<Order> MaxOrder,String load) {
        
        if(load == 'Start'){           
            this.MaxOrder = MaxOrder;
            this.CurOrder = MaxOrder[0];
        }
        else {
          
          MaxOrder.remove(0);
          this.MaxOrder = MaxOrder;
          if(MaxOrder.size()>0){
            this.CurOrder= MaxOrder[0];
          }
          
          
        }   

        system.debug('**OrderLineCountManager: Cur**'+CurOrder);
          system.debug('**OrderLineCountManager: Max**'+MaxOrder);

    }
    public void execute(System.QueueableContext qc) {
    //Public static void ProcessLineCount(Order CurOrder){
        system.debug('**OrderLineCountManager: CurOrder Order size exe**'+CurOrder);
        if(CurOrder != null){

        
                List<Id> OrderId = new List<Id>();
                OrderId.add(CurOrder.id);
                OrderItem[] lst_OrdItem = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);

                try{
                    ItemGroupSync(lst_OrdItem,CurOrder);
                }
                catch(exception e){

                }

                if(!test.isrunningtest()){
                    System.enqueueJob(new Order_OrderLineCountManager(MaxOrder,'Next'));
                }
        }
    }
    Public static void ItemGroupSync(OrderItem[] lst_OrdItem,Order CurOrder){

        Map<String, List<OrderItem>> Map_ItemGrpId = new  Map<String, List<OrderItem>>();
        Map<OrderItem, List<OrderItem>> Map_ItemGrp = new  Map<OrderItem, List<OrderItem>>();
        Map<String, OrderItem> Map_ItemGrpHead = new  Map<String, OrderItem>();

        List<OrderItem> lst_ItemGroup = new List<OrderItem>();
        List<OrderItem> lst_RemoveItemGroup = new List<OrderItem>(); 

        List<Integer> lstItemremoveIndex = new List<Integer>();

        system.debug('**Line Count: ProcessLineCount**: ItemGroupSync1');
        DebugLogs= '**Line Count: ProcessLineCount**: ItemGroupSync1';
        DebugLogs += '\r\n';

        Integer index = 0;
        
        List<id> lstRemove = new List<id>();

        for(OrderItem item:lst_OrdItem){

            if(item.ItemGroup__c != null){
                 
                    if(Map_ItemGrpHead.get(item.ItemGroup__c) !=null){
                            Map_ItemGrp.get(Map_ItemGrpHead.get(item.ItemGroup__c)).add(item);
                                                //  system.debug('**Line Count: ProcessLineCount**: Component 1: Loop Start');
                                            //   system.debug('**Line Count: ProcessLineCount**: Component 1:'+ item.Product2.Name);
                                                //  system.debug('**Line Count: ProcessLineCount**: Component 2:'+  Map_ItemGrp.get(Map_ItemGrpHead.get(item.ItemGroup__c)));

                    }
                    else if(Map_ItemGrpId.get(item.ItemGroup__c) != null){
                        Map_ItemGrpId.get(item.ItemGroup__c).add(item);
                                                   //    system.debug('**Line Count: ProcessLineCount**: Component 2:'+ item.Product2.Name);
                    }
                    else{
                        lst_ItemGroup = new List<OrderItem>();
                        lst_ItemGroup.add(item);
                        Map_ItemGrpId.put(item.ItemGroup__c,lst_ItemGroup);

                                                //  system.debug('**Line Count: ProcessLineCount**: Component 3:'+ item.Product2.Name);
                    }
                                                   //lst_RemoveItemGroup.add(item);
                                                    //lstItemremoveIndex.add(index);
                  index++;                    
            }
            else if(item.ProductType__c == 'Item Group'){                 

                Map_ItemGrpHead.put(item.id,item);

                if(Map_ItemGrp.get(item) == null && Map_ItemGrpId.get(item.id) ==null){
                    lst_ItemGroup = new List<OrderItem>();
                    lst_ItemGroup.add(item);
                    Map_ItemGrp.put(item,lst_ItemGroup);
                                              //  system.debug('**Line Count: ProcessLineCount**: Group1 '+ item.Product2.Name);
                }
                else if(Map_ItemGrp.get(item) == null && Map_ItemGrpId.get(item.id) !=null){
                    Map_ItemGrpId.get(item.id).add(item);
                    Map_ItemGrp.put(item,Map_ItemGrpId.get(item.id));
                                         //  system.debug('**Line Count: ProcessLineCount**: Group2 '+ item.Product2.Name);
                }
                else{
                    Map_ItemGrpId.get(item.id).add(item);
                    Map_ItemGrp.put(item,Map_ItemGrpId.get(item.id));
                                                 // system.debug('**Line Count: ProcessLineCount**: Group3 '+ item.Product2.Name);
                }
                                                //system.debug('***Add Item Group: header:');
                                                //lst_RemoveItemGroup.add(item);
                                                //lstItemremoveIndex.add(index);
                 
                index++;
            }
            

        }
                                                //  system.debug('**Line Count: ProcessLineCount**: index'+ index);        
                                                //  system.debug('**Line Count: ProcessLineCount**: ItemGroupSync2'+lstItemremoveIndex.size());
                                                //  system.debug('**Line Count: ProcessLineCount**: Map_ItemGrp'+Map_ItemGrp);
                                                
        Integer listsize = lst_OrdItem.size();
        
        for(Integer i=listsize-1; i>0; i-- ){
                                                //system.debug('***Index**'+i);
                                                //if(i<270){
                                                    
               if(lst_OrdItem.get(i).ProductType__c == 'Item Group' || lst_OrdItem.get(i).ItemGroup__c != null){
                    lst_OrdItem.remove(i);
               }    
                                                        
                                                    //}
                                                    
        }
                                                //  system.debug('**Line Count: ProcessLineCount**: NI fullistsize'+ lst_OrdItem.size());
                                                //  system.debug('**Line Count: ProcessLineCount**: Map_ItemGroup'+ Map_ItemGrp.size());

        creatlists(lst_OrdItem,Map_ItemGrp,CurOrder);

    }

    Public static void creatlists(OrderItem[] lst_OrdItem,Map<OrderItem, List<OrderItem>> Map_ItemGroup,Order CurOrder){

        Decimal fullistsize = lst_OrdItem.size();
        Decimal NoChunks = (fullistsize/FIXEDLINECOUNT);
        Map<Integer,List<OrderItem>> Map_Itemlist = new Map<Integer,List<OrderItem>>();
        Map<String, String> Map_IGLookup = new Map<String, String>();
        

        List<OrderItem> lstNewOrderitems;
                                                                        //  system.debug('**Line Count: ProcessLineCount**: NI fullistsize'+ fullistsize);
                                                                        //   system.debug('**Line Count: ProcessLineCount**: NI NoChunks'+ NoChunks);
                                                                        //   DebugLogs+= '**Line Count: ProcessLineCount**: NI fullistsize ' + fullistsize;
                                                                        //   DebugLogs += '\r\n';
                                                                        //   DebugLogs+= '**Line Count: ProcessLineCount**: NI NoChunks'+ NoChunks;
                                                                        //  DebugLogs += '\r\n';
       Integer count = 0;
        Integer LoopChunks=0;
        if(NoChunks>1){
            
            lstNewOrderitems = new List<OrderItem>(); 
            count = 1;
            LoopChunks = 1;
                                                                        //     system.debug('**Line Count: ProcessLineCount**: NI Greater than 1');
                                                                        //      DebugLogs+= '**Line Count: ProcessLineCount**: NI Greater than 1';
                                                                        //   DebugLogs += '\r\n';
            for(OrderItem item:lst_OrdItem){

                                                                        //  system.debug('**Line Count: ProcessLineCount**: loop');
                if(count>FIXEDLINECOUNT){

                    if(Map_Itemlist.get(LoopChunks)== null){
                        Map_Itemlist.put(LoopChunks,lstNewOrderitems);
                    }

                    Map_Itemlist.get(LoopChunks).add(item);

                    if(Map_Itemlist.get(LoopChunks).size() == FIXEDLINECOUNT){
                        LoopChunks++;
                        lstNewOrderitems = new List<OrderItem>();
                    }
                                                                            //system.debug('**Line Count: ProcessLineCount**: LoopChunks '+LoopChunks);               
                }

                

                count++;
            }
        }

        if(Map_ItemGroup.size()>0){
            
                                                                         //    system.debug('**Line Count: ProcessLineCount**: LoopChunks size'+Map_Itemlist.get(LoopChunks).size());
            lstNewOrderitems = new List<OrderItem>();
                                                                           //  system.debug('**Line Count: ProcessLineCount**: LoopChunks size'+Map_Itemlist.get(LoopChunks).size());
             

            if(LoopChunks== 0){
                LoopChunks=1;
            }
            else{
                LoopChunks++;
            }
       
            count = 1;
 
                                                                                        // system.debug('**Line Count: ProcessLineCount**: Map_ItemGroup'+ Map_ItemGroup.size());

                                                                                        //  DebugLogs+= '**Line Count: ProcessLineCount**:Map_ItemGroup '+ Map_ItemGroup.size();
                                                                                    //  DebugLogs += '\r\n';

            Map_Itemlist.put(LoopChunks,lstNewOrderitems);
            Integer CurrentChunkSize;

            for(OrderItem item: Map_ItemGroup.keyset()){
                
                Integer CurListSize = count + Map_ItemGroup.get(item).size();
                                                                                            /*
                                                                                            system.debug('**Line Count: ProcessLineCount**: CurListSize'+ CurListSize);
                                                                                            system.debug('**Line Count: ProcessLineCount**: FIXEDLINECOUNT'+ FIXEDLINECOUNT);

                                                                                            DebugLogs+='**Line Count: ProcessLineCount**: CurListSize '+ CurListSize;
                                                                                    DebugLogs += '\r\n';
                                                                                    DebugLogs+='**Line Count: ProcessLineCount**: FIXEDLINECOUNT '+ FIXEDLINECOUNT;
                                                                                    DebugLogs += '\r\n';
                                                                                    */
                                                                                        //  system.debug('**Line Count: ProcessLineCount**: Group '+ item.Product2.Name);
               
                if(CurListSize  < FIXEDLINECOUNT){
                    CurrentChunkSize = Map_Itemlist.get(LoopChunks).size();
                                                                /*
                                                                system.debug('**Line Count: ProcessLineCount**: Component CurrentChunkSize 1a:'+ CurrentChunkSize);
                                                                system.debug('**Line Count: ProcessLineCount**: CurListSize b'+ Map_ItemGroup.get(item).size());
                                                                
                                                                DebugLogs+='**Line Count: ProcessLineCount**: Component CurrentChunkSize 1a:'+ CurrentChunkSize;
                                                                DebugLogs += '\r\n';
                                                                DebugLogs+= '**Line Count: ProcessLineCount**: CurListSize b '+ Map_ItemGroup.get(item).size();
                                                                DebugLogs += '\r\n';
                                                                */
                    for(OrderItem itemComp:Map_ItemGroup.get(item)){
                                                                // lstNewOrderitems.add(item);   
                                                            //      system.debug('**Line Count: ProcessLineCount**: ProdName '+ itemComp.Product2.Name);

                       DebugLogs+='**Line Count: ProcessLineCount**: ProdName '+ itemComp.Product2.Name;
                       DebugLogs += '\r\n';

                        Map_Itemlist.get(LoopChunks).add(itemComp);
                        Map_IGLookup.put(itemComp.ProductEAN__c, item.ProductEAN__c);
                        count++;
                    }
                    DebugLogs+= '**Line Count: ProcessLineCount**: ProdName LoopChunks:'+ LoopChunks;
                    DebugLogs += '\r\n';
                    CurrentChunkSize = Map_Itemlist.get(LoopChunks).size();
                                                                    /*
                                                                    system.debug('**Line Count: ProcessLineCount**: Component CurrentChunkSize 1b:'+ CurrentChunkSize);

                                                                    DebugLogs+='**Line Count: ProcessLineCount**: Component CurrentChunkSize 1b:'+ CurrentChunkSize;
                                                                    DebugLogs += '\r\n';
                                                                    */
                                                                // LoopChunks++;
                } 
                else{
                    lstNewOrderitems = new List<OrderItem>();
                    
                    
                    CurrentChunkSize = Map_Itemlist.get(LoopChunks).size() + Map_ItemGroup.get(item).size();
                                                                    /*
                                                                    system.debug('**Line Count: ProcessLineCount**: Component CurrentChunkSize 2:'+ CurrentChunkSize);

                                                                    DebugLogs+= '**Line Count: ProcessLineCount**: Component CurrentChunkSize 2:'+ CurrentChunkSize;
                                                                    DebugLogs += '\r\n';
                                                                    */

                    if( CurrentChunkSize > FIXEDLINECOUNT){
                        LoopChunks++;
                        lstNewOrderitems = new List<OrderItem>();
                    }
                    if(Map_Itemlist.get(LoopChunks)== null){
                                                                //LoopChunks++;
                        Map_Itemlist.put(LoopChunks,lstNewOrderitems);
                        
                    }
                                                                        /*
                                                                        system.debug('**Line Count: ProcessLineCount**: Component LoopChunks:'+ LoopChunks);
                                                                        */
                    DebugLogs+= '**Line Count: ProcessLineCount**: Component LoopChunks:'+ LoopChunks;
                    DebugLogs += '\r\n';
                    
                    for(OrderItem itemComp:Map_ItemGroup.get(item)){
                                                                    //  lstNewOrderitems.add(itemComp);   
                        

                        Map_IGLookup.put(itemComp.ProductEAN__c, item.ProductEAN__c);
                        Map_Itemlist.get(LoopChunks).add(itemComp);
                        count++;

                                                                  //system.debug('**Line Count: ProcessLineCount**: Component 2a:'+ itemComp.Product2.Name);
                     //   DebugLogs+= '**Line Count: ProcessLineCount**: Component 2a:'+ itemComp.Product2.Name;
                     //   DebugLogs += '\r\n';

                                                                    // system.debug('**Line Count: ProcessLineCount**: Component 2b:'+ itemComp.ProductEAN__c);
                                                                    // system.debug('**Line Count: ProcessLineCount**: Component 2c:'+ item.ProductEAN__c);
                    }
                                                              //Map_Itemlist.put(LoopChunks,lstNewOrderitems);
                }
                
                
            }
        }

        if(count>0){
            ReparentItems(CurOrder, Map_Itemlist,lst_OrdItem,Map_IGLookup);
        }
   

    }

    Public static void ReparentItems(Order CurOrder, Map<Integer,List<OrderItem>> Map_Itemlist,OrderItem[] lst_OrdItem, Map<String, String> Map_IGLookup){


        Order newOrder;
        List<OrderItem> lst_InsertItemGroup = new List<OrderItem>(); 
        List<OrderItem> lst_Insert= new List<OrderItem>(); 
        List<OrderItem> lst_Delete= new List<OrderItem>(); 

        Map<String, String> Map_IGLookup2 = new Map<String, String>();
        
        
        MaxOrderLine__c MaxOrderLine = new MaxOrderLine__c();
        Insert MaxOrderLine;
        Integer lineCount = Integer.valueof(CurOrder.LineCount__c);

        Set<Id> Set_OrdId = new Set<Id>();
        Set_OrdId.add(CurOrder.id);

        for(Integer LoopChunks: Map_Itemlist.keyset()){

            newOrder = new Order();
                                                                            // newOrder = CurOrder;
           newOrder = CurOrder.clone(false, false, false, false); 
           NewOrder.id=null;
            NewOrder.MasterOrder__c = CurOrder.id;
            NewOrder.MaxOrderLine__c = MaxOrderLine.id;
            NewOrder.ActivateforBatchProcessing__c = true;
            NewOrder.RelatedOrderActivationBlock__c = true;                                                                 // newOrder.AccountId = newOrder.AccountId;
            
           Insert newOrder;
           Set_OrdId.add(newOrder.id);

           DebugLogs+= '**Line Count: ProcessLineCount**: Final LoopChunks:'+ LoopChunks;
           DebugLogs += '\r\n';

            for(OrderItem item:Map_Itemlist.get(LoopChunks)){
                
                OrderItem newItem = new OrderItem();
                newItem = item.clone(false, false, false, false);
                newItem.id = null;
                newItem.OrderId = newOrder.id;

              //  newItem.ComponentListPrice__c = newItem.ComponentListPrice__c.setscale(2);
              //  newItem.unitprice = newItem.unitprice.setscale(2);

                                                            // system.debug('**Line Count: ProcessLineCount**: Final 0a:'+ item.Product2.Name);
                                                            // system.debug('**Line Count: ProcessLineCount**: Final 0b:'+ item.ProductType__c);
                if(item.ListPriceDiscount__c != null){
                    newItem.ListPriceDiscount__c = item.ListPriceDiscount__c;
                }                                                

                if(item.ProductType__c == 'Item Group'){      
                                                             //  system.debug('**Line Count: ProcessLineCount**: Final 1:'+ item.Product2.Name);
                                                               DebugLogs+= '**Line Count: ProcessLineCount**: Final 1:'+ item.Product2.Name;
                                                               DebugLogs += '\r\n';
                    lst_InsertItemGroup.add(newItem);  
                }   
                else if(item.ItemGroup__c != null){ 
                                                           //   system.debug('**Line Count: ProcessLineCount**: Final 2:'+ item.Product2.Name);
                                                              DebugLogs+= '**Line Count: ProcessLineCount**: Final 2:'+ item.Product2.Name;
                                                               DebugLogs += '\r\n';
                    newItem.ProductComponent__c = item.ProductComponent__c;
                    
                    lst_InsertItemGroup.add(newItem);
                }
                else{
                                                                //   system.debug('**Line Count: ProcessLineCount**: Final 3:'+ item.Product2.Name);
                    lst_Insert.add(newItem);
                }    
                

                
                                                         //if(!lst_Delete.contains(item)){
                    lst_Delete.add(item);
                                                         // } 
                
                 
                
                
            }

                                                            //update Map_Itemlist.get(LoopChunks);
        }


        
        
        try{
            insert lst_InsertItemGroup;
            
            for(OrderItem item: lst_InsertItemGroup){
                if(item.ProductType__c == 'Item Group'){                         
                    Map_IGLookup2.put(item.ProductEAN__c,Item.id);

                                                                //  system.debug('**Line Count: ProcessLineCount**: IG Update Final Grp 1:'+ item.Product2.Name);
                }
            }
            
            for(OrderItem item: lst_InsertItemGroup){ 
                
                                                                    //  system.debug('**Line Count: ProcessLineCount**: IG Update Final Grp 2a:'+ Map_IGLookup.get(item.ProductEAN__c));
                                                                    //  system.debug('**Line Count: ProcessLineCount**: IG Update Final Grp 2b:'+ Map_IGLookup2.get(item.ProductEAN__c));
                                                                    //  system.debug('**Line Count: ProcessLineCount**: IG Update Final Grp 2c:'+ item.ProductEAN__c);
                                                                        
                if(Map_IGLookup2.get(Map_IGLookup.get(item.ProductEAN__c)) != null && item.ProductType__c != 'Item Group'){
                    item.ItemGroup__c =    Map_IGLookup2.get(Map_IGLookup.get(item.ProductEAN__c));

                                                                //      system.debug('**Line Count: ProcessLineCount**: IG Update Final Grp 2d:'+ item.ItemGroup__c);
                                                                //      system.debug('**Line Count: ProcessLineCount**: IG Update Final Grp 2e:'+ item.id);
                   }
            }


            update lst_InsertItemGroup;
        }
        catch(exception e){
            system.debug('**Line Count: ProcessLineCount**: IG Update Final Grp 2 : Error:'+ e.getMessage());
            DebugLogs+= '**Line Count: ProcessLineCount**: IG Update Final Grp 2 : Error:'+ e.getMessage();

            HandleCustomException.LogException(e,newOrder.id);
        }


        try{

            system.debug('**Line Count: lst_Delete**'+lst_Delete.size());
                                                                                                        //system.debug('**Line Count: lst_Insert**'+lst_Insert.size());
                                                                                                    // update lst_OrdItem;       
                                                                                                    //  system.debug('**Line Count: CurOrder.MaxOrderLine__c**'+CurOrder.MaxOrderLine__c);
                                                                                                    //   system.debug('**Line Count: CurOrder.id**'+CurOrder.id);

                                                                                                    // lst_Insert.addAll(lst_InsertItemGroup);
                                                                                                        
                                                                                                        //insert lst_InsertItemGroup;

                                                                                                        //system.debug('**Line Count: Before Delete**'+lst_Delete);
                                                                                                    //    DebugLogs = '**Line Count: lst_Delete** '+lst_Delete.size();
                                                                                                    // system.debug('**Line Count: lst_Delete**'+lst_Delete.size());
                                                                                                        


                                                                                            /*
                                                                                                        set<String> Set_Dup = new set<String>();
                                                                                                        for(OrderItem i:lst_Delete){
                                                                                                            if(Set_Dup.contains(i.id)){
                                                                                                                DebugLogs+= '**Line Count: ProcessLineCount**: Duplicate:'+ i.id;
                                                                                                                DebugLogs += '\r\n';
                                                                                                            }
                                                                                                            else{
                                                                                                                Set_Dup.add(i.id);   
                                                                                                            }
                                                                                                        
                                                                                            */
            delete lst_Delete;
        // ErrorLog__c ErrorLog = new ErrorLog__c();
        //    ErrorLog.ExceptionMessage__c = DebugLogs;
        //    insert ErrorLog;
                                                                                                           

            insert lst_Insert;

            MaxOrderLine.LineCount__c = lineCount;
            MaxOrderLine.OrderTotal__c = CurOrder.TotalAmount;
            
            CurOrder.OrderImportLineCountSent__c = FIXEDLINECOUNT;
            CurOrder.MaxOrderLine__c = MaxOrderLine.id;
            CurOrder.ActivateforBatchProcessing__c=true;
            CurOrder.RelatedOrderActivationBlock__c = true; 
            Update CurOrder;
            
            List<Order> lstInsertedOrd = [Select ValidationErrorsOrder__c,ValidationErrorsOrderProducts__c from Order where id in: Set_OrdId];
            
            Integer Count=0, ActiveReady=0;
            for(Order ord:lstInsertedOrd){

                if(ord.ValidationErrorsOrder__c==0 && ord.ValidationErrorsOrderProducts__c==0){
                    ActiveReady++;
                }
                
                Count++;
            }
            MaxOrderLine.ActivationReadyCount__c = ActiveReady;
            MaxOrderLine.ExpectedActivationCount__c = Count;
            Update MaxOrderLine;
            
            
        }
        catch(exception e){
            system.debug('**Error**'+e.getMessage());
            HandleCustomException.LogException(e,CurOrder.id);
        }

    }


}