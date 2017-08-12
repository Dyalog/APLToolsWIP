:class Countries
    :field public shared CacheDays←10  ⍝ number of days till cache expires

⍝ Describe::
⍝ Small collection of country-related Tools. Might evolve into something useful.
⍝
⍝ No Constructors (yet)!::
⍝ No need to instantiate, class exposes shared methods only
⍝
⍝ Requires Files (which is available in MiServer\Utils and is always present in any MiServer-environment...)


    ∇ z←List;t;cache;idn
      :Access public shared
      cache←{((¯1+⍵⍳'.')↑⍵),'.cache'}SourceFile ⎕THIS
      :Hold 'countrycache'
          :If ~#.Files.Exists cache
              t←cache ⎕FCREATE 0
              (1 3⍴0 ¯1 0)⎕FSTAC t  ⍝ Allow everyone access
              0 0 ⎕FAPPEND¨t
              ⎕FUNTIE t
          :EndIf
          t←cache ⎕FSTIE 0
          :If (idn←2 ⎕NQ'.' 'DateToIDN'⎕TS)>CacheDays+⎕FREAD t,1
              z←getem
              :If 0=1↑⍴z               ⍝ if there was an error while retrieving data
              :AndIf 0<1↑⍴⎕FREAD t,2   ⍝ and we have something in the cache
                  z←⎕FREAD t,2         ⍝ use that
              :Else                    ⍝ otherwise
                  ⎕FHOLD t
                  idn ⎕FREPLACE t,1    ⍝ update cache
                  z ⎕FREPLACE t,2
                  ⎕FHOLD ⍬
              :EndIf
          :Else ⋄ z←⎕FREAD t,2         ⍝ use cached values
          :EndIf
          ⎕FUNTIE t
      :EndHold
    ∇


    ∇ z←getem
      :Access public shared
    ⍝ Result is a 2-col matrix with [;1] code and [;2] name
    ⍝ this ALWAYS retrieves the JSON, whereas List (recommended!)
    ⍝ caches the results
      :Trap 0 ⍝ if anything goes wrong here, we simply return a 0 2⍴ matrix
          z←(1(7159⌶)(#.HttpCommand.Get'http://country.io/names.json').Data)[;2 3]
          z←(∧/(⎕DR' ')=⎕DR¨z)⌿z     ⍝ make sure its all strings
          z←z[⍋↑z[;2];] ⍝ sort by name
      :Else
          z←0 2⍴⊂''
      :EndTrap
    ∇


    ∇ R←{what}FromIP ip
      :Access public shared
⍝ Get country by IP. Returns a ns with complete record from country-database (unless specific field select with left argument "what")
⍝ Example:
⍝ {"ip":"176.199.5.98",
⍝  "country_code":"DE",
⍝  "country_name":"Germany",
⍝  "region_code":"SN",
⍝  "region_name":"Saxony",
⍝  "city":"Grundau",
⍝  "zip_code":"09517",
⍝  "time_zone":"Europe/Berlin",
⍝  "latitude":50.65,
⍝  "longitude":13.2833,
⍝  "metro_code":0
⍝  }
⍝ zip_code is wrong, so do not put too much trust into such details. Country should be fairly reliable...
     
      R←(#.HttpCommand.Get'http://freegeoip.net/json/',ip).Data
      R←(7159⌶)R
      :If 2=⎕NC'what'    ⍝ return selected element
      :AndIf 2=R.⎕NC what
          R←R⍎what
      :EndIf
    ∇

    ∇ R←GetNameFromCode code;l
      :Access public shared
      l←List⍪⊂''
      R←(l[;1]⍳⊂code)⊃l[;2]
    ∇

    ⍝ following from AB:
      SourceFile←{ ⍝ Get pathname to sourcefile for ref ⍵
          file←⊃(4∘⊃¨(/⍨)(⍵≡⊃)¨)5177⌶⍬ ⍝ ⎕FIX
          ''≡file:⍵.SALT_Data.SourceFile ⍝ SALT
          file
      }
:endclass
