/*
@author Cloud Coachers S.L.
@date 06/02/2018
@description Controlador para poder mostrar los datos con un outputField con un formato especifico. Esta clase necesita el el custom setting  

<pre>
FECHA                 AUTOR                    ACCION
06/02/2018            IHU                      Creación
</pre>
*/
public without sharing class OutputController {
	
	public Decimal valueCtrl{get;set;}
	public String typeCtrl{get;set;}
	public Integer decimalPlacesCtrl{get;set;}
	public String fieldCustomSetting{get;set;}

	public FormatValue__c getObj(){
		assignFieldCustomSetting();
		FormatValue__c obj = new FormatValue__c();
		obj.put(fieldCustomSetting,valueCtrl);
		return obj;
	}

	private void assignFieldCustomSetting(){
		fieldCustomSetting = typeCtrl + '_' + decimalPlacesCtrl + '__c';
	} 
}