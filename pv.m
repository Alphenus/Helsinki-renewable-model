function [ pv_produdction ] = pv( capacity, pv_30deg, pv_90deg, pv_30_share )
%PV Converts solar to electricity
%   Detailed explanation goes here

% pv_yearly_forecast = 1300000; % MWh, according to Pöyry
% pv_cap = pv_yearly_forecast / sum(pv_prod_mw) = 1500;

pv_unit_price = 0.05*10^3;      % €/MWp


%pv_30_share = 0.5; % 50% of PV is installed 30 deg, rest 90 deg
pv_30_prod = pv_30deg ./ 1000; % 1 MWp produces x MW of elec.
pv_90_prod = pv_90deg ./ 1000; % 1 MWp produces x MW of elec.

% PV production in MW
pv_prod_mw = pv_30_share * pv_30_prod + (1-pv_30_share)*pv_90_prod;


pv_produdction = capacity * pv_prod_mw;

end

