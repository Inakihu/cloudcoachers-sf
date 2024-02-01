/**
* @author Cloud Coachers S.L.
* @date 17/02/2021
* @description Clase de test para la generacion del Object Course.
* @group Test
<pre>
FECHA                 AUTOR                    ACCION
17/02/2021            IHU                      Creación.

</pre>
*/
@isTest
public class CC_TestDF_Course_Attendance {

	public static List<Course_Attendance__c> createRecords(List<Account> lstAlumnos, Id courseId ){
		List<Course_Attendance__c> returnedRecords = createVariableRecords(lstAlumnos, courseId);
		insert returnedRecords;
		return returnedRecords;
	}

	public static List<Course_Attendance__c> createVariableRecords(List<Account> lstAlumnos, Id courseId){
		List<Course_Attendance__c> returnedRecords = new List<Course_Attendance__c>();
		for(Account acc : lstAlumnos){
			Course_Attendance__c auxRecord = new Course_Attendance__c();
			System.debug('acc: ' + acc + ' - ' + acc.PersonContactId);
			fillSystemRequireFields(auxRecord, acc.PersonContactId, courseId);
			returnedRecords.add(auxRecord);
		}
		return returnedRecords;
	}

	private static void fillSystemRequireFields(Course_Attendance__c record, Id contactId, Id courseId){
        record.Attendant__c = contactId;
        record.Course__c = courseId;
	}	
	
}