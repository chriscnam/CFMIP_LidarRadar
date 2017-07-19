load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;===============================================================
; This script contains a panel of 5 figures of:
; 1) Cloud Fraction (CALIPSO observations & Model with Calipso simulator & 'Only' Model)
;	Cloud fraction is defined as particles yielding a scattering ratio > 5.
; 2) Hydrometeor Fraction (CloudSat observations & Model with radar simulator)
;	Hydrometeor fraction is defined as particles yielding reflectivity > -30 dBZe.
;
; This NCL script has been made for example data June/July/August 2008. Variable names follow CMIP5 convention.
; 
; You need to make the following changes (find 'Metric'): 
; 1)File format of output file (i.e. pdf or eps) & Choose color table
; 2)Title of output file
; 3)Directories of input files and working directory
; 4)Input files: Note Users must replace ‘IPSL+simulator’ files AND variable names.
; 5)Temporary *nc files
;
; Christine Nam
;    Laboratoire de Météorologie Dynamique
;    Institut Pierre Simon Laplace
;    Centre National de la Recherche Scientifique
;    Paris, France
;    Nov. 2012
; 
; Support of this work came from the EUCLIPSE project - European Union, Seventh Framework Programme (FP7/2007–2013) grant 244067. 
;
;===============================================================
; FILE INFORMATION
; --------------------------------------------------------------
; example: wks = gsn_open_wks("Metric1","Metric2")
  wks = gsn_open_wks("pdf","IPSL5Bamip_ZonalLidarRadar_2008")  ;file type: "x11";"pdf";"eps"

  cmap = RGBtoCmap("RGBmatlab.txt")     ; CNam: using personalized color table
  gsn_define_colormap(wks, cmap) 	
;  gsn_define_colormap(wks,"matlab_jet"); CNam: uncomment for NCL predefined table

  plot = new(6,graphic)              ; create plot array
  
;===============================================================
; MODELS with COSP Calipso and Parasol satellite simulators
; --------------------------------------------------------------
; example: directoryA = "/Metric3/" ; Directory of CALIPSO Satellite data
;	   directoryB = "/Metric3/" ; Directory of COSP Lidar simulator
;	   directoryC = "/Metric3/" ; Directory of original Model data
;	   directoryD = "/Metric3/" ; Directory of CloudSat Satellite data
;	   directoryE = "/Metric3/" ; Directory of COSP Radar simulator
;	   directoryF = "/Metric3/" ; Working Directory
  directoryA = "/data/cnlmd/Satellites_v20110323/GOCCP_Monthly/"
  directoryB = "/data/ionela/runs_CMIP5_v3/AMIPNPC1Y/CMIP5_cf3hr/"
  directoryC = "/data/ionela/runs_CMIP5_v3/AMIPNPC1Y/HF/"
  directoryD = "/data/cnlmd/Satellites_v20110323/CloudSat/"
  directoryE = "/data/ionela/runs_CMIP5_v3/AMIPNPC1Y/CMIP5_cf3hr/"
  directoryF = "/data/cnlmd/CMIP5_AMIP_Metric/"

;--------------------------------------------------------------
; CALIPSO OBSERVATIONAL DATA
;--------------------------------------------------------------
;  example = "Metric4"
     file001 = "3D_CloudFraction330m_200706_avg_CFMIP2_sat_2.1.nc"
     file002 = "3D_CloudFraction330m_200707_avg_CFMIP2_sat_2.1.nc"
     file003 = "3D_CloudFraction330m_200708_avg_CFMIP2_sat_2.1.nc"
   pear  = addfile(directoryA+file001,"r")
   plum  = addfile(directoryA+file002,"r")
   fig   = addfile(directoryA+file003,"r")
      printVarSummary(pear)   ; overview of var

   GOCCP_lat = pear->latitude(:)
   GOCCP_lon = pear->longitude(:)
   GOCCP_alt = pear->alt_bound(0,:)
      print(GOCCP_alt)

      nlat = dimsizes(GOCCP_lat)
      nlon = dimsizes(GOCCP_lon)
      nalt = dimsizes(GOCCP_alt)

   GOCCP_cld001 = pear->clcalipso(0,:,:,:)  ;time, alt, latitude, longitude
      printVarSummary(GOCCP_cld001) 
         GOCCP_cld001@_FillValue = -9999
   GOCCP_cld002 = plum->clcalipso(0,:,:,:)
