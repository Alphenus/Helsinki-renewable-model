function [ heat_prod, elec_prod ] = bio( heat, elec, heat_from_elec, cop )
%BIO Summary of this function goes here
%   Args:
%       heat:   Heat production in MW
%       elec:   Elec production in MW
%       heat_from_elec:  share of heat produced from electricity
%       cop:    COP of the elec->heat convesion

%bio_fuel_price = 10; % €/MWh
%bio_unit_price = 10000 ;     % €/MW

%bio_price = capacity * bio_unit_price * ones(length(8575), 1); % €

heat_prod = (heat + elec*heat_from_elec*cop) .* ones(8757, 1);
elec_prod = elec*(1-heat_from_elec)*ones(8757, 1);


%bio_fuel_cost = bio_prod * 8760 * bio_fuel_price;

end

