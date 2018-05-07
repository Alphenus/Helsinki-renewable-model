function [ wind_production ] = wind( capacity, wind_mw )
%WIND Wind production calculation
%   Args:
%       wind_cap: Wind capacity in MW
%       wind_mw: Wind production per MW installed

wind_unit_price = 10000;    % €/MW
wind_price_total = capacity * wind_unit_price; % €

% Wind production in MW
wind_production = capacity * wind_mw;

end