;      printVarSummary(GOCCP_cld002) 
         GOCCP_cld002@_FillValue = -9999
   GOCCP_cld003 = fig->clcalipso(0,:,:,:)
;      printVarSummary(GOCCP_cld003) 
         GOCCP_cld003@_FillValue = -9999

   GOCCP_CldFraction         = new((/3,nalt,nlat,nlon/),"double")
     GOCCP_CldFraction!0     = "months"
   GOCCP_CldFraction(0,:,:,:)=GOCCP_cld001
   GOCCP_CldFraction(1,:,:,:)=GOCCP_cld002
   GOCCP_CldFraction(2,:,:,:)=GOCCP_cld003
   printVarSummary(GOCCP_CldFraction) 

   GOCCP_CldFra=dim_avg_Wrap(dim_avg_Wrap(GOCCP_CldFraction(altitude|:,latitude|:,longitude|:,months|:)))
	GOCCP_CldFra!0 = "altitude"
	GOCCP_CldFra&altitude = GOCCP_alt
      printVarSummary(GOCCP_CldFra) 


;--------------------------------------------------------------
; MODEL WITH LIDAR SIMULATOR
;--------------------------------------------------------------
; CNam Note: Files staggered due to size of files
;----------
;  example = "Metric4"
     file100 = "cfadLidarsr532_cf3hr_IPSL-CM5A-LR_amip_r1i1p1_200807010300-200808010000.nc"
	apple  = addfile(directoryB+file100,"r")

   nmon=3
   print(nmon)

   COSP_BinCenter = apple->scatratio(:)            ;holds 15bins of Reflectivity
   COSP_HeightBins = apple->alt40(:)
      print(COSP_BinCenter) 
      print(COSP_HeightBins(::5)) 
   nSRatio  = dimsizes(COSP_BinCenter(3:14))
   nalt40   = dimsizes(COSP_HeightBins)

   COSP_lat=apple->lat
   COSP_lon=apple->lon
;     print(COSP_lat(:))
;     print(COSP_lon(:))
   nlat = dimsizes(COSP_lat)
   nlon = dimsizes(COSP_lon)


;--------------------------------------------------------------
; Define Variables
;--------------------------------------------------------------
   in=apple->cfadLidarsr532(1,3:14,:,:,:)
   Zonal_COSP_SRatio_month=new((/(2*nmon),nalt40,nlat/),typeof(in))
   delete(in)
	Zonal_COSP_SRatio_month!0="month"
	Zonal_COSP_SRatio_month!1="alt40"
	Zonal_COSP_SRatio_month!2="lat"
	Zonal_COSP_SRatio_month&alt40= COSP_HeightBins
	Zonal_COSP_SRatio_month&lat= COSP_lat
	Zonal_COSP_SRatio_month&lat@units= "degrees_north"


;--------------------------------------------------------------
; Calculations
;--------------------------------------------------------------
; Land and Ocean 
;----------
     ntime = dimsizes(apple->time)

     COSP_SRatio_month001a=apple->cfadLidarsr532(1:(((ntime-1)/2)-1):2,3:14,:,:,:)
	COSP_SRatio_month001a@_FillValue = 1.e20
	COSP_SRatio_month001a!0="time"
	COSP_SRatio_month001a!1="SRatio"
	COSP_SRatio_month001a!2="alt40"
	COSP_SRatio_month001a!3="lat"
	COSP_SRatio_month001a!4="lon"
     Zonal_COSP_SRatio_month(0,:,:)=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(COSP_SRatio_month001a(alt40|:,lat|:,SRatio|:,lon|:,time|:))))
     delete(COSP_SRatio_month001a)

     COSP_SRatio_month001b=apple->cfadLidarsr532(ntime/2:(ntime-1):2,3:14,:,:,:)
	COSP_SRatio_month001b@_FillValue = 1.e20
	COSP_SRatio_month001b!0="time"
	COSP_SRatio_month001b!1="SRatio"
	COSP_SRatio_month001b!2="alt40"
	COSP_SRatio_month001b!3="lat"
	COSP_SRatio_month001b!4="lon"
     Zonal_COSP_SRatio_month(1,:,:)=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(COSP_SRatio_month001b(alt40|:,lat|:,SRatio|:,lon|:,time|:))))
     delete(COSP_SRatio_month001b)
     print("Jun")
     delete(apple)
     delete(file100)

