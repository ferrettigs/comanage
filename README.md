# Tunisian Co-Management Application

To facilitate transparent fishing activity in the Tunisian exclusive economic zone, we developed this prototype virtual logbook application for fishermen to report their catches and monitor current and past ocean use.

## Version 1.1 Updates
[Co-management App](https://sp2.cs.vt.edu/shiny/comanage/)
### Maps
- **Fishing Effort Map**: Displays a grid with 0.25x0.25 degree resolution of total fishing effort in hours over a specified temporal range.
  - Displays top flag and gear per grid cell.
      - you can include a sub-toggle in the map to display individual nations and gears 
  - Added a toggle between "Fishing Activity" and "Fishing Effort".
      - this is good; we may need to lower the spatial resolution by half.
  - Increased time range from 15 days to 30 days.
  - Included locally-sourced port locations with anchor icons.
  - Visualizes a broader range of gear types.
  - we need to look for API or packages to integrate weather layers (sea conditions, wind, temperature etc.) 

### Catch Logging
- Added fields:
  - "Boat Name"
  - "How many species did you catch?"
  - "Weight of Total Catch (kg)"
- Included locally-sourced port locations for identifying port of use.
- Removed the Elasmobranch-specific question for what was caught.

## To Implement
- Auxiliary forms to report a breakdown of species and landing quantity.
- Standardized gear type syntax, such as changing "trawlers" to "Trawl".
- Improved facilitation for Arabic-speakers.
- Replace fishing hours slider with prompts for time entering and exiting port.
- We need to develop the front page and decide what to include for describing teh app and auxiliary info useful to users 
## Sponsors
 - We need to include sponsors in teh front page
## Created By
Code by Jeremy Jenrette - PhD Candidate in Fish and Wildlife Conservation at Virginia Tech

