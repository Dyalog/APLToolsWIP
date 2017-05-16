﻿:Class X509Cert

    :Field Public Shared LDRC←''           ⍝ Save a ref to DRC to be used from X509Cert
    :Field Private Instance _Cert←''       ⍝ Raw certificate
    :Field private Instance _Key←''        ⍝ Raw certificate private key
    :Field Private Instance _usemsstoreapi ⍝ Use GNU unless this is set to 1
    :Field Private Instance _CertOrigin←'' ⍝ Where did this certificate come from
    :Field Private Instance _KeyOrigin←''  ⍝ Where did the  private part come from
    :Field Private Instance _ParentCert←'' ⍝ Parent certificate or ''

    tochar←{80=⎕DR 'A':⎕UCS ⍵ ⋄ ⎕AV[⎕IO+⍵]}

    :Property UseMSStoreAPI
    :Access Public Instance
        ∇ r←Get args
          r←_usemsstoreapi
        ∇
        ∇ Set args;z
          _usemsstoreapi←args.NewValue
          z←⎕EX¨'_Elements' '_Formatted' '_Extended'
        ∇
    :EndProperty

    :Property Cert
    :Access Public Instance
        ∇ r←Get args
          r←_Cert
        ∇
        ∇ Set args;z
          _Cert←args.NewValue
          z←⎕EX¨'_Elements' '_Formatted' '_Extended' 'DecodeOK'
        ∇
    :EndProperty

    :Property CertOrigin
    :Access Public Instance
        ∇ r←Get args
          r←_CertOrigin
        ∇
        ∇ Set args
          _CertOrigin←args.NewValue
        ∇
    :EndProperty

    :Property KeyOrigin
    :Access Public Instance
        ∇ r←Get args
          r←_KeyOrigin
        ∇
        ∇ Set args
          _KeyOrigin←args.NewValue
        ∇
    :EndProperty

    :Property ParentCert
    :Access Public Instance
        ∇ r←get args
          r←⍬
          :Trap 0
              :If 0<_ParentCert.IsCert
                  r←_ParentCert
              :EndIf
         
         
          :EndTrap
        ∇
        ∇ Set args
          :Trap 0
              :If 0<args.NewValue.IsCert
              :AndIf Elements.Issuer≡args.NewValue.Elements.Subject
                  _ParentCert←args.NewValue
              :Else
                  'Not a parent certificate'⎕SIGNAL 11
              :EndIf
          :Else
              'Not a certificate'⎕SIGNAL 11
              _ParentCert←⍬
          :EndTrap
         
        ∇
    :EndProperty


    PropertyNames←'Version' 'SerialNo' 'AlgorithmID' 'AlgorithmParams' 'Issuer' 'ValidFrom' 'ValidTo' 'Subject' 'KeyID' 'KeyParams' 'KeyLength' 'Key' 'IssuerID' 'SubjectID' 'Extensions'
    PropertyIndices←1 2 (3 1)(3 2)4 (5 1)(5 2)6 (7 1)(7 2)(7 3)(7 4) 8 9 10

    :Property Elements,Formatted,Extended
    :Access Public Instance
        ∇ r←get args;i;z;n;t
          i←¯1+'Elements' 'Formatted' 'Extended'⍳⊂args.Name
          :If 0≠⎕NC n←'_',args.Name ⋄ r←⍎n ⍝ Already decoded?
          :Else ⍝ We must decode it now
              :If 0=1⊃z←LDRC.Certs'Decode'_Cert('Details'i),_usemsstoreapi/⊂'DecodeApi' 'store'
                  DecodeOK←1
                  r←⍎n,'←⎕NS '''''
                  t←PropertyIndices⊃¨⊂2 2⊃z
                  ⍎n,'.(',(⍕PropertyNames),')←t'
                  :If i≥0 ⋄ r.(KeyHex←(⎕D,⎕A)[1+2⊥⍉(((⍴Key)÷4),4)⍴Key]) ⋄ :EndIf
         
                  :If 3=⍴2⊃z ⋄ t←2 3⊃z ⋄ :Else ⋄ t←('' '' '')'' '' '' ⋄ :EndIf ⍝ MS Store?
                  r.((KeyProvider KeyContainer KeyProviderType)FriendlyName Description EnhancedKeyUsage)←t
              :Else
                  (⍕z)⎕SIGNAL 11
              :EndIf
          :EndIf
        ∇
    :EndProperty

      base64←{⎕IO ⎕ML←0 1             ⍝ Base64 encoding and decoding as used in MIME.
     
          chars←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
          bits←{,⍉(⍺⍴2)⊤⍵}                   ⍝ encode each element of ⍵ in ⍺ bits,
                                       ⍝   and catenate them all together
          part←{((⍴⍵)⍴⍺↑1)⊂⍵}                ⍝ partition ⍵ into chunks of length ⍺
     
          0=2|⎕DR ⍵:2∘⊥∘(8∘↑)¨8 part{(-8|⍴⍵)↓⍵}6 bits{(⍵≠64)/⍵}chars⍳⍵
                                       ⍝ decode a string into octets
     
          four←{                             ⍝ use 4 characters to encode either
              8=⍴⍵:'=='∇ ⍵,0 0 0 0           ⍝   1,
              16=⍴⍵:'='∇ ⍵,0 0               ⍝   2
              chars[2∘⊥¨6 part ⍵],⍺          ⍝   or 3 octets of input
          }
          cats←⊃∘(,/)∘((⊂'')∘,)              ⍝ catenate zero or more strings
          cats''∘four¨24 part 8 bits ⍵
      }

    ∇ r←items GetDN DN;split;secs
        ⍝ Get an item from a distiguished name
     
      split←{1↓¨(⍺=⍺,⍵)⊂⍺,⍵}
      secs←'='split¨','split DN
      r←2⊃¨(secs,⊂'' '')[(1⊃¨secs)⍳items]
     
    ∇

    ∇ r←{name}Save path;name;filename;data;tn;ext;fixpath
      :Access public
      :Trap 0
          fixpath←{⍵,(~∨/'/\'∊⊃⌽⍵)⍴('/\'∩⍵),'/'}
          :If 0<⎕NC'name'
              (name ext)←'.'{2↑1↓¨⍺{(⍺=⍵)⊂⍵}⍺,⍵}name,'.cer'
          :Else
              name←⊃(⊂,'CN')GetDN ⎕THIS.Formatted.Subject
              ext←'cer'
          :EndIf
     
          path←fixpath path
     
          :Select ##.##.lcase ext
          :CaseList 'cer' 'pem'
              filename←path,name,'.',ext
              data←⊃,/('X509 CERTIFICATE'{pre←{'-----',⍺,' ',⍵,'-----'} ⋄ (⊂'BEGIN'pre ⍺),⍵,⊂'END'pre ⍺}↓64{s←(⌈(⍴⍵)÷⍺),⍺ ⋄ s⍴(×/s)↑⍵}base64 Cert),¨⊂⎕UCS 10 13
              ⍝ remember to create the directory
              tn←filename ⎕NCREATE 0
              data ⎕NAPPEND tn 80
              ⎕NUNTIE tn
     
          :Case 'der'
              filename←path,name,'.',ext
              tn←filename ⎕NCREATE 0
              (_Cert)⎕NAPPEND tn 83
              ⎕NUNTIE tn
          :Else
              'Unknown Certificate format'⎕SIGNAL 11
          :EndSelect
          r←0
      :Else
          r←⎕EN
      :EndTrap
    ∇

    ∇ {r}←CopyCertificationChainFromStore;trustroot;trustca;rix;iix;⎕IO;foundroot;current
      :Access Public
          ⍝ Follow certificate chain from "⎕this" until a root certificate is found,
          ⍝ Updating the ParentCert Property so the Certificate Chain is complete if possible
     
      ⎕IO←1
     
      trustroot←LDRC.X509Cert.ReadCertFromStore'root'
      trustca←LDRC.X509Cert.ReadCertFromStore'CA'
      current←⎕THIS
     
      :Repeat
          :If foundroot←(⍴trustroot)≥rix←trustroot.Formatted.Subject⍳⊂current.Formatted.Issuer
              ⍝ we have found the root cert
              current.ParentCert←rix⊃trustroot
     
          :ElseIf (⍴trustca)≥iix←trustca.Formatted.Subject⍳⊂current.Formatted.Issuer
               ⍝ we have found an intermediate  cert
              current.ParentCert←iix⊃trustca
              current←current.ParentCert
          :Else
              'Unable to reach a root certificate'⎕SIGNAL 999
          :EndIf
     
      :Until foundroot
      r←⍴Chain
    ∇

    ∇ chain←Chain;pc
      :Access Public
      chain←,⊂⎕THIS
      pc←ParentCert
      :While ⍬≢pc
      :AndIf 0<pc.IsCert
      :AndIf (⊃¯1↑chain).Elements.Subject≢pc.Elements.Subject
          chain,←pc
          pc←pc.ParentCert
      :EndWhile
    ∇

    ∇ arg←AsArg
      :Access Public
      arg←⍬
      :If ''≢_Cert
          arg,←⊂'PublicCertData'Chain.Cert
      :ElseIf ''≢_CertOrigin
          arg,←⊂'PublicCertFile'_CertOrigin
      :EndIf
      :If ''≢_Key
          arg,←⊂'PrivateKeyData'_Key
      :ElseIf ''≢_KeyOrigin
          arg,←⊂'PrivateKeyFile'(_KeyOrigin)
      :EndIf
    ∇

    ∇ r←IsCert;z
      :Access public
      :If 2=⎕NC'DecodeOK'
          r←DecodeOK
      :Else
          r←(0=⊃z←LDRC.Certs'Decode'_Cert)
          DecodeOK←r
      :EndIf
      r+←(r=1)∧(_KeyOrigin≢'')∨_Key≢''
    ∇

    ∇ Make0
      :Access Public
      :Implements Constructor
      Cert←''
      _Key←''
      _usemsstoreapi←0
      _CertOrigin←_KeyOrigin←('DER' '')
      LDRC←FindDRC''
    ∇

    ∇ Make1 cert
      :Access Public
      :Implements Constructor
     
      :If 1≠≡cert ⋄ cert←1⊃cert ⋄ :EndIf
      Cert←cert
      _usemsstoreapi←0
      _CertOrigin←_Key←_KeyOrigin←''
      LDRC←FindDRC''
    ∇

    ∇ Make2(cert origin)
      :Access Public
      :Implements Constructor
      Cert←cert
      _usemsstoreapi←0
      _CertOrigin←origin
      :If 'MSStore'≡1⊃origin
          _KeyOrigin←origin
      :EndIf
      LDRC←FindDRC''
    ∇

    ∇ Make3(cert certorigin keyorigin)
      :Access Public
      :Implements Constructor
      Cert←cert
      _usemsstoreapi←0
      _CertOrigin←certorigin
      _KeyOrigin←keyorigin
      LDRC←FindDRC''
    ∇

    ∇ ldrc←FindDRC dummy
    ⍝ Establish a pointer to a Conga instance or a v2 DRC namspace
      :If ''≢LDRC ⋄ ldrc←LDRC ⍝ Ref already set
      :Else
          :If 9=⎕NC'#.Conga' ⍝ Else use Conga factory function
              ldrc←#.Conga.Init''
          :ElseIf 9=⎕NC'#.DRC'   ⍝ Look for v2 DRC namespace
              ldrc←#.DRC
          :EndIf
      :EndIf
    ∇

    ∇ r←base Decode code;ix;bits;size;s
      ix←¯1+base⍳code
     
      bits←,⍉((2⍟⍴base)⍴2)⊤ix
      size←{(⌊(¯1+⍺+⊃⍴⍵)÷⍺),⍺}
     
      s←8 size bits
     
      r←(8⍴2)⊥⍉s⍴(×/s)↑bits
      r←(-0=¯1↑r)↓r
    ∇

    :Section Deprecated Shared Methods

    ∇ certs←ReadCertUrls;LDRC
     ⍝ NB Deprecated / for backwards compatibility
     ⍝    Use instance method CertificateUrls
      :Access Public Shared
      LDRC←FindDRC ⍬
      certs←LDRC.ReadCertUrls
    ∇

    ∇ certs←ReadCertFromStore storename;LDRC
     ⍝ NB Deprecated / for backwards compatibility
     ⍝    Use instance method CertificateFromStore
      :Access Public Shared
      LDRC←FindDRC ⍬
      certs←LDRC.ReadCertFromStore storename
    ∇

    ∇ certs←ReadCertFromFolder foldername;LDRC
     ⍝ NB Deprecated / for backwards compatibility
     ⍝    Use instance method CertificateFromFolder
      :Access Public Shared
      LDRC←FindDRC ⍬
      certs←LDRC.ReadCertFromFolder foldername
    ∇

    ∇ certs←ReadCertFromFile filename;LDRC
     ⍝ NB Deprecated / for backwards compatibility
     ⍝    Use instance method CertificateFromFolder
      :Access Public Shared
      LDRC←FindDRC ⍬
      certs←LDRC.ReadCertFromFile filename
    ∇

    :EndSection Deprecated Shared Methods


:EndClass