;----------
;  example = "Metric4"
     file100 = "cfadLidarsr532_cf3hr_IPSL-CM5A-LR_amip_r1i1p1_200807010300-200808010000.nc"
	apple  = addfile(directoryB+file100,"r")
     ntime = dimsizes(apple->time)

     COSP_SRatio_month002a=apple->cfadLidarsr532(1:(((ntime-1)/2)-1):2,3:14,:,:,:)
	COSP_SRatio_month002a@_FillValue = 1.e20
	COSP_SRatio_month002a!0="time"
	COSP_SRatio_month002a!1="SRatio"
	COSP_SRatio_month002a!2="alt40"
	COSP_SRatio_month002a!3="lat"
	COSP_SRatio_month002a!4="lon"
     Zonal_COSP_SRatio_month(2,:,:)=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(COSP_SRatio_month002a(alt40|:,lat|:,SRatio|:,lon|:,time|:))))
     delete(COSP_SRatio_month002a)

     COSP_SRatio_month002b=apple->cfadLidarsr532(ntime/2:(ntime-1):2,3:14,:,:,:)
	COSP_SRatio_month002b@_FillValue = 1.e20
	COSP_SRatio_month002b!0="time"
	COSP_SRatio_month002b!1="SRatio"
	COSP_SRatio_month002b!2="alt40"
	COSP_SRatio_month002b!3="lat"
	COSP_SRatio_month002b!4="lon"
     Zonal_COSP_SRatio_month(3,:,:)=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(COSP_SRatio_month002b(alt40|:,lat|:,SRatio|:,lon|:,time|:))))
     delete(COSP_SRatio_month002b)
     print("Jul")
     delete(apple)
     delete(file100)

;----------
;  example = "Metric4"
     file100 = "cfadLidarsr532_cf3hr_IPSL-CM5A-LR_amip_r1i1p1_200808010300-200809010000.nc"
	apple  = addfile(directoryB+file100,"r")
     ntime = dimsizes(apple->time)

     COSP_SRatio_month003a=apple->cfadLidarsr532(1:(((ntime-1)/2)-1):2,3:14,:,:,:)
	COSP_SRatio_month003a@_FillValue = 1.e20
	COSP_SRatio_month003a!0="time"
	COSP_SRatio_month003a!1="SRatio"
	COSP_SRatio_month003a!2="alt40"
	COSP_SRatio_month003a!3="lat"
	COSP_SRatio_month003a!4="lon"
     Zonal_COSP_SRatio_month(4,:,:)=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(COSP_SRatio_month003a(alt40|:,lat|:,SRatio|:,lon|:,time|:))))
     delete(COSP_SRatio_month003a)

     COSP_SRatio_month003b=apple->cfadLidarsr532(ntime/2:(ntime-1):2,3:14,:,:,:)
	COSP_SRatio_month003b@_FillValue = 1.e20
	COSP_SRatio_month003b!0="time"
	COSP_SRatio_month003b!1="SRatio"
	COSP_SRatio_month003b!2="alt40"
	COSP_SRatio_month003b!3="lat"
	COSP_SRatio_month003b!4="lon"
     Zonal_COSP_SRatio_month(5,:,:)=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(COSP_SRatio_month003b(alt40|:,lat|:,SRatio|:,lon|:,time|:))))
     delete(COSP_SRatio_month003b)
     print("Aug")
     delete(apple)

;----------

   Zonal_COSP_SRatio = dim_avg_Wrap(Zonal_COSP_SRatio_month(alt40|:,lat|:,month|:))


