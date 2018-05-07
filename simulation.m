%% Initialization
clear;

load data_profiles_helsinki.mat

heat_consumption = hki_heat;
elec_consumption = hki_elec;
hour = hour/24;
hours = length(hour);

c_blue = [0.15,0.50,0.80, 0.9];
c_red = [0.80,0.33,0.1, 0.9];

%% Skenaario 1

sken = "Skenaario 1";

capacity_wind =         0;
capacity_pv =           0.340 + 0.850;
capacity_water =        60.2;
capacity_bio_heat_1 =     420;
capacity_bio_elec_1 =     220;
bio_elec_to_heat_share_1 = 1; % 1 = all elec to heat; 0 = no elec to heat
bio_cop_1 =               3;
capacity_bio_heat_2 =   0;
capacity_bio_elec_2 =   000;
bio_elec_to_heat_share_2 = 0;
bio_cop_2 =             3;
deepheat_number =       8;
capacity_nuclear_heat = 700;
capacity_nuclear_elec = 570;
capacity_heat_other =   0;
capacity_elec_other =   0;

heat_pump_capacity =    300; %MW of heat <- capacity/cop electricity consumption
heat_pump_cop =         2.5; 

n_batteries = 3;
size_elec_storage = n_batteries*129;
power_elec_storage = n_batteries*100;
size_heat_storage = 1000 + 1250 + 11600; % MWh
power_heat_storage = 150;
%% Skenaario 2

sken = "Skenaario 2";

capacity_wind =         1500;
capacity_pv =           1500 + 0.340 + 0.850;
capacity_water =        60.2;
capacity_bio_heat_1 =   600;
capacity_bio_elec_1 =   650;
bio_elec_to_heat_share_1 = 0;
bio_cop_1 =             3;
capacity_bio_heat_2 =   420;
capacity_bio_elec_2 =   220;
bio_elec_to_heat_share_2 = 1;
bio_cop_2 =             3;
deepheat_number =       20;
capacity_nuclear_heat = 0;
capacity_nuclear_elec = 0;

heat_pump_capacity =    200; %MW of heat <- capacity/cop electricity consumption
heat_pump_cop =         3; 

n_batteries = 11;
size_elec_storage = n_batteries*129;
power_elec_storage = n_batteries*100;
size_heat_storage = 1000 + 1250 + 11600; % MWh
power_heat_storage = 150;
%% Skenaario 3

sken = "Skenaario 3";

capacity_wind =            300;
capacity_pv =              650 + 0.340 + 0.850;
capacity_water =           60.2;
capacity_bio_heat_1 =      430;
capacity_bio_elec_1 =      220;
bio_elec_to_heat_share_1 = 1; % 1 = all elec to heat; 0 = no elec to heat
bio_cop_1 =                3;
capacity_bio_heat_2 =      600;
capacity_bio_elec_2 =      650;
bio_elec_to_heat_share_2 = 0;
bio_cop_2 =             3;
deepheat_number =       20;
capacity_nuclear_heat = 0;
capacity_nuclear_elec = 0;
capacity_heat_other =   0;
capacity_elec_other =   0;

heat_pump_capacity =    200; %MW of heat <- capacity/cop electricity consumption
heat_pump_cop =         3; 

n_batteries = 11;
size_elec_storage = n_batteries*129;
power_elec_storage = n_batteries*100;
size_heat_storage = 1000 + 1250 + 11600; % MWh
power_heat_storage = 150;
%% DEBUG Skenaario 4

sken = "Skenaario 4";

capacity_wind =         0;
capacity_pv =           1500;
capacity_water =        0;
capacity_bio_heat_1 =   0;
capacity_bio_elec_1 =   0;
bio_elec_to_heat_share_1 = 0;
bio_cop_1 =             3;
capacity_bio_heat_2 =   0;
capacity_bio_elec_2 =   0;
bio_elec_to_heat_share_2 = 1;
bio_cop_2 =             3;
deepheat_number =       0;
capacity_nuclear_heat = 0;
capacity_nuclear_elec = 0;

heat_pump_capacity =    0; %MW of heat <- capacity/cop electricity consumption
heat_pump_cop =         3; 

