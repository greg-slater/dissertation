Data Descriptions
-----------------

The table below gives details for each of the datasets used in the model, broken down by ecosystem service category and demand indicator.

``` r
kable(grid, align = "l", format = 'markdown') %>%
  kable_styling(full_width = F) %>%
  column_spec(1, bold = T) %>%
  collapse_rows(columns = 1:2, valign = "middle")
```

<table>
<colgroup>
<col width="2%" />
<col width="7%" />
<col width="21%" />
<col width="4%" />
<col width="11%" />
<col width="20%" />
<col width="32%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Category</th>
<th align="left">Demand Indicator</th>
<th align="left">Data Source</th>
<th align="left">Type</th>
<th align="left">Resolution / Scale</th>
<th align="left">Measure</th>
<th align="left">Link</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">Cultural</td>
<td align="left">Depression prevalence</td>
<td align="left">NHS Quality and Outcomes Framework Prevalence data 2017 – 2018</td>
<td align="left">count per GP practice</td>
<td align="left">Number of affected patients on GP practice register</td>
<td align="left">Patients per LSOA with new diagnosis of depression / population of indicator age group per LSOA</td>
<td align="left"><a href="https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data/2017-18" class="uri">https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data/2017-18</a></td>
</tr>
<tr class="even">
<td align="left">Cultural</td>
<td align="left">Dementia prevalence</td>
<td align="left">NHS Quality and Outcomes Framework Prevalence data 2017 – 2019</td>
<td align="left">count per GP practice</td>
<td align="left">Number of affected patients on GP practice register</td>
<td align="left">Patients per LSOA with new diagnosis of dementia / population of indicator age group per LSOA</td>
<td align="left"><a href="https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data/2017-18" class="uri">https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data/2017-18</a></td>
</tr>
<tr class="odd">
<td align="left">Cultural</td>
<td align="left">Obesity prevalence</td>
<td align="left">NHS Quality and Outcomes Framework Prevalence data 2017 – 2020</td>
<td align="left">count per GP practice</td>
<td align="left">Number of affected patients on GP practice register</td>
<td align="left">Patients per LSOA with BMI ≥ 30 / population of indicator age group per LSOA</td>
<td align="left"><a href="https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data/2017-18" class="uri">https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data/2017-18</a></td>
</tr>
<tr class="even">
<td align="left">Cultural</td>
<td align="left">Cardiovascular disease prevalence</td>
<td align="left">NHS Quality and Outcomes Framework Prevalence data 2017 – 2021</td>
<td align="left">count per GP practice</td>
<td align="left">Number of affected patients on GP practice register</td>
<td align="left">Patients per LSOA with new diagnosis of hypertension / population of indicator age group per LSOA</td>
<td align="left"><a href="https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data/2017-18" class="uri">https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data/2017-18</a></td>
</tr>
<tr class="odd">
<td align="left">Regulating</td>
<td align="left">Air pollution levels</td>
<td align="left">London Atmospheric Emissions Inventory modelled 2020 concentrations of NO2</td>
<td align="left">point</td>
<td align="left">20m grid</td>
<td align="left">Mean concentration of NO2 per LSOA</td>
<td align="left"><a href="https://data.london.gov.uk/dataset/london-atmospheric-emissions-inventory-2013" class="uri">https://data.london.gov.uk/dataset/london-atmospheric-emissions-inventory-2013</a></td>
</tr>
<tr class="even">
<td align="left">Regulating</td>
<td align="left">Air pollution levels</td>
<td align="left">London Atmospheric Emissions Inventory modelled 2020 concentrations of Nox</td>
<td align="left">point</td>
<td align="left">20m grid</td>
<td align="left">Mean concentration of Nox per LSOA</td>
<td align="left"><a href="https://data.london.gov.uk/dataset/london-atmospheric-emissions-inventory-2013" class="uri">https://data.london.gov.uk/dataset/london-atmospheric-emissions-inventory-2013</a></td>
</tr>
<tr class="odd">
<td align="left">Regulating</td>
<td align="left">Air pollution levels</td>
<td align="left">London Atmospheric Emissions Inventory modelled 2020 concentrations of PM2.5</td>
<td align="left">point</td>
<td align="left">20m grid</td>
<td align="left">Mean concentration of PM2.5 per LSOA</td>
<td align="left"><a href="https://data.london.gov.uk/dataset/london-atmospheric-emissions-inventory-2013" class="uri">https://data.london.gov.uk/dataset/london-atmospheric-emissions-inventory-2013</a></td>
</tr>
<tr class="even">
<td align="left">Regulating</td>
<td align="left">Air pollution levels</td>
<td align="left">London Atmospheric Emissions Inventory modelled 2020 concentrations of PM10</td>
<td align="left">point</td>
<td align="left">20m grid</td>
<td align="left">Mean concentration of PM10 per LSOA</td>
<td align="left"><a href="https://data.london.gov.uk/dataset/london-atmospheric-emissions-inventory-2013" class="uri">https://data.london.gov.uk/dataset/london-atmospheric-emissions-inventory-2013</a></td>
</tr>
<tr class="odd">
<td align="left">Regulating</td>
<td align="left">Ambient temperature</td>
<td align="left">VITO ‘UrbClim’ simulation of mean temperature at midnight during summer 2011 at 250m resolution</td>
<td align="left">raster</td>
<td align="left">250m grid</td>
<td align="left">Mean ambient temperature per LSOA</td>
<td align="left"><a href="https://data.london.gov.uk/dataset/london-s-urban-heat-island---average-summer" class="uri">https://data.london.gov.uk/dataset/london-s-urban-heat-island---average-summer</a></td>
</tr>
<tr class="even">
<td align="left">Regulating</td>
<td align="left">Risk of Surface Water Flooding</td>
<td align="left">DEFRA Risk of Flooding from Surface Water Hazard: 3.3 percent annual chance</td>
<td align="left">polygon</td>
<td align="left">smallest polygon = 4m²</td>
<td align="left">Proportion of LSOA area with any risk of surface water flooding</td>
<td align="left"><a href="https://environment.data.gov.uk/dataset/924d4380-d465-11e4-bf2a-f0def148f590" class="uri">https://environment.data.gov.uk/dataset/924d4380-d465-11e4-bf2a-f0def148f590</a></td>
</tr>
<tr class="odd">
<td align="left">Regulating</td>
<td align="left">Ambient noise</td>
<td align="left">DEFRA road noise night time annual average noise level results in dB (night defined as 2300 – 0700)</td>
<td align="left">polygon</td>
<td align="left">smallest polygon = 0.3m²</td>
<td align="left">Proportion of LSOA area with noise level above 50dB</td>
<td align="left"><a href="https://data.london.gov.uk/dataset/noise-pollution-in-london" class="uri">https://data.london.gov.uk/dataset/noise-pollution-in-london</a></td>
</tr>
<tr class="even">
<td align="left">Regulating</td>
<td align="left">Ambient noise</td>
<td align="left">DEFRA rail noise night time annual average noise level results in dB (night defined as 2300 – 0700)</td>
<td align="left">polygon</td>
<td align="left">smallest polygon = 0.2m²</td>
<td align="left">Proportion of LSOA area with noise level above 50dB</td>
<td align="left"><a href="https://data.london.gov.uk/dataset/noise-pollution-in-london" class="uri">https://data.london.gov.uk/dataset/noise-pollution-in-london</a></td>
</tr>
</tbody>
</table>
