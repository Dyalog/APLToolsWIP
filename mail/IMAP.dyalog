:Class IMAP

⍝ (Very) basic interface for IMAP

    (⎕IO ⎕ML)←1

    :field public Server←''  ⍝ server address
    :field public Port←⍬     ⍝ server port (default depends on whether running 587 or 465 (secure))
    :field public Userid←''  ⍝ userid for authentication (defaults to From)
    :field public Password←''⍝ optional password (if server requires authentication)
    :field public Secure←¯1  ⍝ indicates whether to use SSL/TLS, 0 = no, 1 = yes, ¯1 = let port number determine
    :field public CongaRootName←'IMAP'

    :field public shared CongaRef←''   ⍝ user-supplied reference to location of Conga namespace
    :field public shared LDRC←''     ⍝ reference to Conga library instance after CongaRef has been resolved

    :field _clt←''          ⍝ Conga client id
    :field _loggedOn←0
    :field _msgno←0         ⍝ IMAP requests require a unique id
    :field _capability←''   ⍝ Server capabilities (from the CAPABILITY command)

    ∇ r←Version
      :Access public shared
      r←'IMAP' '0.1' '2021-02-22'
    ∇

    :property Clt  ⍝ client
    :access public
        ∇ r←get
          r←_clt
        ∇
    :endproperty

    ∇ make
      :Access public
      :Implements constructor
    ∇

    ∇ make1 args
      :Access public
      :Implements constructor
     
      ⍝ args is either a vector with up to 4 elements: [1] server, [2] port, [3] userid, [4] password
      ⍝      or a namespace containing named elements
      :Select ⎕NC⊂'args'
      :Case 2.1 ⍝ variable
          (Server Port Userid Password)←(Server Port Userid Password){(≢⍺)↑⍵,(≢⍵)↓⍺},⊆args
      :Case 9.1 ⍝ namespace
          (Server Port Userid Password)←args{6::⍎⍵ ⋄ ⍺⍎⍵}¨'Server' 'Port' 'Userid' 'Password'
      :Else
          ⎕←'*** invalid constructor argument'
      :EndSelect
    ∇

    ∇ unmake;base
      :Implements destructor
      :Trap 0
          {}Logoff
          :If 0∊≢⎕INSTANCES base←⊃⊃⎕CLASS ⎕THIS
              base.LDRC←''
          :EndIf
      :EndTrap
    ∇

    ∇ (rc msg)←Connect;r;uid;dom;cert
      :Access public
      (rc msg)←¯1 ''
      :If 0∊⍴Server ⋄ →Exit⊣msg←'Server not defined' ⋄ :EndIf
     
      :If 0∊⍴Port ⍝ if port not specified, select default based on Secure
          Port←(1+0⌈Secure)⊃143 993
      :ElseIf ¯1=Secure ⍝ else if Secure is not set, set based on Port
          Secure←Port∊993
      :EndIf
     
      Secure←0⌈Secure
      Port←⊃Port
     
      :If ~Port∊⍳65535 ⋄ →Exit⊣msg←'Invalid Port' ⋄ :EndIf
     
      :If 0∊⍴uid←Userid ⋄ →Exit⊣msg←'Userid not specified' ⋄ :EndIf
     
      :If 0∊⍴LDRC
      :OrIf {0::1 ⋄ 0≠⊃LDRC.Describe'.'}''
          (rc msg)←Init CongaRootName
      :EndIf
     
      cert←⍬
      :If Secure
          :If 0∊⍴LDRC.X509Cert.LDRC ⋄ LDRC.X509Cert.LDRC←LDRC ⋄ :EndIf
          cert←⊂'X509'(⎕NEW LDRC.X509Cert)
      :EndIf
     
      :Select ⊃r←LDRC.Clt(''Server Port'text' 2000000,cert)
      :Case 0
          _clt←2⊃r                   ⍝ Conga client name
          :If 0=⊃(rc msg)←1 Do''       ⍝ retrieve the server response
              (rc msg)←Capability
          :Else
              {}LDRC.Close _clt
              _clt←''
          :EndIf
      :Case 100 ⍝ timeout
          msg←'*** Conga timeout on connect'
      :Else ⍝ some Conga error occured
          _clt←''
          msg←'*** Conga error: ',,⍕⊃r
      :EndSelect
     Exit:msg←(1+rc≠0)⊃''msg
    ∇

    ∇ (rc msg)←{notag}Do cmd;cnt;data;c;tag;res;status;t
      :Access public
      :If 0=⎕NC'notag' ⋄ notag←0 ⋄ :EndIf  ⍝ if we expect a tag in the response
      cnt←0
      data←''
      rc←1
      :If ⊃c←Connected                   ⍝ if we're connected
          tag←''
          →Try if empty cmd
          _msgno+←1
          tag←,'<a>,ZI4'⎕FMT _msgno
          :If 0≠⊃res←LDRC.Send Clt(tag,' ',cmd,CRLF)
              →Exit⊣msg←'*** Conga error: ',∊⍕2↑res
          :EndIf
     Try:
          :Select ⊃res←LDRC.Wait Clt 2000  ⍝ wait up to 2 seconds
          :Case 0
              data,←4⊃res                   ⍝ grab the data
              (t status)←2↑(⊃¯1↑data splitOn CRLF)splitOn' '
              rc←~(t≡tag)∨notag∧'OK' 'BAD' 'NO' 'PREAUTH' 'BYE'∊⍨⊂status
              →rc↓Exit,Try
          :Case 100                         ⍝ timeout, try up to 3 times
              →Exit if 0<≢data
              cnt+←1
              →Try if 3>cnt
              msg←'*** Conga timeout'
          :Else
              msg←'*** Conga error: ',∊⍕2↑res
          :EndSelect
      :Else                              ⍝ if the socket does not exist
          msg←'*** Conga IMAP server not connected - ',2⊃c
      :EndIf
     Exit: :If 0=rc ⋄ msg←data splitOn CRLF ⋄ :EndIf
    ∇

    :Section IMAP
    ⍝ This section contains covers for low-level IMAP commands 
    ⍝ as described in and in the same order as found in
    ⍝ https://tools.ietf.org/html/rfc3501#section-6

    ∇ (rc msg)←Capability
      :Access public
      →0 if⊃(rc msg)←1 Do'CAPABILITY'
      _capability←1⊃msg
    ∇

    ∇ (rc msg)←Noop
      :Access public
      (rc msg)←Do'NOOP'
    ∇

    ∇ (rc msg)←Logout
      :Access public
    ⍝ Log out from an IMAP mail server
      :If 0=⊃(rc msg)←1 Do'LOGOUT'
          rc←⊃LDRC.Close Clt
      :EndIf
      _loggedOn←0
    ∇

    ∇ (rc msg)←StartTLS
      :Access public
      (rc msg)←¯1 'STARTTLS not yet implemented'
    ∇

    ∇ (rc msg)←Authenticate what
      :Access public
      (rc msg)←¯1 'AUTHENTICATE not yet implemented'
    ∇

    ∇ (rc msg)←Login;mask
      :Access public
    ⍝ Login to an IMAP server optionally using AUTH PLAIN authentication if Userid and Password are non-empty
    ⍝  Other authentication types may be added in the future
    ⍝  If no password is set, then authentication is not done
    ⍝
      (rc msg)←¯1 ''
      :If ∨/mask←0∊∘⍴¨Userid Password
          →Exit⊣msg←'*** Empty ',4↓∊mask/'and '∘,¨'Userid' 'Password'
      :EndIf
     
      :If ~⊃Connected
          →Exit if 0≠⊃(rc msg)←Connect
      :EndIf
     
      :If ~∨/'AUTH=PLAIN'⍷_capability
          →Exit⊣msg←'*** Server does not support AUTH PLAIN'
      :EndIf
     
      →Exit if 0≠⊃(rc msg)←Do'LOGIN ',Userid,' ',Password
      :If 'CAPABILITY'≡(1⊃msg)word 2 ⋄ _capability←1⊃msg ⋄ :EndIf
      msg←''
     Exit:
      _loggedOn←0=rc
    ∇

    ∇ (rc msg)←Select what
      :Access public
      (rc msg)←Do'SELECT ',what
    ∇

    ∇ (rc msg)←Examine what
      :Access public
      (rc msg)←Do'EXAMINE ',quote what
    ∇

    ∇ (rc msg)←Create what
      :Access public
      (rc msg)←Do'CREATE ',what
    ∇

    ∇ (rc msg)←Delete what
      :Access public
      (rc msg)←Do'DELETE ',what
    ∇

    ∇ (rc msg)←Rename what
      :Access public
      (rc msg)←Do'RENAME ',what
    ∇

    ∇ (rc msg)←Subscribe what
      :Access public
      (rc msg)←Do'SUBSCRIBE ',what
    ∇

    ∇ (rc msg)←Unsubscribe what
      :Access public
      (rc msg)←Do'UNSUBSCRIBE ',what
    ∇

    ∇ (rc msg)←List what
      :Access public
      (rc msg)←Do'LIST ',what
    ∇

    ∇ (rc msg)←Lsub what
      :Access public
      (rc msg)←Do'LSUB ',what
    ∇

    ∇ (rc msg)←Status what
      :Access public
      (rc msg)←Do'STATUS ',what
    ∇

    ∇ (rc msg)←where Append what
      :Access public
      (rc msg)←Do'APPENFD ',what
    ∇

    ∇ (rc msg)←Check
      :Access public
      (rc msg)←Do'CHECK'
    ∇

    ∇ (rc msg)←Close
      :Access public
      (rc msg)←Do'CLOSE'
    ∇

    ∇ (rc msg)←Expunge
      :Access public
      (rc msg)←Do'EXPUNGE'
    ∇

    ∇ (rc msg)←Search what
      :Access public
      (rc msg)←Do'SEARCH ',what
    ∇

    ∇ (rc msg)←Fetch what
      :Access public
      (rc msg)←Do'FETCH ',what
    ∇

    ∇ (rc msg)←Store what
      :Access public
      (rc msg)←Do'STORE ',what
    ∇

    ∇ (rc msg)←Copy what
      :Access public
      (rc msg)←Do'COPY ',what
    ∇

    ∇ (rc msg)←Uid what
      :Access public
      (rc msg)←Do'UID ',what
    ∇

    :EndSection

    :Section API 