; --------------------------------------------------------------
;  READ IN DATA :  IPSL5B MODEL DATA
; --------------------------------------------------------------
;  example = systemfunc("cdo selvar,rneb "+directoryC+"Metric4 "+directoryF+"Metric5")
;    extract1=systemfunc("cdo selvar,rneb "+directoryC+"AMIPNPC1Y_20080601_20080630_3H_histhf3h.nc "+directoryF+"rneb_AMIPNPC1Y_20080601_20080630_3H_histhf3h.nc")
;    extract2=systemfunc("cdo selvar,rneb "+directoryC+"AMIPNPC1Y_20080701_20080731_3H_histhf3h.nc "+directoryF+"rneb_AMIPNPC1Y_20080701_20080731_3H_histhf3h.nc")
;    extract3=systemfunc("cdo selvar,rneb "+directoryC+"AMIPNPC1Y_20080801_20080831_3H_histhf3h.nc "+directoryF+"rneb_AMIPNPC1Y_20080801_20080831_3H_histhf3h.nc")

    file200 = systemfunc ("ls "+directoryF+"rneb*.nc") ; file paths
        kiwi  = addfiles (file200, "r")
        ListSetType (kiwi, "cat")
	printVarSummary(kiwi)   ; overview of var

   IPSL5B_lat = kiwi[0]->lat(:)

   IPSL5B_rneb = kiwi[:]->rneb(:,:,:,:)   
	IPSL5B_rneb@_FillValue = 9.96921e+36

   IPSL5B_presnivs = kiwi[0]->presnivs(:)
	printVarSummary(IPSL5B_rneb) 
	printVarSummary(IPSL5B_presnivs) 
   IPSL5B_altitude=(1-((IPSL5B_presnivs/101325)^(1/5.25588)))/2.25577e-5/1000
	print(IPSL5B_altitude)


   IPSL5B_CldFra=dim_avg_Wrap(dim_avg_Wrap(IPSL5B_rneb(presnivs|:,lat|:,lon|:,time|:)))
	IPSL5B_CldFra!0="alt"
	IPSL5B_CldFra&alt=IPSL5B_altitude
   printVarSummary(IPSL5B_CldFra)




; --------------------------------------------------------------
;  CLOUDSAT OBSERVATIONAL DATA
; --------------------------------------------------------------
;  example = "Metric4"
   file300 = "cfadDbze94_200801-200812.nc"
 	plum  = addfile(directoryD+file300,"r")

   CloudSat_lat = plum->lat(:)
   CloudSat_lon = plum->lon(:)
;      print(CloudSat_lat)

   CloudSat_BinBoundary = plum->dbze_bnds(:,:)
   CloudSat_BinCenter = plum->dbze(:)
   CloudSat_AltBins = plum->alt40(:)
      print(CloudSat_BinCenter) 
      print(CloudSat_AltBins(::5))   ; overview of var
      nheight   = dimsizes(CloudSat_AltBins)
      nbincnt   = dimsizes(CloudSat_BinCenter(3:14))         ; for dBZe > -30 (-27.5)


   CloudSat_dBZe = plum->cfadDbze94(5:7,:,:,:,:)
      printVarSummary(CloudSat_dBZe) 
      CloudSat_dBZe@_FillValue = -999
      ntime_dBZe = dimsizes(plum->time(5:7))


  CloudSat_CldFra=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(CloudSat_dBZe(alt40|:,lat|:,dbze|3:14,lon|:,time|:))))
  printVarSummary(CloudSat_CldFra)
  delete(CloudSat_dBZe)

; --------------------------------------------------------------
; MODEL WITH RADAR SIMULATOR
; --------------------------------------------------------------
;      CNam Note: Files staggered due to size of files
;----------
;  example = "Metric4"
     file400 = "cfadDbze94_cf3hr_IPSL-CM5A-LR_amip_r1i1p1_200806010300-200806210000.nc" ; CNam NOTE: File Name says ISPL5A but it is IPSL5B
	grape  = addfile(directoryE+file400,"r")

   nmon=3
   print(nmon)

   COSP_BinCenter = grape->dbze(:)            ;holds 15bins of Reflectivity
   COSP_HeightBins = grape->alt40(:)
      print(COSP_BinCenter) 
      print(COSP_HeightBins(::5)) 
   ndBZe  = dimsizes(COSP_BinCenter(3:14))
   nalt40   = dimsizes(COSP_HeightBins)

   COSP_lat=grape->lat
   COSP_lon=grape->lon
;     print(COSP_lat(:))
;     print(COSP_lon(:))
   nlat = dimsizes(COSP_lat)
   nlon = dimsizes(COSP_lon)


