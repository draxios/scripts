Module modSCCM

    'SCCM objects
    Public oSMS
    Public oLocator
    Public oResults

    'SCCM default config values
    Public SiteServer As String = ".com"
    Public SiteCode As String = ""
    Public COLFOLDER = ""


    Function AddMachineToCollection(strComputer, AddingCollectionId) As Boolean

        AllowEvents()
        WriteToLog("Attempting to run AddMachineToCollection function.")
        Dim bResult As Boolean = False

        Try

            'Return the resourceID of the machine
            Dim sResourceID = FindMachine(strComputer)
            Dim oCollection
            Dim oCollectionRule

            'Set the machine collection
            oCollection = oSMS.Get("SMS_Collection.CollectionID=" & """" & AddingCollectionId & """")

            'Create a membership rule
            oCollectionRule = oSMS.Get("SMS_CollectionRuleDirect").SpawnInstance_()

            'Define the membership rules properties
            oCollectionRule.ResourceClassName = "SMS_R_System"

            'HAD A AN ISSUE WITH NOT GETTING THE RESOURCEID WHICH IS AN INT 
            'BUG HERE TYPE MISMATCH
            oCollectionRule.ResourceID = sResourceID

            'MIGHT NEED TO RE-ENABLE TRY ERROR HANDLING FOR BOGUS NAMES
            '-----------------------------------------------------------

            WriteToLog("ATTEMPTING SOFTWARE ON " & UCase(strComputer))
            oCollection.AddMembershipRule(oCollectionRule)
            bResult = True
            WriteToLog(UCase(strComputer) & " ADDED TO SOFTWARE COLLECTION " & sResourceID)

        Catch ex As Exception
            MsgBox("The workstation addition failed." & vbNewLine & "Reason: " & ex.Message, MsgBoxStyle.Critical)
            WriteToLog(UCase(strComputer) & " WAS NOT ADDED TO SOFTWARE COLLECTION: " & ex.Message)
            bResult = False
        End Try

        Return bResult

    End Function

    'Connect to the SCCM server
    Public Sub ConnectToSCCM(progress As ToolStripProgressBar)

        progress.Style = ProgressBarStyle.Marquee
        AllowEvents()

        Dim blnReturn As Boolean = False
        oLocator = CreateObject("WbemScripting.SWbemLocator")
        AllowEvents()

        Try
            'Connect to the SCCM Site Server
            oSMS = oLocator.ConnectServer(SiteServer, "root\sms\site_" & SiteCode)
            AllowEvents()
            WriteToLog("USER CONNECTED SUCCESSFULLY TO (" & SiteCode & "): " & SiteServer)

            'Set security settings for on-going connection to SCCM
            oSMS.Security_.ImpersonationLevel = 3
            oSMS.Security_.AuthenticationLevel = 6

            blnReturn = True
        Catch ex As Exception
            MsgBox("Error occurred while attempting to connect to SCCM." & vbNewLine & "Reason: " & ex.Message, MsgBoxStyle.Critical)
            'WriteToLog("USER FAILED TO CONNECTED TO SERVER (" & SiteCode & "): " & SiteServer & " - ERROR: " & ex.Message)
            blnReturn = False
            AllowEvents()
            End
        End Try

        'set the global connection status
        AreWeConnectedToSCCM = blnReturn
        AllowEvents()
        progress.Style = ProgressBarStyle.Continuous
    End Sub

    Function LoadSubCollections(strColFolder) As ArrayList

        Dim strSQLQuery As String = ""
        Dim strResult As String = ""
        Dim foundCollections As New ArrayList

        Dim objSubColCol
        Dim objSubColItem
        Dim intIDSSCNID
        Dim colQueryCollectionResults

        strSQLQuery = "SELECT ContainerNodeID FROM SMS_ObjectContainerNode WHERE Name = '" & strColFolder & "' AND ObjectType = 5000"

        objSubColCol = oSMS.ExecQuery(strSQLQuery)

        For Each objSubColItem In objSubColCol
            intIDSSCNID = objSubColItem.ContainerNodeID
        Next

        colQueryCollectionResults = oSMS.ExecQuery("SELECT * FROM SMS_Collection")

        For Each objSubColItem In colQueryCollectionResults
            If Strings.Left(objSubColItem.Name, 3) = "IDS" Then
                foundCollections.Add(objSubColItem.Name & ";" & objSubColItem.CollectionID)
            End If
        Next

        If foundCollections.Count = 0 Then
            MsgBox("No collections were returned. Try reconnecting.")
        End If

        WriteToLog("Collections loaded into SCCM Window.")
        LoadSubCollections = foundCollections

    End Function


    Function FindMachine(strComputer)

        Dim WasItFound As Boolean = False
        Dim strBufferID As Integer = 0

        Try

            'Query WMI for the machine ID
            oResults = oSMS.ExecQuery("SELECT * FROM SMS_R_System WHERE Name = '" & strComputer & "'")

            For Each oResourceID In oResults
                strBufferID = oResourceID.ResourceID
                WasItFound = True
            Next

            WriteToLog("Trying to find " & strComputer & " in collection: " & WasItFound)

            'return the result ID of the machine
            If WasItFound = False Then
                FindMachine = 0
                WriteToLog("NOT FOUND: " & strBufferID)
            Else
                FindMachine = strBufferID
                WriteToLog("FOUND: " & strBufferID)
            End If

        Catch ex As Exception
            MessageBox.Show("There was an error while trying to find the machine." & vbNewLine & "Error: " & ex.Message & vbNewLine & "Reason: Lost connection, bad input, or non-admin user.")
            WriteToLog("Error while trying to find the machine :" & ex.Message)
            FindMachine = 0
        End Try

    End Function

    Function IsItInTheCollection(COLID, UserToCheck)

        Dim strSQLQuery As String = ""
        Dim FoundFlag As Boolean = False
        Dim objQueryCol
        Dim objPC

        strSQLQuery = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='" & COLID & "'"
        'strSQLQuery = "SELECT * from SMS_CollectionMember_a where ResourceID='EH100036'"
        'strSQLQuery = "select v_FullCollectionMembership.CollectionID As 'Collection ID', v_Collection.Name As 'Collection Name', v_R_System.Name0 As 'Machine Name' from v_FullCollectionMembership JOIN v_R_System on v_FullCollectionMembership.ResourceID = v_R_System.ResourceID JOIN v_Collection on v_FullCollectionMembership.CollectionID = v_Collection.CollectionID Where v_R_System.Name0='2UA1390VN8'"

        Try

            objQueryCol = oSMS.ExecQuery(strSQLQuery)

            For Each objPC In objQueryCol
                'msgbox UCase(objPC.Name) & "=" & UCase(UserToCheck)
                If UCase(objPC.Name) = UCase(UserToCheck) Then
                    FoundFlag = True
                End If
            Next

            WriteToLog("Was " & UserToCheck & " in " & COLID & "? - " & FoundFlag)

            If FoundFlag = True Then
                IsItInTheCollection = True
                WriteToLog("WAS FOUND IN COLLECTION")
            Else
                IsItInTheCollection = False
                WriteToLog("WAS NOT FOUND IN COLLECTION")
            End If

        Catch ex As Exception
            WriteToLog("IsItInTheCollection() failed to run correctly - " & ex.Message)
            IsItInTheCollection = False
        End Try

    End Function

End Module