⍝ this section will be populated with higher-level API

    ∇ r←Folders;status;folders
    ⍝ return [;1] folder name [;2] # messages [;3] # unseen messages
      :Access public
      →Exit if 0≠⊃r←List'"*" "*"'
      folders←2⊃r
      folders←folders/⍨folders beginsWith¨⊂'* LIST'
      folders←{⊃¯1↑splitIMAP ⍵}¨folders
      status←{Status ⍵,' (MESSAGES UNSEEN)'}¨folders
      status←{num deparen⊃¯1↑splitIMAP 2 1⊃⍵}¨status
      r←folders,↑status
     Exit:
    ∇            

    :EndSection

    :section Utilities
    if←⍴⍨
    unless←↓⍨
    okay←{0=⊃⍺.(rc msg log)←{3↑⍵,(≢⍵)↓¯99 '' ''},⊆⍵}
    empty←0∘∊⍴
    lc←0∘(819⌶)
    splitOn←(~∊)⊆⊣ ⍝ e.g. response splitOn CRLF
    word←{⍵{(⍺⌊1+≢⍵)⊃⍵,⊂''}⍺(≠⊆⊣)' '}
    quote←{'""'≡2↑¯1⌽⍵:⍵⋄'"',⍵,'"'}
    dequote←{'""'≡2↑t←¯1⌽⍵:2↓t⋄⍵}
    deparen←{')('≡2↑t←¯1⌽⍵:2↓t⋄⍵}
    num←{⊃(//)⎕VFI ⍵}
    beginsWith←{⍺{⍵≡⍺↑⍨≢⍵},⍵}
    splitIMAP← {⍵⊆⍨~(' '=⍵)>(+⌿+\1 ¯1×⍤0 1⊢'()'∘.=⍵)∨≠\'"'=⍵} ⍝ split "pieces" of an IMAP result message

    ∇ r←Config
    ⍝ returns current service configuration
      :Access public
      r←↑{⍵(⍎⍵)}¨⎕THIS⍎'⎕NL ¯2.2 ¯2.3'
    ∇

    ∇ r←CRLF
      r←⎕UCS 13 10
    ∇

    ∇ (rc msg)←Connected;r;state
      :Access public
      msg←'IMAP server has not been connected'
      →0↓⍨rc←Clt≢''
      :Trap 0 ⍝ handle any Conga error, LDRC not defined, etc
          r←LDRC.Describe Clt
      :Else
          →0⊣(rc msg)←0 'Conga could not query client'
      :EndTrap
      :If 0=⊃r ⍝ good Conga return code?
          :Select state←lc 2⊃3↑2⊃r
          :Case 'client'
              (rc msg)←1 'connected'
          :Case 'error'
              (rc msg)←0 'not connected (possible server timeout)'
          :Else
              (rc msg)←0 'unknown client state: ',∊⍕state
          :EndSelect
      :Else
          (rc msg)←0('non-zero Conga return code (',(⍕⊃r),')')
      :EndIf
    ∇

    :endsection

    :Section Conga
    ∇ (rc msg)←Init rootname;ref;root;nc;class;dyalog;n;ns;congaCopied
      (rc msg)←¯1 ''
      ⍝↓↓↓ Check is LDRC exists (VALUE ERROR (6) if not), and is LDRC initialized? (NONCE ERROR (16) if not)
      :Hold 'IMAPInit'
          :If {6 16 999::1 ⋄ ''≡LDRC:1 ⋄ 0⊣LDRC.Describe'.'}''
              LDRC←''
              :If 9=#.⎕NC'Conga' ⋄ {#.Conga.X509Cert.LDRC←''}⍬ ⋄ :EndIf ⍝ if #.Conga exists, reset X509Cert.LDRC reference
              :If ~0∊⍴CongaRef  ⍝ did the user supply a reference to Conga?
                  LDRC←rootname ResolveCongaRef CongaRef
                  :If ''≡LDRC
                      msg←'CongaRef (',(⍕CongaRef),') does not point to a valid instance of Conga'
                      →Exit
                  :EndIf
              :Else
                  :For root :In ##.## #
                      ref nc←root{1↑¨⍵{(×⍵)∘/¨⍺ ⍵}⍺.⎕NC ⍵}ns←(-~0∊⍴rootname)↓'Conga' 'DRC' ⍝ if rootname is supplied, can only use Conga (no DRC)
                      :If 9=⊃⌊nc ⋄ :Leave ⋄ :EndIf
                  :EndFor
                  :If 9=⊃⌊nc
                      LDRC←rootname ResolveCongaRef root⍎∊ref
                      :If ''≡LDRC
                          msg←(⍕root),'.',(∊ref),' does not point to a valid instance of Conga'
                          →Exit
                      :EndIf
                      →∆COPY↓⍨{999::0 ⋄ 1⊣LDRC.Describe'.'}'' ⍝ it's possible that Conga was saved in a semi-initialized state
                  :Else
     ∆COPY:
                      class←⊃⊃⎕CLASS ⎕THIS
                      dyalog←{⍵,'/'↓⍨'/\'∊⍨¯1↑⍵}2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'
                      congaCopied←0
                      :For n :In ns
                          :Trap 0
                              n class.⎕CY dyalog,'ws/conga'
                              LDRC←rootname ResolveCongaRef class⍎n
                              :If ''≡LDRC
                                  msg←n,' was copied from [DYALOG]/ws/conga, but is not valid'
                                  →Exit
                              :EndIf
                              congaCopied←1
                              :Leave
                          :EndTrap
                      :EndFor
                      :If ~congaCopied
                          msg←'Neither Conga nor DRC were successfully copied from [DYALOG]/ws/conga'
                          →Exit
                      :EndIf
                  :EndIf
              :EndIf
          :EndIf
          rc←¯1×LDRC≢''
     Exit:
      :EndHold
    ∇

    ∇ LDRC←rootname ResolveCongaRef CongaRef;z;failed
    ⍝ CongaRef could be a charvec, reference to the Conga or DRC namespaces, or reference to an LDRC instance
    ⍝ :Access public shared  ⍝!!! testing only  - remove :Access after testing
      LDRC←'' ⋄ failed←0
      :Select ⎕NC⊂'CongaRef' ⍝ what is it?
      :Case 9.1 ⍝ namespace?  e.g. CongaRef←DRC or Conga
     Try:
          :Trap 0
              :If ∨/'.Conga'⍷⍕CongaRef ⍝ is it Conga?
                  LDRC←CongaRef.Init rootname
              :ElseIf 0≡⊃CongaRef.Init'' ⍝ DRC?
                  LDRC←CongaRef
              :Else
                  →0⊣LDRC←''
              :End
          :Else ⍝ if HttpCommand is reloaded and re-executed in rapid succession, Conga initialization may fail, so we try twice
              :If failed
                  →0⊣LDRC←''
              :Else
                  →Try⊣failed←1
              :EndIf
          :EndTrap
      :Case 9.2 ⍝ instance?  e.g. CongaRef←Conga.Init ''
          LDRC←CongaRef ⍝ an instance is already initialized
      :Case 2.1 ⍝ variable?  e.g. CongaRef←'#.Conga'
          :Trap 0
              LDRC←ResolveCongaRef(⍎∊⍕CongaRef)
          :EndTrap
      :EndSelect
    ∇
    :endsection

:EndClass
