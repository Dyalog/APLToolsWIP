﻿cert←ReadCert filename;fn
⍝ Prepare a certificate for use by test functions

fn←CertPath,filename
cert←⊃iConga.X509Cert.ReadCertFromFile fn,'-cert.pem'
cert.KeyOrigin←'DER' (fn,'-key.pem')
