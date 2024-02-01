/**
* @author Cloud Coachers S.L.
* @date 30/11/2017
* @description Clase de test para la generacion del Object Account.
* @group Test
<pre>
FECHA                 AUTOR                    ACCION
30/11/2017            IHU                      Creación.

</pre>
*/
@isTest
public class CC_TestDF_Account {

	public static List<Account> createAccounts(Integer numberOfAccounts){
		List<Account> returnedAccounts = createVariableAccounts(numberOfAccounts);
		insert returnedAccounts;
		return returnedAccounts;
	}

	public static List<Account> createAccountsWithTypeName(Integer numberOfAccounts, String RecordTypeName){
		List<Account> returnedAccounts = createVariableAccountsWithTypeName(numberOfAccounts, RecordTypeName);
		insert returnedAccounts;
		return returnedAccounts;
	}

	public static List<Account> createVariableAccounts(Integer numberOfAccounts){
		List<Account> returnedAccounts = new List<Account>();
		for(Integer i = 0 ; i<numberOfAccounts ; i++){
			Account auxAccount = new Account();
			fillSystemRequireFields(auxAccount, i);
			fillBillingAddress(auxAccount);
			returnedAccounts.add(auxAccount);
		}
		return returnedAccounts;
	}

	public static List<Account> createVariableAccountsWithTypeName(Integer numberOfAccounts, String RecordTypeName){
		Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RTs = R.getRecordTypeInfos();
        Id RecordTypeId;
        for(Schema.RecordTypeInfo rti : RTs ){
			if(rti.getDeveloperName() == RecordTypeName ){
				RecordTypeId = rti.getRecordTypeId();
            }
        }
		List<Account> returnedAccounts = new List<Account>();
		for(Integer i = 0 ; i < numberOfAccounts ; i++){
			Account auxAccount = new Account();
			auxAccount.RecordTypeId = RecordTypeId;
			switch on RecordTypeName {
				when 'PersonAccount' {
					fillSystemRequireFieldsPersonAccount(auxAccount, i);
				}
				when else {
					fillSystemRequireFields(auxAccount, i);
				}
			}
			
			fillBillingAddress(auxAccount);
			returnedAccounts.add(auxAccount);
		}
		return returnedAccounts;
	}

	private static void fillSystemRequireFields(Account a){
		a.Name = 'Name';
		//a.Razon_Social__C ='Razon Social ';
	}

	private static void fillSystemRequireFieldsPersonAccount(Account a){
		a.LastName = 'Name';
		a.PersonEmail = 'test@cloudcoachers.com';
	}

	private static void fillSystemRequireFields(Account a, Integer index){
		a.Name = 'Name ' + index;
	}

	private static void fillSystemRequireFieldsPersonAccount(Account a, Integer index){
		a.LastName = 'Name ' + index;
		a.PersonEmail = 'test@cloudcoachers.com';
	}

	private static void fillSystemRequireFields(Account a, Integer index, String name){
		fillSystemRequireFields(a,index);
		a.Name = name + ' ' + index;
		a.PersonEmail = 'test@cloudcoachers.com';
	}
	private static void fillSystemRequireFieldPersonAccounts(Account a, Integer index, String name){
		fillSystemRequireFields(a,index);
		a.LastName = name + ' ' + index;
		a.PersonEmail = 'test@cloudcoachers.com';
	}

	private static void fillBillingAddress(Account a){
		a.BillingStreet = 'Castellana 27';
		a.BillingPostalCode = '12345';
		a.BillingState = 'Madrid';
		a.BillingCountry = 'Spain';
		a.BillingCity = 'Madrid';
	}
	
	
}