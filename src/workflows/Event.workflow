<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AIA_Open_Enrollment_Meeting_3_Day_Not_Full_Notification</fullName>
        <ccEmails>testaia@carefirst.com</ccEmails>
        <description>AIA Open Enrollment Meeting 3 Day Not Full Notification</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_Open_Enrollment_Meeting_3_Day_Not_Full_Notification</template>
    </alerts>
    <rules>
        <fullName>AIA Open Enrollment Meeting</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>AIA: Open Enrollment Meeting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.Meeting_Status1__c</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <description>AIA Open Enrollment Meeting</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>AIA_Open_Enrollment_Meeting_3_Day_Not_Full_Notification</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Event.EndDateTime</offsetFromField>
            <timeLength>-3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
