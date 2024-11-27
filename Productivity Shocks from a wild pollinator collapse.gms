** Estimation of productivity shocks for the study "The Economic and Agricultural Repercussions of a Wild Pollinator Collapse in Europe"

** Introduce all sets
$INCLUDE SetsDefinition.gms

Parameter
** The following parameters are loaded from the FAOdata_input excel sheet
FAOprod(regFAO,FAOcrops)                           Production in tons according to FAO 
FAOprices(regFAO,FAOcrops)                         Producer Prices in USD perton according to FAO
DepRatios(FAOcrops,source,intens)                       Dependency ratio at different intensities for Siopa et al. (2024) and Klein et al. (2007)

** The following parameters are computed based on the input data
FAOprod(regFAO,FAOcrops)                            Production in tons according to FAO for 2017
FAOprices(regFAO,FAOcrops)                          Producer Prices in USD perton according to FAO for 2017

regCAPRI_prodvalue(regCAPRI,FAOcrops)                   Production value in each FAO crop
reg_prodvalue(reg,FAOcrops)                             Regional value in each FAO crop
global_prodvalue(FAOcrops)                              Global value in each FAO crops

regCAPRI_prodshare(regCAPRI,FAOcrops)                   CAPRI region production share
reg_prodshare(reg,FAOcrops)                             Regional (continental) production share
global_prodshare(FAOcrops)                              Global production shares

CAPRIreg_price(regCAPRI,FAOcrops)                       Price at CAPRI region
reg_price(reg,FAOcrops)                                 Regional price
global_price(FAOcrops)                                  Global price

prod_value(regFAO,FAOcrops)                             Production value of FAO crop in FAO region
prod_valueCAPRI(regCAPRI,CAPRIcrops)                    Aggregate production value of CAPRI commodity in CAPRI region

share_aggregate(regFAO,FAOcrops,regCAPRI,CAPRIcrops)    Share of FAOcrop in FAOregion in CAPRIcrop and CAPRIregion
poll_shocks(regCAPRI,CAPRIcrops,source,intens)          Productivity shocks for CAPRIcrops' CAPRIregions and intensity for a collapse of both MANAGED & WILD pollinators

;

*** Loading data from excel input file
** Possibly delete the line "writeAll: True" if you encounter an error


$onEmbeddedCode Connect:
- ExcelReader:
    file: data_input_file.xlsx
    symbols:
      - name: FAOprod
        range: Production!F4
        rowDimension: 2
        columnDimension: 0
      - name: FAOprices
        range: ProducerPrices!F4
        rowDimension: 2
        columnDimension: 0
      - name: DepRatios
        range: DepRatios!B4
        rowDimension: 1
        columnDimension: 2             
- GAMSWriter:
    writeAll: True
    domainCheckType: checked
$offEmbeddedCode


** Aliases of selected sets
Alias(FAOcrops2, FAOcrops), (regCAPRI2, regCAPRI), (reg2, reg);


** Set dependence ratios to 0.99 if they equal 1
*DepRatios(FAOcrops,source,intens)$(DepRatios(FAOcrops,source,intens) EQ 1) = 0.99;
DepRatios(FAOcrops,source,intens)$(DepRatios(FAOcrops,source,intens) GT 0.99) = 0.99;

** calculate the confidence interval assuming a triangular distribution
scalar
cl Confidence Level /0.95/ 
er Error level at each side of the distribution

;

er = (1-cl)/2;

** to avoid values too close to zero
DepRatios(FAOcrops,source,"Max")$DepRatios(FAOcrops,source,"Max") = DepRatios(FAOcrops,source,"Max")+0.0001;


** The confidence interval is estimated assuming a triangular distribution with the mode (Assumed to be equal to the mean), as well as the minimum (Min) and maximum (Max) values as determined by either Siopa et al or Klein et al.
** The lower bound is then: lower = Min + (er * (Max - Min) * (Mean - Min))^(0.5)
** and the upper bound is: upper = Max - (er * (Max-Min) * (Max-Mean))^(0.5)

** Estimate lower bound with P2.5
DepRatios(FAOcrops,source,"lower")$(DepRatios(FAOcrops,source,"Mean"))  =
                    DepRatios(FAOcrops,source,"Min") +
                            (er*(DepRatios(FAOcrops,source,"Max")-DepRatios(FAOcrops,source,"Min"))
                            * (DepRatios(FAOcrops,source,"Mean")-DepRatios(FAOcrops,source,"Min")))**(0.5);

** Estimate upper bound with P97.5
DepRatios(FAOcrops,source,"upper")$(DepRatios(FAOcrops,source,"Mean")) =
            DepRatios(FAOcrops,source,"Max") -
                            (er*(DepRatios(FAOcrops,source,"Max")-DepRatios(FAOcrops,source,"Min"))
                            * (DepRatios(FAOcrops,source,"Max")-DepRatios(FAOcrops,source,"Mean")))**(0.5);
 
*** Calculate production value weighted average prices at the level of CAPRIregion, continental region and globally ****

