' ============================================================
' remove_zero_rows.bas
' VBA Macro: Multi-Sheet Zero Row Removal
'
' Iterates through all worksheets in the active workbook.
' On each sheet, deletes rows where:
'   - Column B is empty OR equal to 0
'   - Column A has a value (product ID is present)
'
' Intended use: cleaning order files before upload to ERP.
' ============================================================

Sub RemoveZeroRowsFromAllSheets()
    
    Dim ws As Worksheet
    Dim totalDeleted As Long
    totalDeleted = 0
    
    ' Turn off screen updating and alerts for speed
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    
    ' Loop through all worksheets
    For Each ws In ThisWorkbook.Worksheets
        
        Dim deleted As Long
        deleted = RemoveZeroRowsFromSheet(ws)
        totalDeleted = totalDeleted + deleted
        
        If deleted > 0 Then
            Debug.Print "Sheet '" & ws.Name & "': deleted " & deleted & " rows"
        End If
        
    Next ws
    
    Application.ScreenUpdating = True
    Application.DisplayAlerts = True
    
    MsgBox "Done! Total rows deleted: " & totalDeleted, vbInformation, "Zero Row Remover"

End Sub


Private Function RemoveZeroRowsFromSheet(ws As Worksheet) As Long
    
    Dim lastRow As Long
    Dim i As Long
    Dim deletedCount As Long
    
    ' Find last row with data in column A
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    
    ' Loop backwards (critical when deleting rows)
    For i = lastRow To 1 Step -1
        
        ' Process only rows where column A has a value (product ID exists)
        If Not IsEmpty(ws.Cells(i, 1).Value) Then
            
            ' Delete if column B is empty or zero
            If IsEmpty(ws.Cells(i, 2).Value) Or ws.Cells(i, 2).Value = 0 Then
                ws.Rows(i).Delete
                deletedCount = deletedCount + 1
            End If
            
        End If
        
    Next i
    
    RemoveZeroRowsFromSheet = deletedCount

End Function