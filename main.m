clear; clc; close all;

%% **Configuración de parámetros**
ImDB_path = 'C:/Users/guill/OneDrive/Documents/Prog2PIV/UKentuckyDatabase/';
ImDB_name_prefix = 'ukbench';
num_images = 10; 
hist_bins = 256;        % Número de bins en el histograma
num_candidatos = 10;    % Número de imágenes a recuperar por query
input_file = 'input.txt';

% Métodos de similitud disponibles en algo2
metodos_similitud = {'chi2', 'jensen-shannon', 'bhattacharyya',  'hellinger', 'kl-divergence'};
%generate_input_file("ukbench", 2000, input_file);

% Leer input file
queries = textread(input_file,'%s');
num_queries = length(queries);


%% --- Indexación de la base de datos (algo1) ---
disp('Indexando la base de datos...');
if ~isfile('H.mat')
    tic;
    H = algo1_indexar(ImDB_path, ImDB_name_prefix, 2000, hist_bins);
    indexing_time = toc;
    save('H.mat','H');
    disp(['Indexación completada en ', num2str(indexing_time), ' seg. Guardada en H.mat.']);
else
    load('H.mat','H');
    indexing_time = 0;
    
    disp('Cargando indexación precomputada desde H.mat.');
end
unique_histograms = unique(H, 'rows');
fprintf('Number of unique histograms: %d out of %d images\n', size(unique_histograms,1), size(H,1));
%% --- Búsqueda y evaluación para todos los métodos ---
disp('Ejecutando búsqueda para cada método...');
figure('Name','Comparación de métodos','NumberTitle','off');
hold on; grid on;
colors = lines(length(metodos_similitud));  % Paleta de colores
legend_entries = {};

for i = 1:length(metodos_similitud)
    metodo = metodos_similitud{i};
    output_file_metodo = ['output_', metodo, '.txt'];

    % --- Búsqueda (algo3) ---
    tic;
    algo3_busqueda(H, ImDB_path, ImDB_name_prefix, input_file, ...
                   output_file_metodo, hist_bins, metodo, num_candidatos);
    retrieval_time(i) = toc;

    % --- Evaluación con Precision & Recall ---
 [avg_precision, avg_recall, avg_f1] = ...
        precision_recall(output_file_metodo,metodo ,hist_bins, num_images, num_queries, num_candidatos);

    mean_f1 = max(avg_f1); %agafem el maxim per saber quin es el F1
    if isnan(mean_f1), mean_f1 = 0; end

    % Curva de Precision vs Recall
    plot(avg_recall, avg_precision, '-o', 'Color', colors(i,:), 'LineWidth', 2, ...
        'DisplayName',[metodo,' (F=', num2str(mean_f1,'%.3f'),')']);

    % Guardar leyenda
    legend_entries{end+1} = [metodo,' (F=', num2str(mean_f1,'%.3f'),')'];

    disp(['--- RESULTADOS PARA MÉTODO: ', metodo,' ---']);
    fprintf('Tiempo de búsqueda: %.2f seg\n', retrieval_time(i));
end
plot([0,1],[1,1],'--k','LineWidth',2,'DisplayName','F=1 ideal');
% Añadir un pequeño tramo extra
%plot([1,1.05],[1,1],'--k','LineWidth',2);
plot([1,1],[1,0],'--k','LineWidth',2);
% Añadir una punta en x=1.05
plot(1.05,1,'>k','MarkerSize',6,'MarkerFaceColor','k','DisplayName','');

legend_entries{end+1} = 'F=1 ideal';

xlabel('Recall');
ylabel('Precision');
title('Comparación de métodos (Precision vs Recall)');
legend(legend_entries, 'Location','SouthWest');
axis([0 1.1 0 1.05]); % Extender eje X hasta 1.1 para mostrar la \"punta\"
hold off;
% **Mostrar resumen**
disp('--- RESUMEN DE RESULTADOS ---');
fprintf('Número de imágenes indexadas: %d\n', num_images);
fprintf('Tiempo de indexación: %.2f segundos\n', indexing_time);
%fprintf('Volumen de descriptores: %.2f MB\n', descriptor_volume_MB);

for i = 1:length(metodos_similitud)
    fprintf('Método: %s | Tiempo total de búsqueda: %.2f seg | Tiempo promedio por query: %.4f seg  \n' ,metodos_similitud{i}, retrieval_time(i), retrieval_time(i) / numel(textread(input_file, '%s')));
end

disp('Comparación de métodos finalizada.');
