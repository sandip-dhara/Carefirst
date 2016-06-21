<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AIA_External_Assignee_Notification_From_PRF_NEW</fullName>
        <description>AIA_External_Assignee_Notification_From_PRF_NEW</description>
        <protected>false</protected>
        <recipients>
            <field>External_Assignee__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_External_Assignee_Notification_From_PRF_NEW</template>
    </alerts>
    <alerts>
        <fullName>AIA_Internal_Assignee_Notification_From_PRF_NEW</fullName>
        <description>AIA_Internal_Assignee_Notification_From_PRF_NEW</description>
        <protected>false</protected>
        <recipients>
            <field>PRF_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_Internal_Assignee_Notification_From_PRF_NEW</template>
    </alerts>
    <alerts>
        <fullName>AIA_Workplan_TaskAssgined</fullName>
        <ccEmails>Chidananda.nagaraj@infosys.com</ccEmails>
        <description>AIA Workplan TaskAssgined</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_Workplan_Assignment</template>
    </alerts>
    <alerts>
        <fullName>AIA_Workplan_Task_Assgined</fullName>
        <ccEmails>Chidananda.nagaraj@infosys.com</ccEmails>
        <description>AIA - Workplan Task Assgined</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/AIA_Workplan_Assignment</template>
    </alerts>
    <alerts>
        <fullName>External_Assignee_Notification_For_Workplan_Assignment_Reminder_From_PRF</fullName>
        <description>External Assignee Notification For Workplan Assignment Reminder From PRF</description>
        <protected>false</protected>
        <recipients>
            <field>External_Assignee__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/External_Users_Notification_for_WorkPlan_Assignment_Reminder_From_PRF</template>
    </alerts>
    <alerts>
        <fullName>Internal_Assignee_Notification_For_Workplan_Assignment_Reminder_From_PRF</fullName>
        <description>Internal Assignee Notification For Workplan Assignment Reminder From PRF</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/Internal_Users_Notification_for_WorkPlan_Assignment_Reminder_From_PRF</template>
    </alerts>
    <fieldUpdates>
        <fullName>AIA_WOrkplan_Assignment_status_Completed</fullName>
        <field>Date_Completed__c</field>
        <formula>Now()</formula>
        <name>AIA WOrkplan Assignment status Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>External_Assignee_Reminder_From_PRF</fullName>
        <description>Internal Assignee Reminder From PRF</description>
        <field>Reminder__c</field>
        <literalValue>0</literalValue>
        <name>External Assignee Reminder From PRF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Internal_Assignee_Reminder_From_PRF</fullName>
        <field>Reminder__c</field>
        <literalValue>0</literalValue>
        <name>Internal Assignee Reminder From PRF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reminder_Date_Time_Update_From_PRF</fullName>
        <description>Reminder Date/Time Update From PRF</description>
        <field>Reminder_Date_Time__c</field>
        <name>Reminder Date/Time Update From PRF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Date_Accepted</fullName>
        <field>Date_Accepted__c</field>
        <formula>NOW()</formula>
        <name>Set Date Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Date_Completed</fullName>
        <field>Date_Completed__c</field>
        <formula>NOW()</formula>
        <name>Set Date Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AIA - Workplan Task Assigned</fullName>
        <actions>
            <name>AIA_Workplan_Task_Assgined</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(TEXT(Status__c) = &apos;Sent&apos; &amp;&amp;   Workplan_Type_Task__r.Send_Notification__c, ISBLANK(Proposal_Request_Form__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AIA - Workplan Task Owner Changed</fullName>
        <actions>
            <name>AIA_Workplan_TaskAssgined</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(OwnerId),ISBLANK(Proposal_Request_Form__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AIA Set Date Accepted in Workplan Assignment</fullName>
        <actions>
            <name>Set_Date_Accepted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AIA_Workplan_Assignment__c.Status__c</field>
            <operation>equals</operation>
            <value>Accepted</value>
        </criteriaItems>
        <description>AIA Set Date Accepted in Workplan Assignment</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AIA Set Date Completed in Workplan Assignmnet</fullName>
        <actions>
            <name>Set_Date_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AIA_Workplan_Assignment__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>AIA Set Date Completed in Workplan Assignmnet</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AIA Workplan Assignment Status Completed</fullName>
        <actions>
            <name>AIA_WOrkplan_Assignment_status_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>AIA_Workplan_Assignment__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AIA_External_Assignee_Notification_From_PRF</fullName>
        <actions>
            <name>External_Assignee_Notification_For_Workplan_Assignment_Reminder_From_PRF</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>External_Assignee_Reminder_From_PRF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workplan Assignment Creation from PRF to External Assignee</description>
        <formula>AND(NOT(ISBLANK(External_Assignee__c)),(ISBLANK( Reminder_Date_Time__c )),Reminder__c = true, NOT(ISBLANK(Proposal_Request_Form__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AIA_External_Assignee_Notification_From_PRF_NEW</fullName>
        <actions>
            <name>AIA_External_Assignee_Notification_From_PRF_NEW</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workplan Assignment to External Assignee</description>
        <formula>NOT(ISBLANK(External_Assignee__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AIA_External_Assignee_TimeBased_Notification_From_PRF</fullName>
        <active>true</active>
        <description>AIA External Assignee TimeBased Notification From PRF</description>
        <formula>AND(NOT(ISBLANK( External_Assignee__c )),Reminder__c = true, NOT(ISBLANK(Reminder_Date_Time__c)),NOT(ISBLANK(Proposal_Request_Form__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>External_Assignee_Notification_For_Workplan_Assignment_Reminder_From_PRF</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>External_Assignee_Reminder_From_PRF</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Reminder_Date_Time_Update_From_PRF</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>AIA_Workplan_Assignment__c.Reminder_Date_Time__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AIA_Internal_Assignee_Notification_From_PRF</fullName>
        <actions>
            <name>Internal_Assignee_Notification_For_Workplan_Assignment_Reminder_From_PRF</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Internal_Assignee_Reminder_From_PRF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workplan Assignment Creation from PRF to Internal Assignee</description>
        <formula>AND((ISBLANK( External_Assignee__c )),(ISBLANK( Reminder_Date_Time__c )),Reminder__c = true, NOT(ISBLANK(Proposal_Request_Form__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AIA_Internal_Assignee_Notification_From_PRF_NEW</fullName>
        <actions>
            <name>AIA_Internal_Assignee_Notification_From_PRF_NEW</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AIA_Workplan_Assignment__c.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>AIA_Workplan_Assignment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PRF Assignment</value>
        </criteriaItems>
        <description>Internal Assignee Notification From PRF</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AIA_Internal_Assignee_TimeBased_Notification_From_PRF</fullName>
        <active>true</active>
        <description>Internal Assignee TimeBased Notification From PRF</description>
        <formula>AND((ISBLANK( External_Assignee__c )),Reminder__c = true,  NOT(ISBLANK(Reminder_Date_Time__c)),NOT(ISBLANK(Proposal_Request_Form__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Internal_Assignee_Notification_For_Workplan_Assignment_Reminder_From_PRF</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Internal_Assignee_Reminder_From_PRF</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Reminder_Date_Time_Update_From_PRF</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>AIA_Workplan_Assignment__c.Reminder_Date_Time__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
