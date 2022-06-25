:class EUVAT
⍝ 
⍝ *** DO NOT USE!!!
⍝
⍝ relies on "non-official" site vatid.eu - which went out of service shortly after the implementation of this class.
⍝ Describe::
⍝ Tools to deal with european VAT
⍝ 
⍝ No Constructors!::
⍝ No need to instantiate, class exposes shared methods only  
⍝

 
∇ z←SimpleCheck vatid
:access public shared
z←  {
        h←⎕NEW #.HttpCommand 
        h.(Command URL Headers)←'get'('https://vatid.eu/check/',(2↑⍵),'/',2↓⍵)('Accept' 'application/json') 
        'true'≡(0(7159⌶)(h.Run).Data).response.valid
        }vatid
∇

∇ z←ownid DocumentedCheck vatid
:access public shared
⍝ Result: (Valid)(Request_Date)(Request_Identifier)
z← ownid {
        h←⎕NEW #.HttpCommand 
        h.(Command URL Headers)←'get'('https://vatid.eu/check/',(2↑⍵),'/',(2↓⍵),'/',(2↑⍺),'/',2↓⍺)('Accept' 'application/json') 
⍝        (0(7159⌶)(h.Run).Data)
d←0(7159⌶)(h.Run).Data
d←d.response
r←(        'true'≡d.valid)(d.request_date)(d.request_identifier)
        }vatid
∇


:endclass

