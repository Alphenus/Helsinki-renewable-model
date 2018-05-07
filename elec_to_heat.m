function [ heat_other, elec_for_heating ] = elec_to_heat( heat_consumption, heat_from_elec_factor, COP, heat_from_hp_factor )
%elec_to_heat Convert electricity to heat
%   Parameters:
%       heat_consumption : vector of heat consumption
%       heat_from_elec_factor : how large share of heat is produced using
%       elec
%       COP : Heat pump average COP
%       heat_from_hp_factor : how large share of heat is produced using
%       heatpumps

heat_f_elec = heat_from_elec_factor * heat_consumption; % heat produced with elec
heat_other = (1-heat_from_elec_factor) * heat_consumption; % heat produced by other means

heat_f_hp = heat_from_hp_factor * heat_f_elec;
heat_f_direct = (1 - heat_from_hp_factor) * heat_f_elec;

elec_for_heating = heat_f_hp / COP + heat_f_direct;

end

