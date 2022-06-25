:class ConfApp
    :field public confs

    :field public packages
    :field public items
    :field public i2p
    :field public itemtypes
    :field private DataDir ← ''
    :field private Texts←0 0⍴' '

    :section General tools
    novat←{⍵÷1+⍺×0.01}   ⍝ vat {} price
⍝ novat probably not needed - possibly only when storing things in DB. Keep it meanwhile...
    jsonClone←{(7159⌶)0(7160 ⌶) ⍵}  ⍝ re-create JSON-Object ⍵

    ∇ ns AddIDNspan fieldnames;n
⍝ fieldnames has 3 elemes: names of field with
⍝ start/end/duration. First 2 must exist, 3d will be defined.
⍝ suffix "TS_IDN" automatically appended
      fieldnames←fieldnames,¨'TS_IDN' 'TS_IDN' '_IDN'
      :For n :In ns
          n⍎(3⊃fieldnames),'←{(⍵[1]-1)+⍳1+-/⌽⍵}',¯1↓∊2↑fieldnames,¨','
      :EndFor
    ∇

    ∇ R←{apicall}getJSON file
      :Access public
      R←0(7159⌶)#.Files.GetText file
      :If 2=⎕NC'apicall'
      :AndIf apicall
          R←0 ''R    ⍝ return different format if called through API-Interface
      :EndIf
    ∇


    :endsection General tools

    ∇ make0
      :Access public
      :Implements constructor
      :If 0=⎕NC'#.Boot.ms'   ⍝ we're run as an APLProcess (w/o MiServer-Environment)
      '#.Boot.ms'⎕ns''
          #.Boot.MSRoot←∊1 ⎕NPARTS(1⊃⎕NPARTS ⎕WSID),'..\'
          #.Boot.AppRoot←'InValidPath:'  ⍝ just something that won't work...
          #.Boot.(ConfigureDatasources ms)
      :EndIf
    ∇

    ∇ make1 path
      :Access public
      :Implements constructor
