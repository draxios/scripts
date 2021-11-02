    Public Sub FindWorkstation(ByVal PCname As String)

        AddToConsole("Running FindWorkstation()")

        Dim strSQLQuery As String = ""
        Dim objSystemCol, objSystemItem


        strPC = PCname
        strSQLQuery = "SELECT ResourceID,ADSiteName FROM SMS_R_System WHERE NetbiosName = '" & strPC & "'"
        objSystemCol = objSWbemServices.ExecQuery(strSQLQuery)

        strResourceID = "0"

        For Each objSystemItem In objSystemCol
            strResourceID = objSystemItem.ResourceID
            strADSiteName = objSystemItem.ADSiteName
        Next

        If strResourceID = "0" Then
            isPCinSCCM = False
            AddToConsole(strPC & " was not found in SCCM, skipping.")
            'UpdateStatusLabel(strPC & " was not found in SCCM, skipping.")
        Else
            isPCinSCCM = True
            strADSiteName = Strings.Mid(strADSiteName, 1, 7)               ' strip off -SITE from ADSiteName, i.e. 1000291-SITE
            AddToConsole(strPC & " was found in SCCM.")
            'UpdateStatusLabel(strPC & " was found in SCCM.")
        End If

        AddToConsole("Finished FindWorkstation()")
    End Sub
