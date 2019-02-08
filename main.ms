Experience Main {

    String text label("Enter IP or website domain. If you leave empty, you will get info related with your public IP") as Label
    
    String userIp label("Enter IP or website domain") as TextField
     
    Decision getInfo action("MainContext.getInfo") label("Get info")
    
    
    String output label("")

//    Decision showLocation action("MainContext.showLocation") label("Show location on map") 
    
    Array<Marker> locationInMap as MapView
}


Model MyInfo{

    String query
    String country
    String countryCode
    String region
    String regionName
    String city
    String zip
    Double lat
    Double lon
    String timezone
    String isp
    String org
    Bool mobile // ?not used
    Bool proxy // not used ?
    //String AS  //<--- problemas con este atributo
}

//Model Utils {

//    Bool getInfofromAPI (String query){
        
//        return true

//    }

//}


RuleContext MainContext {


    Rule getInfo {
    
    
        Main m = broker.ui.getDataSource()

        //Llamada a servicio HTTP con único parámetro "Query String" configurado de tipo String.
        
         MyInfo mi 

        try {
            //MyIP mi = service.MyIPService.call("json")
            if(m.userIp != null){
                mi = service.getSiteOrIPInfo.call(m.userIp)
            }else{
                mi = service.getInfo_IPAPIService.call()
            }
            
           // {"as":"AS28114 Alpha Tel S.A.","lat":-32.9167,"lon":-68.8333,"status":"success"}
            
            if (mi != null) {
                //Petición HTTP exitosa
               m.output = "IP : "+ mi.query +"\n"+"Country: " + mi.country +"\n"+"Country code: " + mi.countryCode +"\n"+"Region: " + mi.region +"\n"+"Region name: " + mi.regionName +"\n"+"City: " + mi.city +"\n" +"\n"+"ZIP: " + mi.zip +"\n"+"Timezone: " + mi.timezone +"\n"+"ISP: " + mi.isp +"\n"+"Organization: " + mi.org +"\n"
               
               
               // create map, add location
               if(mi.lat != null && mi.lon != null){
                
                broker.ui.showAlert("debug", "entro al if ")
                
                if(m.locationInMap == null){
                    broker.ui.showAlert("debug", "mapa nulo ") // no funciona indica que mapa es nulo :-(
                    
                
                }
                
                if (m.locationInMap.size() > 0) {
                    m.locationInMap.removeAll()
                }
                
                String markerName = "public IP location"
                
                Location loc = Location(latitude: mi.lat, longitude: mi.lon)
                
                Marker eventMarker = Marker(location: loc, title: markerName, showBubble: true, leftIcon: "https://goo.gl/Sg9RG9")
                
                m.locationInMap.add(eventMarker)
                
               }
               
                
               
            }    
        } catch (e) {
            // Error in HTTP call 
            if (e.httpStatusCode() > 0) {
                //excepción http
                broker.ui.showAlert("HTTP ERROR, CODE: " + e.httpStatusCode().toString(), "Description: " + e.httpErrorMessage())
            } else {
                //Exception 
                broker.ui.showAlert("Unexpected exception", "Description: " + e.reason())
            }
        }

    } // getInfo
    

    
    //Rule showLocation{     }
    

    
}


