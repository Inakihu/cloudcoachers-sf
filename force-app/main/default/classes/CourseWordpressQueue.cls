/**
 * @description       : 
 * @author            : IHU - ihernando@cloudcoachers.com
 * @group             : 
 * @last modified on  : 04-11-2021
 * @last modified by  : IHU - ihernando@cloudcoachers.com
 * Modifications Log 
 * Ver   Date         Author                              Modification
 * 1.0   04-05-2021   IHU - ihernando@cloudcoachers.com   Initial Version
**/
public with sharing class CourseWordpressQueue implements Queueable, Database.AllowsCallouts{
    private List<Course__c> courseListWPQueueable;
    
    public  courseWordpressQueue(List<Course__c> courseListWP) {
            this.courseListWPQueueable = courseListWP;
    }

    public void  execute(QueueableContext context) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        WPConfig__c wPConfig = WPConfig__c.getInstance();
        String secreto=wPConfig.Secret__c;
        String timeStamp = string.valueOf(Datetime.Now().getTime() / 1000);
        String hash=encodeSecret(secreto,timeStamp);
        request.setEndpoint(wPConfig.endPoint__c); 
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization',hash);
        String bodyrequest=('{"data":'+JSON.serialize(this.courseListWPQueueable)+',"timeStamp":"'+timeStamp+'"}');
        request.setBody(bodyrequest);
        HttpResponse response = http.send(request);
        List<ObjectCustomWP> courseListJson=new List<ObjectCustomWP>();
        List<Course__c> courseUpdateList = new List<Course__c>();
        boolean error = false;
        if (response.getStatusCode() == 200) {
            try {
                courseListJson =(List<ObjectCustomWP>)JSON.deserialize(response.getBody(),list<ObjectCustomWP>.class);// Parse the JSON response 
            } catch (Exception e) {
                error = true;
                for (Course__c objectWPFail : courseListWPQueueable) {
                    Course__c course = new Course__c ();
                    course.Id=objectWPFail.id;
                    course.Wordpress_Integration_Error_Message__c=e.getMessage();
                    course.Wordpress_Integration_Status__c='Error';
                    course.Wordpress_Last_Synchronization__c=Date.today();
                    courseUpdateList.add(course);
                }
            }
            if(error == false){
                for (Integer i = 0 ; i < courseListJson.size() ; i++){
                    if (courseListJson[i].Status != false) {
                        if(String.isNotBlank(courseListWPQueueable[i].id)){
                            Course__c course = new Course__c ();
                            course.Event_Id_Wordpress__c = courseListJson[i].Event_Id_Wordpress;
                            course.Id = this.courseListWPQueueable[i].Id;
                            course.Wordpress_Integration_Error_Message__c = courseListJson[i].Wordpress_Integration_Error_Message;
                            course.Wordpress_Integration_Status__c = courseListJson[i].Wordpress_Integration_Status;
                            course.Wordpress_Last_Synchronization__c = Datetime.valueOf(courseListJson[i].Wordpress_Last_Synchronization);
                            courseUpdateList.add(course);
                        }
                    }   
                }
            }
            if (!courseUpdateList.isEmpty()) {
                update courseUpdateList;
            }
        }else {
            for (Course__c objectWPFail : courseListWPQueueable) {
                Course__c course = new Course__c ();
                course.Id=objectWPFail.id;
                course.Wordpress_Integration_Error_Message__c = response.getStatus();
                course.Wordpress_Integration_Status__c = 'Error';
                course.Wordpress_Last_Synchronization__c = Date.today();
                courseUpdateList.add(course);
            }
            if (!courseUpdateList.isEmpty()) {
                update courseUpdateList;
            }  
        }
    }
    
    public class ObjectCustomWP {
		public String IdSF;	//IDSF 
		public Integer Event_Id_Wordpress;//Id number
		public String Wordpress_Integration_Error_Message;	// Strnig
        public String Wordpress_Integration_Status;	//Confirmed/Error/Resend
        public String  Wordpress_Last_Synchronization; //date('Y-m-d H:i:s')
        public Boolean Status;
    }
    
    public static String encodeSecret(String secreto, String timestamp) {
        Blob requestBlob = Blob.valueOf(secreto + timestamp);
        Blob hash = Crypto.generateDigest('MD5', requestBlob);
        String requestSignature = EncodingUtil.convertToHex(hash);
        return requestSignature;
    }
}


// data action tipo update,mostrar error// editar layout campo de  error
//