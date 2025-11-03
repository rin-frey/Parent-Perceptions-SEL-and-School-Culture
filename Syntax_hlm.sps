* Encoding: UTF-8.

GET FILE='/full_parentperceptionsHLM_dataset.sav'.

SAVE OUTFILE='/final_parentperceptionsHLM_dataset.sav'
  /KEEP = 
    X1TCHAPP X2TCHAPP X1TCHCON X2TCHCON X1TCHPER X2TCHPER
    P1METCHR P2CHILDR P2HLPLRN P2SATSCL P2LGNOTE X1LOCALE
    X1PUBPRI S2WLCOME S2INVOLV S2PRNTNG S2SCISRV X_DISTPOV
    S2ORIENT S2T3HMLG FEMALE RACE6 MOMED DADED CHILDAGE
    DISABILITY CHILDID PARENTID S1_ID S2_ID meetteacher
    schoolnote_hl parented_prgram healthsocial_srv orientation
    supp_materials_hl approachlearning selfcontrol interpersonal
    SCHOOL_ID composite_ncog approachlearning_mean selfcontrol_mean
    interpersonal_mean P2SATSCL_RECODED SUBURB TOWN RURAL
    X12SESL.

RECODE X12SESL (-9 = SYSMIS) (ELSE = COPY) INTO ses.
EXECUTE.

COMPUTE approachlearning = MEAN(X1TCHAPP, X2TCHAPP).
EXECUTE.

COMPUTE selfcontrol= MEAN(X1TCHCON, X2TCHCON).
EXECUTE.

COMPUTE interpersonal = MEAN(X1TCHPER, X2TCHPER).
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (S1_ID = S2_ID).
EXECUTE.

COMPUTE SCHOOL_ID = S1_ID.
VARIABLE LABELS SCHOOL_ID 'consistent school id'.
EXECUTE.

AGGREGATE
  /OUTFILE='unique_schools.sav'
  /BREAK=SCHOOL_ID.

GET FILE='unique_schools.sav'.
FREQUENCIES VARIABLES=SCHOOL_ID.

FREQUENCIES VARIABLES = approachlearning.
DESCRIPTIVES VARIABLES = approachlearning.
  /STATISTICS = MIN MAX MEAN MEDIAN.

FREQUENCIES VARIABLES = selfcontrol.
DESCRIPTIVES VARIABLES = selfcontrol.
  /STATISTICS = MIN MAX MEAN MEDIAN.

FREQUENCIES VARIABLES = interpersonal.
DESCRIPTIVES VARIABLES = interpersonal.
  /STATISTICS = MIN MAX MEAN MEDIAN.

RELIABILITY 
  /VARIABLES=approachlearning selfcontrol interpersonal 
  /SCALE('Non-cognitive Composite') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVES SCALE CORR.

* Exploratory Factor Analysis (one factor) *.
FACTOR
  /VARIABLES=approachlearning selfcontrol interpersonal
  /MISSING=LISTWISE
  /PRINT=INITIAL EXTRACTION
  /PLOT=EIGEN
  /EXTRACTION=PC
    /CRITERIA=FACTORS(1) ITERATE(25)
  /ROTATION=NOROTATE.


CORRELATIONS 
  /VARIABLES=approachlearning selfcontrol interpersonal 
  /PRINT=TWOTAIL NOSIG 
  /MISSING=PAIRWISE.


COMPUTE composite_ncog= MEAN(approachlearning, selfcontrol, interpersonal).
VARIABLE LABELS composite_ncog 'Composite non cognitive score/SEL'.

RECODE P2SATSCL (1=4) (2=3) (3=2) (4=1) INTO parent_satisfaction.
RECODE P2HLPLRN (1=3) (2=2) (3=1) into P2HLPLRN.
RECODE P2CHILDR (1=3) (2=2) (3=1) into P2CHILDR.
COMPUTE SUBURB = (X1LOCALE = 2).
COMPUTE TOWN   = (X1LOCALE = 3).
COMPUTE RURAL  = (X1LOCALE = 4).
EXECUTE.

DESCRIPTIVES VARIABLES=
  composite_ncog
  meetteacher P2CHILDR P2HLPLRN P2SATSCL 
  S2WLCOME parented_prgram healthsocial_srv
  orientation supp_materials_hl
   MOMED DADED RURAL TOWN SUBURB
   gm_ses SCHOOL_ID
  /STATISTICS=MEAN STDDEV MIN MAX
