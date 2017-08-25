:Namespace XL
    (⎕IO ⎕ML ⎕WX)←1 1 3


    ∇ r←{larg}Load args;XL;books;range;sheet;book;file;i;Workbook;opened;sheets;Sheet;Range;xl;rc_tit;rc;TitleRows;GetAs;UseOLE;r2;dt;r1
     ⍝ Load Data from a book,sheet,range. Selections can be made or elided (⍬) at each level:
     ⍝                                                                                 mkrom 2008
     ⍝ book=⍬ means ActiveWorkbook, sheet=⍬ means ActiveSheet, range=⍬ means UsedRange
     ⍝    ActiveSheet='*' means all sheets
     ⍝
     ⍝ Examples:
     ⍝
     ⍝ LoadXL ⍬                                      (UsedRange of active Sheet)                    - needs OLE
     ⍝ LoadXL ⍬ '*'                                  (UsedRange of all sheets in ActiveWorkbook)    - needs OLE
     ⍝ LoadXL 'C:\Temp\Book1.xlsx' 'Sheet1' 'A1:C4'  (Selection at all levels)                      - uses Syncfucion'x XlsIo via Pierre Gilbert's sfExcel
     ⍝        if no sheet is specified (⍬≡2⊃args), we will read the first worksheet only!
     ⍝ opts LoadXL filename
     ⍝ GetAs: Number|Text|Value|Datatable|DatatableObject|sfExcel (return sfExcel-Object)
     
      →WindowsOnly↓0
      args←,(⊂⍣((0≠⊃⍴,args)∧1=≡args))args
      book sheet range←3↑args,⍬ ⍬ ⍬
      :If 0=⎕NC'larg' ⋄ larg←⍬ ⋄ :EndIf
      UseOLE←larg GetParam'UseOLE' 0
     
      :If UseOLE
          XL←⎕NEW'OleClient'(⊂'ClassName' 'Excel.Application')
          opened←0 ⍝ We did not open a book
     
     ⍝ --- Select or Open Book ---
     
          :If 0=⍴book ⍝ Current Book
              Workbook←XL.ActiveWorkbook
          :Else
              :If 0≠XL.Workbooks.Count ⍝ Currently open books
                  books←⌷XL.Workbooks
              :AndIf (⍴books)≥i←books.FullName⍳⊂book ⍝ Already open?
                  Workbook←i⊃books
              :Else
                  Workbook←XL.Workbooks.Open⊂book
                  opened←1
              :EndIf
          :EndIf
     
      ⍝ --- Select Sheet(s) ---
          :If 0=⍴,sheet ⍝ Current Sheet
              Sheet←XL.ActiveSheet
          :Else
              :If (,sheet)≡,'*' ⋄ Sheet←⌷Workbook.Sheets
              :Else ⋄ Sheet←Workbook.Sheets[⊂sheet] ⋄ :EndIf
          :EndIf
     
      ⍝ --- Select Range ---
          :If 0=⍴range
              Range←Sheet.UsedRange
          :Else
              Range←(,Sheet).{Range[⊂⍵]}⊂range ⍝ dfn needed in case Sheet has several elements
          :EndIf
     
          r←Range.{0::0 0⍴0 ⋄ Value2}0
     
          :If opened  ⍝ Close it if we opened it
              :Trap 0 ⍝ If workbook somehow damaged and close fails
                  Workbook.Saved←1
                  Workbook.Close ⍬
              :EndTrap
          :EndIf
          →0
      :Else
         ⍝ use sfExcel to read from file
          :If preFlightCheck=0   ⍝ should we trap the errors here? Guess we'll leave it to the user to :Trap around LoadXL...!
              TitleRows←larg GetParam'TitleRows' 0
              GetAs←1(819⌶)larg GetParam'GetAs' 'VALUE'
     
              xl←⎕NEW sfExcel
              :If 0<≢book   ⍝ if file was specified
                  xl.LoadFile book
                  :If ⍬≢sheet  ⍝ seems we have a sheetname
                      ⎕←xl.SetActiveWorksheet sheet
                  :EndIf
                  :If range≡⍬ ⋄ range←xl.UsedRange ⋄ :EndIf
                  :If range≡0 0 0 0 ⋄ r←0 0⍴0 ⋄ →0 ⋄ :EndIf  ⍝ not an XLS or empty...
     
                  :If 0<TitleRows         ⍝ retrieve title-rows first and adjust range (will use faster methods if GetAs is given)
                      rc←rc_tit←range
                      rc_tit[3]←rc_tit[1]+TitleRows
                      r1←xl.GetText2 rc_tit
                      rc[1]+←TitleRows
                      range←rc
                      'w/o title=',rc
                  :EndIf
     
                  :If GetAs≡'NUMBER' ⋄ r←xl.GetNumber2 range
                  :ElseIf GetAs≡'TEXT' ⋄ r←xl.GetText2 range
                  :ElseIf GetAs≡'VALUE' ⋄ r←xl.GetValue range
                  :ElseIf GetAs≡'DATATABLE' ⋄ dt←xl.ExportDataTable range ⋄ r←xl.DTtoApl dt
                  :ElseIf GetAs≡'DATATABLEOBJECT' ⋄ r←xl.ExportDataTable range
                  :ElseIf GetAs≡'SFEXCEL' ⋄ r←xl
                  :Else
                      r←xl.GetValue range     ⍝ or throw error if GetAs is not known?
                  :EndIf
     
                  :If 0<TitleRows
                  :AndIf (⊂GetAs)∊'NUMBER' 'TEXT' 'VALUE'
                      r←r1⍪r
                  :EndIf
                  :If GetAs≢'SFEXCEL' ⋄ xl.Dispose ⋄ :EndIf
              :EndIf
          :EndIf
      :EndIf
    ∇

    ∇ r←{larg}Save args;⎕ML;XL;books;range;sheet;book;file;i;Workbook;opened;sheets;Sheet;Range;created;data;eis;topleft;cell;xl
     ⍝ Save 2-dimensional matrix to (book,sheet,topleft). Selections can be made or elided (⍬) at each level:
     ⍝                                                                                                mkrom 2008
     ⍝ book=⍬ means ActiveWorkbook, sheet=⍬ means ActiveSheet, topleft=⍬ means CurrentCell
     ⍝
     ⍝ Examples:
     ⍝
     ⍝ SaveXL Data                                     (At CurrentCell in active Sheet)
     ⍝ SaveXL Data ⍬ ⍬ 'B7'                            (At B2 in CurrentSheet)
     ⍝ SaveXL Data ⍬ 'Sheet2' 'B2'                     (At B2 in Sheet2 of ActiveWorkbook)
     ⍝ SaveXL Data 'C:\Temp\Book1.xlsx' 'Sheet1' 'B2'  (Selection at all levels)
     ⍝    If workbook/sheet do not exist, they will be created.
     ⍝    If workbook is created, and sheet is named, it will ONLY have the named sheet
     ⍝    First 3 variants (that do not specify a filename with a distinguishable path) will automatically use OLE
     ⍝    to communicate with XLS (no chance to fulfill request oterwise)
     ⍝
     ⍝ larg contains optional parameters for more options, mainly related to the use of sfExcel
     ⍝
     ⍝ UseOLE=0|1: boolean value that controls whether or not to use OLE (the "old" method as opposed to sfExcel)
     ⍝ ReadFile=fully qualified filename: basefile to read (we will save under the name given in ⍵[1], but using
     ⍝           this technique you may read another file as "template" and replace specified cells)
     ⍝ "Data" can be an APL-Array OR an instance of sfExcel (as returned by 'GetAs' 'sfExcel'Load)
     
      ⎕ML←1
      →WindowsOnly↓0
     
      :If 0=⎕NC'larg' ⋄ larg←⍬ ⋄ :EndIf
      :If 2=⍴⍴args ⋄ args←,⊂args ⋄ :EndIf ⍝ Just a data matrix
      (data book sheet range)←4↑args,(⍴,args)↓(1 1⍴⊂'Wot?')⍬ ⍬ ⍬
      UseOLE←larg GetParam'UseOLE'(0=≡book) ⍝ use OLE if empty book
      :If UseOLE
     
          XL←⎕NEW'OleClient'(⊂'ClassName' 'Excel.Application')
          XL.DisplayAlerts←0 ⍝ avoid being prompted for anything
          opened←created←0 ⍝ we did not open a book
     
     ⍝ --- Select, Open or Create WorkBook ---
     
          :If 0=⍴book ⍝ Current Book
              :If 0=XL.Workbooks.Count
                  Workbook←XL.Workbooks.Add ⍬
                  created←1
              :Else
                  Workbook←XL.ActiveWorkbook
              :EndIf
          :Else
              :If 0≠XL.Workbooks.Count ⍝ Currently open books
                  books←⌷XL.Workbooks
              :AndIf (⍴books)≥i←books.FullName⍳⊂book ⍝ Already open?
                  Workbook←i⊃books
              :Else
                  :Trap 11
                      Workbook←XL.Workbooks.Open⊂book
                      opened←1
                  :Else
                      Workbook←XL.Workbooks.Add ⍬
                      created←1
                  :EndTrap
              :EndIf
          :EndIf
     
      ⍝ --- Select or Add Sheet ---
          :If 0=⍴,sheet ⍝ Current Sheet
              Sheet←XL.ActiveSheet
          :ElseIf (⊂sheet)∊(⌷Workbook.Sheets).Name
              Sheet←Workbook.Sheets[⊂sheet]
          :Else ⍝ Sheet not found, must be added
              Sheet←Workbook.Sheets.Add ⍬
              :If created
                  sheets←⌷Workbook.Sheets
                  ((~sheets.Name∊⊂Sheet.Name)/sheets).Delete ⍝ Delete all sheets in new book
              :EndIf
              Sheet.Name←sheet
          :EndIf
     
      ⍝ --- Select Range ---
          :If 0=⍴range ⋄ topleft←1 1
          :Else
              topleft←Sheet.Range[⊂range].(Row Column)
          :EndIf
     
          cell←{' '~⍨((2⊃⍵)⊃,(' ',⎕A)∘.,⎕A),⍕1⊃⍵}
          range←(cell topleft),':',cell topleft+(¯2↑1,⍴data)-1
          Sheet.Range[⊂range].Value2←data
     
          :If opened∨created  ⍝ Save and Close it if we opened it
              :Trap 0 ⍝ If workbook somehow damaged
                  :If created
                ⍝ We used to change xlsx format (51) into xls (56), then M$ changed that to 52/57
                ⍝ We now save in native format
                ⍝ :If Workbook.FileFormat=51 ⋄ Workbook.FileFormat←56 ⋄ :EndIf
                      Workbook.SaveAs⊂book
                  :Else
                      Workbook.Save
                  :EndIf
                  Workbook.Close ⍬
              :EndTrap
          :EndIf
     
      :ElseIf preFlightCheck=0
          :If 0<≢rf←larg GetParam'ReadFile' ''
              xl←⎕NEW sfExcel
              xl.LoadFile rf
              :If 0<≢sheet
                  xl.SetActiveWorksheet sheet
              :EndIf
          :Else
              :If 0<≢book
                  :If ⎕NEXISTS book  ⍝ if file exists
                      xl←⎕NEW sfExcel
                      xl.LoadFile book
                      :If 0<≢sheet
                          xl.SetActiveWorksheet sheet
                      :Else
                          xl.SetActiveWorksheet 1
                      :EndIf
                  :Else   ⍝ nope - new file
                      xl←⎕NEW sfExcel 1  ⍝ one sheet
                      :If 0<≢sheet
                          1 xl.SetWorksheetName sheet
                      :EndIf
                  :EndIf
              :ElseIf ~isInstance data  ⍝ if we did not get an instance, create one
                  xl←⎕NEW sfExcel
              :EndIf
          :EndIf
     
          :If isInstance data  ⍝ data is an instance
              xl←data   ⍝ just create a ref and continue to work with it
          :Else  ⍝ no, it's not (the common case): transfer data into the sheet
              :If 0=≢range    ⍝ no range specified - compute it
                  range←'A1:',xl.ConvertRCtoA1⍴data
              :EndIf
              range xl.SetValue data
          :EndIf
     
          :Select 1(819⌶)3⊃⎕NPARTS book  ⍝ depending on extension
          :Case '.CSV' ⋄ xl.SaveAsCSV book
          :Case '.XLS' ⋄ xl.SaveAsXls book
          :Case '.XLSX' ⋄ xl.SaveAsXlsx book
          :Case '.PDF' ⋄ xl.SaveAsPdf book
          :CaseList '.HTM' '.HTML' ⋄ xl.SaveAsHtml book
          :EndSelect
     
          :If ~isInstance data ⋄ xl.Dispose ⋄ :EndIf  ⍝ clear instance if it is not needed
          r←0
      :EndIf
     
    ∇

    :section Helpers

    ∇ {z}←preFlightCheck;z;data;urls;url;script;path;em;lm
        ⍝ This function checks if the sfExcel-Class is available and if not, will retry to download it
        ⍝ and load it. Result "z" indicates success (=0) or failure (≠0) of this.
        ⍝ In case of failure, fn will also ⎕SIGNAL an error and provide some hopefully helpful
        ⍝ info in ⎕DMX.
        ⍝ When shipping apps that rely on this code, you should make sure to include sfexcel.dyalog -
        ⍝ this stuff about downloading etc. is mainly intended as a convenience for the developer :-)
     
      →(9=⎕NC'sfExcel')/z←0 ⍝ only execute if sfExcel is not yet loaded, so dev can load it in advance (or perhaps even save it with his WS)
     
     
     
      SourceFile←{ ⍝ Get pathname to sourcefile for ref ⍵
          file←⊃(4∘⊃¨(/⍨)(⍵≡⊃)¨)5177⌶⍬ ⍝ ⎕FIX
          ''≡file:⍵.SALT_Data.SourceFile ⍝ SALT
          file
      }
     
      path←1⊃⎕NPARTS SourceFile ⎕THIS
     
      :If ~⎕NEXISTS script←path,'sfExcel.dyalog'
          {}⎕FIX'file://',(2 ⎕NQ'.' 'GetEnvironment' 'dyalog'),'/Library/Conga/HttpCommand.dyalog'
          data←HttpCommand.Get'http://aplwiki.com/sfExcel'
          :If ~z←200≠data.HttpStatus   ⍝ ⎕en 1
                 ⍝ get all URLs of attachments related to sfExcel
              urls←('link rel="Appendix" title="sfExcel.*" href="(.*)">'⎕S'\1')data.Data
                 ⍝ use the last URL and replace "view" with "get" to retrieve the file
                 ⍝ (or maybe it would be better to always get a specific version that we know is compatible?)
              url←'http://aplwiki.com',('view'⎕R'get')⊃¯1↑urls
                 ⍝ decode the argument-separator &
              url←('amp;'⎕R'')url
                 ⍝ get it
              data←HttpCommand.Get url
              :If 1=z←1+200≠data.HttpStatus    ⍝ ⎕en 2
                  :Trap 0
                      data.Data ⎕NPUT script
                      ⎕←'Downloaded sfExcel and saved as ',script   ⍝ output some info into the session
                      z←0
                  :Else   ⍝ ⎕en 3
                      em←'Error while attempting to write ',script
                      ↑⎕DM
                      z←3
                  :EndTrap
              :Else
                  em←'Error downloading sfExcel from APLWiki: ',data.HttpStatusMsg
                  em,←(⎕UCS 13),'URL used was ',url
              :EndIf
          :Else
              em←'Error retrieving the sfExcel-Page on APLWiki: ',data.HttpStatusMsg
          :EndIf
          :If z≠0
              lm←⊂'sfExcel was not found and the automatic install failed.'
              lm,←⊂'Please retrieve it from http://aplwiki.com/sfExcel'
              lm,←⊂'and save it as ',script
              ⎕SIGNAL⊂('Message'(∊((⊂em),lm),¨⎕UCS 10))('EN'z)
          :EndIf
      :EndIf
     
      {}⎕FIX'file://',script  ⍝ load it
    ∇

    ∇ r←list GetParam(nam deflt);nms
      :If 0∊⍴list ⋄ r←deflt ⋄ →0 ⋄ :EndIf
      :If (⎕DR' ')=⎕DR 1⊃list ⋄ list←,⊂list ⋄ :EndIf
      nms←1(819⌶)1↑¨list ⋄ nam←1(819⌶)nam
      r←2⊃(nms⍳⊂,⊂nam)⊃list,⊂'*'deflt
    ∇

    ∇ r←WindowsOnly
      :If ~r←'Win'≡3↑⊃'.'⎕WG'APLVersion'
          ⎕←'This function runs on Windows only'
      :EndIf
    ∇

    ∇ r←{ref}isInstance ao
      →0↓⍨r←9.2∊⎕NC⊂'ao'
      :If 0≠⎕NC'ref'
          r←ref∊∊⎕CLASS ao
      :EndIf
    ∇


    :endsection

:EndNamespace
⍝)(!GetParam!mbaas!2017 8 25 11 0 16 0!0
⍝)(!Load!mbaas!2017 8 25 11 0 16 0!0
⍝)(!Save!mbaas!2017 8 25 11 1 13 0!0
⍝)(!WindowsOnly!mbaas!2017 8 25 11 0 16 0!0
⍝)(!isInstance!mbaas!2017 8 25 11 0 16 0!0
⍝)(!preFlightCheck!mbaas!2017 8 25 11 0 16 0!0