; --------------------------------------------------------------
; Define Variables
; ----------------
   in=grape->cfadDbze94(1,3:14,:,:,:)
   Zonal_COSP_dBZe_month=new((/(2*nmon),nalt40,nlat/),typeof(in))
   delete(in)
	Zonal_COSP_dBZe_month!0="month"
	Zonal_COSP_dBZe_month!1="alt40"
	Zonal_COSP_dBZe_month!2="lat"
	Zonal_COSP_dBZe_month&alt40= COSP_HeightBins
	Zonal_COSP_dBZe_month&lat= COSP_lat
	Zonal_COSP_dBZe_month&lat@units= "degrees_north"


; --------------------------------------------------------------
; Calculations
; ----------------
; Land and Ocean
; ----------------
     ntime = dimsizes(grape->time)

     COSP_dBZe_month001a=grape->cfadDbze94(1:(((ntime-1)/2)-1):2,3:14,:,:,:)
	COSP_dBZe_month001a@_FillValue = 1.e20
	COSP_dBZe_month001a!0="time"
	COSP_dBZe_month001a!1="dbze"
	COSP_dBZe_month001a!2="alt40"
	COSP_dBZe_month001a!3="lat"
	COSP_dBZe_month001a!4="lon"
     Zonal_COSP_dBZe_month(0,:,:)=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(COSP_dBZe_month001a(alt40|:,lat|:,dbze|:,lon|:,time|:))))
     delete(COSP_dBZe_month001a)

     COSP_dBZe_month001b=grape->cfadDbze94(ntime/2:(ntime-1):2,3:14,:,:,:)
	COSP_dBZe_month001b@_FillValue = 1.e20
	COSP_dBZe_month001b!0="time"
	COSP_dBZe_month001b!1="dbze"
	COSP_dBZe_month001b!2="alt40"
	COSP_dBZe_month001b!3="lat"
	COSP_dBZe_month001b!4="lon"
     Zonal_COSP_dBZe_month(1,:,:)=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(COSP_dBZe_month001b(alt40|:,lat|:,dbze|:,lon|:,time|:))))
     delete(COSP_dBZe_month001b)
     print("Jun")
     delete(grape)
     delete(file400)

;----------
;  example = "Metric4"
     file400 = "cfadDbze94_cf3hr_IPSL-CM5A-LR_amip_r1i1p1_200807010300-200808010000.nc"
	grape  = addfile(directoryE+file400,"r")
     ntime = dimsizes(grape->time)

     COSP_dBZe_month002a=grape->cfadDbze94(1:(((ntime-1)/2)-1):2,3:14,:,:,:)
	COSP_dBZe_month002a@_FillValue = 1.e20
	COSP_dBZe_month002a!0="time"
	COSP_dBZe_month002a!1="dbze"
	COSP_dBZe_month002a!2="alt40"
	COSP_dBZe_month002a!3="lat"
	COSP_dBZe_month002a!4="lon"
     Zonal_COSP_dBZe_month(2,:,:)=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(COSP_dBZe_month002a(alt40|:,lat|:,dbze|:,lon|:,time|:))))
     delete(COSP_dBZe_month002a)

     COSP_dBZe_month002b=grape->cfadDbze94(ntime/2:(ntime-1):2,3:14,:,:,:)
	COSP_dBZe_month002b@_FillValue = 1.e20
	COSP_dBZe_month002b!0="time"
	COSP_dBZe_month002b!1="dbze"
	COSP_dBZe_month002b!2="alt40"
	COSP_dBZe_month002b!3="lat"
	COSP_dBZe_month002b!4="lon"
     Zonal_COSP_dBZe_month(3,:,:)=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(COSP_dBZe_month002b(alt40|:,lat|:,dbze|:,lon|:,time|:))))
     delete(COSP_dBZe_month002b)
     print("Jul")
     delete(grape)
     delete(file400)

