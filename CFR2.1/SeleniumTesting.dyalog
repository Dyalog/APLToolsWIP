:class TestConfReg
    :field public shared Config←⎕ns''
    :field public shared CSV_Data
    :field public shared DLLPATH←''
        :field public shared home←''

    lower←{0(819⌶)⍵}
    UPPER←{1(819⌶)⍵}


    ∇ Init
      :Access private shared
⍝      #.Config←getJSON{((⍵⍳'.')↑⍵),'json'}SourceFile ⎕THIS  ⍝ waiting for ⌶
      ⎕←'Loading required scripts:'
      R←HOME
      Config←getJSON{((⍵⍳'.')↑⍵),'json'}SourceFile ⎕THIS
     ⍝ ⎕SE.UCMD'Load ',Config.MiServerPath,'/Utils/Files -target=#'   ⍝ required by Countries...
      #.⎕FIX'file://',Config.MiServerPath,'/Utils/Files.dyalog'
     ⍝ ⎕SE.UCMD'Load ',Config.MiServerPath,'/Utils/Strings -target=#'   ⍝ required by ConfApp
      #.⎕FIX'file://',Config.MiServerPath,'/Utils/Strings.dyalog'
      ⍝⎕SE.UCMD'Load ',R,'/API/ConfApp.dyalog -target=#'
      #.⎕FIX'file://',R,'/API/ConfApp.dyalog'
      ⍝⎕SE.UCMD'Load ',R,'/Code/Countries.dyalog -target=#'
      #.⎕FIX'file://',R,'/Code/Countries.dyalog'
      ⍝⎕SE.UCMD'Load ',Config.SPATH,'Selenium.dyalog -target=#'
      #.⎕FIX'file://',Config.SPATH,'Selenium.dyalog'
      app←⎕NEW #.ConfApp (HOME,'Data/')
    ∇


    ∇ R←getJSON file
      :Access public
      R←0(7159⌶)1⊃⎕NGET file
    ∇

    ⍝ following from AB:
      SourceFile←{ ⍝ Get pathname to sourcefile for ref ⍵
          file←⊃(4∘⊃¨(/⍨)(⍵≡⊃)¨)5177⌶⍬ ⍝ ⎕FIX
          ''≡file:⍵.SALT_Data.SourceFile ⍝ SALT
          file
      }

    ∇ R←HOME
      :Access public shared
    ⍝ home-directory of the script
      R←SourceFile ⎕THIS
    R←1⊃1 ⎕NPARTS R
    ∇

    ∇ r←Run;S;result;data;i
      :Access public shared
      ⍝ test CFR against the actual registrations and check if we get similar results...
          
      :If 0=≢Config.⎕NL-2 ⋄ Init ⋄ :EndIf
     
      S←#.Selenium
      S.DLLPATH←Config.DLLPATH
      S.InitBrowser''
      app←⎕NEW #.ConfApp(HOME,'Data/')
      '→⎕lc+1   ⍝ continue after you made sure that ConfReg is running and listening on port ',⍕Config.PORT
      ∘∘∘
      TheItems←app.items
      TheItems←(TheItems.id_conf=Config.conf_id)/TheItems   ⍝ only those relevant for the current conf...
      :if ∨/'xls'∊¯5↑Config.TestFile
     'xl'⎕WC'oleclient' 'excel.application'
     wb←xl.Workbooks.Add⊂Config.(HOMEDIR,'/',TestFile)
     data←wb.Sheets[1].UsedRange.Value2
⍝     xl.Quit
     wb.Close ⍬
     data←1↓[1]data ⍝ remove first row with headings for headings ;-)
