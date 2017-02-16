:namespace TestFTPClient
    :section Documentation
    ⎕ML←1 ⋄ ⎕IO←1 ⍝ standard-settings for these
    ∇ R←Describe
⍝ This namespace contains functions to test the functionality of the FtpClient class.
⍝ All functions named "test_*" are test-functions.
⍝ Documentation of the individual functions and the tests they perform
⍝ is provided in the functions themselves.
⍝ Documentation of FtpClient is contained in the class in ADOC-format and can be viewed using
⍝    ]adoc_browse #.FtpClient
      R←{0 1↓(⍵[;1]='⍝')⌿⍵}⎕CR ⎕IO⊃⎕SI  ⍝ all lines with a lamp in col1 considered "public" comments
   ⍝ comments in other columns are "internal" comments which are not shown as description
    ∇

    ∇ R←Version
      R←'#.TestFTPClient' '1.0.0' '2017-02-16'
   ⍝[@MK,BB,AB] minor detail: I think readability of the source-code would be improved if this
   ⍝ Version-Info could be part of the "central comments" in Describe and would be extracted
   ⍝ from there by this fn. Perhaps using ADOC's ⍝⍝-feature which will not show the text of
   ⍝ such lines in the doc (result of Version is included anyway)
    ∇
    :endsection

    :section Testing (feel free to add more)
    ∇ test_mirrorservice;z;pub;readme;host;user;pass;folder;file;sub;path;NL;CR
⍝ Test the FTP Client
      NL←⎕UCS 13 10 ⋄ CR←1⊃NL
      (host user pass)←'ftp.mirrorservice.org' 'anonymous' 'testing'
      path←∊(folder sub file)←'pub/' 'FreeBSD/' 'README.TXT'
     
      :Trap 0
          z←⎕NEW ##.FTPClient(host user pass)
     ⍝ Create a new object
      :Else
          ⎕←'Unable to connect to ',host ⋄ →0
      :EndTrap
     
     
      :If 0≠1⊃pub←z.List folder ⍝ retrieve contents of a folder
          ⎕←'Unable to list contents of folder: ',,⍕pub ⋄ →0
      :EndIf
     
      :If ~∨/(¯1↓sub)⍷2⊃pub   ⍝ does it contain the subfolder we're expecting?
          ⎕←'Sub folder ',sub,' not found in folder ',folder,': ',file ⋄ →0
      :EndIf
     
      :If 0≠1⊃readme←z.Get path   ⍝ retrieve file README.TXT
          ⎕←'File not found in folder ',folder,': ',file ⋄ →0
      :EndIf
     
      ⎕←path,' from ',host,':',CR
      ⎕←(⍕⍴2⊃readme),' characters read'  ⍝ maybe we should also check if the file has the expected length? (Assuming it does not change over time - not sure if that is a valid assumption)
    ∇
    :endsection

    :section QA
    ∇ Run
⍝ Runs all "test_" functions in current namespace
⍝ we should get a result from these to determine whether they executed successfully or not -
⍝ but the design of these is something for later.
⍝ "We need an "APLUnit" namespace" (MK)

⍝[@all] do we care about setting up the ws properly - or is it up to the user to make sure conga and the FTPClient are loaded?
      ⎕CY'conga'    ⍝ make sure conga is there...
⍝     ⎕SE.UCMD'LOAD FTPClient.dyalog'  ⍝[AB] from the same path as this ns - how could we do that???

      ⍎¨{((⊂'test_')≡¨5↑¨⍵)/⍵}⎕NL-3
    ∇
    :endsection
:endnamespace