n_batteries = 10;
size_elec_storage = n_batteries*129;
power_elec_storage = n_batteries*100;
size_heat_storage = 0; % MWh
power_heat_storage = 150;
%% Simulation

% Initializations
prod_elec_wind = wind(capacity_wind, wind_mw);
prod_elec_pv = pv(capacity_pv, pv_30deg, pv_90deg, 0.5);
prod_elec_water = water(capacity_water);
[prod_heat_bio_1, prod_elec_bio_1] = bio(capacity_bio_heat_1, capacity_bio_elec_1, bio_elec_to_heat_share_1, bio_cop_1);
[prod_heat_bio_2, prod_elec_bio_2] = bio(capacity_bio_heat_2, capacity_bio_elec_2, bio_elec_to_heat_share_2, bio_cop_2); % 1000 MW production capacity with bio
prod_heat_bio = prod_heat_bio_1 + prod_heat_bio_2;
prod_elec_bio = prod_elec_bio_1 + prod_elec_bio_2;
prod_heat_deepheat = deepheat(deepheat_number); % 10 deepheat thermal holes
[prod_heat_nuc, prod_elec_nuc] = nuclear(capacity_nuclear_heat, capacity_nuclear_elec);

max_elec_production = [prod_elec_wind, prod_elec_pv, prod_elec_water, prod_elec_bio, prod_elec_nuc];
max_heat_production = [prod_heat_bio, prod_heat_deepheat, prod_heat_nuc];


storage_elec_level = zeros(length(hour), 1);
storage_elec_level(1) = size_elec_storage; % battery is charged at the beginning

storage_heat_level = zeros(length(hour), 1);
storage_heat_level(1) = size_heat_storage;

% Loopping

extra_elec_needed = zeros(length(hour), 1);
extra_heat_needed = zeros(length(hour), 1);

true_needed_elec = zeros(length(hour), 1);
true_needed_heat = zeros(length(hour), 1);

elec_production = zeros(length(hour), 1);
heat_production = zeros(length(hour), 1);

energy_from_battery = zeros(length(hour), 1);

uptime_deepheat = 0;
uptime_water = 0;
uptime_bio_elec = 0;
uptime_bio_heat = 0;
uptime_wind = 0;
uptime_heatpump = 0;

overproduction_pv = zeros(length(hour), 1);
overproduction_nuc_elec = zeros(length(hour), 1);
overproduction_nuc_heat = zeros(length(hour), 1);
overproduction_deepheat = zeros(length(hour), 1);

% Loop itself

