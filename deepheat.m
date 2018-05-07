function [ deepheat_prod ] = deepheat( number_of_units )
%DEEPHEAT Summary of this function goes here
%   Detailed explanation goes here

deepheat_power = 40; % MW

deepheat_prod = number_of_units * deepheat_power .* ones(8757, 1);

end

