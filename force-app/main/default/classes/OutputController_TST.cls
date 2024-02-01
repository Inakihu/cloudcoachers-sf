/*
@author Cloud Coachers S.L.
@date 06/02/2018
@description Clase de test de outputController.

<pre>
FECHA                 AUTOR                    ACCION
06/02/2018            IHU                      Creación
</pre>
*/
@isTest
private class OutputController_TST
{
	@isTest
	static void itShould()
	{
		OutputController testController = new OutputController();
		testController.valueCtrl = 10000;
		Decimal d = testController.valueCtrl;
		testController.typeCtrl = 'Number';
		String s = testController.typeCtrl;
		testController.decimalPlacesCtrl = 2;
		Integer i = testController.decimalPlacesCtrl;
		testController.fieldCustomSetting = 'Test';
		s = testController.fieldCustomSetting;

		testController.getObj();
	}
}