function [ heat_prod, elec_prod ] = nuclear( capacity_heat, capacity_elec )
%Nuclear Summary of this function goes here
%   Detailed explanation goes here

heat_prod = capacity_heat .* ones(8757, 1);
elec_prod = capacity_elec .* ones(8757, 1);


end