⍝ read the JSON files with our data and do some basic transformations/reformatting of data:
      make0
      Init path
    ∇

    ∇ {r}←Init path
      :Access public
      r←0 ''⍬
      :If ~×≢DataDir←path
             ⍝ no path provided - try to figure out where this file was stored (in a {app}/Code-dir) and go to "./../Data"
             ⍝p←SourceFile ⎕this
             ⍝∘∘∘
          ⎕SIGNAL'Constructor must be called with a path as argument!'
      :EndIf
      'Called init with DataDir=',path
     
      confs←getJSON path,'confs.json'
      confs.GridRows←{'#'#.Strings.split ⍵}¨confs.GridRows
      confs AddIDNspan'Start' 'End' 'Duration'
      confs AddIDNspan'GridStart' 'GridEnd' 'GridDuration'  ⍝ Grid-Duration = date-range for hotel-nights!
     
      items←getJSON path,'items.json'
      ⍝   items.(_Price+←_PriceAccommodation)   ⍝ add all price-components to _Price
      ⍝ items._PriceNoVat←confs._VAT[confs.id⍳items.id_conf]novat items._Price
      items.Picked←0
      items.MiControl←⊂''
      items AddIDNspan'SlotStart' 'SlotEnd' 'SlotDuration'
      items.HotelNights←items{(∨/'Accommodation'⍷⍺.Title)∧((⍵.id⍳⍺.id_conf)⊃⍵.GridDuration_IDN)∊⍺.SlotDuration_IDN}¨⊂confs
      items.AttDays←items{(~∨/∊('Accommodation' 'Banquet')⍷¨⊂⍺.Title)∧((⍵.id⍳⍺.id_conf)⊃⍵.GridDuration_IDN)∊⍺.SlotDuration_IDN}¨⊂confs
     
⍝          items.IncludedIn←⊂⍳0
⍝          :for i :in (0<≢items.nvIncludes)/items
⍝              z←items.id⍳i.nvIncludes
⍝              items[z].IncludedIn,¨←i.id
⍝          :endif
     
      itemtypes←getJSON path,'itemtypes.json'
      i2p←getJSON path,'items2packages.json'
     
      packages←getJSON path,'packages.json'
      packages.CurrPrefix←(⊂confs){(⍺.id⍳⍵.id_conf)⊃⍺.CurrPrefix}¨packages  ⍝ currency-symbol
      packages.CurrSuffix←(⊂confs){(⍺.id⍳⍵.id_conf)⊃⍺.CurrSuffix}¨packages
      default←⎕NS'' ⋄ default.HotelNights←(1⊃items.HotelNights)×0
      ⍝ determine HotelNights for every package - apologies for the one-liner ;)
      packages.HotelNights←(⊂items i2p){default←⎕NS'' ⋄ default.HotelNights←(1⊃1⊃⍺).HotelNights×0 ⋄ ∨⌿↑(((1⊃⍺),default)[(1+⍴1⊃⍺),(1⊃⍺).id⍳((2⊃⍺).id_package=⍵.id)/(2⊃⍺).id_item]).HotelNights}¨packages
     
      ⍝ ConditionCostTypes is a nice little beast: it is defined in the XLS as "t1←t2⋄[t3←t4]", for example 16←14 (read: "16 if 14" and that means:
      ⍝ if we find a CostType 14 has been applied already, then this package will add costtype 16.
      ⍝ This is used to create additional cost when selecting a TH workshop as an add-on to packages that do not include TH WS.
      packages.ConditionalCostTypes←{~×≢⍵:⍵ ⋄ {{⍬⍴#.Strings.tonum ⍵}¨'←'#.Strings.split ⍵}¨('⋄'#.Strings.split ⍵)}¨packages.ConditionalCostTypes
     
⍝          packages._PriceNoVat←(⊂confs){⍵._Price÷1+⍺[⍺.id⍳⍵.id_conf]._VAT×0.01}¨packages
      ⍝:Else
      ⍝    r←1(⍕⎕DM)''
      ⍝    ⎕←'error in init:' ⋄ ⎕DM
      ⍝:EndTrap
    ∇


    ∇ R←GetConfs status
      :Access public
    ⍝ returns all active conferences
    ⍝ perhaps add some HTML with a Conf-Description?!
      R←0 ''({(⍵._Status=status)⌿⍵}confs)
    ∇

    ∇ R←{InternalCall}FormatDays(conf days);wd;mn
⍝ iConfDays←APIdo('FormatDays' (Conference_id(YDays='Y') ))
⍝ days=bool / refers to confdays
⍝     =int  => IDN of days
      :Access public
      wd←','#.Strings.split(GetText'Weekdays')
      mn←{GetText'Months',⍕⍵}¨⍳12           ⍝ short month-names can be defined in texts.xlsx
      :If 11=⎕DR days ⋄ days←(¯6↑days)/(confs.id⍳conf)⊃confs.GridDuration_IDN ⋄ :EndIf
      :If 0=≢days ⋄ R←''
      :Else
          R←(⊂wd mn){((1+⍵[4])⊃1⊃⍺),' ',(⍕⍵[3]),' ',(2⊃⍺)[2⊃⍵]}¨{2 ⎕NQ'.' 'IDNtoDate'⍵}¨days
      :EndIf
      :If 0=⎕NC'InternalCall'
      :OrIf 0=InternalCall
          R←0 ''R
      :EndIf
    ∇

    ∇ R←{ConsiderAvail}BuildPackageOpts(c∆ p∆ EB)
      :Access public
      r←(((∨/¨packages.nvRoomTypes=p∆[1])∧packages.id_conf=c∆))/packages
      r←jsonClone r  ⍝ make sure r is a "new" object not linked to its origin anymore
      :If 0=⎕NC'ConsiderAvail'
      :OrIf ~ConsiderAvail
          r.Disabled←r.HotelNights{∨/⍺∧⍵}¨⊂(UpdateAvailability c∆)[(1+p∆[1]∊2 3)+p∆[2]=1;1↓⍳7]=0
      :EndIf
      price←r._Price×1-0.1×EB
      :If (3=1⊃p∆)∧0<3⊃3↑p∆        ⍝ adjust price for couples depending on spouse's meal-plan
          :Select 3⊃p∆
          :Case 1
              price←price+r._PriceSpouseDinner
          :Case 2
              price←price+r._PriceSpouseAllMeals
          :EndSelect
      :EndIf
      R←0 ''(((r.Title,¨price{⍺=0:'' ⋄ ' (',#.Strings.deb ⍵.CurrPrefix,' ',(⍕⍺),(' '{×≢⍵:⍺,⍵ ⋄ ''}⍵.CurrSuffix),')'}¨r),[1.5]'p',¨⍕¨r.id),r.Disabled)
    ∇

    ∇ opts←BuildAccommodationOpts c∆;avail
    ⍝ R=x*3 Matrix of Packages and options
    ⍝ [;1]=Title
    ⍝ [;2]=Code
    ⍝ [;3]=Depth
    ⍝ [;4]=id of package (code is arbitrary, but unique - whereas the same package may appear in diff. branches of the tree)
    ⍝ [;5]=disabled-flag (0=ok, 1=disabled=no more rooms available!)
    ⍝ must be made more flexible wrt roomtypes by conference (i.e. online-events!)
    ⍝
    ⍝ RoomTypes: (aka "Accommodation[1]")
    ⍝ 1=Single
    ⍝ 2= Sharing with another delegate
    ⍝ 3= Sharing with spouse/partner
    ⍝ 4= Non-residential
    ⍝
    ⍝ For RoomTypes ∊ 2 3, there also is Accommodation[2] which selects TwinRooom (=1) oder Double Room (=2).
    ⍝ Accommodation[3] has info on the SpouseMealPlan (1=All Meals, 2=Dinner only)
    ⍝
    ⍝ The variable "Accommodation" will always be a 3-element vector, unused elems will be =0.
     
      :Access public
     
      avail←UpdateAvailability c∆
      opts←1 4⍴(c∆ GetText'lRoomType4')'4' 0 0  ⍝ roomtype=0 for non-res was a bad idea - let's try this!
      opts⍪←(c∆ GetText'lRoomType1')'1' 0,∧/0≥avail[1;1↓⍳7]
      opts⍪←(c∆ GetText'lRoomType2')'2' 0,∧/,0≥avail[2 3;1↓⍳7]
      opts⍪←(c∆ GetText'lTwinRoom')'2.1' 1,∧/0≥avail[3;1↓⍳7]
      opts⍪←(c∆ GetText'lDoubleRoom')'2.2' 1,∧/0≥avail[2;1↓⍳7]
      opts⍪←(c∆ GetText'lRoomType3')'3' 0,∧/,0≥avail[2 3;1↓⍳7]
      opts⍪←(c∆ GetText'lDoubleRoom')'3.2' 1,∧/0≥avail[2;1↓⍳7]
      opts⍪←(c∆ GetText'lMealPlanAllMeals')'3.2.2' 2,∧/0≥avail[2;1↓⍳7]
      opts⍪←(c∆ GetText'lMealPlanDinner')'3.2.1 ' 2,∧/0≥avail[2;1↓⍳7]
      opts⍪←(c∆ GetText'lTwinRoom')'3.1' 1,∧/0≥avail[3;1↓⍳7]
      opts⍪←(c∆ GetText'lMealPlanAllMeals')'3.1.2' 2,∧/0≥avail[3;1↓⍳7]
      opts⍪←(c∆ GetText'lMealPlanDinner')'3.1.1' 2,∧/0≥avail[3;1↓⍳7]
      opts←opts[;1 2 3 2 4]
      opts[;2]←'p',¨⍕¨⍳1↑⍴opts
     
      opts←0 ''opts
    ∇


    ∇ R←BuildConfGrid c∆;idx;ConfDays
      :Access public
    ⍝ Build ConferenceGrid for conference c∆
      c←(confs.id⍳c∆)⊃confs.(GridStartTS_IDN GridEndTS_IDN GridRows GridDuration_IDN)
      ConfDays←4⊃c ⍝ TS of all conference-Days
      attrs←mat←((1+1↑⍴3⊃c),1+1↑⍴ConfDays)⍴⊂''
      mat[1+⍳1↑⍴3⊃c;1]←3⊃c     ⍝ RowTitles
      mat[1;1+⍳⍴ConfDays]←1 FormatDays c∆ ConfDays
      idx←,(1+⍳1↑⍴3⊃c)∘.,1+⍳⍴ConfDays
      idx←(~(⍳⍴,idx)∊∊(items.id_conf=c∆)/items.nvGridCells)/idx
      mat[idx]←'⍬' ⍝ indicator for unused cells...
      R←0 ''mat
    ∇

    ∇ a←UpdateAvailability confid;booked;s
⍝ a = roomtypes and availability per day (for all "event-days")
      a←getJSON DataDir,'availability.json'   ⍝ read availability-data
      a←↑a.((⊂Roomtype),Availability)
      booked←SQLDo'SELECT RoomType, YHotel, count(RoomType) FROM Bookings  WHERE Conference_id=:I: AND status NOT IN ("C","N")GROUP BY YHotel,RoomType;'confid
      s←a[;1]⍳'Single' 'Double' 'Twin'
      a[s[1];1↓⍳7]+←+⌿a[(⍳1↑⍴a)~s[1];1↓⍳7] ⍝ double/twin-rooms also available as single
      :If ×≢booked
          booked[;3]←∊#.Strings.tonum¨booked[;3]
          booked←booked,↑booked[;3]×'Y'=6↑¨booked[;2]         ⍝ col 4..9 specify booked rooms per day  // 6↑ not very fortunate, but hard to generalize with that DB in backend
          booked←booked[;1]{⍺,(+⌿⍵)}⌸booked[;4 5 6 7 8 9] ⍝ group data to get sums per roomtype (in columns 2..7
          a←↑(↓a){⍺[1],(1↓⍺)-+⌿(∨/¨⍺[1]⍷⍵[;1])⌿0 1↓⍵}¨⊂booked  ⍝ finally adjust availability by subtracting bookings
          a[s[2];1↓⍳7]+←a[s[2];1↓⍳7]+0⌊a[s[1];1↓⍳7] ⍝ subtract overbooked singles from doubles
          a[s[3];1↓⍳7]+←a[s[3];1↓⍳7]+0⌊a[s[2];1↓⍳7] ⍝ subtract overbooked doubles from twins
      :EndIf
    ∇



    ∇ R←Get varnam
      :Access public
⍝ simple tool to retrieve class-data...
      R←0 ''(⍎varnam)
    ∇

    ∇ R←{GridIndices}SetConfGrid(c∆ pckId opts)
      :Access public
      mat←3⊃BuildConfGrid c∆
      :If 0=⎕NC'GridIndices' ⋄ GridIndices←,⊃∘.,/1↓¨⍳¨⍴mat ⋄ :EndIf ⍝ indices of all cells (except 1st row and 1st column)
     
⍝      mat[1↓⍳1↑⍴mat;1↓⍳¯1↑⍴mat]←⊂''
      :For i :In (i2p.id_package=pckId)/i2p.id_item   ⍝ for all items of selected package
          itm←(items.id⍳i)⊃items    ⍝ the items
          :For gc :In itm.nvGridCells
          ⍝    rc←2+(¯1+⍴mat)⊤gc-1    ⍝ convert cell-index into row/col-coordinates (add 1 because of titles...)
              ((gc⊃GridIndices)⌷mat)←⊂itm.Title
          :EndFor
      :EndFor
      R←0 ''mat
    ∇

    ∇ R←GetOptionalItems(pckId EB Accommodation);avail
      :Access public
⍝ R = items available for addition to package. ("Inlucded"=1 if so, "Disabled" if sold out)
      P←(packages.id⍳pckId)⊃packages
      z←(items._RoomType∊¯1,P.nvRoomTypes)∧items.id_conf=P.id_conf
      avail←UpdateAvailability P.id_conf
      :If 0<⍴P.nvItemTypes
          z←z∧items._Type∊P.nvItemTypes
      :EndIf
      z←z∧pckId{0=⍴⍵.nvOnlyIfPackageIn:1 ⋄ pckId∊⍵.nvOnlyIfPackageIn}¨items
     
      R←jsonClone z/items
      R.Disabled←0
      R.Gross←R._Price
      R._Price←R._Price×1-0.1×EB×R._EarlyBirdApplicable
      :If 0<⍴R
          R.Included←R.id∊(i2p.id_package=pckId)/i2p.id_item
          R.TitleWithPrice←(⊂confs){⍵.(Included∨_Price=0):⍵.Title ⋄ ⍵.Title,' (',((⍺.id⍳⍵.id_conf)⊃⍺.CurrPrefix),' ',(⍕⍵._Price),' ',((⍺.id⍳⍵.id_conf)⊃⍺.CurrSuffix),')'}¨R
          R←R[⍋itemtypes._sorting[itemtypes.id⍳R._Type]]
          :If Accommodation[1]∊⍳3
              R.Disabled←R{(⍺._PriceAccommodation>0)∧∨/⍺.HotelNights∧0=⍵}¨⊂avail[(1 3 2)[1⊃Accommodation];1↓⍳7]
          :EndIf
      :EndIf
      R←0 ''R
    ∇

    ∇ R←GetItemType id
      :Access public
      R←0 ''((itemtypes.id⍳id)⊃itemtypes)
    ∇

    ∇ R←GetItem id
      :Access public
      R←0 ''((items.id⍳id)⊃items)
    ∇

    ∇ R←SQLDo arg
⍝ little tool to take care of all DB-Interaction
⍝ using the single Connection we have and w/o simply throwing err500 if anything goes wrong
      arg←(⊂'Confreg'),#.HtmlElement.eis arg
      :Hold 'Database'
          R←#.SQL.Do arg
      :EndHold
      :If ~×R.ReturnCode
          R←R.Data
      :Else
          R.Message ⎕SIGNAL 500
      :EndIf
    ∇


    ∇ R←{confId}GetText code
      :Access public
      :If ~×≢Texts      ⍝ get texts and only those for the selected conf! (needs testing later...)
          Texts←getJSON(DataDir,'texts.json')
          :If 2=⎕NC'confId'
              Texts←(Texts{⍺.((⊃1↑(conf_id=⍵))∨0=≢conf_id)}confId)/Texts  ⍝ simplify!
          :EndIf
      :EndIf
      R←(Texts.Code⍳⊂code)⊃(Texts.HTML,⊂'') ⍝ just return empty vector for unrecognized codes...
    ∇


:endclass