for h = 2:length(hour)
    heat_needed = heat_consumption(h);
    elec_needed = elec_consumption(h);
    
    heat_to_storage_avail = 0;
    elec_to_storage_avail = 0;
    
    % Nuclear heat
    %if(heat_needed > 0)
        prod = prod_heat_nuc(h);
        needed = max(heat_needed - prod, 0);
        overproduction_nuc_heat(h) = max(prod - heat_needed, 0);
        heat_needed = needed;
        heat_production(h) = heat_production(h) + prod;
        if(needed < prod)
            heat_to_storage_avail = heat_to_storage_avail + (prod - needed);
        end
    %end
    
    % Heat pumps
    if(heat_needed > 0)
        hp_conversion = min(heat_needed, heat_pump_capacity);
        heat_production(h) = heat_production(h) + hp_conversion;
        heat_needed = heat_needed - hp_conversion;
        elec_needed = elec_needed + hp_conversion / heat_pump_cop;
        uptime_heatpump = uptime_heatpump + 1;
    end
    
    % Deepheat
    if(heat_needed > 0)
        prod = min(prod_heat_deepheat(h), heat_needed);
        prod_heat_deepheat(h) = prod;
        needed = max(heat_needed - prod, 0);
        overproduction_deepheat(h) = max(prod - heat_needed, 0);
        heat_needed = needed;
        heat_production(h) = heat_production(h) + prod;
        if(needed < prod)
            heat_to_storage_avail = heat_to_storage_avail + (prod - needed);
        end
        uptime_deepheat = uptime_deepheat + 1;
    else
        prod_heat_deepheat(h) = 0;
    end

        
    % Thermal storage usage
    if(heat_needed > 0)
        avail = storage_heat_level(h-1);
        draw = min(min(avail, power_heat_storage), heat_needed);
        storage_heat_level(h) = storage_heat_level(h-1) - draw;
        heat_needed = heat_needed - draw;
    else
        storage_heat_level(h) = storage_heat_level(h-1);
    end
    
    % Bio heat
    if(heat_needed > 0)
        prod = min(prod_heat_bio(h), heat_needed);
        prod_heat_bio(h) = prod;
        needed = max(heat_needed - prod, 0);
        heat_needed = needed;
        heat_production(h) = heat_production(h) + prod;
        if(needed < prod)
            heat_to_storage_avail = heat_to_storage_avail + (prod - needed);
        end
        uptime_bio_heat = uptime_bio_heat + 1;
    else
        prod_heat_bio(h) = 0;
    end
    
    
    % Nuclear electricity 
    if(capacity_nuclear_elec > 0) %Ydinvoima puksuttaa vaikka mitä tekisi
        prod = prod_elec_nuc(h);
        needed = max(elec_needed - prod, 0);
        overproduction_nuc_elec(h) = max(prod-elec_needed, 0);
        elec_needed = needed;
        elec_production(h) = elec_production(h) + prod;
        if(needed < prod)
            elec_to_storage_avail = elec_to_storage_avail + (prod - needed);
        end
    end
    
    
    %PV
    if(elec_needed > 0 && capacity_pv > 0)
        prod = prod_elec_pv(h);
        needed = max(elec_needed - prod, 0);
        overproduction_pv(h) = max(prod-elec_needed, 0);

        elec_needed = needed;
        elec_production(h) = elec_production(h) + prod;
        if(needed < prod)
            elec_to_storage_avail = elec_to_storage_avail + (prod - needed);
        end
    end
        
    % Wind
    if(elec_needed > 0 && capacity_wind > 0)
        prod = min(prod_elec_wind(h), elec_needed);
        prod_elec_wind(h) = prod;
        needed = max(elec_needed - prod, 0);
        elec_needed = needed;
        elec_production(h) = elec_production(h) + prod;
        if(needed < prod)
            storable = prod - needed;
            elec_to_storage_avail = elec_to_storage_avail + storable;
        end
        uptime_wind = uptime_wind + 1;
    else
        prod_elec_wind(h) = 0;
    end
    

    
    % Water power
    if(elec_needed > 0 && capacity_water > 0)
        prod = min(prod_elec_water(h), elec_needed);
        prod_elec_water(h) = prod;
        needed = max(elec_needed - prod, 0);
        elec_needed = needed;
        elec_production(h) = elec_production(h) + prod;
        if(needed < prod)
            storable = prod - needed;
            elec_to_storage_avail = elec_to_storage_avail + storable;
        end
        uptime_water = uptime_water + 1;
    else
        prod_elec_water(h) = 0;
    end
    
    % Electric storage usage
    if(elec_needed > 0)
        avail = storage_elec_level(h-1);
        draw = min(min(avail, power_elec_storage), elec_needed);
        energy_from_battery(h) = draw;
        storage_elec_level(h) = storage_elec_level(h-1) - draw;
        elec_needed = elec_needed - draw;
    else
        storage_elec_level(h) = storage_elec_level(h-1);
    end
    

    
    % Bio elec
    if(elec_needed > 0)
        prod = min(prod_elec_bio(h), elec_needed);
        prod_elec_bio(h) = prod;
        needed = max(elec_needed - prod, 0);
        elec_needed = needed;
        elec_production(h) = elec_production(h) + prod;
        if(needed < prod)
            storable = prod - needed;
            elec_to_storage_avail = elec_to_storage_avail + storable;
        end
        uptime_bio_elec = uptime_bio_elec + 1;
    else
        prod_elec_bio(h) = 0;
    end
    
    % Store electricity
    if(elec_to_storage_avail > 0)
        chargable = min(power_elec_storage, elec_to_storage_avail);        
        elec_production(h) = elec_production(h) + min(chargable, size_elec_storage-storage_elec_level(h));
        storage_elec_level(h) = min(storage_elec_level(h) + chargable, size_elec_storage);
    end
    
    % Store heat
    if(heat_to_storage_avail > 0)
        chargable = min(power_heat_storage, heat_to_storage_avail);
        heat_production(h) = heat_production(h) + min(chargable, size_heat_storage - storage_heat_level(h));
        storage_heat_level(h) = min(storage_heat_level(h) + chargable, size_heat_storage);
    end
    
    % Add some losses to storages
    storage_heat_level(h) = 0.99*storage_heat_level(h);
    storage_elec_level(h) = 0.99*storage_elec_level(h);  
    
    if(elec_needed > 0)
        extra_elec_needed(h) = elec_needed;
    end
    
    if(heat_needed > 0)
        extra_heat_needed(h) = heat_needed;
    end
    
