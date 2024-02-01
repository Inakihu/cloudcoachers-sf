/**
 * @File Name          : SendEmailWithAttachments.cls
 * @Description        : 
 * @Author             : Oriol Farras - ofarras@cloudcoachers.com
 * @Group              : 
 * @Last Modified By   : IHU - ihernando@cloudcoachers.com
 * @Last Modified On   : 1/29/2020, 3:42:51 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    20/1/2020   Oriol Farras - ofarras@cloudcoachers.com     Initial Version
**/
public with sharing class SendEmailWithAttachments {

    @InvocableMethod (
        label = 'Change Object Record Type'
        description = 'Change Record Type by Developer Name'
    )
    public static void executeSendEmailWithAttachments(List<Request> requests) {
        system.debug(JSON.serialize(requests));
        executeSendEmailWithAttachmentsAsync(JSON.serialize(requests));
        
    }

    @future
    public static void executeSendEmailWithAttachmentsAsync(string JSONRequests) {

        List<Request> requests = new List<Request>();
        system.debug(JSONRequests);
        requests = (List<request>)JSON.deserializeStrict(JSONRequests, List<Request>.class);

        //Lista con las respuestas
        List<Response> responses = new List<Response>();

        system.debug('***getCpuTime(antes de coger las templates)***'+Limits.getCpuTime());
        //Buscamos los ids de las templates y creamos un mapa apara añadir en el correo
        Map<String,Id> emailtemplatesmap = getTemplates();
        system.debug('***getCpuTime(despues de coger las templates) ***'+Limits.getCpuTime());
          
        //Lista con los mensajes para cada asistente
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        
        //creamos un mapa para relacionar un curso con sus attachments
        Map<Id,List<ContentVersion>> attachmentcurso =  new Map<Id,List<ContentVersion>>();

        //Para cada solicitud que hemos recibido del PB
        system.debug('***getCpuTime(antes de recorre las requests) ***'+Limits.getCpuTime());
          
        Map<id,request> attendantsRequestMap = new Map<id,request>();

        for (request request:requests){

            attendantsRequestMap.put(request.idAsistente,request);
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTemplateId(emailtemplatesmap.get(request.tipoAdjuntos));  //Id de la plantilla que utilizamos
            message.setWhatId(request.idAsistente); // Objeto que utilizamos en la plantilla
            message.setTargetObjectId(request.idContacto); // A quien vamos a enviar el corereo

            system.debug('***getCpuTime(antes de buscar las attachments) ***'+Limits.getCpuTime());
            //si no tenemos los attachments para el curso los buscamos
            if (!attachmentcurso.containsKey(request.idProducto)){
                List<ContentVersion> contentVersions = getContentVersions(request.idProducto);
                if (contentVersions.size()>0){
                    attachmentcurso.put(request.idProducto,contentVersions);
                }                
            }
            system.debug('***getCpuTime(despues de buscar las attachments) ***'+Limits.getCpuTime());

            //Si hay attachments para el curso se los añadimos al correo
            List<Messaging.EmailFileAttachment> emailattachments = new List<Messaging.EmailFileAttachment>();
            if (attachmentcurso.containskey(request.idProducto)){
                for (ContentVersion attachment:attachmentcurso.get(request.idProducto)){
                    if (request.tipoAdjuntos == attachment.Title.left(2))
                    {
                        // Creamos el attachment
                        Messaging.EmailFileAttachment emailattachment = new Messaging.EmailFileAttachment();
                        emailattachment.setBody(attachment.VersionData); // El body del attachment
                        emailattachment.setFileName(attachment.Title.Substring(3,attachment.Title.length())+'.'+attachment.FileType); // El nombre del archivo menos el prefijo del tipo de adjunto
                        emailattachment.setContentType(getContentType(attachment.FileType)); // El content type del archivo TODO - Determinar el contenttype con APEX
                        emailattachment.setInline(false); // Donde aparecera el archivo si inline (true) o como attachment (false).
                        emailattachments.add(emailattachment);   
                    }
                }
                if (emailattachments.size()>0){
                    // adjuntamos los ficheros al mensaje
                    message.setFileAttachments(emailattachments);
                }
            } 
            
          
            messages.add(message);
        } 
        system.debug('***getCpuTime(despues de recorre las requests) ***'+Limits.getCpuTime());

        //Si ha mensajes que enviar
        
        if (messages.size()>0){
            system.debug('***getCpuTime(antes de enviar los emails) ***'+Limits.getCpuTime());
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages,false);
            system.debug('***getCpuTime(despues de enviar los emails) ***'+Limits.getCpuTime());

            system.debug('***getCpuTime(antes de tratar las respuesta) ***'+Limits.getCpuTime());
            //creamos un set con todos los ids de los asistentes para indicar si hemos enviado el correo
            
            //Validamos si el envio ha sido correcto y si no lo añadimos en un mapa con los errores
            Map<id,Response> maprequestfail = new Map<id,Response>();
            for(Messaging.SendEmailResult result:results){
                if (!result.isSuccess()){
                    for (Messaging.SendEmailError error:result.getErrors()){
                        Response respuesta = new Response();
                        respuesta.errorMessage = error.getMessage();
                        respuesta.success = result.isSuccess();
                        maprequestfail.put(ID.valueof(getAsistenteContacto(error.getTargetObjectId(),requests)),respuesta);
                        System.debug(LoggingLevel.ERROR,'error-->'+error);
                    }
                }
            }

            //Indicamos los casos en que se ha enviado satisfactoriamente el correo y los errores encontrados
            Set<Id> idAsistentes = attendantsRequestMap.keySet();
            List<Course_Attendance__C> asistentes = [Select id,name from Course_Attendance__C where id in :idAsistentes];
            List<Course_Attendance__C> asistentesupd = new List<Course_Attendance__C>();
            for (Course_Attendance__C asistente:asistentes){
                if (maprequestfail.containsKey(asistente.id)){
                    asistente.SendEmailError__c = maprequestfail.get(asistente.id).errorMessage;
                    asistentesupd.add(asistente);
                }else{
                    if (attendantsRequestMap.get(asistente.id).tipoAdjuntos=='EX'){
                        asistente.Exam_Sent__c = true;
                        asistentesupd.add(asistente);
                    }
                    if (attendantsRequestMap.get(asistente.id).tipoAdjuntos=='DC'){
                        asistente.Documentation_Sent__c = true;
                        asistentesupd.add(asistente);
                    }
                 }
            } 
            //Actualizamos los asistentes
            if (asistentesupd.size()>0){
                update asistentesupd;
            }
            
            system.debug('***getCpuTime(despues de tratar las respuesta) ***'+Limits.getCpuTime());
        }
       
        
        //Tratar la respueta
        //return(responses);
    } 


 /**
    *   description inner class del objeto de salida del metodo invocable
    */   
    public class Request {

        @InvocableVariable(
            label='Tipo adjuntos (EX,DC)' 
            description='Tipo de adjuntos que vamos a mandar, valores EX=Examenes  y DC=Docuemntacion' 
            required=true
        )
        public String tipoAdjuntos;

        @InvocableVariable(
            label='Asistentes' 
            description='Asistente a quien vamos a enviar el adjunto' 
            required=true
        )
        public Id idAsistente;

        @InvocableVariable(
            label='Contacto' 
            description='Contacto a quien vamos a enviar el email' 
            required=true
        )
        public Id idContacto;


        @InvocableVariable(
            label='Producto' 
            description='Producto de donde vamos a sacar los adjuntos' 
            required=true
        )
        public Id idProducto;


    }

    /**
    *   @description inner class del objeto de salida del metodo invocable
    */
    public class Response {

        @InvocableVariable(
            label = 'Mensaje de error'
            description = 'El mensaje de error'
        )
        public String errorMessage;

        @InvocableVariable(
            label = 'Is Success'
            description = 'Enviado con exito'
        )
        public Boolean success;
    }


    /***************** PRIVATE METHODS *********************/
    private static Map<String,Id> getTemplates(){

        Map<String,Id> emailtemplatesmap = new Map<String,Id>();
        List<String> templatesnames = new List<String>();
        Map<String,String> emailPrefixByNAme = new Map<String,String>();

        //Nos traemos los custom setting con las plantillas y sus prefijos.ApexPages
        List<SendEmail_Setting__mdt> sendEmail_Settings = [select File_Prefix__c,TemplateName__c from SendEmail_Setting__mdt];
        for (SendEmail_Setting__mdt sendEmail_Setting:sendEmail_Settings ){
            //Rellenamos lo nombre a buscar y creamos un mapa para asociar los prefijos
            templatesnames.add(sendEmail_Setting.TemplateName__c);
            emailPrefixByNAme.put(sendEmail_Setting.TemplateName__c,sendEmail_Setting.File_Prefix__c);
        }
        //Buscamo las templates que hemos configurado en los custom settings y añadimos en el mapa de salida <prefijo archivo,id de la template>
        List<EmailTemplate> emailtemplates = [SELECT id,DeveloperName FROM EmailTemplate WHERE DeveloperName in :templatesnames];
        for (EmailTemplate emailtemplate:emailtemplates){
           emailtemplatesmap.put(emailPrefixByNAme.get(emailtemplate.DeveloperName),emailtemplate.id);
        } 
        
        return emailtemplatesmap;
    }

    private static List<Contentversion> getContentVersions(Id idProducto){
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        //creamos un mapa para relacionar un curso con sus attachment
        Set<Id> contentDocsLinksIds = new Set<Id>();
        List<ContentDocumentLink> contentDocLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :idProducto];
        for ( ContentDocumentLink contentDocLink:contentDocLinks)
        {
            contentDocsLinksIds.add(contentDocLink.ContentDocumentId);
        }
        if (contentDocsLinksIds.Size()>0){
            Set<Id> contentDocumentsIds = new Set<Id>();
            List<ContentDocument> contentDocs = [SELECT LatestPublishedVersionId FROM ContentDocument where id in :contentDocsLinksIds];
            for ( ContentDocument contentDoc:contentDocs)
            {
                contentDocumentsIds.add(contentDoc.LatestPublishedVersionId);
            }
            contentVersions = [SELECT Id, VersionData, Title,FileType FROM ContentVersion WHERE Id in :contentDocumentsIds];
        }

        return contentVersions;
    }


    public static String getContentType(String filetype){
        String contenttype;
        switch on filetype.toLowerCase() {
            when  'zip'{
                contenttype = 'application/zip';
            }
            when  'pdf'{
                contenttype = 'application/pdf';
            }
            when else {
                contenttype = '';
            }
        }
        System.debug('Filetype-->'+filetype+', content-type-->'+contenttype);
        return contenttype;
    }

    public static String getAsistenteContacto(id idcontacto,List<Request> requests){
        for (Request request:requests){
            if (request.idContacto == idcontacto){
                return request.idAsistente;
            }
        }
        return '';
    }
}