/MISSING=LISTWISE.

FREQUENCIES VARIABLES = SCHOOL_ID  
  /FORMAT = NOTABLE  
  /STATISTICS = NONE  
  /ORDER = ANALYSIS.

DESCRIPTIVES VARIABLES=ses /MISSING=LISTWISE.

DESCRIPTIVES VARIABLES=meetteacher P2CHILDR P2HLPLRN P2SATSCL_RECODED MOMED DADED gm_ses
    S2WLCOME parented_prgram healthsocial_srv orientation supp_materials_hl
    SUBURB TOWN RURAL composite_ncog
/SAVE.


MIXED composite_ncog  
  /METHOD=REML  
  /FIXED=  
  /RANDOM=INTERCEPT | SUBJECT(SCHOOL_ID) COVTYPE(vc)  
  /PRINT=G SOLUTION TESTCOV.

MIXED composite_ncog WITH  
    meetteacher 
    P2CHILDR 
    P2HLPLRN 
    P2SATSCL_RECODED
    MOMED
    DADED
    gm_ses
/METHOD=REML
/FIXED= 
    meetteacher 
    P2CHILDR 
    P2HLPLRN 
    P2SATSCL_RECODED 
    MOMED
    DADED
    gm_ses
    | SSTYPE(3)
/RANDOM=INTERCEPT | SUBJECT(SCHOOL_ID) COVTYPE(VC)
/PRINT=G SOLUTION TESTCOV.

MIXED composite_ncog WITH  
    meetteacher 
    P2CHILDR 
    P2HLPLRN 
    P2SATSCL_RECODED 
    MOMED
    DADED
    gm_ses
    S2WLCOME 
    parented_prgram 
    healthsocial_srv
    orientation 
    supp_materials_hl
    SUBURB
    RURAL
    TOWN
/METHOD=REML
/FIXED= 
    meetteacher 
    P2CHILDR 
    P2HLPLRN 
    P2SATSCL_RECODED 
    MOMED
    DADED
    gm_ses
    S2WLCOME 
    parented_prgram 
    healthsocial_srv
    orientation 
    supp_materials_hl
    SUBURB
    RURAL
    TOWN
    | SSTYPE(3)
/RANDOM=INTERCEPT | SUBJECT(SCHOOL_ID) COVTYPE(VC)
/PRINT=G SOLUTION TESTCOV.

* First model: Parent-level predictors only, standardized.
MIXED Zcomposite_ncog WITH  
    Zmeetteacher 
    ZP2CHILDR 
    ZP2HLPLRN 
    ZP2SATSCL_RECODED
    ZMOMED
    ZDADED
    Zgm_ses
/METHOD=REML
/FIXED= 
    Zmeetteacher 
    ZP2CHILDR 
    ZP2HLPLRN 
    ZP2SATSCL_RECODED 
    ZMOMED
    ZDADED
    Zgm_ses
    | SSTYPE(3)
/RANDOM=INTERCEPT | SUBJECT(SCHOOL_ID) COVTYPE(VC)
/PRINT=G SOLUTION TESTCOV.

* Second model: Full model including school-level predictors, all standardized.
MIXED Zcomposite_ncog WITH  
    Zmeetteacher 
    ZP2CHILDR 
    ZP2HLPLRN 
    ZP2SATSCL_RECODED 
    ZMOMED
    ZDADED
    Zgm_ses
    ZS2WLCOME 
    Zparented_prgram 
    Zhealthsocial_srv
    Zorientation 
    Zsupp_materials_hl
    ZSUBURB
    ZRURAL
    ZTOWN
/METHOD=REML
/FIXED= 
    Zmeetteacher 
    ZP2CHILDR 
    ZP2HLPLRN 
    ZP2SATSCL_RECODED 
    ZMOMED
    ZDADED
    Zgm_ses
    ZS2WLCOME 
    Zparented_prgram 
    Zhealthsocial_srv
    Zorientation 
    Zsupp_materials_hl
    ZSUBURB
    ZRURAL
    ZTOWN
    | SSTYPE(3)
/RANDOM=INTERCEPT | SUBJECT(SCHOOL_ID) COVTYPE(VC)
/PRINT=G SOLUTION TESTCOV.