end

overproduction_elec = overproduction_nuc_elec + overproduction_pv;
overproduction_heat = overproduction_nuc_heat + overproduction_deepheat;

fprintf('\n\n   %s \n', sken)

fprintf('Electricity produced :     %.02f TWh \n', sum(elec_production)/1000000);
fprintf('Extra electricity needed : %.05f TWh \n', sum(extra_elec_needed)/1000000);
fprintf('Ratio of electricity produced/total consumption : %f \n', sum(elec_production)/sum(elec_consumption));

fprintf('Heat produced :     %.02f TWh \n', sum(heat_production)/1000000);
fprintf('Extra heat needed : %.05f TWh \n', sum(extra_heat_needed)/1000000);
fprintf('Ratio of heat produced/total consumption : %f \n', sum(heat_production)/sum(heat_consumption));

fprintf('Water was used %.02f , bio electricity %.02f , bio_heat %02f  and deepheat %.02f of time \n', uptime_water/hours, uptime_bio_elec/hours, uptime_bio_heat/hours, uptime_deepheat/hours)

fprintf('Solar production :     %.02f GWh \n', sum(prod_elec_pv)/1000);


%% TuotantoPlot 
figure
yyaxis left 
plot(hour, elec_production, 'LineWidth', 2, 'Color', c_blue)
ylabel('Sähköntuotanto (MW)')

yyaxis right
plot(hour, heat_production, 'LineWidth', 2, 'Color', c_red)
ylabel('Lämmöntuotanto (MW)')

xlabel('Aika (tuntia)');
pbaspect([1.6 1 1])
xlim([0,365])
%
ax = gca;
ax.XRuler.Axle.LineStyle = 'none';  
%ax.YRuler.Axle.LineStyle = 'none';
ax.TickLength = [0.01,0.01];
ax.LineWidth = 1.5;
ax.FontSize = 18;
ax.Color = 'none';
set(gca,'box','off')
ax.TickDir = 'out';

%% Akkujen varaustaso Plot
figure
yyaxis left 
plot(hour, storage_elec_level, 'LineWidth', 2, 'Color', c_blue)
ylabel('Sähköakkujen varaus (MW)')
ylim([0, 400])

yyaxis right
plot(hour, storage_heat_level, 'LineWidth', 4, 'Color', c_red)
ylabel('Lämpövarastojen varaus (MW)')

xlabel('Aika (tuntia)');
pbaspect([1.6 1 1])
xlim([0,365])
%
ax = gca;
ax.XRuler.Axle.LineStyle = 'none';  
%ax.YRuler.Axle.LineStyle = 'none';
ax.TickLength = [0.01,0.01];
ax.LineWidth = 1.5;
ax.FontSize = 18;
ax.Color = 'none';
set(gca,'box','off')
ax.TickDir = 'out';

%% Ylituotanto Plot 
figure
yyaxis left 
plot(hour, overproduction_elec, 'LineWidth', 2, 'Color', c_blue)
ylabel('Sähkön ylituotanto (MW)')
ylim([0, 10])

yyaxis right
plot(hour, overproduction_heat, 'LineWidth', 2, 'Color', c_red)
ylabel('Lämmön ylituotanto (MW)')
ylim([0, 10])

