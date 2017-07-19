# CFMIP_LidarRadar
Zonal cloud and hydrometeor plots comparing COSP Lidar and Radar with CALIPSO-GOCCP and CloudSat.

The zonal plots show cloud fraction as determined by the lidar in CALIPSO GOCCP observations,
model with lidar simulator and the model itself. Similarly, the hydrometeor fraction as determined by
CloudSat and the radar simulator.

# REFERENCE:
Nam, C., and J. Quaas, Evaluation of clouds and precipitation in the ECHAM5 general circulation model using CALIPSO and CloudSat , J. Clim., 25, 4975-4992, doi:10.1175/JCLI-D-11-00347.1, 2012.

# Model Input Variables
Unfortunately, due to file size and availability, no supplementary data will be provided for this script.
Please note that within the NCL script, all IPSL+simulator files AND variable names must be replaced.
The files below are merely and example of which variables are needed to create the plots.

| Frequency |	Variable |	Variable labels |	Unit |	Example File |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| Monthly | 3D Cloud Fraction | cl | % | cl_Amon_CanAM4_amip_r1i1p1_195001-200912.nc
| | COSP lidar simulator scattering ratio | cfadLidarsr532 | | cfadLidarsr532_cfOff_CanAM4_amip_r1i1p1_200801-200912.n
| | COSP radar simulator reflectivities | cfadDbze94 | | cfadDbze94_cfOff_CanAM4_amip_r1i1p1_200801-200912.nc

# Obs4MIPS Input Variables
| Frequency |	Variable |	Variable labels |	Unit |	
| ------------- | ------------- | ------------- | ------------- | 
| Monthly | 3D Cloud Fraction CALIPSO-GOCCP | clcalipso | % |
| | CALIPSO-GOCCP Scattering Ratio | cfadLidarsr532 |	 | 
| | CloudSat Reflectivities |	cfadDbze94 |  | 

# Figure Generation
This script processes and draws the figure 'LidarRadarZonal_Metrics_CNam.png'