regCAPRI_prodvalue(regCAPRI,FAOcrops)   = SUM(regFAO, map_regFAO_regCAPRI(regFAO,regCAPRI) * FAOprod(regFAO,FAOcrops) * FAOprices(regFAO,FAOcrops)) ;
                      
reg_prodvalue(reg,FAOcrops)  = SUM(regFAO, map_regFAO_reg(regFAO,reg) * FAOprod(regFAO,FAOcrops) * FAOprices(regFAO,FAOcrops)) ;

global_prodvalue(FAOcrops) = SUM(regFAO, FAOprod(regFAO,FAOcrops) * FAOprices(regFAO,FAOcrops));


regCAPRI_prodshare(regCAPRI,FAOcrops)$regCAPRI_prodvalue(regCAPRI,FAOcrops) = regCAPRI_prodvalue(regCAPRI,FAOcrops) / SUM(regCAPRI2, regCAPRI_prodvalue(regCAPRI2,FAOcrops)) ;

reg_prodshare(reg, FAOcrops)$reg_prodvalue(reg,FAOcrops) = reg_prodvalue(reg,FAOcrops)  / SUM(reg2, reg_prodvalue(reg2,FAOcrops) );

global_prodshare(FAOcrops)$global_prodvalue(FAOcrops) = global_prodvalue(FAOcrops) / SUM(FAOcrops2, global_prodvalue(FAOcrops2));


CAPRIreg_price(regCAPRI,FAOcrops)= SUM(regFAO,  FAOprices(regFAO,FAOcrops) *  regCAPRI_prodshare(regCAPRI,FAOcrops));
reg_price(reg,FAOcrops)          =  SUM(regFAO, FAOprices(regFAO,FAOcrops) *  reg_prodshare(reg,FAOcrops));                     
global_price(FAOcrops)           =  SUM(regFAO, FAOprices(regFAO,FAOcrops) *  global_prodshare(FAOcrops));                     

**** Estimate the production value per FAO region with either national producer prices (if available), CAPRIregion avg. prices, continental avg. prices - or if all fails - with global average prices

** calculate with national prices

prod_value(regFAO,FAOcrops)$FAOprices(regFAO,FAOcrops) =  FAOprod(regFAO,FAOcrops) * FAOprices(regFAO,FAOcrops);


** calculate with CAPRI regional prices
prod_value(regFAO,FAOcrops)$(FAOprices(regFAO,FAOcrops) EQ 0) = FAOprod(regFAO,FAOcrops) *
                            SUM(regCAPRI$map_regFAO_regCAPRI(regFAO,regCAPRI),CAPRIreg_price(regCAPRI,FAOcrops));

** calculate with regional prices if all else is zero
prod_value(regFAO,FAOcrops)$(FAOprices(regFAO,FAOcrops) EQ 0 and SUM(regCAPRI$map_regFAO_regCAPRI(regFAO,regCAPRI),CAPRIreg_price(regCAPRI,FAOcrops)) EQ 0)
                                = FAOprod(regFAO,FAOcrops) * SUM(reg$map_regFAO_reg(regFAO,reg),reg_price(reg,FAOcrops) );
                                                        
** if all prices above are zero then calculate with global price                            
prod_value(regFAO,FAOcrops)$(FAOprices(regFAO,FAOcrops) EQ 0 and
                    SUM(regCAPRI$map_regFAO_regCAPRI(regFAO,regCAPRI),CAPRIreg_price(regCAPRI,FAOcrops)) EQ 0 and
                    SUM(reg$map_regFAO_reg(regFAO,reg), reg_price(reg,FAOcrops) EQ 0) )
                                = FAOprod(regFAO,FAOcrops) * global_price(FAOcrops);
                                
  
****  calculate production value for each CAPRI region

prod_valueCAPRI(regCAPRI,CAPRIcrops) = SUM(regFAO$map_regFAO_regCAPRI(regFAO,regCAPRI),
                    SUM(FAOcrops$map_FAOcrops_CAPRIcrops(FAOcrops,CAPRIcrops), prod_value(regFAO,FAOcrops)));


share_aggregate(regFAO,FAOcrops,regCAPRI,CAPRIcrops)$(prod_valueCAPRI(regCAPRI,CAPRIcrops) and map_regFAO_regCAPRI(regFAO,regCAPRI)
                    and map_FAOcrops_CAPRIcrops(FAOcrops,CAPRIcrops))   = prod_value(regFAO,FAOcrops) / prod_valueCAPRI(regCAPRI,CAPRIcrops) ;

** the CAPRI model includes an aggregate for "OAFC" - however it is not available as a single commodity
** The chosen setting maps "lupins" (210) "mustard seed" (292), "poppy seed" (296) and "linseed" to OAFC - which cannot be shocked.
** Consequently, these crops are taken out from the subsequent analyis - which is uncritical given the almost negligible role of these crops.

share_aggregate(regFAO,FAOcrops,regCAPRI,"OAFC") =   0;

                        

