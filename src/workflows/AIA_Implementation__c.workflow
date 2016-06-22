<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AIA_UPDATE_STATUS</fullName>
        <field>Status__c</field>
        <literalValue>In-Progress</literalValue>
        <name>AIA_UPDATE STATUS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AIA_OWNER_CHANGE</fullName>
        <actions>
            <name>AIA_UPDATE_STATUS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED(OwnerId), LEFT(PRIORVALUE(OwnerId), 3) = &apos;00G&apos;, NOT(BEGINS(OwnerId, &quot;00G&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
