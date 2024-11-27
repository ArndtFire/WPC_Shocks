# WPC_Shocks - Estimation of productivity shocks to simulate a collapse in wild pollinator populations in Europe

This folder includes scripts and datasets designed to reproduce the productivity shocks that simulate a collapse in wild pollinators that is passed on to the CAPRI model – as presented in the associated article. To successfully run the provided materials, the following system requirements must be met:

# System Requirements:

1. Operating System

-	Compatible with Windows 10 or newer (64-bit recommended).
-	Compatible with macOS (Tested with Sonoma 14.5)
-	Potentially compatible for Linux/Ubuntu (not tested)

2. Software Requirements

-	GAMS version 46.0 or newer (tested with GAMS version 46). See https://www.gams.com/ to get a version – install time is < 10 minutes.
-	Ensure the GDX Utilities and GAMS Connect libraries are included in your GAMS installation.
-	Microsoft Excel: Excel 2016 or newer may be required if using the Excel integration for data import/export (via GAMS Connect).
-	More information on GAMS Connect is available at: https://www.gams.com/48/docs/UG_GAMSCONNECT.html?search=GAMS%20Connect

# Instructions for the Estimation of productivity shocks following a wild pollinator decline in Europe

1.	Save the following files in one directory:

-	data_input_file.xlsx; 
-	CAPRI_base_values.xlsx; 
-	Productivity Shocks from a wild pollinator collapse.gms; 
-	SetsDefinition.gms;
    and 
-	Productivity Shocks from a wild pollinator collapse_result.gdx 

2.	Open GAMS Studio that comes with GAMS (a free demo version can be obtained from https://www.gams.com/download/)

3.	Open the main program file Productivity Shocks from a wild pollinator collapse.gms; 

4.	Run the code by pressing F10 or pusing the green button with the option “with GDX creation”. Expected run time is < 1 minute.

5.	Inspect the shock parameters from the newly created .gdx file 

6.	Optionally: Compare it with the values from the .gdx file (Productivity Shocks from a wild pollinator collapse_result.gdx) provided in this project.

# 