data←{⍵≡⎕NULL: '' ⋄ ⍵}¨data
      :else 
          data←(⎕CSV⍠'Separator' ';') HOME,'/Data/',CSV_Data
            :endif

      FindCol←data[1;]∘⍳
      GetField←{(FindCol⊂⍵)⊃data[i;]}             ⍝ get contents of field
      GetNField←{⍬⍴∊(//)⎕VFI⍕(FindCol⊂⍵)⊃data[i;]}  ⍝ get numeric field
      IntoField←{⍺←⍵ ⋄ ⍵ S.SendKeys GetField ⍺}   ⍝ sends data from field ⍺ of "data" into formfield ⍵ (⍺ is optional, default will be ⍵)
⍝      data[;FindCol⊂'CountryCode']←{⍵≡'UK':'GB' ⋄ ⍵}¨data[;FindCol⊂'CountryCode']  ⍝ replace "UK" with "GB" as correct ISO 31661alpha-2-code
     testok←⍬
      :For i :In 1↓⍳1↑⍴data 
          S.GoTo'http://localhost:',(⍕Config.PORT),'/index?conf_id=',⍕Config.conf_id
          S.Click'cfracc_section_1'
          IntoField'DelegateName'
'CompanyName'          IntoField'Company'
'Email'          IntoField'EMail'
          IntoField'Address'
          IntoField'Town'
          IntoField'Region'
          IntoField'Postcode'
     
          S.Click'Country_chosen'    ⍝ handling the chosen-field is a bit more tricky...
          obj←S.BROWSER.FindElementByCssSelector⊂'.chosen-search input'       ⍝ the Search has no id, so we need a selector to create the obj beforehand
⍝          obj S.SendKeys #.Countries.GetNameFromCode(FindCol⊂'CountryCode')⊃data[i;]   ⍝ the database-data needs to be translated back...
          obj S.SendKeys GetField'Country'
          obj S.SendKeys S.Keys.Return
S.ExecuteScript'document.querySelector("#cfracc_section_2").previousElementSibling.children[1].click();'
         ⍝ determine roomtype
          :Select lower 2↑GetField'RoomType'   ⍝ 2 characters more than sufficient to distinguish ;-)
          :Case 'si' ⋄ rt←'Single'
              id_acc←TheItems.((_Type=0)∧_RoomType=1)/TheItems.id  ⍝ ids for accommodation-items...
          :Case 'do' ⋄ rt←'Sharing with '
              :If ∨/'another'⍷GetField'RoomType'
                  rt,←'another delegate'
                  id_acc←TheItems.((_Type=0)∧_RoomType=2)/TheItems.id
              :Else
                  rt,←'guest/spouse'
                  id_acc←TheItems.((_Type=0)∧_RoomType=3)/TheItems.id
              :EndIf
          :Case 'no' ⋄ rt←'Non-Residential'
          :Else ⋄ ⎕←'Unknown roomtype: ',GetField'RoomType'
          :EndSelect
          ⎕DL 1.2
          'pckg_1'S.Select rt
          ⎕DL 1.2
          'pSelPack'S.Select'Custom'     ⍝ always select custom-package (and rely on optimisation to pick best price!)
          ⎕DL 1.2
⍝          S.Click'cfracc_section_3'
S.ExecuteScript'document.querySelector("#cfracc_section_3").previousElementSibling.children[1].click();'
          ⎕dl .8

          ⍝z←'Y'=GetField'YHotel'
          z←{⍬⍴GetNField'cb',⍕⍵}¨20 21 22 23 24 25  ⍝ cb20..25=Accommodation
          {S.Click'cb_',⍕⍵}¨z/id_acc
          ⍝z←'Y'=GetField'YDays'
          z←{⍬⍴GetNField'cb',⍕⍵}¨11 12 13 14 15 16 ⍝ cb11..16=Attendance

          ⍝ they will have meals on all days they attend: (=will get banquet if they attend that day)
          {S.Click'cb_',⍕⍵}¨z/(TheItems._Type=Config.type_confdays)/TheItems.id    ⍝ User Meeting
        ⍝  {S.Click'cb_',⍕⍵}¨z/TheItems.(_Type=5)/TheItems.id   ⍝ Meals - no extra meals were offered at '16conf!
          ⎕DL 1
          :If ×≢ GetField'Courses'⍝ if courses selected
          :andif ∨/z[1 6]         ⍝ and days booked  
          workshops←(∨/¨TheItems.Title{∨/¨⍵⍷¨⊂⍺}¨⊂','#.Strings.split GetField'Courses')/TheItems
          workshops←(∊(⊂z[1 6]){((1⊃⍵.Title)∊⍺/'ST')}¨workshops)/workshops ⍝ stupid simple & pragmatic test to see if user attends days of courses!
              {S.Click'radio_',(⍕⍵._Type),'_',⍕⍵.id}¨workshops
          :EndIf       
          ⎕dl 1.5
          ⎕←'Total=',total←S.getText'total'
          :If (#.Strings.tonum total)=GetNField'Invoice Amount'
          testok,←1
              ⎕←'### Everything fine!'
          :Else
          testok,←0
              ⎕←'=================== Something is different! === Testcase=',⍕i
              ⎕SE.Dyalog.Utils.disp data[1,i;]
              'Total vs. Invoice Amount:',total,' / ',,GetField'Invoice Amount'
          :EndIf
          ∘∘∘
     
      :EndFor
⍝          S.('APLedit'SendKeys Keys.Return)
⍝  ⌈        result←'ClassName'S.Find'result'
⍝          r←result S.WaitFor'5 7 9' '1 2 3+4 5 6 failed'
    ∇


:Endclass
