<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ProspectingCloseDate</fullName>
        <field>ProspectingCloseDate__c</field>
        <formula>now()</formula>
        <name>ProspectingCloseDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ProspectingCloseDateToNull</fullName>
        <field>ProspectingCloseDate__c</field>
        <name>ProspectingCloseDateToNull</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ProspectingDate</fullName>
        <field>ProspectingDate__c</field>
        <formula>now()</formula>
        <name>ProspectingDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sold_Date</fullName>
        <field>Sold_Date__c</field>
        <formula>Now()</formula>
        <name>Update Sold Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AIA Set Opportunity Sold Date</fullName>
        <actions>
            <name>Update_Sold_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Sold</value>
        </criteriaItems>
        <description>Mark Opportunity as Sold</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ProspectingCLoseDateToNull</fullName>
        <actions>
            <name>ProspectingCloseDateToNull</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CloseProspect__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Prospecting</value>
        </criteriaItems>
        <description>This rule makes the field to blank value when the close prospecting check box is false</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ProspectingCloseDate</fullName>
        <actions>
            <name>ProspectingCloseDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CloseProspect__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Prospecting</value>
        </criteriaItems>
        <description>This rules captures the close date of prospecting Opportunity</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ProspectingDate</fullName>
        <actions>
            <name>ProspectingDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Prospecting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Prospecting</value>
        </criteriaItems>
        <description>This captures the date of the prospecting opportunity</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
