% energia_hogar.m
clear; clc;

% Lista interna de 50 aparatos
aparatos = {
    'Refrigerador', 'Televisor', 'Microondas', 'Computadora', 'Cargador celular', ...
    'Ventilador', 'Lavadora', 'Secadora', 'Licuadora', 'Cafetera', ...
    'Horno electrico', 'Plancha', 'Router WiFi', 'Consola de videojuegos', 'Bocinas', ...
    'Lampara LED', 'Aire acondicionado', 'Calefactor', 'Deshumidificador', 'Aspiradora', ...
    'Tablet', 'Monitor PC', 'Impresora', 'Freidora de aire', 'Batidora', ...
    'Camara de seguridad', 'Televisor LED grande', 'Smartwatch', 'Humidificador', 'Secador de cabello', ...
    'Maquina de coser', 'Proyector', 'Equipo de sonido', 'Extractor de aire', 'Maquina de afeitar', ...
    'Dispensador de agua', 'Estufa electrica', 'Cargador de laptop', 'Antena digital', 'Lampara halogena', ...
    'Despertador digital', 'Pulidora', 'Taladro electrico', 'Calentador de agua', 'Ventilador industrial', ...
    'Reproductor DVD', 'Escaner', 'Modem', 'Mini nevera', 'Camara digital'
};

% Potencia estimada en kW
potencias = [
    0.15, 0.1, 1.2, 0.2, 0.01, ...
    0.075, 0.5, 2.5, 0.3, 0.6, ...
    1.5, 1.1, 0.012, 0.18, 0.2, ...
    0.01, 2.0, 1.5, 0.7, 1.2, ...
    0.01, 0.05, 0.1, 1.4, 0.25, ...
    0.02, 0.12, 0.005, 0.03, 1.0, ...
    0.08, 0.2, 0.4, 0.05, 0.02, ...
    0.1, 2.2, 0.065, 0.03, 0.05, ...
    0.01, 0.8, 0.6, 1.8, 1.5, ...
    0.03, 0.1, 0.05, 0.08, 0.03
];

fprintf('Presione ENTER para iniciar el programa...\n');
pause;

% Mostrar lista de aparatos
fprintf('\nLista de aparatos:\n');
for i = 1:length(aparatos)
    fprintf('%2d. %s\n', i, aparatos{i});
end

% Ingreso de datos
entrada_aparatos = input('\nIngrese los numeros de los aparatos usados (separados por coma) o escriba "salir": ', 's');
if strcmpi(strtrim(entrada_aparatos), 'salir')
    fprintf('Programa finalizado.\n');
    return;
elseif isempty(strtrim(entrada_aparatos))
    fprintf('No se ingreso ningun numero. Intente de nuevo.\n');
    return;
end
aparatos_idx = str2num(entrada_aparatos); %#ok<ST2NM>

entrada_horas = input('Ingrese las horas de uso mensual de cada aparato en el mismo orden (separadas por coma): ', 's');
if strcmpi(strtrim(entrada_horas), 'salir')
    fprintf('Programa finalizado.\n');
    return;
elseif isempty(strtrim(entrada_horas))
    fprintf('No se ingresaron horas. Intente de nuevo.\n');
    return;
end
horas_uso = str2num(entrada_horas); %#ok<ST2NM>

if length(aparatos_idx) ~= length(horas_uso)
    error('La cantidad de aparatos y de horas no coincide.');
end

% Selección de distribuidora
fprintf('\nSeleccione su distribuidora:\n1. EEGSA\n2. Deocsa\n3. Deorsa\n');
dist_sel = input('Opcion (1-3): ');
switch dist_sel
    case 1
        distribuidora = 'EEGSA';
    case 2
        distribuidora = 'Deocsa';
    case 3
        distribuidora = 'Deorsa';
    otherwise
        error('Distribuidora no valida.');
end

% Selección de tarifa
fprintf('\nSeleccione tipo de tarifa:\n1. Social\n2. No Social\n');
tipo_tarifa = input('Opcion (1-2): ');
if tipo_tarifa ~= 1 && tipo_tarifa ~= 2
    error('Opcion de tarifa no valida.');
end

% Tarifas (vigente mayo-julio 2025)
tarifas = struct(...
    'EEGSA', [1.42, 1.51], ...
    'Deocsa', [2.09, 2.21], ...
    'Deorsa', [2.02, 2.11]);

% Cálculo de consumo
potencias_seleccionadas = potencias(aparatos_idx);
consumos = potencias_seleccionadas .* horas_uso;
consumo_total = sum(consumos); % en kWh

% Cálculo de tarifa
tarifa_kwh = tarifas.(distribuidora)(tipo_tarifa);
costo_total = consumo_total * tarifa_kwh;

% Mostrar resultados
fprintf('\n=== RESULTADOS ===\n');
fprintf('Distribuidora: %s\n', distribuidora);
fprintf('Tarifa %s: Q%.2f por kWh\n', ternary(tipo_tarifa==1, 'Social', 'No Social'), tarifa_kwh);
fprintf('Consumo total mensual: %.2f kWh\n', consumo_total);
fprintf('Costo mensual estimado: Q%.2f\n', costo_total);

% Gráfica por aparato
figure;
bar(consumos);
xticks(1:length(aparatos_idx));
xticklabels(aparatos(aparatos_idx));
xtickangle(45);
ylabel('Consumo (kWh)');
title('Consumo mensual por aparato');
grid on;

% Estimación para los siguientes 12 meses (crecimiento del 5% mensual)
meses = 1:12;
consumo_estimado = consumo_total * (1.05) .^ (meses - 1);

figure;
plot(meses, consumo_estimado, '-o', 'LineWidth', 2);
xlabel('Mes');
ylabel('Consumo estimado (kWh)');
title('Proyeccion de consumo los proximos 12 meses');
grid on;

fprintf('\nProyeccion de consumo para los proximos 12 meses (kWh):\n');
disp(consumo_estimado);

fprintf('\nCosto mensual estimado actual: Q%.2f\n', costo_total);
fprintf('Costo total estimado por 12 meses: Q%.2f\n', sum(consumo_estimado)*tarifa_kwh);

% === Interpolacion de Lagrange ===
x = meses;
y = consumo_estimado;
mes_interp = input('\nIngrese el mes decimal que desea estimar (ej. 3.5): ');
consumo_interp = lagrange_interp(x, y, mes_interp);
fprintf('Consumo estimado para el mes %.2f: %.2f kWh\n', mes_interp, consumo_interp);

% Función ternaria auxiliar
function out = ternary(cond, valTrue, valFalse)
    if cond
        out = valTrue;
    else
        out = valFalse;
    end
end

% Función de interpolación de Lagrange
function L = lagrange_interp(x, y, x0)
    n = length(x);
    L = 0;
    for i = 1:n
        term = y(i);
        for j = 1:n
            if i ~= j
                term = term * (x0 - x(j)) / (x(i) - x(j));
            end
        end
        L = L + term;
    end
end
