#!/bin/sh
# =======================================================================================
# =======================================================================================
export CIME_MODEL=cesm
export COMPSET=I2000Clm50Fates
export RES=CLM_USRDAT                                
export MACH=hydra                                             # Name your machine
export COMPILER=gnu                                            # Name your compiler
export SITE=yangambi_jra                                                # Name your site

export TAG=fates-tutorial-${SITE}  # give your run a name
export CASE_ROOT=$VSC_SCRATCH/cesm/cases/                  # where in scratch should the run go?
export PARAM_FILES=$VSC_SCRATCH/cesm/params                    # FATES parameter file location

# surface and domain files
export SITE_BASE_DIR=$VSC_SCRATCH/cesm/sitedata
export CLM_USRDAT_DOMAIN=domain.lnd.fv0.9x1.25_gx1v7_${SITE}_c250826.nc
export CLM_USRDAT_SURDAT=surfdata_${SITE}_hist_2000_16pfts_c250826.nc
export CLM_USRDAT_MESH=domain_${SITE}_fates_mesh.nc
export CLM_SURFDAT_DIR=${SITE_BASE_DIR}/${SITE}
export CLM_DOMAIN_DIR=${SITE_BASE_DIR}/${SITE}
export CLM_MESH_DIR=${SITE_BASE_DIR}/${SITE}
export DIN_LOC_ROOT_FORCE=${SITE_BASE_DIR}


# climate data will recycle data between these years 
export DATM_START=2003
export DATM_STOP=2015

# DEPENDENT PATHS AND VARIABLES (USER MIGHT CHANGE THESE..)
# =======================================================================================
export SOURCE_DIR=$VSC_SCRATCH/cesm/sources/ctsm-5.2.0/cime/scripts # change to the path where your /cime/sripts is
cd ${SOURCE_DIR}
export CASE_NAME=${CASE_ROOT}/${TAG}.`date +"%Y-%m-%d"`


# REMOVE EXISTING CASE IF PRESENT
rm -r ${CASE_NAME}

# CREATE THE CASE
./create_newcase --case=${CASE_NAME} --res=${RES} --compset=${COMPSET} --mach=${MACH} --compiler=${COMPILER} --run-unsupported 

cd ${CASE_NAME}


# SET PATHS TO SCRATCH ROOT, DOMAIN AND MET DATA (USERS WILL PROB NOT CHANGE THESE)
# =================================================================================

./xmlchange --force CLM_USRDAT_DIR=/scratch/brussel/vo/000/bvo00003/vsc46573/cesm/sitedata/${SITE}

./xmlchange --force PTS_LON=24.4

./xmlchange --force PTS_LAT=0.76

#./xmlchange ATM_DOMAIN_MESH=${CLM_MESH_DIR}/${CLM_USRDAT_MESH}
./xmlchange LND_DOMAIN_FILE=${CLM_USRDAT_DOMAIN}
./xmlchange LND_DOMAIN_PATH=${CLM_DOMAIN_DIR}
#./xmlchange DATM_MODE=1PT
#./xmlchange DIN_LOC_ROOT_CLMFORC=${DIN_LOC_ROOT_FORCE}
./xmlchange CLM_USRDAT_NAME=${SITE}

# For constant CO2
./xmlchange CCSM_CO2_PPMV=412
./xmlchange DATM_CO2_TSERIES=none
./xmlchange CLM_CO2_TYPE=constant

# SPECIFY PE LAYOUT FOR SINGLE SITE RUN (USERS WILL PROB NOT CHANGE THESE)
# =================================================================================

./xmlchange NTASKS=1

# SPECIFY RUN TYPE PREFERENCES (USERS WILL CHANGE THESE)
# =================================================================================

./xmlchange DEBUG=FALSE
./xmlchange STOP_N=10                        # how many years should the simulation run
./xmlchange RUN_STARTDATE='1900-01-01'       # which year corresponds to first year of simulation
./xmlchange STOP_OPTION=nyears
./xmlchange REST_N=10                        # how often to make restart files
./xmlchange RESUBMIT=0                       # how many resubmits (only important for very long runs) 

./xmlchange DATM_YR_START=${DATM_START}
./xmlchange DATM_YR_END=${DATM_STOP}    # are defined at start of script


# MACHINE SPECIFIC, AND/OR USER PREFERENCE CHANGES (USERS WILL CHANGE THESE)
# =================================================================================

# point to your parameter file
# add any history variables you want 
cat >> user_nl_clm <<EOF
fsurdat = '${CLM_SURFDAT_DIR}/${CLM_USRDAT_SURDAT}'
fates_paramfile='${PARAM_FILES}/fates_params_default-1pft.nc'
use_fates=.true.
use_fates_planthydro=.false.
hist_fincl1=
'FATES_VEGC_PF', 'FATES_VEGC_ABOVEGROUND',
'FATES_NPLANT_SZ', 'FATES_CROWNAREA_PF',
'FATES_LAI', 'FATES_BASALAREA_SZPF', 'FATES_CA_WEIGHTED_HEIGHT', 'Z0MG',
'FATES_MORTALITY_CSTARV_CFLUX_PF', 'FATES_MORTALITY_CFLUX_PF',
'FATES_MORTALITY_HYDRO_CFLUX_PF', 'FATES_MORTALITY_BACKGROUND_SZPF',
'FATES_MORTALITY_HYDRAULIC_SZPF', 'FATES_MORTALITY_CSTARV_SZPF',
'FATES_MORTALITY_IMPACT_SZPF', 'FATES_MORTALITY_TERMINATION_SZPF',
'FATES_MORTALITY_FREEZING_SZPF', 'FATES_MORTALITY_CANOPY_SZPF',
'FATES_MORTALITY_USTORY_SZPF', 'FATES_NPLANT_SZPF',
'FATES_NPLANT_CANOPY_SZPF', 'FATES_NPLANT_USTORY_SZPF',
'FATES_NPP_PF', 'FATES_GPP_PF', 'FATES_NEP', 'FATES_FIRE_CLOSS',
'FATES_ABOVEGROUND_PROD_SZPF', 'FATES_ABOVEGROUND_MORT_SZPF',
'FATES_NPLANT_CANOPY_SZ', 'FATES_NPLANT_USTORY_SZ',
'FATES_DDBH_CANOPY_SZ', 'FATES_DDBH_USTORY_SZ',
'FATES_MORTALITY_CANOPY_SZ', 'FATES_MORTALITY_USTORY_SZ'
EOF

# Setup case
./case.setup 
#cp ${SITE_BASE_DIR}/${SITE}/user_mods/user_nl_datm_streams  $VSC_SCRATCH/cesm/cases/${TAG}.`date +"%Y-%m-%d"`/
./preview_namelists

# Build and submit the case
./case.build --skip-provenance-check # skipping provenance avoids calling git (for this tutorial only)
./case.submit
