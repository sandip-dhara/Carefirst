<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_For_High_Priority_Cases</fullName>
        <description>Email Alert For High Priority Cases</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/SLA_For_Case</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_For_Low_Priority_Cases</fullName>
        <description>Email Alert For Low Priority Cases</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/SLA_For_Case</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_For_Medium_Priority_Cases</fullName>
        <description>Email Alert For Medium Priority Cases</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/SLA_For_Case</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_For_Urgent_Priority_Cases</fullName>
        <description>Email Alert For Urgent Priority Cases</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/SLA_For_Case</template>
    </alerts>
    <alerts>
        <fullName>Email_To_IssueOwner_High_Priority</fullName>
        <description>If an Issue with Priority = &quot;High&quot; has not been closed within 1 business day from the time of creation, the Application sends a notification to the Issue owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/SLA_For_Case</template>
    </alerts>
    <alerts>
        <fullName>Email_To_IssueOwner_Low_Priority</fullName>
        <description>If the Case Closed age is less than 7 days with priority &quot;Low&quot; then email will be trigger to Case Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/SLA_For_Case</template>
    </alerts>
    <alerts>
        <fullName>Email_To_IssueOwner_Medium_Priority</fullName>
        <description>If an Issue with Priority = &quot;Medium&quot; has not been closed within 3 business days from the time of creation, the Application sends a notification to the Issue owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/SLA_For_Case</template>
    </alerts>
    <alerts>
        <fullName>Email_To_IssueOwner_Urgent_Priority</fullName>
        <description>If an Issue with Priority = &quot;Urgent&quot; has not been closed within 4 hours from the time of creation, the Application sends a notification to the Issue owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AIA_Email_Templates/SLA_For_Case</template>
    </alerts>
    <rules>
        <fullName>AIA Email Notification for High Priority Cases</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>High</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>AIA Account Issue</value>
        </criteriaItems>
        <description>If an Issue (Case) with Priority = &quot;High&quot; and it is not closed within 1 week from the time of creation  then application will send an email to the Issue(Case) Onwer</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Alert_For_High_Priority_Cases</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AIA Email Notification for Low Priority Cases</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>AIA Account Issue</value>
        </criteriaItems>
        <description>If an Issue (Case) with Priority = &quot;Low&quot; and it is not closed within 1 week from the time of creation  then application will send an email to the Issue(Case) Onwer</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Alert_For_Low_Priority_Cases</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AIA Email Notification for Medium Priority Cases</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Medium</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>AIA Account Issue</value>
        </criteriaItems>
        <description>If an Issue (Case) with Priority = &quot;Medium&quot; and it is not closed within 1 week from the time of creation  then application will send an email to the Issue(Case) Onwer</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Alert_For_Medium_Priority_Cases</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AIA Email Notification for Urgent Priority Cases</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>AIA Account Issue</value>
        </criteriaItems>
        <description>If an Issue with Priority = Urgent has not been closed within 4 hours from the 
time of creation, the Application sends a notification to the Issue owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Alert_For_Urgent_Priority_Cases</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
