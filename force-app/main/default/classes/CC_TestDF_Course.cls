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
public class CC_TestDF_Course {
    
	public static List<Course__c> createRecords(Integer numberOfRecords){
		List<Course__c> returnedRecords = createVariableRecords(numberOfRecords);
		insert returnedRecords;
		return returnedRecords;
	}

	public static List<Course__c> createRecordsWithTypeName(Integer numberOfRecords,String RecordTypeName){
		List<Course__c> returnedRecords = createVariableAccountsWithTypeName(numberOfRecords, RecordTypeName);
		insert returnedRecords;
		return returnedRecords;
	}

	public static List<Course__c> createVariableRecords(Integer numberOfRecords){
		List<Course__c> returnedRecords = new List<Course__c>();
		for(Integer i = 0 ; i<numberOfRecords ; i++){
			Course__c auxRecord = new Course__c();
			fillSystemRequireFields(auxRecord, i);
			returnedRecords.add(auxRecord);
		}
		return returnedRecords;
	}

	public static List<Course__c> createVariableAccountsWithTypeName(Integer numberOfRecords,String RecordTypeName){
        Schema.DescribeSObjectResult R = Course__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RTs = R.getRecordTypeInfos();
        Id RecordTypeId;
        for(Schema.RecordTypeInfo rti : RTs ){
            if(RecordTypeName == rti.getDeveloperName()){
                RecordTypeId = rti.getRecordTypeId();
            }
        }

		List<Course__c> returnedRecords = new List<Course__c>();
		for(Integer i = 0 ; i<numberOfRecords ; i++){
			Course__c auxRecord = new Course__c();
            auxRecord.RecordTypeId = RecordTypeId;
			fillSystemRequireFields(auxRecord, i);
			returnedRecords.add(auxRecord);
		}
		return returnedRecords;
	}

	private static void fillSystemRequireFields(Course__c record){
		record.Name = 'Name';
	}

	private static void fillSystemRequireFields(Course__c record, Integer index){
		record.Name = 'Name ' + index;
	}

	private static void fillSystemRequireFields(Course__c record, Integer index, String name){
		record.Name = name + ' ' + index;
	}

	private static void fillFields(Course__c a){
		
	}
	
	
}