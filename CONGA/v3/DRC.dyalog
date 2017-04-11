:Class DRC
⍝ NB instances are always created as siblings of the Conga namespace

    :Field Public LibPath
    :Field Public RootName

      check←{
          0≠⊃⍵:('DLL Error: ',,⍕⍵)⎕SIGNAL 999
          0≠⊃2⊃⍵:(##.Conga.Error⊃2⊃⍵),1↓2⊃⍵
          2=⍴⍵:(⎕IO+1)⊃⍵
          1↓⍵}

    lcase←0∘(819⌶)                    ⍝ Lower-casification
    ncase ←{(lcase ⍺) ⍺⍺ lcase ⍵ }    ⍝ Case-insensitive operator

    ∇ r←arg getargix(args list);mn;mp;ixs;nix
      ⍝ Finds argumenst in a list of positional and named arguments
     
      ixs←list⍳ncase args
     
      nix←+/∧\2>|≡¨arg ⍝ identify where the named arguments starts
     
      r←(⍴ixs)⍴1+⍴list      ⍝ prefill the result
      mp←ixs≤nix
      :If ∨/mp        ⍝ for positionals args
          (mp/r)←mp/ixs
      :EndIf
      mn←(~mp)∧ixs<1+⍴list
      :If ∨/mn       ⍝ for named args.
      :AndIf nix<⍴arg
          (mn/r)←-nix+(1⊃¨nix↓arg)⍳ncase mn/args
     
      :EndIf
    ∇

    ∇ r←a getarg ixs;m
      m←0<ixs
      r←(⍴ixs)⍴⍬
      :If ∨/m
          (m/r)←a[m/ixs]
      :EndIf
      m←~m
      :If ∨/m
          (m/r)←2⊃¨a[-m/ixs]
      :EndIf
    ∇

    ∇ r←reparg a;arglist;ix;cert
      arglist←'Name' 'Address' 'Port' 'Mode' 'BufferSize' 'SSLValidation' 'EOM' 'IgnoreCase' 'Protocol' 'PublicCertData' 'PrivateKeyFile' 'PrivateKeyPass' 'PublicCertFile' 'PublicCertPass' 'PrivateKeyData' 'X509'
      ix←a getargix('X509' 'PublicCertData' 'PrivateKeyFile' 'PrivateKeyPass' 'PublicCertFile' 'PublicCertPass' 'PrivateKeyData')(arglist)
      :If (⍴a)≥|⊃ix
          cert←a getarg⊃ix
     
          :If 9=⎕NC'cert'
          ⍝:AndIf 0<cert.IsCert   ⍝Accept empty certificates.
              a←(~(⍳⍴a)∊|ix)/a
              a,←cert.AsArg
          :EndIf
      :EndIf
      r←a
    ∇

    ∇ r←bit2problem a      ⍝ returned by DRC.Clt in case secure connection fails with error 1202
      r←a{(((⍴⍵)/2)⊤⍺)/⍵}'' 'CERT_INVALID' '' '' 'REVOKED' 'SIGNER_NOT_FOUND' 'SIGNER_NOT_CA' 'INSECURE_ALGORITHM' 'NOT_ACTIVATED' 'CERT_EXPIRED' 'SIGNATURE_FAILURE' 'REVOCATION_DATA_SUPERSEDED' '' 'UNEXPECTED_OWNER' 'REVOCATION_DATA_ISSUED_IN_FUTURE' 'SIGNER_CONSTRAINTS_FAILURE' 'MISMATCH'
    ∇

    ∇ r←X509Cert
      :Access Public Instance
      r←##.Conga.X509Cert
    ∇

    ∇ MakeN arg;rootname;z;s
      :Access public
      :Implements Constructor
     
      (LibPath RootName)←2↑arg
     
      :If 3=##.Conga.⎕NC'⍙InitRPC'
          z←##.Conga.⍙InitRPC RootName LibPath
          :Select ⊃z
          :Case 1091
              :If 80≠⎕DR' '
                  s←##.Conga.(SetXlate DefaultXlate)
              :EndIf
          :Case 1043
     
          :Else
              (##.Conga.Error z)⎕SIGNAL 999
          :EndSelect
     
          ⍝ SetProp '.' 'EventMode' 1
      :EndIf
     
    ∇

    ∇ vc←SetParentCerts vc;ix;m
    ⍝ Set parent certificates
      ix←vc.Elements.Subject⍳vc.Elements.Issuer  ⍝ find the index of the parents
      :If ∨/m←(ix≤⍴vc)∧ix≠⍳⍴ix                   ⍝ Mask the found items with parents and not selfsigned
          (m/vc).ParentCert←vc[m/ix]             ⍝ Set the parent
      :EndIf                                     ⍝ NB the :If prevents creation of an empty cert to allow above line to work
      vc←vc~vc.ParentCert                        ⍝ remove all parents from list
    ∇

    ∇ UnMake
      :Implements Destructor
      _←Close'.'
    ∇

    ∇ m←Magic arg
      :Access public
      m←(4/256)⊥⎕UCS 4↑arg
    ∇

    ∇ r←Srv a;ix;arglist;cert
      :Access public
⍝ Create a Server
⍝    "Name",            // string
⍝    "Address",         // string
⍝    "Port",            // Integer or service name
⍝    "Mode",            // command,raw,text
⍝    "BufferSize",
⍝    "SSLValidation",   // integer
⍝    "EOM",             // Vector of stop strings
⍝    "IgnoreCase",      // boolean
⍝    "Protocol",        // ipv4,ipv6
⍝    "PublicCertData",
⍝    "PrivateKeyFile",
⍝    "PrivateKeyPass",
⍝    "PublicCertFile",
⍝    "PublicCertPass",
⍝    "PrivateKeyData'
     
      a←reparg a
      r←check ##.Conga.⍙CallR RootName'ASrv'a 0
    ∇

    ∇ r←Send a;⎕IO
      :Access public
     ⍝ Name data {CloseConnection}
      ⎕IO←1
      r←check ##.Conga.⍙CallRL RootName'ASendZ'((a,0)[1 3])(2⊃a)
    ∇

    ∇ r←Clt a
      :Access public
⍝ Create a Client
⍝    "Name",            // string
⍝    "Address",         // string
⍝    "Port",            // Integer or service name
⍝    "Mode",            // command,raw,text
⍝    "BufferSize",
⍝    "SSLValidation",   // integer
⍝    "EOM",             // Vector of stop strings
⍝    "IgnoreCase",      // boolean
⍝    "Protocol",        // ipv4,ipv6
⍝    "PublicCertData",
⍝    "PrivateKeyFile",
⍝    "PrivateKeyPass",
⍝    "PublicCertFile",
⍝    "PublicCertPass",
⍝    "PrivateKeyData'
     
      a←reparg a
      r←check ##.Conga.⍙CallR RootName'AClt'a 0
    ∇

    ∇ r←Close con;_
      :Access Public
     ⍝ arg:  Connection id
      r←check ##.Conga.⍙CallR RootName'AClose'con 0
 ⍝     :If ((,'.')≡,con)∧(0<⎕NC'⍙naedfns')  ⍝ Close root and unload share lib
 ⍝         _←⎕EX¨⍙naedfns
 ⍝         _←⎕EX'⍙naedfns'
 ⍝     :EndIf
    ∇

    ∇ r←Certs a
      :Access public
      ⍝ Working with certificates.
      ⍝ ListMSStores
      ⍝ MSStore storename Issuer subject details api password
      ⍝ Folder not implemented
      ⍝ DER  not implemented
      ⍝ PK#12 not implemented
      r←check ##.Conga.⍙CallR RootName'ACerts'a 0
    ∇

    ∇ r←Names root
      :Access public
     ⍝ Return list of top level names
     
      :If 0=1↑r←Tree root
          r←{0=⍴⍵:⍬ ⋄ (⊂1 1)⊃¨⍵}2 2⊃r
      :EndIf
    ∇

    ∇ r←Progress a;cmd;data;⎕IO
      :Access public
     ⍝ cmd data
      ⎕IO←1 ⋄ r←check ##.Conga.⍙CallRL RootName'ARespondZ'(a[1],0)(2⊃a)
    ∇

    ∇ r←Respond a;⎕IO
      :Access public
     ⍝  cmd  data
      ⎕IO←1 ⋄ r←check ##.Conga.⍙CallRL RootName'ARespondZ'(a[1],1)(2⊃a)
    ∇

    ∇ r←SetProp a
      :Access public
      ⍝ Name Prop Value
      ⍝ '.' 'CertRootDir' 'c:\certfiles\ca'
     
      r←check ##.Conga.⍙CallR RootName'ASetProp'a 0
    ∇

    ∇ r←SetRelay a
      :Access public
      ⍝ Name Prop Value
      ⍝ 'RelayFrom' 'RelayTo' [blocksize=16384 [oneway=0]]
     
      r←check ##.Conga.⍙CallR RootName'ASetRelay'a 0
    ∇

    ∇ r←SetPropnt a
      :Access public
      ⍝ Name Prop Value
      ⍝ '.' 'CertRootDir' 'c:\certfiles\ca'
     
      r←check ##.Conga.⍙CallRnt RootName'ASetProp'a 0
    ∇

    ∇ r←Tree a
      :Access public
      ⍝ Name
      r←check ##.Conga.⍙CallR RootName'ATree'a 0
    ∇

    ∇ r←Micros
      :Access public
      r←##.Conga.Micros
    ∇

    ∇ v←Version;version;err
      :Access public
      :Trap 0
          :If 0≠⎕NC'##.Conga.⍙Version'
              (err v)←##.Conga.⍙Version 3
          :Else
              version←{no←(¯1+(⍵∊⎕D)⍳1)↓⍵ ⋄ 3↑⊃¨2⊃¨⎕VFI¨'.'{1↓¨(⍺=⍵)⊂⍵}'.',no}
              v←version 2 1 4⊃Tree'.'
          :EndIf
      :Else
          'Try DRC.Init '⎕SIGNAL 16
          v←0 0 0
      :EndTrap
    ∇

    ∇ r←Describe name;enum;state;type
      :Access public
      ⍝ Return description of object
     
      :If 0=1↑r←Tree name
          r←2 1⊃r
          enum←{2↓¨(⍵=1↑⍵)⊂⍵}
          state←enum',SNew,SIncoming,SRootInit,SListen,SConnected,SAPL,SReadyToSend,SSending,SProcessing,SReadyToRecv,SReceiving,SFinished,SMarkedForDeletion,SError,SDoNotChange,SShutdown,SSocketClosed,SAPLLast,SSSL,SSent,SListenPaused'
          type←enum',TRoot,TServer,TClient,TConnection,TCommand,TMessage'
     
          :If 0=2⊃r ⍝ Root
              r←0('[DRC]'(4⊃r)('State=',(1+3⊃r)⊃state)('Threads=',⍕5⊃r))
          :Else     ⍝ Something else
              (2⊃r)←(1+2⊃r)⊃type
              (3⊃r)←(1+3⊃r)⊃state
              r←0 r
          :EndIf
      :EndIf
    ∇

    ∇ r←Exists root
      :Access public
     ⍝ 1 if a Conga object name is in use
      r←0≡⊃⊃Tree root
    ∇

    ∇ r←GetProp a
      :Access public
      ⍝ Name Prop
      ⍝ Root: DefaultProtocol  PropList  ReadyStrategy  RootCertDir
      ⍝ Server: OwnCert  LocalAddr  PropList
      ⍝ Connection: OwnCert  PeerCert  LocalAddr  PeerAddr  PropList
     
      r←check ##.Conga.⍙CallR RootName'AGetProp'a 0
     
      :If 0=⊃r
      :AndIf ∨/'OwnCert' 'PeerCert'∊a[2]
      :AndIf 0<⊃⍴2⊃r
          (2⊃r)←SetParentCerts ##.⎕NEW¨X509Cert,∘⊂¨⎕THIS,¨⊂¨2⊃r
      :EndIf
    ∇

    ∇ r←Wait a;⎕IO
      :Access public
     ⍝ Name [timeout]
     ⍝ returns: err Obj Evt Data
      ⎕IO←1
      :If (1≥≡a)∧∨/80 82∊⎕DR a
          a←(a)1000
      :EndIf
      →(0≠⊃⊃r←check ##.Conga.⍙CallRLR RootName'AWaitZ'a 0)⍴0
      ⍝:If 0=⊃⊃r ⋄ timing,←⊂(4⊃4↑⊃r),Micros ⋄ :EndIf
      r←(3↑⊃r),r[2]
      :If 0<⎕NC'⍙Stat' ⋄ Stat r ⋄ :EndIf
     
    ∇

    ∇ r←Waitt a;⎕IO
      :Access public
     ⍝ Name [timeout]
     ⍝ returns: err Obj Evt Data
      ⎕IO←1
      :If (1≥≡a)∧∨/80 82∊⎕DR a
          a←(a)1000
      :EndIf
      →(0≠⊃⊃r←check ##.Conga.⍙CallRLR RootName'AWaitZ'a 0)⍴0
      ⍝:If 0=⊃⊃r ⋄ timing,←⊂(4⊃4↑⊃r),Micros ⋄ :EndIf
      r←(3↑⊃r),r[2],⊂(4⊃4↑⊃r),Micros
    ∇

:endClass