xlabel('Aika (tuntia)');
pbaspect([1.6 1 1])
xlim([0,365])
%
ax = gca;
ax.XRuler.Axle.LineStyle = 'none';  
%ax.YRuler.Axle.LineStyle = 'none';
ax.TickLength = [0.01,0.01];
ax.LineWidth = 1.5;
ax.FontSize = 18;
ax.Color = 'none';
set(gca,'box','off')
ax.TickDir = 'out';



%% SubPlotter 

subplot(2,2,1);

title('Production')
yyaxis left 
plot(hour, elec_production)

yyaxis right
plot(hour, heat_production)

subplot(2,2,2);
title('Consumption')
yyaxis left 
plot(hour, elec_consumption)

yyaxis right
plot(hour, heat_consumption)

subplot(2,2,3);
title('Overproduction ')
yyaxis left 
plot(hour, overproduction_elec)

yyaxis right
plot(hour, overproduction_heat, '.')

subplot(2,2,4);
title('Storage level')
yyaxis left 
plot(hour, storage_elec_level)

yyaxis right
plot(hour, storage_heat_level)

figure;
plot(hour, extra_elec_needed)

%% Kulutus

figure;
yyaxis left 

p1 = plot(...
    hour, elec_consumption,...
    'LineWidth',0.1,...
    'Color', c_blue);

xlabel('Aika (päiviä)')
ylabel('Sähkönkulutus')

ylim([0, 800])

yyaxis right
p2 = plot(hour, heat_consumption,...
    'LineWidth',0.2,...
    'Color',c_red);

ylabel('Lämmönkulutus')

ylim([0, 2550])

pbaspect([1.6 1 1])
xlim([0,365])
%
ax = gca;
ax.XRuler.Axle.LineStyle = 'none';  
%ax.YRuler.Axle.LineStyle = 'none';
ax.TickLength = [0.01,0.01];
ax.LineWidth = 1.5;
ax.FontSize = 18;
ax.Color = 'none';
set(gca,'box','off')
ax.TickDir = 'out';

%% PV ja Tuuli

figure;

subplot(2,1,1)

yyaxis left
plot(...
    hour, pv_30deg/1000,...
    'LineWidth',0.2,...
    'Color', c_blue);

ylabel({'Aurinkosähkö'; '30° asennuskulma';'(MW/MW_p)'})
ylim([0, 1])


pbaspect([2.5 1 1])
xlim([0,365])
ax = gca;
ax.XRuler.Axle.LineStyle = 'none';  
ax.TickLength = [0.01,0.01];
ax.LineWidth = 1.5;
ax.FontSize = 14;
ax.Color = 'none';
set(gca,'box','off')
ax.TickDir = 'out';

yyaxis right
plot(...
    hour, pv_90deg/1000,...
    'LineWidth',0.05,...
    'Color', c_red);

xlabel('Aika (päiviä)')
ylabel({'Aurinkosähkö'; '90° asennuskulma';'(MW/MW_p)'})

ylim([0, 1])
set(gca,'xticklabel',{[]}) 

pbaspect([2.5 1 1])
xlim([0,365])
ax = gca;
ax.XRuler.Axle.LineStyle = 'none';  
ax.TickLength = [0.01,0.01];
ax.LineWidth = 1.5;
ax.FontSize = 14;
ax.Color = 'none';
set(gca,'box','off')
ax.TickDir = 'out';

subplot(2,1,2)

p2 = plot(hour, wind_mw,...
    'LineWidth',0.2,...
    'Color',c_blue);

ylabel({'Tuulisähkö';'(MW/MW_p)'})
xlabel('Aika (päiviä)')

ylim([0, 1])

pbaspect([2.5 1 1])
xlim([0,365])
%
ax = gca;
ax.XRuler.Axle.LineStyle = 'none';  
ax.YRuler.Axle.LineStyle = 'none';
ax.TickLength = [0.01,0.01];
ax.LineWidth = 1.5;
ax.FontSize = 14;
ax.Color = 'none';
set(gca,'box','off')
ax.TickDir = 'out';
set(gca,'XAxisLocation','top')