** Calculate pollinator shocks for both MANAGED AND WILD POLLINATORS - for all regions, crops, intensities and data sources 
poll_shocks(regCAPRI,CAPRIcrops,source,intens)  = SUM(regFAO$map_regFAO_regCAPRI(regFAO,regCAPRI),
                                    SUM(FAOcrops$map_FAOcrops_CAPRIcrops(FAOcrops,CAPRIcrops),
                                    share_aggregate(regFAO,FAOcrops,regCAPRI,CAPRIcrops) *
                                    DepRatios(FAOcrops,source,intens)));
                                    

** Assign data for the wild pollinator contribution to different crops - at global and European scale
** Note: The global scale is not used for the modelling. Oil palm, coffee and cocoa are excluded because the scenario only concerns Europe.

Table
wild_contribution(CAPRIcrops, scope) Mean wild pollinator contribution to different crops according to Reilly et al. 2024
** data is taken from the excel sheet "Wild pollinator contribution data from Reilly et al..xlsx"- see the matrix from C102:K128 in the sheet "wild share data"
** data refers to the mean contribution of pollinators to all measured yield indicators for either globally or just Europe

     global europe
* For Tomatos the overall average is assumed 
TOMA 47.8  50.4  
SUNF 14.5  14.67 
* For  soybeans the overall average is assumed 
SOYA 47.8  50.4  
RAPE 62.9  59.63 
PULS 74.0  76.0
OVEG 72.8  76.0  
OFRU 47.8  48.13 
OAFC 58.0  58.0  
OCER 45.5  23.0
* for Citrus the global value is used for Europe
CITR 15.5  15.5
APPL 35.7  42.92
    ;
    
** Calculate decline in wild pollinator shocks

Parameter
wild_poll_shocks(regCAPRI,CAPRIcrops,source,intens)     Productivity shocks following a collapse in only  WILD pollinators
CAPRI_base_prodvalue(CAPRIcrops,regCAPRI)               Production value of CAPRI commodities in the reference scenario - used as aggregation weights
CAPRI_Europe_prodshare(CAPRIcrops,regCAPRI)             Production value shares of each CAPRI region in total European production value
poll_shocks_Europe(CAPRIcrops,source,intens)            Productivity shocks following a collapse in both MANAGED & WILD pollinators
wild_poll_shocks_Europe(CAPRIcrops,source,intens)       Productivity shocks following a collapse in only  WILD pollinators
;

wild_poll_shocks(regCAPRI,CAPRIcrops,source,intens)$regCAPRI_Europe(regCAPRI) = wild_contribution(CAPRIcrops,"europe")/100 * SUM(regFAO$map_regFAO_regCAPRI(regFAO,regCAPRI),
                                    SUM(FAOcrops$map_FAOcrops_CAPRIcrops(FAOcrops,CAPRIcrops),
                                    share_aggregate(regFAO,FAOcrops,regCAPRI,CAPRIcrops) *
                                    DepRatios(FAOcrops,source,intens)));

** Based on the assumption, that wild pollinators only collapse in Europe
wild_poll_shocks(regCAPRI,CAPRIcrops,source,intens)$(not regCAPRI_Europe(regCAPRI)) = 0;

** Delete the information for "max" and "min" intensities - only the 95% confidence interval is used.
wild_poll_shocks(regCAPRI,CAPRIcrops,source,"max") = 0;
wild_poll_shocks(regCAPRI,CAPRIcrops,source,"min") = 0;

** Load Base Land Use Data from the CAPRI model
** Possibly delete the line "writeAll: True" if you encounter an error

$onEmbeddedCode Connect:
- ExcelReader:
    file: CAPRI_base_values.xlsx
    symbols:
      - name: CAPRI_base_prodvalue
        range: CAPRI_base_prodvalue!A2
        rowDimension: 2
        columnDimension: 0
           
- GAMSWriter:
    writeAll: True
    domainCheckType: checked
$offEmbeddedCode

*** Calculate production value weighted average productivity shocks at the European level

CAPRI_Europe_prodshare(CAPRIcrops,regCAPRI)$(regCAPRI_Europe(regCAPRI) and SUM(regCAPRI2$regCAPRI_Europe(regCAPRI2), CAPRI_base_prodvalue(CAPRIcrops,regCAPRI))) =
            CAPRI_base_prodvalue(CAPRIcrops,regCAPRI) / SUM(regCAPRI2$regCAPRI_Europe(regCAPRI2), CAPRI_base_prodvalue(CAPRIcrops,regCAPRI2));
        
poll_shocks_Europe(CAPRIcrops,source,intens) = SUM(regCAPRI,
           poll_shocks(regCAPRI,CAPRIcrops,source,intens) *
           CAPRI_Europe_prodshare(CAPRIcrops,regCAPRI) );
           
** This parameter (for source = Siopa) is also the underlying data for Table 1 in the main text
wild_poll_shocks_Europe(CAPRIcrops,source,intens) = SUM(regCAPRI,
            wild_poll_shocks(regCAPRI,CAPRIcrops,source,intens) *
           CAPRI_Europe_prodshare(CAPRIcrops,regCAPRI) );
    

                                     