;----------
;  example = "Metric4"
     file400 = "cfadDbze94_cf3hr_IPSL-CM5A-LR_amip_r1i1p1_200808010300-200809010000.nc"
	grape  = addfile(directoryE+file400,"r")
     ntime = dimsizes(grape->time)

     COSP_dBZe_month003a=grape->cfadDbze94(1:(((ntime-1)/2)-1):2,3:14,:,:,:)
	COSP_dBZe_month003a@_FillValue = 1.e20
	COSP_dBZe_month003a!0="time"
	COSP_dBZe_month003a!1="dbze"
	COSP_dBZe_month003a!2="alt40"
	COSP_dBZe_month003a!3="lat"
	COSP_dBZe_month003a!4="lon"
     Zonal_COSP_dBZe_month(4,:,:)=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(COSP_dBZe_month003a(alt40|:,lat|:,dbze|:,lon|:,time|:))))
     delete(COSP_dBZe_month003a)

     COSP_dBZe_month003b=grape->cfadDbze94(ntime/2:(ntime-1):2,3:14,:,:,:)
	COSP_dBZe_month003b@_FillValue = 1.e20
	COSP_dBZe_month003b!0="time"
	COSP_dBZe_month003b!1="dbze"
	COSP_dBZe_month003b!2="alt40"
	COSP_dBZe_month003b!3="lat"
	COSP_dBZe_month003b!4="lon"
     Zonal_COSP_dBZe_month(5,:,:)=dim_sum_Wrap(dim_avg_Wrap(dim_avg_Wrap(COSP_dBZe_month003b(alt40|:,lat|:,dbze|:,lon|:,time|:))))
     delete(COSP_dBZe_month003b)
     print("Aug")
     delete(grape)
     delete(file400)
;----------

   Zonal_COSP_dBZe = dim_avg_Wrap(Zonal_COSP_dBZe_month(alt40|:,lat|:,month|:))




;======================================================================  
; PLOT
;======================================================================
  res001                      = True               ; enable plot options
  res001@gsnMaximize          = True               ; Maximize plot in frame.
  res001@gsnDraw              = False              ; don't draw
  res001@gsnFrame             = False              ; don't advance frame

  res001@cnFillOn             = True               ; Fill contours
  res001@cnFillMode           = "RasterFill"       ; Blocks vs. Smooth
  res001@cnLinesOn            = False              ; Contour lines off
  res001@cnLineLabelsOn       = False              ; turn on/off the contour line label
  res001@cnInfoLabelOn        = False              ; line info
  res001@cnLevelSelectionMode = "ExplicitLevels"    ; set explicit contour levels
  res001@cnLevels             = (/0,0.05,0.10,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5/)   ; set levels

  res001@gsnSpreadColors      = True               ; spread colors around 0
  res001@gsnSpreadColorStart  = 2                  ; start at color XXX in colormap

  res001@txFont			= 21                 ; hevelica
  res001@tiMainFont		= 21
  res001@tiXAxisFont		= 21
  res001@tiYAxisFont		= 21
  res001@tmXBLabelFont		= 21
  res001@tmYLLabelFont		= 21
  res001@lbLabelFont		= 21

  res001@gsnLeftString        = ""                  ;string at right top of plot
  res001@gsnRightString       = ""                  ; string at right top of plot
  res001@tiXAxisString        = "Latitude"  
  res001@tiXAxisFontHeightF = 0.05
  res001@tiYAxisFontHeightF = 0.05
;  res001@lbLabelBarOn         = False              ; turn off individual cb's

  res001@lbLabelStride   = 2
  res001@tmXBLabelFontHeightF  = 0.03
  res001@tmYLLabelFontHeightF  = 0.04

  res001@tiMainFontHeightF = 0.04

  res001@tmXTBorderOn      = True ; kills border line (x-axis top)
  res001@tmYRBorderOn      = True ; kills border line (y-axis right)
  res001@tmXTOn            = False ; kills tick marks (x-axis top)
  res001@tmYROn            = False ; kills tick marks (y-axis right)

  res001@cnLabelBarEndStyle = "ExcludeOuterBoxes"

;======================================================================  
; Fields Specific for Plot (0)
;======================================================================  
  res001@tiMainString         = "CALIPSO GOCCP"  ;Main title
  res001@tiYAxisString        = "Altitude (km)"
  res001@gsnRightString       = "Cloud Fraction"; string at right top of plot

  res001@tmXBMode          = "Explicit"
  res001@tmXBValues        =(/-90,-60,-30,0,30,60,90/)
  res001@tmXBLabels        =(/"90S","60S","30S","0","30N","60N","90N"/)
  res001@tmYLMode          = "Explicit"
  res001@tmYLValues 	   = (/0,2.4,4.8,7.2,9.6,12,14.4,16.8,19.2/) ; cheat by naming 18.72km 19.2km
  res001@tmYLLabels 	   = (/"0","","4.8","","9.6","","14.4","",""/)

  plot(0)= gsn_csm_contour(wks,GOCCP_CldFra,res001)

