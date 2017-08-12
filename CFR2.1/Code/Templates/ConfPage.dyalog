:class ConfPage : MiPage
    :field public title←''
    :field private Texts←0 3⍴' '
    :Field public confId            ⍝ id of conference the user registers for
    :Field public confIdx           ⍝ index of that conference
    :field public EarlyBirdActive

    :field public DelegateName
    :field public EMail
    :field public Town
    :field public Postcode
    :field public Company
    :field public Address
    :field public Region
    :field public Country←'DEFAULT'
    :field public CountryLong
    :field public Countries
    :field public ATTENDANCE←,0
    :field public TotalGross
    :field public TotalNet
    :field public ConferenceGross
    :field public ConferenceNet
    :field public SpouseGross
    :field public SpouseNet
    :field public YDays
    :field public YHotel
    :field public YBanquet
    :field public SecondName←''
    :field public SecondEmail←''
    :field public RoomType
    :field public SpouseMealPlan←''
    :field public ItemsAndCategories←''
    :field public Notes
    :field public notes
    :field public Conference_VAT
    :field public Accommodation_VAT
    :field public Invoice
    :field public YEarlyBird
    :field public Status
    :field public rtTxt
    :field public SelectedPackage
    :Field public ConfGrid
    :Field public TheItems
    :Field public CurrPrefix
    :Field public CurrSuffix
    :Field public InvoiceAmount
    :Field public PaymentStatus
    :Field public TransactionId
    :field public domain←''    ⍝ the domain that we're working on...
    :Field public confs
    :Field public iHotelNights
    :Field public iConfDays
    :Field public smpTxt
    :Field public VATpct
    :Field public VAT_Amount

    ifUndefined←{6::⍺ ⋄ ⍎⍵}
    isUndefined←{6::1 ⋄ 0××≢⍎⍵}



    ∇ r←jsonClone R
      :Access public
      r←{(7159⌶)0(7160⌶)⍵}R  ⍝ re-create JSON-Object ⍵
    ∇

    ∇ {r}←Wrap
      :Access public
      ⍝domain←1↓{((∨\⍵=':')^3>+\⍵='/')/⍵}#.Boot.ms.Config.Application.CallbackURL   ⍝ extract //.../-portion (w/o protocol)
      domain←'//',(_Request.Headers[;1]⍳⊂'host')⊃_Request.Headers[;2]  ⍝ use what's being used
      :If isUndefined'confs' ⋄ confs←APIdo('GetConfs' 1) ⋄ :EndIf  ⍝ might happen if server is restarted while user has form elready open...
      :If isUndefined'confIdx' ⋄ :If ~isUndefined'confId' ⋄ confIdx←confs.id⍳confId
          :Else ⋄ confIdx←≢confs ⋄ :EndIf  ⍝ set default confIdx here!
      :EndIf
      :If 0<confIdx
          Head.Add _.Style'.TheBody' ((ScriptFollows #.Strings.subst'%img%' (confIdx⊃confs.img))#.Strings.subst'%domain%' domain)
          ⍝ background: url("%domain%/img/%img%") no-repeat fixed center !important;

      :EndIf
      Use'JQueryUI'
      Use'jBox'

      ⍝ missing file-phenomenon:
      Use'⍎',domain,'/Syncfusion/assets/scripts/web/ej.web.all.min.js'
      Use'⍎',domain,'/Syncfusion/assets/external/jquery.easing.1.3.min.js'
      Use'⍕',domain,'/Syncfusion/assets/css/web/gradient-saffron/ej.web.all.min.css'
      Use'⍕',domain,'/FontAwesome/css/font-awesome.min.css'
      Use'⍕',domain,'/Dyalog/dcPanel/dcPanel.css'
  



 
 
 
       
      
      Use'⍎',domain,'/Scripts/confreg.js'
      _CssReset←domain,'/Styles/normalize.css'
      Add _.StyleSheet(domain,'/Styles/confreg.css')
     
    ⍝ set a meta tag to make it explicitly UTF-8
      (Add _.meta).SetAttr'http-equiv="content-type" content="text/html;charset=UTF-8"'
      (Add _.meta).SetAttr'name="viewport" content="width=device-width, initial-scale=1"'
     
     
      :If title≡'' ⋄ title←_Request.Server.Config.Name ⋄ :EndIf  ⍝ set a default
      Add _.title title ⍝ we do that on the individual Pages!
     
      :If '###'≡'###'SessionGet'showMsg'
          _Request.Session.showMsg←⍬     ⍝ vector with ⊂(type)(text)    where type=0=nothing, ¯2: error, ¯1=warning, 1=info, 2=success and text is a VECTOR with the text of the msg
      :EndIf
      :If title≡'' ⋄ title←_Request.Server.Config.Name ⋄ :EndIf  ⍝ set a default
    ⍝ jBox is a different story, it may happen that a callback creates the first jBox ever. So let's explicitely load the resource:
      :While 0<⍴_Request.Session.showMsg
          :If 0>⊃1⊃_Request.Session.showMsg   ⍝ there is an errormsg (or a warning) to show!
              OnLoad,←_.jBox.Modal(New _.Panel((,2⊃t)(t[1]⊃'warn' 'error')))
          :ElseIf 0<⊃t←1⊃_Request.Session.showMsg
              OnLoad,←Notice t
          :EndIf
          _Request.Session.showMsg←1↓_Request.Session.showMsg
      :EndWhile
      ⍝ call the base class Wrap function
     
    ⍝ wrap the content of the <body> element in a div
      hdr←(#.Files.GetText #.Boot.AppRoot,'\header17.html')
      hdr←hdr #.Strings.subst'{domain}'(domain,'/')
      Body.Push'.Container'New _.div hdr
      Body.Add'</div>'  ⍝ close the first div-tag of header17
      Body.Add _.br
      Body.Add(ExpandPlaceholders (#.Files.GetText #.Boot.AppRoot,'\worldpay.html'))
      Body.Set'class=TheBody'
     
      :Trap 991
          r←⎕BASE.Wrap
      :Else
          .
      :EndTrap
     
    ∇

    ∇ R←{opts}Notice content
      :Access public
⍝ get JS to display a notice
⍝ content[1]= 1 (info), 2=success, 3=error
⍝ content[2]=message
⍝∘∘∘
      :If 0=⎕NC'opts' ⋄ opts←⎕NS'' ⋄ :EndIf
      :If 0=⎕NC'opts.color' ⋄ opts.color←content[1]⊃'blue' 'green' 'yellow' ⋄ :EndIf
      opts.position←⊂'{x: "right", y: "top"}'
      opts.width←450
      R←opts #._.jBox.Notice((#.HtmlElement.New _.Icon(content[1]⊃'fa-info-circle' 'fa-check' 'fa-exclamation-triangle')),2⊃content)
    ∇

    ∇ {R}←APIdo rarg
      :Access public
      R←CatchAPIErrors(SessionGet'APIref').CallAPI rarg
    ∇


    ∇ R←CatchAPIErrors S
      :Access public
        ⍝ simplistic mechanism to handle API-Errors and Warning:
        ⍝ any return-code ≠0 will ⎕SIGNAL and get out of the stack,
        ⍝ so the result returned in case of successfull operations
        ⍝ will be the 3d element of the calls result.
      :If 0=⊃S
          R←3⊃S
      :Else
          ('API-Warning/Error-Msg: ',2⊃S)⎕SIGNAL 2
      :EndIf
     
    ∇

    ∇ R←SQLDo arg
      :Access public
⍝ little tool to take care of all DB-Interaction
⍝ using the single Connection we have and w/o simply throwing err500 if anything goes wrong
      arg←(⊂'Confreg'),#.HtmlElement.eis arg
      R←#.SQL.Do arg
      :If ~×R.ReturnCode
          R←R.Data
      :Else
          R.Message ⎕SIGNAL 500
      :EndIf
    ∇



    ∇ R←{dflt}GetText code
      :Access public
      :If ~×≢Texts      ⍝ get texts and only those for the selected conf! (needs testing later...)
          Texts←APIdo'getJSON'(#.Boot.AppRoot,'/Data/texts.json')1
⍝          Texts←(Texts{⍺.((⊃1↑(conf_id=⍵))∨0=≢conf_id)}confId)/Texts  ⍝ simplify!   ⍝ might have been a bad idea, remove conf_is from texts-table!
      :EndIf
      :if 0=⎕nc'dflt' ⋄ dflt←'' ⋄ :endif
      R←(Texts.Code⍳⊂code)⊃Texts.HTML,⊂dflt ⍝ just return empty vector for unrecognized codes...
    ∇

    ∇ R←MakeDyalogTransID
      :Access public
⍝ Make unique Dyalog transaction ID
      R←('Dy',⍕(+/1↓⎕TS),⎕TID,?1000000)~' '
      R←(16⌊⍴R)↑R
    ∇


    ∇ R←ExpandPlaceholders r;j;k;∆;z;suff;pre;ifContent;ifClause;p
      :Access public
      R←''
      ⍝ first evaluate the :if's - if any ;-)
      :While ∨/z←':IF '⍷#.Strings.uc r
          p←(':ENDIF'⍷#.Strings.uc r)⍳1  ⍝ where does it end?
          ifClause←{(∧\~⍵∊⎕UCS 10 13)/⍵}(z⍳1)↓(p-1)↑r
          ifContent←''
          :Trap 0
              :If ⍎3↓ifClause
                  ifContent←(⍴ifClause)↓(z⍳1)↓(p-1)↑r
              :EndIf
          :Else
              ifContent←'Error processing ifClause "',3↓ifClause,'"'
          :EndTrap
          pre←((¯1+z⍳1)↑r)
          suff←{(∨\~⍵∊' ',⎕UCS 10 13)/⍵}(p+5)↓r
          r←pre,ifContent,suff
      :EndWhile
     
      ⍝ now expand variables
      :While 0<⍴r
          j←¯1+(r∊'⍎⍕')⍳1
          R,←j↑r
          r←j↓r
          :If 0<⍴r
              k←(1↓r)⍳r[1]
              ∆←k↑r
              r←(k+1)↓r
              :Trap 0
                  :If '⍎'=⍬⍴∆ ⋄
                      ∆←⍎1↓∆
                  ⍝∆←{0:⍵ ⋄ ⍎⍵}1↓∆
                  :ElseIf '⍕'=⍬⍴∆ ⋄ ∆←GetText 1↓∆
                  :EndIf
              :Else
                  ∆←(∊⎕DM),' "',∆,'"'
              :EndTrap
              R,←∆
          :EndIf
      :EndWhile
     
    ∇

:endclass
