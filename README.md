# Tunisian Co-Management Application

To facilitate transparent fishing activity in the Tunisian exclusive economic zone, we developed this prototype virtual logbook application for fishermen to report their catches and monitor current and past ocean use.

## Version 1.1 Updates

### Maps
- **Fishing Effort Map**: Displays a grid with 0.25x0.25 degree resolution of total fishing effort in hours over a specified temporal range.
  - Displays top flag and gear per grid cell.
  - Added a toggle between "Fishing Activity" and "Fishing Effort".
  - Increased time range from 15 days to 30 days.
  - Included locally-sourced port locations with anchor icons.
  - Visualizes a broader range of gear types.

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

## Sponsors

## Created By
Code by Jeremy Jenrette - PhD Candidate in Fish and Wildlife Conservation at Virginia Tech

<iframe src="https://sp2.cs.vt.edu/shiny/comanage/fishing_effort_grid.html" width="100%" height="600px" frameborder="0"></iframe>