;======================================================================  
; Field Specific for Plot (1)
;======================================================================
  res001@tiMainString         = "IPSL5B Lidar Sim."  ;Main title
  res001@tiYAxisString        = ""

  res001@tmXBMode          = "Explicit"
  res001@tmXBValues        =(/-90,-60,-30,0,30,60,90/)
  res001@tmXBLabels        =(/"90S","60S","30S","0","30N","60N","90N"/)
  res001@tmYLMode          = "Explicit"
  res001@tmYLValues        = (/0,2400,4800,7200,9600,12000,14400,16800,19200/)
  res001@tmYLLabels 	   = (/"0","","4.8","","9.6","","14.4","","19.2"/)

  plot(1) = gsn_csm_contour(wks,Zonal_COSP_SRatio,res001)            ; plot contour map


;====================================================================== 
; Fields Specific for Plot (2)
;======================================================================
  res001@tiMainString         = "IPSL5B"  ;Main title
  res001@tiYAxisString        = "" 
  res001@gsnStringFontHeightF = 0.03

  res001@trYMaxF=19.2
  res001@tmYLMode       = "Explicit"
  res001@tmYLValues 	= (/0,2.4,4.8,7.2,9.6,12,14.4,16.8,19.2/) ; cheat by naming 18.72km 19.2km
  res001@tmYLLabels 	= (/"0","","4.8","","9.6","","14.4","",""/)

  res001@gsnYAxisIrregular2Linear = True  
  plot(2) = gsn_csm_contour(wks,IPSL5B_CldFra,res001)
  res001@gsnYAxisIrregular2Linear = False


;======================================================================  
; Fields Specific for Plot (3)
;======================================================================  
  res001@tiMainString         = "CloudSat"  ;Main title
  res001@tiYAxisString        = "Altitude (km)"
  res001@gsnRightString       = "Hydrometeor Fraction"; string at right top of plot

  res001@tmXBMode          = "Explicit"
  res001@tmXBValues        =(/-90,-60,-30,0,30,60,90/)
  res001@tmXBLabels        =(/"90S","60S","30S","0","30N","60N","90N"/)
  res001@tmYLMode          = "Explicit"
  res001@tmYLValues        = (/0,2400,4800,7200,9600,12000,14400,16800,19200/)
  res001@tmYLLabels 	   = (/"0","","4.8","","9.6","","14.4","","19.2"/)

  plot(3)= gsn_csm_contour(wks,CloudSat_CldFra,res001)


;======================================================================  
; Field Specific for Plot (4)
;======================================================================
  res001@tiMainString         = "ISPL5B Radar Sim."  ;Main title
  res001@tiYAxisString        = ""

  plot(4) = gsn_csm_contour(wks,Zonal_COSP_dBZe,res001)            ; plot contour map



;======================================================================
; PANEL PLOT 
;======================================================================
  res_Panel                     = True      ; modify the panel plot
  res_Panel@gsnMaximize         = True      ; maximize plot 

  res_Panel@gsnPanelXWhiteSpacePercent = 3    ;extra white space between panels in the x and y directions
  res_Panel@gsnPanelYWhiteSpacePercent = 10

  res_Panel@txString            = "Zonal Hydrometeor Fraction 2008 JJA"
  res_Panel@txFontHeightF       = 0.02
  res_Panel@txFont               = 21                 ; hevelica

  res_Panel@lbOrientation               = "vertical"      ; vertical label bars
  res_Panel@lbLabelFontHeightF          = 0.01            ; label bar font
  res_Panel@lbPerimOn                   = False           ; no box around label bar
  res_Panel@lbLabelStrings = (/"0","","0.10","","0.2","","0.3","","0.4"/) ; Format the labels 
  res_Panel@cnLabelBarEndStyle = "ExcludeOuterBoxes"

  res_Panel@pmLabelBarWidthF            = 0.07            ; control size of colorbar
  res_Panel@pmLabelBarHeight           = 0.3             ;
  res_Panel@pmLabelBarOrthogonalPosF    = 0.03            ; position wrt plot

  res_Panel@lbAutoManage                = False           ; manual   
              

;======================================================================
  gsn_panel(wks,plot,(/3,3/),res_Panel)             ; now draw as one plot


end

