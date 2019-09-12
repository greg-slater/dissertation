Data Descriptions
-----------------

The table below gives details for each of the datasets used in the model, broken down by ecosystem service category and demand indicator.

``` r
kable(grid, align = "l") %>%
  kable_styling(full_width = F) %>%
  column_spec(1, bold = T) %>%
  collapse_rows(columns = 1:2, valign = "middle")
```

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
Category
</th>
<th style="text-align:left;">
Demand Indicator
</th>
<th style="text-align:left;">
Data Source
</th>
<th style="text-align:left;">
Type
</th>
<th style="text-align:left;">
Resolution / Scale
</th>
<th style="text-align:left;">
Measure
</th>
<th style="text-align:left;">
Link
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;font-weight: bold;vertical-align: middle !important;" rowspan="4">
Cultural
</td>
<td style="text-align:left;">
Depression prevalence
</td>
<td style="text-align:left;">
NHS Quality and Outcomes Framework Prevalence data 2017 – 2018
</td>
<td style="text-align:left;">
count per GP practice
</td>
<td style="text-align:left;">
Number of affected patients on GP practice register
</td>
<td style="text-align:left;">
Patients per LSOA with new diagnosis of depression / population of indicator age group per LSOA
</td>
<td style="text-align:left;">
test other text
</td>
</tr>
<tr>
<td style="text-align:left;">
Dementia prevalence
</td>
<td style="text-align:left;">
NHS Quality and Outcomes Framework Prevalence data 2017 – 2019
</td>
<td style="text-align:left;">
count per GP practice
</td>
<td style="text-align:left;">
Number of affected patients on GP practice register
</td>
<td style="text-align:left;">
Patients per LSOA with new diagnosis of dementia / population of indicator age group per LSOA
</td>
<td style="text-align:left;">
some more testing
</td>
</tr>
<tr>
<td style="text-align:left;">
Obesity prevalence
</td>
<td style="text-align:left;">
NHS Quality and Outcomes Framework Prevalence data 2017 – 2020
</td>
<td style="text-align:left;">
count per GP practice
</td>
<td style="text-align:left;">
Number of affected patients on GP practice register
</td>
<td style="text-align:left;">
Patients per LSOA with BMI ≥ 30 / population of indicator age group per LSOA
</td>
<td style="text-align:left;">
<https://data.london.gov.uk/dataset/london-atmospheric-emissions-inventory-2013>
</td>
</tr>
<tr>
<td style="text-align:left;">
Cardiovascular disease prevalence
</td>
<td style="text-align:left;">
NHS Quality and Outcomes Framework Prevalence data 2017 – 2021
</td>
<td style="text-align:left;">
count per GP practice
</td>
<td style="text-align:left;">
Number of affected patients on GP practice register
</td>
<td style="text-align:left;">
Patients per LSOA with new diagnosis of hypertension / population of indicator age group per LSOA
</td>
<td style="text-align:left;">
“<https://data.london.gov.uk/dataset/london-atmospheric-emissions-inventory-2013>”
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;vertical-align: middle !important;" rowspan="8">
Regulating
</td>
<td style="text-align:left;vertical-align: middle !important;" rowspan="4">
Air pollution levels
</td>
<td style="text-align:left;">
London Atmospheric Emissions Inventory modelled 2020 concentrations of NO2
</td>
<td style="text-align:left;">
point
</td>
<td style="text-align:left;">
20m grid
</td>
<td style="text-align:left;">
Mean concentration of NO2 per LSOA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
London Atmospheric Emissions Inventory modelled 2020 concentrations of Nox
</td>
<td style="text-align:left;">
point
</td>
<td style="text-align:left;">
20m grid
</td>
<td style="text-align:left;">
Mean concentration of Nox per LSOA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
London Atmospheric Emissions Inventory modelled 2020 concentrations of PM2.5
</td>
<td style="text-align:left;">
point
</td>
<td style="text-align:left;">
20m grid
</td>
<td style="text-align:left;">
Mean concentration of PM2.5 per LSOA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
London Atmospheric Emissions Inventory modelled 2020 concentrations of PM10
</td>
<td style="text-align:left;">
point
</td>
<td style="text-align:left;">
20m grid
</td>
<td style="text-align:left;">
Mean concentration of PM10 per LSOA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
Ambient temperature
</td>
<td style="text-align:left;">
VITO ‘UrbClim’ simulation of mean temperature at midnight during summer 2011 at 250m resolution
</td>
<td style="text-align:left;">
raster
</td>
<td style="text-align:left;">
250m grid
</td>
<td style="text-align:left;">
Mean ambient temperature per LSOA
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
Risk of Surface Water Flooding
</td>
<td style="text-align:left;">
DEFRA Risk of Flooding from Surface Water Hazard: 3.3 percent annual chance
</td>
<td style="text-align:left;">
polygon
</td>
<td style="text-align:left;">
smallest polygon = 4m²
</td>
<td style="text-align:left;">
Proportion of LSOA area with any risk of surface water flooding
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;vertical-align: middle !important;" rowspan="2">
Ambient noise
</td>
<td style="text-align:left;">
DEFRA road noise night time annual average noise level results in dB (night defined as 2300 – 0700)
</td>
<td style="text-align:left;">
polygon
</td>
<td style="text-align:left;">
smallest polygon = 0.3m²
</td>
<td style="text-align:left;">
Proportion of LSOA area with noise level above 50dB
</td>
<td style="text-align:left;">
NA
</td>
</tr>
<tr>
<td style="text-align:left;">
DEFRA rail noise night time annual average noise level results in dB (night defined as 2300 – 0700)
</td>
<td style="text-align:left;">
polygon
</td>
<td style="text-align:left;">
smallest polygon = 0.2m²
</td>
<td style="text-align:left;">
Proportion of LSOA area with noise level above 50dB
</td>
<td style="text-align:left;">
NA
</td>
</tr>
</tbody>
</table>
